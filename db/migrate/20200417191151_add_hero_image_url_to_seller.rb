# frozen_string_literal: true

class AddHeroImageUrlToSeller < ActiveRecord::Migration[6.0]
  def change
    add_column :sellers, :hero_image_url, :string
    add_column :sellers, :progress_bar_color, :string
  end
end
