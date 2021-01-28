# frozen_string_literal: true

require 'google/cloud/storage'

class GcsController < ApplicationController
  # POST /gcs
  def create
    bucket_name = 'scl-lny-receipts'
    file_name = gcs_params[:file_name]
    file_type = gcs_params[:file_type]

    storage = Google::Cloud::Storage.new
    storage_expiry_time = 5 * 60 # 5 minutes

    url = storage.signed_url bucket_name, file_name, method: 'PUT',
                                                     expires: storage_expiry_time, version: :v4,
                                                     headers: { 'Content-Type' => file_type }

    json_response({ url: url })
  end

  private

  def gcs_params
    params.require(:file_name)
    params.require(:file_type)
    params.permit(
      :file_name,
      :file_type
    )
  end
end
