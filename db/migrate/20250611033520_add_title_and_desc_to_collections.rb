# frozen_string_literal: true

class AddTitleAndDescToCollections < ActiveRecord::Migration[7.2]
  def change
    add_column :collections, :title, :string, default: "", null: false
    add_column :collections, :desc, :string, default: "", null: false
  end
end
