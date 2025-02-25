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
end

require_relative "lib/discourse_collections/engine"

after_initialize do
  # Code which should run after Rails has finished booting
end
