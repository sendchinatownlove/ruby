# frozen_string_literal: true

class UpdateOwnerUrlColumnName < ActiveRecord::Migration[6.0]
  def change
    rename_column :sellers, :owner_url, :owner_image_url
  end
end
