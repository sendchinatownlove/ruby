# frozen_string_literal: true

class AddInstagramAndRedemptionAccessTokenToContact < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :instagram, :string
    add_column :contacts, :rewards_redemption_access_token, :string
  end
end
