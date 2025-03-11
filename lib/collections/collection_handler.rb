# frozen_string_literal: true

module ::Collections
  class CollectionHandler
    def self.preview_collection(cooked_text)
      Collections::CollectionIndexTopicParser.new(cooked_text).sections
    end

    def self.create_collection_for_topic(topic)
      payload = Collections::CollectionIndexTopicParser.new(topic.ordered_posts.first.cooked).sections
      existing_col = Collections::Collection.find_by(topic_id: topic.id)
      if existing_col
        old_list_of_topics = existing_col.bounded_topics_based_on_payload
        collection = existing_col
        collection.payload = payload
        list_of_topics = collection.bounded_topics_based_on_payload
        list_of_topics_to_remove = old_list_of_topics - list_of_topics
      else
        collection = Collections::Collection.new(topic_id: topic.id, payload: payload)
        list_of_topics = collection.bounded_topics_based_on_payload
      end

      begin
        Topic.transaction do
          collection.save!
          topic.custom_fields[Collections::IS_COLLECTION] = true
          topic.save_custom_fields
          list_of_topics.each do |t_id|
            t = Topic.find_by(id: t_id)
            next unless t
            next if t.trashed?
            next if t.custom_fields[Collections::COLLECTION_INDEX] # don't overwrite existing collection index
            # initial build is always limited to the topics that OP owns
            next unless t.user_id == topic.user_id
            
            # TODO: add a guard for the topic check here
            t.custom_fields[Collections::COLLECTION_INDEX] = topic.id
            t.save_custom_fields
          end
          if (list_of_topics_to_remove)
            list_of_topics_to_remove.each do |t_id|
              t = Topic.find_by(id: t_id)
              next unless t
              t.custom_fields[Collections::COLLECTION_INDEX] = nil
              t.save_custom_fields
            end
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error("Failed to create collection for topic #{topic.id}: #{e}")
        return false
      end

      list_of_topics_to_remove&.each do |t_id|
        MessageBus.publish("/topic/#{t_id}", reload_topic: true)
      end

      true
    end

  end
end