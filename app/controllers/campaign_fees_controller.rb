class CampaignFeesController < ApplicationController
    before_action :set_campaign
    before_action :set_campaign_fee, only: %i[show update]

    # GET /campaigns/:campaign_id/fees
    def index
        json_response(@@campaign.fees)
    end

    # GET /campaigns/:campaign_id/fees/:id
    def show
        json_response(@fee)
    end

    # POST /campaigns/:campaign_id/fees
    def create
        json_response(@campaign.fees.create!(create_fee_params), :created)
    end

    # PUT /campaigns/:campaign_id/fees/:id
    def update
        @fee.update(update_fee_params)
        json_response(@fee)
    end

    private

    def create_fee_params
        params.permit(
            :flat_cost,
            :multiplier,
          )
        update_fee_params
    end

    def update_fee_params
        params.permit(:active, :description)
    end

    def set_campaign
        @campaign = Campaign.find_by!(campaign_id: params[:campaign_id])
    end

    def set_campaign_fee
        @campaign = @campaign.fees.find_by!(id: params[:id]) if @campaign
    end
end
