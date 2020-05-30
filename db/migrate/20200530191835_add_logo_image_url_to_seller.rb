class AddLogoImageUrlToSeller < ActiveRecord::Migration[6.0]
  def change
    add_column :sellers, :logo_image_url, :string
  end
end
