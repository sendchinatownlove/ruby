# frozen_string_literal: true

module Validate
  class ItemQuery
    include ActiveModel::Validations

    attr_accessor :order, :limit

    validates :order, presence: true, inclusion: { in: %w[desc asc] }
    validates :limit, presence: true, numericality: {
      only_integer: true, greater_than: 0, less_than: 11
    }

    def initialize(params = {})
      @order = params[:order] || 'desc' # Default it to most recent
      @limit = params[:limit] || 10 # Default it to 10
    end
  end
end
