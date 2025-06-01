# frozen_string_literal: true

module ::Collections
  class CollectionItemSerializer < ApplicationSerializer
    attributes :id, :collection_id, :name, :url, :position, :is_section_header, :topic_id
  end
end
