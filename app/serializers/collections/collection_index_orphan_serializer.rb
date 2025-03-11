# frozen_string_literal: true

module ::Collections
  class CollectionIndexOrphanSerializer < BasicTopicSerializer
    attributes :can_edit
    
    def can_edit
      scope.change_collection_index_of_topic?(object)
    end
  end
end