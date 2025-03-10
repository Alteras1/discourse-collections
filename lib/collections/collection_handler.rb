# frozen_string_literal: true

module ::Collections
  class CollectionHandler
    def self.preview_collection(cooked_text)
      Collections::CollectionIndexTopicParser.new(cooked_text).sections.to_json
    end

    def self.create_collection_for_topic(topic)
      # check PostRevisor::TopicChanges.track_topic_field with @guardian.ensure_can_edit! and @guardian.ensure_can_create!

      payload = Collections::CollectionIndexTopicParser.new(topic.ordered_posts.first.cooked).sections
      collection = Collections::Collection.new(topic_id: topic.id, payload: payload)
      sections = collection.sections
      list_of_topics = sections
        .flat_map { |section| section.links.map { |link| Collections::Url.extract_topic_id_from_url(link[:href]) } }
        .compact
        .to_set

      begin
        Topic.transaction do
          collection.save!
          topic.custom_fields[Collections::IS_COLLECTION] = is_collection
          topic.save_custom_fields
          list_of_topics.each do |t_id|
            t = Topic.find_by(id: t_id)
            next unless t
            next if t.trashed?
            next if t.custom_fields[Collections::COLLECTION_INDEX] # don't overwrite existing collection index
            # initial build is always limited to the topics that OP owns
            next unless t.user_id == topic.user_id
            
            # TODO: add a guard for the topic check here
            t.custom_fields[Collections::COLLECTION_INDEX] = t.id
            t.save_custom_fields
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error("Failed to create collection for topic #{topic.id}: #{e}")
        return false
      end

      true
    end

  end
end