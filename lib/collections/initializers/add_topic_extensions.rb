# frozen_string_literal: true

module ::Collections
  module Initializers
    class AddTopicExtensions < Initializer
      def apply
        plugin.register_topic_custom_field_type(Collections::COLLECTION_ID, :integer)
        plugin.add_preloaded_topic_list_custom_field(Collections::COLLECTION_ID)

        plugin.add_to_class(:topic, Collections::COLLECTION_ID.to_sym) do
          custom_fields[Collections::COLLECTION_ID]
        end

        plugin.add_to_class(:topic, "#{Collections::COLLECTION_ID}=") do |value|
          custom_fields[Collections::COLLECTION_ID] = value
        end

        plugin.register_topic_custom_field_type(Collections::SUBCOLLECTION_ID, :integer)
        plugin.add_preloaded_topic_list_custom_field(Collections::SUBCOLLECTION_ID)

        plugin.add_to_class(:topic, Collections::SUBCOLLECTION_ID.to_sym) do
          custom_fields[Collections::SUBCOLLECTION_ID]
        end

        plugin.add_to_class(:topic, "#{Collections::SUBCOLLECTION_ID}=") do |value|
          custom_fields[Collections::SUBCOLLECTION_ID] = value
        end
      end
    end
  end
end
