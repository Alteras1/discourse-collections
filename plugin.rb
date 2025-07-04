# frozen_string_literal: true

# name: discourse-collections
# about: Discourse Collections Plugin
# meta_topic_id: 372817
# version: 1.0.2
# authors: Alteras1
# url: https://github.com/Alteras1/discourse-collections
# required_version: 3.4.0

enabled_site_setting :collections_enabled

register_asset "stylesheets/common/index.scss"
register_asset "stylesheets/mobile/mobile.scss", :mobile

module ::Collections
  PLUGIN_NAME = "discourse-collections"

  # names for serializer
  COLLECTION = "collection"
  SUBCOLLECTION = "subcollection"

  # topic custom fields
  COLLECTION_ID = "collection_id"
  SUBCOLLECTION_ID = "subcollection_id"

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
  register_svg_icon "collection-pip"

  reloadable_patch { |plugin| Guardian.prepend Collections::GuardianExtensions }

  # register_search_advanced_filter(/is:collection/) do |post|
  #   if SiteSetting.collections_enabled
  #     post.where(
  #       "topics.id IN (SELECT topic_id FROM topic_custom_fields WHERE name = '#{Collections::IS_COLLECTION}' AND value = 't')",
  #     )
  #   else
  #     post
  #   end
  # end

  Collections::Initializers.apply(self)
end
