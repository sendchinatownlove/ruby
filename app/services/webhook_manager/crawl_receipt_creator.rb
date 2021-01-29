module WebhookManager
   class CrawlReceiptCreator < BaseService
    attr_reader :payment_intent, :amount, :contact_id, :payment_intent_id
    FEBRUARY_EST = Time.now <= Time.find_zone('EST').local(2021,3,1) && Time.now >= Time.find_zone('EST').local(2021,2,1)

    def initialize(params)
      @payment_intent = params[:payment_intent]
      @amount = params[:amount]
      @contact_id = payment_intent.purchaser_id
      @payment_intent_id = payment_intent.id
    end

    def call
<<<<<<< HEAD
      if WebhookManager::CrawlReceiptCreator::FEBRAURY_EST && @amount >= CrawlReceipt::CRAWL_RECEIPT_MIN_AMOUNT
=======
      if FEBRAURY_EST && @amount >= CrawlReceipt::CRAWL_RECEIPT_MIN_AMOUNT
>>>>>>> a07ee5e272ec2ac973224e800b7693cbf0b23e2c
        CrawlReceipt.create!(amount: amount, payment_intent_id: payment_intent_id, contact_id: contact_id, receipt_url: ' ')
      end
    end
  end
end