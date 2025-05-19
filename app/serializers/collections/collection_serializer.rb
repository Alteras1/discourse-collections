# frozen_string_literal: true

module ::Collections
  class CollectionSerializer < ApplicationSerializer
    attributes :id, :is_single_topic, :owner, :maintainers
    has_many :collection_items, serializer: ::Collection::CollectionItemSerializer
    
    def owner
      object.user
    end

    def maintainers
      object.maintainer_ids.map do |user_id|
        User.find_by(id: user_id)
      end
    end
  end
end
