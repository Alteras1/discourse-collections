# frozen_string_literal: true

class CreateCollectionTables < ActiveRecord::Migration[7.2]
  def change
    create_table :collections do |t|
      t.integer :user_id, null: false
      t.integer :maintainer_ids, array: true, default: []
      t.boolean :is_single_topic, null: false, default: false

      t.timestamps
    end

    create_table :collection_items do |t|
      t.references :collection, null: false, foreign_key: true
      t.string :name, null: false
      t.string :icon
      t.string :url
      t.boolean :is_section_header, null: false, default: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end
  end
end
