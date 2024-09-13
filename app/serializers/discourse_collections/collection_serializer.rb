# frozen_string_literal: true

module ::DiscourseCollections
  class CollectionSerializer < ApplicationSerializer
    attributes :id, :title, :description, :created_at, :updated_at, :user, :items

    # has_many :collection_items, serializer: CollectionItemSerializer, key: 'items'
    has_many :collection_curators, serializer: BasicUserSerializer, key: 'curators'

    def user
      # todo: Find a better user serializer to use here, or make multiple serializers for different collection views
      BasicUserSerializer.new(object.user, scope: scope, root: false)
    end

    def items
      object.collection_items.map { |item| DiscourseCollections::CollectionItemSerializer.new(item) }
    end
  end
end