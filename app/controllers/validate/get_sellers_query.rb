# frozen_string_literal: true

module Validate
  class GetSellersQuery
    include ActiveModel::Validations

    attr_accessor :sort_key, :sort_order

    validates :sort_key, presence: true, inclusion: { in: %w[created_at] }
    validates :sort_order, presence: true, inclusion: { in: %w[desc asc] }

    def initialize(params = {})
      if params[:sort].nil?
        # Default to most recent sellers
        @sort_key = 'created_at'
        @sort_order  = 'desc'
      else
        @sort_key = params[:sort].split(':')[0]
        @sort_order = params[:sort].split(':')[1] || 'desc'
      end
    end
  end
end
