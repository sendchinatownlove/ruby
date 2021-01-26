# frozen_string_literal: true

class ContactCrawlReceiptsController < ApplicationController
  
  # GET /contacts/:contact_id/crawl_receipts
  def index
    json_response(CrawlReceipt.where(contact_id: params[:contact_id]))
  end
end
