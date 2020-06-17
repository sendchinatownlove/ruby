# frozen_string_literal: true

class TranslateSeller < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up do
        Seller.create_translation_table!({
                                           name: :string,
                                           story: :text,
                                           owner_name: :string,
                                           summary: :text
                                         }, {
                                           migrate_data: true,
                                           remove_source_columns: true
                                         })
      end

      dir.down do
        Post.drop_translation_table! migrate_data: true
      end
    end
  end
end
