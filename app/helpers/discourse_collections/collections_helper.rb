# frozen_string_literal: true

module DiscourseCollections
  module CollectionsHelper
    def self.getCollectionByCollectable(collectable)
      collection_item = CollectionItem.find_by(collectable: collectable)
      if collection_item.present?
        collection_item.collection
      else
        nil
      end
    end
  end
end