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
    response.headers.delete 'X-Frame-Options'
    show(donation_totals, sellers_total, transaction_totals, gam_count)
  end

  def sellers_total
    Seller.all.count
  end

  def progress_bar_totals
    query = ActiveRecord::Base.connection.execute($april_progress_bar_query)

    total = 0
    query.each do |type|
      total += type['sum'] unless type['sum'].nil?
    end

    total
  end

  def num_days_remaining
    currentDate = Time.now
    endDate = Date.new(2021, 4, 26)
    remainingDays = (endDate.to_date - currentDate.to_date).round
    return 0 if remainingDays <= 0

    (endDate.to_date - currentDate.to_date).round
  end

  def transaction_totals
    Item.all.count
  end

  def show(donation_totals, sellers_total, transaction_totals, gam_count)
    donation_totals = '$%s' % ActionController::Base.helpers.number_with_precision(donation_totals, precision: 0, delimiter: ',')  # "$10,000"
    gam_count           = ActionController::Base.helpers.number_with_precision(gam_count, precision: 0,
                                                                                          delimiter: ',')
    foodcrawl_raised    = '36,573'
    transaction_totals  = ActionController::Base.helpers.number_with_precision(transaction_totals,
                                                                               precision: 0, delimiter: ',')
    sellers_total
    luc_raised = '$47,689'
    response = { box1: donation_totals, box2: gam_count, box3: foodcrawl_raised,
                 box4: transaction_totals, box5: sellers_total, box6: luc_raised, progressBarTotal: progress_bar_totals, numDaysRemaining: num_days_remaining }
    render json: response
  end
end
