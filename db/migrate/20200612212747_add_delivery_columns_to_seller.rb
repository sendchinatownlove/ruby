class AddDeliveryColumnsToSeller < ActiveRecord::Migration[6.0]
  def change
    enable_extension "hstore"

    add_column :sellers, :delivery, :boolean
    add_column :sellers, :delivery_options, :hstore
    add_index :sellers, :delivery_options, using: :gin

  end
end
