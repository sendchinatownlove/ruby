# frozen_string_literal: true

class TranslateBusinessType < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up do
        Seller.add_translation_fields! business_type: :string
      end

      dir.down do
        remove_column :business_type, :string
      end
    end
  end
end
