# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Campaigns API', type: :request do
  before do
    @seller = create :seller_with_location
    @project = create :project
    @location = create(:location, seller_id: @seller.id)
  end

  let!(:distributor) { create :distributor }
  let!(:campaign) do
    create(
      :campaign,
      active: true,
      seller_id: @seller.id,
      project_id: nil,
      location_id: @location.id
    )
  end
  let!(:inactive_campaign) do
    create_list(
      :campaign,
      2,
      seller_id: @seller.id,
      project_id: nil,
      location_id: @location.id,
      active: false
    )
  end

  context 'GET /campaigns' do
    context 'Fetching all active campaigns' do
      subject { get '/campaigns' }

      it 'Returns campaigns' do
        subject
        expect(json).not_to be_empty
        expect(json.size).to eq(1)
      end

      it 'Returns 200' do
        subject
        expect(response).to have_http_status(200)
      end
    end

    context 'with some basic pagination' do
      subject { get '/campaigns/?inactive=true' }
      it 'returns 2 records with default pagination' do
        subject
        expect(json).not_to be_empty
        expect(json.size).to eq 2
      end

      it 'returns 1 record and the first page when querying for one page' do
        get '/campaigns/?inactive=true&items=1'
        expect(json).not_to be_empty
        expect(json.size).to eq 1

        expect(response.headers['Current-Page'].to_i).to eq 1
        expect(response.headers['Total-Pages'].to_i).to eq 2
        expect(response.headers['Total-Count'].to_i).to eq 2
      end

      it 'returns 1 record and two pages when querying for page 2' do
        get '/campaigns/?inactive=true&page=2&items=1'
        expect(json).not_to be_empty
        expect(json.size).to eq 1

        expect(response.headers['Current-Page'].to_i).to eq 2
        expect(response.headers['Total-Pages'].to_i).to eq 2
        expect(response.headers['Total-Count'].to_i).to eq 2
      end
    end
  end

  context 'GET /campaigns/:id' do
    subject { get "/campaigns/#{campaign_id}" }

    context 'With a missing id' do
      let(:campaign_id) { 'missing_id' }

      it 'Returns 404' do
        subject
        expect(response).to have_http_status(404)
      end
    end

    context 'With valid id' do
      let(:campaign_id) { campaign.id }

      it 'Returns the campaign' do
        subject
        expect(json).not_to be_empty
        expect(json['id']).to eq(campaign.id)

        # Has original fields
        expect(json['amount_raised']).to eq 0
        expect(json['last_contribution']).to eq nil
        expect(json['seller_id']).to eq @seller.id

        # Has the directly related seller/dist created in the factory
        expect(json['seller_distributor_pairs']).not_to be_nil
        expect(json['seller_distributor_pairs'].size).to eq 1
      end

      it 'Returns 200' do
        subject
        expect(response).to have_http_status(200)
      end
    end

    context 'with project with multiple sellers and distributors' do
      let!(:campaign) do
        create(
          :campaign,
          :with_sellers_distributors,
          :with_project,
          active: true,
          location_id: @location.id,
          seller: nil,
          distributor: nil
        )
      end

      let(:campaign_id) { campaign.id }

      it 'Returns the campaign with the correct number of seller_distributor_pairs' do
        subject
        expect(json).not_to be_empty
        expect(json['id']).to eq(campaign.id)

        expect(json['seller_distributor_pairs']).not_to be_nil
        expect(json['seller_distributor_pairs'].size).to eq 2
      end
    end
  end

  context 'POST /campaigns' do
    context 'with invalid parameters' do
      context 'With no parameters' do
        before { post '/campaigns', params: {} }

        it 'Returns status code 422' do
          expect(response).to have_http_status(422)
        end
      end

      context 'with all parameters' do
        before do
          post(
            '/campaigns',
            params: {
              end_date: Date.tomorrow,
              location_id: location_id,
              seller_id: seller_id,
              project_id: project_id,
              distributor_id: distributor_id
            },
            as: :json
          )
        end

        context 'all missing ids' do
          let(:location_id) { 'missing-location-id' }
          let(:seller_id) { 'missing-seller-id' }
          let(:project_id) { 'missing-project-id' }
          let(:distributor_id) { 'missing-distributor-id' }

          it 'Returns status code 404' do
            expect(response).to have_http_status(404)
          end
        end

        context 'missing location and seller id' do
          let(:location_id) { 'missing-location-id' }
          let(:seller_id) { 'missing-seller-id' }
          let(:project_id) { 'missing-project-id' }
          let(:distributor_id) { distributor.id }

          it 'returns status code 404' do
            expect(response).to have_http_status(404)
          end
        end

        context 'missing location and distributor ids' do
          let(:location_id) { 'missing-location-id' }
          let(:seller_id) { @seller.seller_id }
          let(:project_id) { 'missing-project-id' }
          let(:distributor_id) { 'missing-distributor-id' }

          it 'returns status code 404' do
            expect(response).to have_http_status(404)
          end
        end

        context 'missing location id' do
          let(:location_id) { 'missing-location-id' }
          let(:seller_id) { @seller.seller_id }
          let(:project_id) { 'missing-project-id' }
          let(:distributor_id) { distributor.id }

          it 'returns status code 404' do
            expect(response).to have_http_status(404)
          end
        end

        context 'missing seller and distributor ids' do
          let(:location_id) { @location.id }
          let(:seller_id) { 'missing-seller-id' }
          let(:project_id) { 'missing-project-id' }
          let(:distributor_id) { 'missing-distributor-id' }

          it 'returns status code 404' do
            expect(response).to have_http_status(404)
          end
        end

        context 'missing both seller and project ids' do
          let(:location_id) { @location.id }
          let(:seller_id) { 'missing-seller-id' }
          let(:project_id) { 'missing-project-id' }
          let(:distributor_id) { distributor.id }

          it 'returns status code 422' do
            expect(response).to have_http_status(422)
          end
        end

        context 'with both seller and project ids' do
          let(:location_id) { @location.id }
          let(:seller_id) { @seller.seller_id }
          let(:project_id) { @project.id }
          let(:distributor_id) { distributor.id }

          it 'returns status code 422' do
            expect(response).to have_http_status(422)
          end
        end

        context 'with valid parameters and seller_id' do
          let(:location_id) { @location.id }
          let(:seller_id) { @seller.seller_id }
          let(:project_id) { nil }
          let(:distributor_id) { distributor.id }

          it 'returns status code 201' do
            expect(response).to have_http_status(201)
          end

          it 'creates a Campaign with default values and matching attributes' do
            response_body = JSON.parse(response.body)
            expect(response_body).not_to be_nil
            expect(json['amount_raised']).to eq 0
            expect(json['last_contribution']).to eq nil

            campaign = Campaign.find(response_body['id'])
            expect(campaign).not_to be_nil
            expect(campaign.location).to eq @location
            expect(campaign.seller).to eq @seller
            expect(campaign.target_amount).to eq 100_000
            expect(campaign.amount_raised).to eq 0
            expect(campaign.price_per_meal).to eq 500
            expect(campaign.display_name).to eq @seller.name + ' x ' + distributor.name

            expect(campaign.active).to be false
            expect(campaign.valid).to be true
          end
        end

        context 'with valid parameters and project_id' do
          let(:location_id) { @location.id }
          let(:seller_id) { nil }
          let(:project_id) { @project.id }
          let(:distributor_id) { distributor.id }

          it 'returns status code 201' do
            expect(response).to have_http_status(201)
          end

          it 'creates a Campaign with default values and matching attributes' do
            response_body = JSON.parse(response.body)
            expect(response_body).not_to be_nil
            expect(json['amount_raised']).to eq 0
            expect(json['last_contribution']).to eq nil

            campaign = Campaign.find(response_body['id'])
            expect(campaign).not_to be_nil
            expect(campaign.location).to eq @location
            expect(campaign.project).to eq @project
            expect(campaign.target_amount).to eq 100_000
            expect(campaign.amount_raised).to eq 0
            expect(campaign.price_per_meal).to eq 500
            expect(campaign.display_name).to eq @project.name

            expect(campaign.active).to be false
            expect(campaign.valid).to be true
          end
        end
      end
    end
  end

  context 'PUT /campaigns' do
    before do
      put(
        "/campaigns/#{campaign_id}",
        params: body,
        as: :json
      )
    end

    context 'With a missing id' do
      let(:campaign_id) { 'missing_id' }

      it 'Returns 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'With a valid id' do
      let(:campaign_id) { campaign.id }
      let(:body) do
        {
          description: 'Campaign description',
          gallery_image_urls: ['https://reddit.com/123.png']
        }
      end

      it 'Returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the campaign with updated fields' do
        expect(json['description']).to eq(body[:description])
        expect(json['gallery_image_urls']).to eq(body[:gallery_image_urls])

        # Has original fields
        expect(json['amount_raised']).to eq 0
        expect(json['last_contribution']).to eq nil
        expect(json['seller_id']).to eq @seller.id
      end

      it 'Updates the fields in the record' do
        updated_campaign = Campaign.find(campaign.id)
        expect(updated_campaign.description).to eq(body[:description])
        expect(updated_campaign.gallery_image_urls).to eq(body[:gallery_image_urls])
      end
    end
  end

  context 'POST /campaigns/:id/seller_distributor' do
    let!(:distributor) { create :distributor }

    subject do
      post(
        "/campaigns/#{campaign.id}/seller_distributor",
        params: {
          distributor_id: distributor.id,
          seller_id: seller.id
        },
        as: :json
      )
    end

    context 'Without a seller location' do
      let!(:seller) { create :seller }
      let!(:campaign) do
        create(
          :campaign,
          active: true,
          seller_id: seller.id,
          project_id: nil,
          location_id: @location.id
        )
      end

      it 'Creates seller and distributor pair' do
        subject
        expect(json['seller_distributor_pairs']).to eq([
                                                         # Directly related seller/dist
                                                         {
                                                           'distributor_id' => campaign.distributor.id,
                                                           'distributor_image_url' => campaign.distributor.image_url,
                                                           'distributor_website_url' => campaign.distributor.website_url,
                                                           'distributor_name' => campaign.distributor.name,
                                                           'seller_id' => campaign.seller.seller_id,
                                                           'seller_image_url' => campaign.seller.hero_image_url,
                                                           'seller_name' => campaign.seller.name,
                                                           'seller_non_profit_location_id' => campaign.seller.non_profit_location_id,
                                                           'seller_city' => nil
                                                         },
                                                         # Seller/dist pair
                                                         {
                                                           'distributor_id' => distributor.id,
                                                           'distributor_image_url' => distributor.image_url,
                                                           'distributor_website_url' => distributor.website_url,
                                                           'distributor_name' => distributor.name,
                                                           'seller_id' => seller.seller_id,
                                                           'seller_image_url' => seller.hero_image_url,
                                                           'seller_name' => seller.name,
                                                           'seller_non_profit_location_id' => seller.non_profit_location_id,
                                                           'seller_city' => nil
                                                         }
                                                       ])
      end

      it 'Returns status code 200' do
        subject
        expect(response).to have_http_status(200)
      end
    end

    context 'With seller location' do
      let!(:seller) { create :seller_with_location }
      let!(:campaign) do
        create(
          :campaign,
          active: true,
          seller_id: seller.id,
          project_id: nil,
          location_id: @location.id
        )
      end

      it 'Creates seller and distributor pair' do
        subject
        expect(json['seller_distributor_pairs']).to eq([
                                                         # Directly related seller/dist
                                                         {
                                                           'distributor_id' => campaign.distributor.id,
                                                           'distributor_image_url' => campaign.distributor.image_url,
                                                           'distributor_website_url' => campaign.distributor.website_url,
                                                           'distributor_name' => campaign.distributor.name,
                                                           'seller_id' => campaign.seller.seller_id,
                                                           'seller_image_url' => campaign.seller.hero_image_url,
                                                           'seller_name' => campaign.seller.name,
                                                           'seller_non_profit_location_id' => campaign.seller.non_profit_location_id,
                                                           'seller_city' => campaign.seller.locations.first.city
                                                         },
                                                         # Seller/dist pair
                                                         {
                                                           'distributor_id' => distributor.id,
                                                           'distributor_image_url' => distributor.image_url,
                                                           'distributor_website_url' => distributor.website_url,
                                                           'distributor_name' => distributor.name,
                                                           'seller_id' => seller.seller_id,
                                                           'seller_image_url' => seller.hero_image_url,
                                                           'seller_name' => seller.name,
                                                           'seller_non_profit_location_id' => seller.non_profit_location_id,
                                                           'seller_city' => seller.locations.first.city
                                                         }
                                                       ])
      end

      it 'Returns status code 200' do
        subject
        expect(response).to have_http_status(200)
      end
    end
  end

  context 'POST /campaigns/:id/gift_card' do
    let!(:project) { create :project }

    subject do
      post(
        "/campaigns/#{campaign.id}/gift_card",
        params: {
          gift_cards: [{
            distributor_id: campaign.seller_distributor_pairs[0]['distributor_id'],
            seller_id: campaign.seller_distributor_pairs[0]['seller_id'],
            gift_card_amount: 200
          }]
        },
        as: :json
      )
    end

    context 'Failure states' do
      let!(:campaign) do
        create(
          :campaign,
          :with_sellers_distributors,
          project_id: project.id,
          seller_id: nil
        )
      end

      it 'Fails if no gift cards are included' do
        post(
          "/campaigns/#{campaign.id}/gift_card",
          params: {},
          as: :json
        )
        expect(json).to eq({ 'message' => 'param is missing or the value is empty: gift_cards' })
      end

      it 'Raises invalid parameter error if there are not enough unallocated funds' do
        subject
        expect(json).to eq({ 'message' => 'Request amount exceeds unallocated amount in campaign. Unallocated amount: 0' })
      end
    end

    context 'Success state' do
      let(:payment_intent) { create :payment_intent, :with_campaign, :with_line_items, successful: true }
      let(:campaign) do
        campaign = Campaign.find(payment_intent.campaign_id)
        campaign.update!('project_id': project.id, 'seller_id': nil)
        FactoryBot.create :campaigns_sellers_distributor, campaign_id: campaign.id
        FactoryBot.create :campaigns_sellers_distributor, campaign_id: campaign.id
        campaign
      end

      it 'Creates gift card successfully' do
        subject
        expect(json).to eq({ 'unallocated_amount' => 400 })
      end
    end
  end
end
