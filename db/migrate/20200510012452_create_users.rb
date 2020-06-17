# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :email, optional: true
      t.boolean :is_subscribed
    end
  end
end
