class OpenHourController < ApplicationController
    before_action :set_seller

    def index
        json_response(@seller.open_hour)
      end
    
      def create
        json_response(@seller.open_hour.create!(create_open_hour_params), :created)
      end
    
      def update
        @open_hour.update(update_open_hour_params)
        @open_hour.save
        json_response(@open_hour)
      end
    
      def destroy
        @open_hour.destroy
    
        head :no_content
      end

end
