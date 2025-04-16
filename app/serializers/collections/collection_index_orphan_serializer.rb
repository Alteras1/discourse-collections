# frozen_string_literal: true

module ::Collections
  class CollectionIndexOrphanSerializer < BasicTopicSerializer
    attributes :can_add_remove_from_collection

    def can_add_remove_from_collection
      scope.change_collection_index_of_topic?(object)
    end
  end
end
