# frozen_string_literal: true

class ChangeTypeColToBusinessType < ActiveRecord::Migration[6.0]
  def change
    rename_column :sellers, :type, :business_type
  end
end
