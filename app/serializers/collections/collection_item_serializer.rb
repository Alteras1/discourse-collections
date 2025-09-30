# frozen_string_literal: true

module ::Collections
  class CollectionItemSerializer < ApplicationSerializer
    attributes :id,
               :collection_id,
               :name,
               :url,
               :icon,
               :icon_type,
               :position,
               :is_section_header,
               :topic_id,
               :can_delete_collection_item
    attribute :topic_name, if: -> { object.topic_id.present? }

    def can_delete_collection_item
      return true if object.collection.is_single_topic
      scope.can_delete_collection_item?(object)
    end

    def topic_name
      Topic.where(id: object.topic_id).pick(:title) || nil
    end
  end
end
