# frozen_string_literal: true

class CrawlReceiptsController < ApplicationController

  # POST /crawl_receipts
  def create
    @crawl_receipt = CrawlReceipt.create!(create_params)
    unless @participating_seller.present? ^ @payment_intent.present?
      raise ArgumentError, "Participating Seller or Payment Intent must exist, but not both. participating_seller_id: #{@participating_seller.id}, payment_intent_id: #{@payment_intent.id}"
    end
    json_response(crawl_receipt_json, :created)
  end

  private

  def crawl_receipt_json(crawl_receipt: crawl_receipt)
    ret = crawl_receipt.as_json
    ret['participating_seller_id'] = crawl_receipt.participating_seller_id
    ret['payment_intent_id'] = crawl_receipt.payment_intent_id
    ret['contact_id'] = crawl_receipt.contact_id
    ret['amount'] = crawl_receipt.amount
    ret['redemption_id'] = crawl_receipt.redemption_id
    ret['receipt_url'] = crawl_receipt.receipt_url
    ret
  end

  def create_params
    params.require(:contact_id)
    params.require(:amount)
    ret = params.permit(
      :participating_seller_id,
      :payment_intent_id,
      :contact_id,
      :amount,
      :receipt_url,
      :redemption_id,
    )

    set_contact
    set_participating_seller
    set_payment_intent

    ret[participating_seller_id] = @participating_seller.id if @participating_seller.present?
    ret[payment_intent_id] = @payment_intent.id if @payment_intent.present?
  end
  end

  def set_participating_seller
    @participating_seller = ParticipatingSeller.find(params[:participating_seller_id])
  end

  def set_payment_intent
    @payment_intent = PaymentIntent.find(params[:payment_intent_id])
  end

  def set_contact
    @contact = Contact.find(params[:contact_id])
  end
end
