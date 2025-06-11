# frozen_string_literal: true

module ::Collections
  class CollectionSerializer < ApplicationSerializer
    attributes :id,
               :title,
               :desc,
               :is_single_topic,
               :maintainers,
               :can_edit_collection,
               :can_delete_collection
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

    def can_edit_collection
      scope.can_edit_collection?(object)
    end

    def can_delete_collection
      scope.can_delete_collection?(object)
    end
  end
end
