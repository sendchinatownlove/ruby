# frozen_string_literal: true

class ChangeStoryFromStringToText < ActiveRecord::Migration[6.0]
  def change
    change_column :sellers, :story, :text
  end
end
