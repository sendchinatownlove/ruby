# frozen_string_literal: true

include Pagy::Backend

class GiftCardsController < ApplicationController
  before_action :set_gift_card, only: %i[show update]
  after_action { pagy_headers_merge(@pagy) if @pagy }

  # GET /gift_cards
  def index
    user = get_session_user
    return head :unauthorized unless user

    contact = Contact.find_by(email: user[:email])
    return head :forbidden unless contact

    # NOTE This query  does not fetch seller name
    gift_cards = GiftCardDetail
    .left_joins(
      :gift_card_amount,
      item: [
        seller: :locations,
        campaign: [:distributor],
      ])
    .left_joins(
      :gift_card_amount,
      item: [
        seller: :locations,
        campaign: [campaigns_sellers_distributors: :distributor],
      ])
    .where({
      distributors: {
        contact_id: contact[:id]
      }})
    .where("expiration > ?", DateTime.current.to_date)
      .select(
        'gift_card_details.expiration',
        'gift_card_amounts.value',
        'gift_card_details.seller_gift_card_id',
        'sellers.id',
        'distributors.id as distributor_id',
        'locations.address1',
        'locations.address2',
        'locations.city',
        'locations.state',
        'locations.zip_code')


=begin
    Seller Names is done in a separate query to
    fetch both zh-CN and EN seller name at the same time.
=end

    ar_sellers = gift_cards.pluck('sellers.id').uniq

    # Select all localized seller names in a separate query
    query2 = Seller
        .select('sellers.id',"json_agg('[' || seller_translations.locale  || ',' || seller_translations.name || ']')")
        .joins("INNER JOIN seller_translations ON sellers.id = seller_translations.seller_id ")
        .where(:id => ar_sellers)
        .group('sellers.id')
        .to_sql

    seller_names = Seller.connection.select_all(query2)


    mapped_localized_names = seller_names.each_with_object({}) do |row,hash|
      arr = JSON.parse(row['json_agg'])
      reduced = arr.each_with_object({}) do |val, reducedLocale|
        locale,name = val[1,val.length - 2].split(',')
        reducedLocale[locale.to_sym] = name
      end

      hash[row['id']] = {id: row['id'], **reduced}
    end

    distributor = Distributor.find(gift_cards.first[:distributor_id])

    @pagy, @records = pagy(gift_cards)
    json_response({:gift_cards => @records, :seller_names => mapped_localized_names, :distributor => distributor})
    # json_response(@records)
  end

  def get_metadata
    user = get_session_user
    return head :unauthorized unless user

    contact = Contact.find_by(email: user[:email])
    return head :forbidden unless contact

    gift_cards = GiftCardDetail
    .left_joins(
      :gift_card_amount,
      item: [
        seller: :locations,
        campaign: [:distributor],
      ])
    .left_joins(
      :gift_card_amount,
      item: [
        seller: :locations,
        campaign: [campaigns_sellers_distributors: :distributor],
      ])
    .where({
      distributors: {
        contact_id: contact[:id]
      }})
    .where("expiration > ?", DateTime.current.to_date)
    .select(
      'gift_card_details.expiration',
      'gift_card_amounts.value',
      'gift_card_details.updated_at'
    )
    .order(updated_at: :desc)
    count = gift_cards.length
    sum = gift_cards.sum("gift_card_amounts.value")
    time = Time.zone.parse(gift_cards[0][:updated_at].to_s)
    json_response({ count: count, sum: sum, updated_at: time })
  end

  # GET /gift_cards/:id
  def show
    json_response(item_gift_card_detail_json)
  end

  # PUT /gift_cards/:id
  def update
    validate_update_params
    GiftCardAmount.create!(
      value: gift_card_params[:amount],
      gift_card_detail: @gift_card_detail
    )

    json_response(item_gift_card_detail_json)
  end

  private

  def get_session_user
    puts session[:user].inspect
    session[:user]
  end

  def gift_card_params
    params.require(:amount)
    params.permit(:amount, :id)
  end

  def set_gift_card
    params.require(:id) # gift_card_id
    @gift_card_detail = GiftCardDetail.find_by!(
      gift_card_id: params[:id]
    )
  end

  def validate_update_params
    current_amount = @gift_card_detail.amount
    unless gift_card_params[:amount] < current_amount
      raise InvalidParameterError,
            "New amount must be less than current amount of: #{current_amount}"
    end
  end

  def item_gift_card_detail_json
    item = Item.find_by(id: @gift_card_detail.item_id)
    json = item.as_json
    json['gift_card_detail'] = @gift_card_detail.as_json
    json['gift_card_detail']['amount'] = @gift_card_detail.amount
    # Replace the internal Seller.id with the external seller_id
    json['seller_id'] = item.seller.seller_id
    json
  end
end
