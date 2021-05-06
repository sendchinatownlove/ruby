class StatsController < ApplicationController
  def donation_totals
    outside_db_contributions = 123_572
    query = ActiveRecord::Base.connection.execute($donation_query)
    query.getvalue(0, 5) + outside_db_contributions
  end

  def gam_count
    @GiftCardDetail = GiftCardDetail.where(single_use: true)
    # Magic constant to track orders not in GAM
    outside_db_contributions = 5140
    # TODO(stanzheng) pull magic constant from GAM spreadsheet
    @GiftCardDetail.length + outside_db_contributions
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
    if ENV['GOOGLEDRIVE_SECRET']
      LiveStats.pull()
    end
    donation_totals = '$%s' % ActionController::Base.helpers.number_with_precision(donation_totals, precision: 0, delimiter: ',')  # "$10,000"
    gam_count           = ActionController::Base.helpers.number_with_precision(gam_count, precision: 0,
                                                                                          delimiter: ',')
    foodcrawl_raised    = '36,573'
    transaction_totals  = ActionController::Base.helpers.number_with_precision(transaction_totals,
                                                                               precision: 0, delimiter: ',')
    sellers_total
    luc_raised = '$47,689'
    response = { box1: donation_totals, box2: gam_count, box3: foodcrawl_raised,
                 box4: transaction_totals, box5: sellers_total, box6: luc_raised}
    render json: response
  end
end
