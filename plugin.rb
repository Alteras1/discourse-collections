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
  IN_COLLECTION = "in_collection"

  class Error < StandardError
  end
end

require_relative "lib/discourse_collections/engine"

after_initialize do
  # Code which should run after Rails has finished booting
  reloadable_patch do
    # Topic.prepend(DiscourseCollections::TopicExtension)
  end
  # Adds a plugin maintained custom field to the topic model.
  # Custom fields are already being pulled in by topic query.
  # This extra field will allow us to determine if a topic is in a collection
  # and reduce total queries.

  # boolean instead of collection_id to reduce validations needed
  register_topic_custom_field_type(DiscourseCollections::IN_COLLECTION, :boolean)

  add_to_class(:topic, DiscourseCollections::IN_COLLECTION.to_sym) do
    custom_fields[DiscourseCollections::IN_COLLECTION] || false
  end

  add_to_class(:topic, "#{DiscourseCollections::IN_COLLECTION}=") do |value|
    # TODO: determine if i need to add a validator here
    custom_fields[DiscourseCollections::IN_COLLECTION] = value
  end

  add_to_serializer(:topic_view, DiscourseCollections::IN_COLLECTION.to_sym) do
    object.topic.send(DiscourseCollections::IN_COLLECTION)
  end

  add_preloaded_topic_list_custom_field(DiscourseCollections::IN_COLLECTION)

  add_to_serializer(:topic_list_item, DiscourseCollections::IN_COLLECTION.to_sym) do
    object.send(DiscourseCollections::IN_COLLECTION)
  end

  add_to_serializer(:topic_view, :collection, include_condition: -> { topic.public_send(DiscourseCollections::IN_COLLECTION) }) do
    collection = DiscourseCollections::CollectionsHelper.getCollectionByCollectable(topic)
    if collection.present?
      DiscourseCollections::CollectionSerializer.new(collection, scope: self.scope, root: false)
    else
      nil
    end
  end

  add_to_serializer(:post, :collection_details, include_condition: -> { object.topic.public_send(DiscourseCollections::IN_COLLECTION) }) do
    collection_item = DiscourseCollections::CollectionItem.find_by(collectable: object)
    puts collection_item
    if collection_item.present?
      # DiscourseCollections::CollectionSerializer.new(collection, scope: self.scope, root: false)
      DiscourseCollections::PostCollectionItemSerializer.new(collection_item, scope: self.scope, root: false)
    else
      nil
    end
  end

end
