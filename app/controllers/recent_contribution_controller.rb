# frozen_string_literal: true

# Controller to fetch most recent contribution
class RecentContributionController < ApplicationController
  before_action :set_seller

  def index
    json_response(get_recent_contribution)
  end

  private

  def get_recent_contribution
    item = @seller.items.order(:created_at).last
    item.item_type == 'donation' ? item.donation_detail : item.gift_card_detail
  end

  def set_seller
    @seller = Seller.find_by!(seller_id: params[:seller_id])
  end
end
