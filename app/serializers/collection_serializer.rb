# frozen_string_literal: true

class CollectionSerializer < ApplicationSerializer
  attributes :id, :title, :description, :created_at, :updated_at, :user

  has_many :collection_items
  has_many :collection_curators, serializer: BasicUserSerializer, key: 'curators'

  def user
    # todo: Find a better user serializer to use here, or make multiple serializers for different collection views
    BasicUserSerializer.new(object.user, scope: scope, root: false).as_json
  end
end