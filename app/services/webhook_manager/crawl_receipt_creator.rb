module WebhookManager
   class CrawlReceiptCreator < BaseService
    attr_reader :payment_intent, :amount, :contact_id, :payment_intent_id

    def initialize(params)
      @payment_intent = params[:payment_intent]
      @amount = params[:amount]
      @contact_id = payment_intent.purchaser_id
      @payment_intent_id = payment_intent.id
    end

    def call
      if Time.now <= Time.find_zone('EST').local(2021,3,1) && Time.now >= Time.find_zone('EST').local(2021,2,1) && @amount >= CrawlReceipt::CRAWL_RECEIPT_MIN_AMOUNT
        CrawlReceipt.create!(amount: amount, payment_intent_id: payment_intent_id, contact_id: contact_id, receipt_url: ' ')
      end
    end
  end
end