# frozen_string_literal: true

module ::Collections
  module Initializers
    class AddTopicExtensions < Initializer
      def apply
        # is_collection
        plugin.register_topic_custom_field_type(Collections::IS_COLLECTION, :boolean)
        plugin.add_preloaded_topic_list_custom_field(Collections::IS_COLLECTION)

        plugin.add_to_class(:topic, Collections::IS_COLLECTION.to_sym) do
          custom_fields[Collections::IS_COLLECTION] || false
        end
      
        plugin.add_to_class(:topic, "#{Collections::IS_COLLECTION}=") do |value|
          custom_fields[Collections::IS_COLLECTION] = value
        end

        plugin.add_to_serializer(:topic_view, Collections::IS_COLLECTION.to_sym) do
          object.topic.send(Collections::IS_COLLECTION)
        end

        # collection index matches topic index
        # let frontend do its own check to see if topic is actually accessible to get full collection
        plugin.register_topic_custom_field_type(Collections::COLLECTION_INDEX, :integer)
        plugin.add_preloaded_topic_list_custom_field(Collections::COLLECTION_INDEX)

        plugin.add_to_class(:topic, Collections::COLLECTION_INDEX.to_sym) do
          custom_fields[Collections::COLLECTION_INDEX]
        end
      
        plugin.add_to_class(:topic, "#{Collections::COLLECTION_INDEX}=") do |value|
          custom_fields[Collections::COLLECTION_INDEX] = value
        end
      
        plugin.add_to_serializer(:topic_view, Collections::COLLECTION_INDEX.to_sym) do
          object.topic.send(Collections::COLLECTION_INDEX)
        end

      end
    end
  end
end