
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChargesController, type: :controller do
  include MockApiResponseHelper

  describe 'POST create' do
    let!(:mock_response) { MockApiResponseHelper::MockSquareApiResponse.new }
    let!(:seller) { create :seller, :with_campaign, square_location_id: '1234', seller_id: 42, cost_per_meal: 50 }
    let!(:project) { create :project }
    let!(:seller_non_prof) { create :seller, :with_campaign, non_profit_location_id: '4321', seller_id: 43 }

    context 'when seller has a non_profit_location_id' do
      it 'should create a payment_intent using the non_profit_location_id' do
        allow(SquareManager::PaymentCreator)
          .to receive(:call)
          .with(create_payment_params(seller: seller_non_prof, seller_has_nonprofit: true))
          .and_return(mock_response)

        response = post :create, params: create_charge_params(seller: seller_non_prof, is_square: true), as: :json
        expect(response.status).to eq 200
        expect(PaymentIntent.find_by(square_location_id: seller_non_prof.non_profit_location_id)).not_to eq nil
      end
    end

    context 'when seller has a blank non_profit_location_id' do
      it 'should create a payment_intent using the square_location_id' do
        allow(SquareManager::PaymentCreator)
          .to receive(:call)
          .with(create_payment_params(seller: seller, seller_has_nonprofit: false))
          .and_return(mock_response)

        response = post :create, params: create_charge_params(seller: seller, is_square: true), as: :json
        expect(response.status).to eq 200
        expect(PaymentIntent.find_by(square_location_id: seller.square_location_id)).not_to eq nil
      end
    end
  end

  describe 'POST create with nonprofit fee' do      
    let!(:mock_response) { MockApiResponseHelper::MockSquareApiResponse.new }
    let!(:seller_id) { 21 }
    let!(:fee_id) { 3 }
    let!(:nonprofit_id) { 4 }
    let!(:campaign_id) { 12 }
    let!(:square_location_id) { 'L8' }
    let!(:project_id) { 19 }

    context 'when campaign has a nonprofit with a fee_id' do
      it 'should create a payment_intent that has the campaign_id and fee_id' do
        seller = create(
          :seller,
          id: seller_id,
          square_location_id: square_location_id
        )
        fee = create(
          :fee, 
          id: fee_id,
          active: true, 
          multiplier: 0.1
        )
        nonprofit = create(
          :nonprofit,
          id: nonprofit_id,
          fee_id: fee.id
        )
        campaign = create(
          :campaign,
          id: campaign_id,
          active: true,
          seller_id: seller_id,
          nonprofit_id: nonprofit.id
        )

        payment_params = create_payment_params(seller: seller, campaign: campaign)
        
        allow(SquareManager::PaymentCreator)
          .to receive(:call)
          .with(payment_params)
          .and_return(mock_response)

        cparams = create_charge_params(
                    seller: seller, 
                    is_square: true, 
                    campaign: campaign, 
                    is_distribution: false
                  )
        response = post :create, params: cparams, as: :json
        payment_intent = PaymentIntent.find_by(campaign_id: campaign_id, fee_id: fee_id)
        expect(payment_intent).to_not eq nil
        expect(response.status).to eq 200
      end
    end

    context 'when campaign has a project_id and a nonprofit with a fee_id' do
      it 'should create a payment_intent that has the project_id, campaign_id and fee_id' do
        project = create(:project, id: project_id, square_location_id: square_location_id)
        fee = create(
          :fee, 
          id: fee_id,
          active: true, 
          multiplier: 0.1
        )
        nonprofit = create(
          :nonprofit,
          id: nonprofit_id,
          fee_id: fee.id
        )
        campaign = create(
          :campaign,
          id: campaign_id,
          active: true,
          seller_id: nil,
          project_id: project.id,
          nonprofit_id: nonprofit.id
        )

        payment_params = create_payment_params(campaign: campaign, project: project)

        allow(SquareManager::PaymentCreator)
          .to receive(:call)
          .with(payment_params)
          .and_return(mock_response)

        cparams = create_charge_params(is_square: true, campaign: campaign, is_distribution: false)
        response = post :create, params: cparams, as: :json
        payment_intent = PaymentIntent.find_by(
                          campaign_id: campaign_id, 
                          project_id: project_id, 
                          fee_id: fee_id
                         ) 
        expect(payment_intent).to_not eq nil
        expect(response.status).to eq 200
      end
    end
  end

  ###############
  ### Helpers ###
  ###############

  def create_charge_params(seller: nil, is_square: false, campaign: nil, is_distribution: true)
    seller_id = seller.seller_id if seller
    campaign_id = campaign.id if campaign
    project_id = campaign.project_id if campaign
    line_items = create_line_items(project_id: project_id)
    params = {
      seller_id: seller_id,
      line_items: line_items,
      email: 'cthulhu@rlyeh.com',
      is_square: is_square,
      name: 'Cthulhu',
      idempotency_key: '42',
      is_subscribed: true,
      is_distribution: is_distribution,
      campaign_id: campaign_id,
      project_id: project_id
    }
    params.merge! nonce: 'cnon:card-nonce-ok' if is_square
    params
  end

  def default_line_items 
    { 
      'amount' => 50, 
      'currency' => 'usd', 
      'quantity' => 1, 
      'item_type' => 'donation' 
    }
  end

  # TODO (billy-yuan): Update create_line_items so that transaction fees can be
  # included as a separate line_items group
  def create_line_items(extra_line_items = {})
    line_items = default_line_items
    extra_line_items.each do |extra_line_item, value|
      if value
        line_items[extra_line_item] = value
      end
    end
    [line_items]
  end

  def create_payment_params(
    seller: nil, 
    seller_has_nonprofit: false, 
    campaign: nil, 
    project: nil,
    line_items: nil
  )
    campaign_id = campaign.id if campaign
    project_id = campaign.project_id if campaign
    location_id = get_location_id(
                    project: project, 
                    seller: seller, 
                    seller_has_nonprofit: seller_has_nonprofit
                  )
    cparams = create_charge_params(
                is_square: true, 
                campaign: campaign
              )
    line_items = create_line_items(project_id: project_id)

    {
      nonce: cparams[:nonce],
      amount: line_items.first['amount'],
      email: cparams[:email],
      location_id: location_id
    }
  end

  def get_location_id(project: nil, seller: nil, seller_has_nonprofit: false)
    if project
      project.square_location_id
    elsif seller_has_nonprofit
      seller.non_profit_location_id
    else
      seller.square_location_id
    end
  end
end
