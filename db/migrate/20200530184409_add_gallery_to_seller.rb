# frozen_string_literal: true

class AddGalleryToSeller < ActiveRecord::Migration[6.0]
  def change
    add_column(
      :sellers,
      :gallery_image_urls,
      :string, array: true,
               default: [],
               null: false
    )
  end
end
