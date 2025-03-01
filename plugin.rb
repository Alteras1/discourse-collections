# frozen_string_literal: true

# name: discourse-collections
# about: TODO
# meta_topic_id: TODO
# version: 0.0.1
# authors: Alteras1
# url: TODO
# required_version: 3.0.0

enabled_site_setting :discourse_collections_enabled

module ::DiscourseCollections
  PLUGIN_NAME = "discourse-collections"

  COLLECTION_INDEX = "collection_index"
  IS_COLLECTION = "is_collection"
  COLLECTION = "collection"

  class Initializer
    attr_reader :plugin

    def initialize(plugin)
      @plugin = plugin
    end

    def apply
      raise NotImplementedError
    end
  end

  module Initializers
    module_function

    def apply(plugin)
      constants.each do |const_name|
        klass = const_get(const_name)
        klass.new(plugin).apply if klass.is_a?(Class) && klass < Initializer
      end
    end
  end
end

require_relative "lib/discourse_collections/engine"

after_initialize do
  DiscourseCollections::Initializers.apply(self)

end
