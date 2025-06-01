# frozen_string_literal: true

module ::Collections
  class CollectionSerializer < ApplicationSerializer
    attributes :id, :is_single_topic, :maintainers
    has_many :collection_items,
             serializer: ::Collections::CollectionItemSerializer,
             embed: :objects,
             include: true
    has_one :user, serializer: BasicUserSerializer, embed: :objects, include: true, key: :owner

    def maintainers
      object.maintainer_ids.map do |user_id|
        BasicUserSerializer.new(User.find_by(id: user_id), scope: scope, root: false)
      end
    end
  end
end
