# frozen_string_literal: true

class CreateCollectionsTables < ActiveRecord::Migration[7.0]
  def change
    create_table :collections do |t|
      t.string :title
      t.text :description, default: ""
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :collections, :title

    create_table :collection_items do |t|
      t.references :collection, null: false, foreign_key: true
      t.string :name
      t.references :collectable, polymorphic: true, index: {unique: true}, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end
    add_index :collection_items, :name

    create_table :collection_curators do |t|
      t.references :collection, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
