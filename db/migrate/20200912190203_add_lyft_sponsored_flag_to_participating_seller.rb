# frozen_string_literal: true

class AddLyftSponsoredFlagToParticipatingSeller < ActiveRecord::Migration[6.0]
  def change
    add_column :participating_sellers, :is_lyft_sponsored, :boolean, default: false
  end
end
