
# class Config
#     class << self ; attr_accessor :donation_query ; end
#     self.donation_query = ''
#   end
  
#   begin
#     require_relative 'stats_helpers/donations.rb'
#   rescue LoadError
#   end

class StatsController < ApplicationController
    def donation_totals
        require_relative 'stats_helpers/donations.rb'
        # total_donations = "./stats_helpers/donations.rb"
        # require_relative total_donations 
        # query ||= ''
        # puts query
        # total_donations = ""
        @result = ActiveRecord::Base.connection.execute($donation_query)
        return @result
      end

    def gam_count
        @GiftCardDetail = GiftCardDetail.where("single_use": true)
        # Magic constant to track orders not in GAM 
        # TODO(stanzheng) pull magic constant from GAM spreadsheet
        return @GiftCardDetail.length + 5140
    end 
    def index
        show(donation_totals(), sellers_total(), transaction_totals(), gam_count()) 
    end

    def sellers_total
        @sellers = Seller.all
        return @sellers.length()
    end

    def transaction_totals
        @Item = Item.all
        return @Item.length()
    end
    

    def show(donation_totals, sellers_total, transaction_totals, gam_count)
        # puts (donation_totals)
        # pry
        require_relative 'stats_helpers/stats_html.rb'
        box1 =  "$%s" % ActionController::Base.helpers.number_with_precision( donation_totals.getvalue(0,5), :precision => 0, :delimiter => ',')  #"$10,000"
        box2 =  ActionController::Base.helpers.number_with_precision( gam_count, :precision => 0, :delimiter => ',') 
        box3 = "36,573" 
        box4 = ActionController::Base.helpers.number_with_precision( transaction_totals, :precision => 0, :delimiter => ',') 
        box5 = sellers_total
        box6 = "$47,689"
        render html: stats_html(box1, box2, box3, box4, box5, box6).html_safe# render :text => @model_object.html_content
    end
    
end
