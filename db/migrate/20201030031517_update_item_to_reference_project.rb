class UpdateItemToReferenceProject < ActiveRecord::Migration[6.0]
  def change
    add_reference :items, :project, index: true
    change_column :items, :seller_id, :bigint, null: true
  end
end
