# frozen_string_literal: true

module ::Collections
  module Initializers
    # add/remove collection object depending on is_collection
    # after lifecycle event so that normal topic save can't be interrupted

    class HandleTopicChanges < Initializer
      def apply
        plugin.on(:topic_trashed) do |topic|
          next unless topic.custom_fields[Collections::IS_COLLECTION]
          collection = Collections::Collection.find_by_topic_id(topic.id)
          collection&.destroy
        end

        plugin.on(:topic_deleted) do |topic|
          next unless topic.custom_fields[Collections::IS_COLLECTION]
          collection = Collections::Collection.find_by_topic_id(topic.id)
          collection&.destroy
        end

        plugin.on(:topic_recovered) do |topic, user|
          next unless topic.custom_fields[Collections::IS_COLLECTION]
          auto_bind = Guardian.new(user).change_collection_status_of_topic?(topic)
          Collections::CollectionHandler.create_collection_for_topic(topic.id, auto_bind: auto_bind)
        end

        plugin.add_model_callback(:post, :after_commit) do
          return unless is_first_post?
          return if previous_changes[:cooked].blank?
          topic = Topic.find_by(id: topic_id)
          return unless topic&.custom_fields&.[](Collections::IS_COLLECTION)
          auto_bind = Guardian.new(user).change_collection_status_of_topic?(topic)
          Collections::CollectionHandler.create_collection_for_topic(topic, auto_bind: auto_bind)
        end
      end
    end
  end
end
