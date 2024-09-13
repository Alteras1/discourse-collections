# frozen_string_literal: true

module ::DiscourseCollections
  class PostCollectionItemSerializer < ApplicationSerializer
    attributes :id, :name, :position
  end
end