# frozen_string_literal: true

module ::DiscourseCollections
  # TODO: Break this out into separate serializers for different views (collection vs in-topic)
  class CollectionItemSerializer < ApplicationSerializer
    attributes :id, :collection_id, :collectable_type, :name, :position, :collectable

    def collectable
      if object.is_topic?
        BasicTopicSerializer.new(object.collectable, scope: scope, root: false)
      elsif object.is_post?
        BasicPostSerializer.new(object.collectable, scope: scope, root: false)
      end
    end
  end
end