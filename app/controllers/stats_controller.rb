# require_relative 'stats_helpers/donations'
# require_relative 'stats_helpers/progressbar'
# require_relative 'stats_helpers/spreadsheet'

class StatsController < ApplicationController
  def donation_totals
    query = ActiveRecord::Base.connection.execute($donation_query)
    query.getvalue(0, 5)
  end

  def gam_count
    @GiftCardDetail = GiftCardDetail.where(single_use: true)
    # Magic constant to track orders not in GAM
    # TODO(stanzheng) pull magic constant from GAM spreadsheet
    @GiftCardDetail.length
  end

  def index
    show(donation_totals, sellers_total, transaction_totals, gam_count)
  end

  def sellers_total
    Seller.all.count
  end

  def transaction_totals
    Item.all.count
  end

  def show(donation_totals, sellers_total, transaction_totals, gam_count)
    outside_db_gam_contributions = 0
    outside_db_fundaising_contributions = 0
    outside_db_meals = 0
    outside_db_fundaising_foodcrawl_raised = 0
    outside_db_luc_raised = 0

    if ENV['GOOGLEDRIVE_SECRET']
      data = Rails.cache.read('spreadsheet_data')
      if data.nil?
        data = LiveStats.pull
        Rails.cache.write('spreadsheet_data', data, expires_in: 60.minutes)
      end
      data = LiveStats.pull
      outside_db_fundaising_contributions += data['outside_db_fundaising_contributions'].to_i
      outside_db_gam_contributions += data['outside_db_gam_contributions'].to_i
      outside_db_meals +=  data['outside_db_meals'].to_i
      outside_db_fundaising_foodcrawl_raised += data['outside_db_fundaising_foodcrawl_raised'].to_i
      outside_db_luc_raised +=  data['outside_db_luc_raised'].to_i
    end
    # box1
    donation_totals += outside_db_fundaising_contributions+ outside_db_gam_contributions + outside_db_fundaising_foodcrawl_raised + outside_db_luc_raised
    donation_totals = '$%s' % ActionController::Base.helpers.number_with_precision(donation_totals, precision: 0, delimiter: ',') # "$10,000"

    # box2
    gam_count += outside_db_meals
    gam_count = ActionController::Base.helpers.number_with_precision(gam_count, precision: 0,
                                                                                          delimiter: ',')
    # box3
    foodcrawl_raised    =  '$' + ActionController::Base.helpers.number_with_precision(outside_db_fundaising_foodcrawl_raised, precision: 0,
      delimiter: ',')

    # box4
    total_vouchers_giftcards = ActionController::Base.helpers.number_with_precision(transaction_totals,
                                                                                    precision: 0, delimiter: ',')
    # box 6
    luc_raised = '$' + ActionController::Base.helpers.number_with_precision(outside_db_luc_raised,
      precision: 0, delimiter: ',')

    response = { box1: donation_totals, box2: gam_count, box3: foodcrawl_raised,
                 box4: total_vouchers_giftcards, box5: sellers_total, box6: luc_raised }
    render json: response
  end
end
