class AddForeignKeys < ActiveRecord::Migration[6.0]
  def change
  	add_foreign_key :delivery_types, :delivery_options, column: :delivery_options_id
  end
end
