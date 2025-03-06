# frozen_string_literal: true

module ::Collections
  module Initializers
    # Adds the collection serializer to a topic view.
    # Will pull the needed data from the topic's custom fields
    class AddCollectionToTopicSerializer < Initializer
      def apply
        plugin.add_to_serializer(
          :topic_view,
          Collections::COLLECTION.to_sym,
          include_condition: -> { object.topic.public_send(Collections::IS_COLLECTION) || object.topic.public_send(Collections::COLLECTION_INDEX) }
        ) do
          if object.topic.public_send(Collections::IS_COLLECTION)
            collection = Collections::Collection.find_by(topic_id: object.topic.id)
          else
            collection = Collections::Collection.find_by(topic_id: object.topic.public_send(Collections::COLLECTION_INDEX))
          end
          collection.present? ? Collections::CollectionSerializer.new(collection, scope: self, root: false) : nil
        end
      end
    end
  end
end