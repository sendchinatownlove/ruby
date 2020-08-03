# frozen_string_literal: true

class CreateDistributors < ActiveRecord::Migration[6.0]
  def change
    create_table :distributors do |t|
      t.string :website_url
      t.string :image_url
    end
  end
end
