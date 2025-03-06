# frozen_string_literal: true

module ::Collections
  class BuildCollection
    def self.preview_collection(cooked_text)
      Collections::CollectionIndexTopicParser.new(cooked_text).sections.to_json
    end

    def self.create_collection_for_topic(topic)
      # check PostRevisor::TopicChanges.track_topic_field with @guardian.ensure_can_edit! and @guardian.ensure_can_create!

      payload = Collections::CollectionIndexTopicParser.new(topic.ordered_posts.first.cooked).sections
      collection = Collections::Collection.create!(topic_id: topic.id, payload: payload)
      collection.save!
      sections = collection.sections
      p sections
    end
  end
end