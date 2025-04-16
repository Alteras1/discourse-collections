# frozen_string_literal: true

module ::Collections
  class CollectionInfoSerializer < ApplicationSerializer
    attributes Collections::IS_COLLECTION.to_sym, Collections::COLLECTION_INDEX.to_sym
    attributes :collection,
               :owned_collection,
               :can_create_delete_collection,
               :can_add_remove_from_collection

    def collection
      return nil unless object.public_send(Collections::COLLECTION_INDEX)
      col =
        Collections::Collection.find_by(topic_id: object.public_send(Collections::COLLECTION_INDEX))
      col.present? ? Collections::CollectionSerializer.new(col, scope: scope, root: false) : nil
    end

    def owned_collection
      return nil unless object.public_send(Collections::IS_COLLECTION)
      col = Collections::Collection.find_by(topic_id: object.id)
      if col.present?
        Collections::CollectionIndexSerializer.new(col, scope: scope, root: false)
      else
        nil
      end
    end

    def can_create_delete_collection
      scope.change_collection_status_of_topic?(object)
    end

    def can_add_remove_from_collection
      scope.change_collection_index_of_topic?(object)
    end
  end
end
