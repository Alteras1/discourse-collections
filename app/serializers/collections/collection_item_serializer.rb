# frozen_string_literal: true

module ::Collections
  class CollectionItemSerializer < ApplicationSerializer
    attributes :id,
               :collection_id,
               :name,
               :url,
               :icon,
               :position,
               :is_section_header,
               :topic_id,
               :can_delete_collection_item

    def can_delete_collection_item
      return true if object.collection.is_single_topic
      scope.can_delete_collection_item?(object)
    end
  end
end
