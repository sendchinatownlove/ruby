# frozen_string_literal: true

class AddDeliveryTypeKeyToDeliveryOption < ActiveRecord::Migration[6.0]
  def change
    add_reference :delivery_types, :delivery_option, index: true, foreign_key: true
  end
end
