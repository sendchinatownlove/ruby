# frozen_string_literal: true
class FixDeliveryTypeReference < ActiveRecord::Migration[6.0]
  def change
    remove_reference :delivery_types, :delivery_option, index: true, foreign_key: true

    add_reference :delivery_options, :delivery_type, index: true, foreign_key: true
  end
end
