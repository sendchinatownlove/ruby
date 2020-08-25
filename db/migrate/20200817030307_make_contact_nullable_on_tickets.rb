# frozen_string_literal: true

class MakeContactNullableOnTickets < ActiveRecord::Migration[6.0]
  def change
    change_column :tickets, :contact_id, :bigint, null: true
  end
end
