# frozen_string_literal: true

module ::Collections
  class Collection < ActiveRecord::Base
    self.table_name = "collections"
    self.primary_key = "topic_id"

    belongs_to :topic
    validates :payload, presence: true

    # This is a QoL function **ONLY** for reading the sections in the payload
    # with symbolized keys. This is not meant to be used for writing. If you
    # need to write to the payload, you should use the `payload` attribute
    # directly.
    def sections
      return nil if payload.blank?
      { s: payload }.deep_symbolize_keys()[:s]
    end

    def bounded_topics_based_on_payload
      return [] if payload.blank?
      sections
        .flat_map do |section|
          section[:links].map { |link| Collections::Url.extract_topic_id_from_url(link[:href]) }
        end
        .compact
        .uniq
    end

    def actual_bounded_topics
      TopicCustomField.where(name: Collections::COLLECTION_INDEX, value: topic_id).pluck(:topic_id)
    end

    after_commit :refresh_bounded_topics, on: %i[create update]
    def refresh_bounded_topics
      actual_bounded_topics.each do |t_id|
        MessageBus.publish("/topic/#{t_id}", type: "collection_updated")
      end
      MessageBus.publish("/topic/#{topic_id}", type: "collection_updated")
    end

    after_commit :clean_up_connected_topics, on: :destroy
    def clean_up_connected_topics
      associated_topic_ids = actual_bounded_topics
      TopicCustomField.delete_by(name: Collections::COLLECTION_INDEX, value: topic_id)
      associated_topic_ids.each do |t_id|
        MessageBus.publish("/topic/#{t_id}", type: "collection_updated")
      end
      MessageBus.publish("/topic/#{topic_id}", type: "collection_updated")
    end
  end
end

# == Schema Information
#
# Table name: collections
#
#  topic_id   :integer          not null, primary key
#  payload    :json             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_collections_on_topic_id  (topic_id) UNIQUE
#
