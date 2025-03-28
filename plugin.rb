# frozen_string_literal: true

# name: discourse-collections
# about: TODO
# meta_topic_id: TODO
# version: 0.0.1
# authors: Alteras1
# url: TODO
# required_version: 3.0.0

enabled_site_setting :collections_enabled

register_asset "stylesheets/common/index.scss"

module ::Collections
  PLUGIN_NAME = "discourse-collections"

  COLLECTION_INDEX = "collection_index"
  IS_COLLECTION = "is_collection"
  COLLECTION = "collection"
  OWNED_COLLECTION = "owned_collection"

  class Initializer
    attr_reader :plugin

    # @param [Plugin::Instance] plugin
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

require_relative "lib/collections/engine"

after_initialize do

  register_svg_icon "collections-add"
  register_svg_icon "collections-remove"

  add_to_class(:guardian, :change_collection_status_of_topic?) do |topic|
    # set to can edit, as this will cover OP and staff.
    # should we need to extend this, ie. as a new permission, we can extend this method
    return can_edit_topic?(topic) if SiteSetting.collection_by_topic_owner
    current_user.in_any_groups?(SiteSetting.collection_modification_by_allowed_groups_map)
  end

  add_to_class(:guardian, :change_collection_index_of_topic?) do |topic|
    return can_edit_topic?(topic) if SiteSetting.collection_by_topic_owner
    current_user.in_any_groups?(SiteSetting.collection_modification_by_allowed_groups_map)
  end

  register_search_advanced_filter(/is:collection/) do |post|
    if SiteSetting.collections_enabled
      post.where("topics.id IN (SELECT topic_id FROM topic_custom_fields WHERE name = '#{Collections::IS_COLLECTION}' AND value = 't')")
    else
      post
    end
  end

  Collections::Initializers.apply(self)
end
