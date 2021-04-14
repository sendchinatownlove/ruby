# frozen_string_literal: true

class AddActiveToParticipatingSellers < ActiveRecord::Migration[6.0]
  def change
    change_table(:participating_sellers) do |t|
      t.column :active, :boolean, default: true
    end
  end
end
