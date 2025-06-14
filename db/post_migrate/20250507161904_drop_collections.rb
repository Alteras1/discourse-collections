# frozen_string_literal: true

require "migration/table_dropper"

class DropCollections < ActiveRecord::Migration[7.2]
  def change
    # No one should be using this plugin at time of writing
    # Data preservation is not a concern

    reversible do |dir|
      dir.up do
        Migration::TableDropper.execute_drop("collections")
        execute <<~SQL
          DELETE FROM topic_custom_fields
          WHERE name = 'is_collection'
        SQL

        execute <<~SQL
          DELETE FROM topic_custom_fields
          WHERE name = 'collection_index'
        SQL
      end

      dir.down { raise ActiveRecord::IrreversibleMigration }
    end
  end
end
