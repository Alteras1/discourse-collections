# frozen_string_literal: true

class AddIconTypeToCollectionItems < ActiveRecord::Migration[7.2]
  def up
    add_column :collection_items, :icon_type, :integer, default: 0, null: false
  end

  def down
    remove_column :collection_items, :icon_type
  end
end
