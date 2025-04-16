# frozen_string_literal: true

class CreateCollections < ActiveRecord::Migration[7.2]
  def change
    create_table :collections, { id: false }, primary_key: :topic_id do |t|
      t.integer :topic_id, null: false, index: { unique: true }
      t.json :payload, null: false

      t.timestamps
    end
  end
end
