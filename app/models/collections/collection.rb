# frozen_string_literal: true

module ::Collections
  class Collection < ActiveRecord::Base
    self.table_name = 'collections'

    belongs_to :topic
    validates :payload, presence: true

    # This is a QoL function **ONLY** for reading the sections in the payload
    # with symbolized keys. This is not meant to be used for writing. If you
    # need to write to the payload, you should use the `payload` attribute
    # directly.
    # 
    # @return [Array<Hash>]
    def sections
      return nil if payload.blank?
      initialize_open_struct_deeply payload
    end

    def bounded_topics_based_on_payload
      return [] if payload.blank?
      sections
        .flat_map { |section| section.links.map { |link| Collections::Url.extract_topic_id_from_url(link[:href]) } }
        .compact
        .to_set
    end

    def actual_bounded_topics
      TopicCustomField.where(name: Collections::COLLECTION_INDEX, value: topic_id).pluck(:topic_id)
    end

    after_commit :refresh_bounded_topics, on: [:create, :update]
    def refresh_bounded_topics
      actual_bounded_topics.each do |t_id|
        MessageBus.publish("/topic/#{t_id}", reload_topic: true)
      end
      MessageBus.publish("/topic/#{topic_id}", reload_topic: true)
    end

    after_commit :clean_up_connected_topics, on: :destroy
    def clean_up_connected_topics
      associated_topic_ids = actual_bounded_topics
      TopicCustomField.delete_by(name: Collections::COLLECTION_INDEX, value: topic_id)
      associated_topic_ids.each do |t_id|
        MessageBus.publish("/topic/#{t_id}", reload_topic: true)
      end
      MessageBus.publish("/topic/#{topic_id}", reload_topic: true)
    end

    private

    def initialize_open_struct_deeply(value)
      case value
      when Hash
        OpenStruct.new(value.transform_values { |hash_value| send __method__, hash_value })
      when Array
        value.map { |element| send __method__, element }
      else
        value
      end
    end
  end
end

# == Schema Information
#
# Table name: collections
#
#  topic_id   :integer          not null, primary key
#  payload    :jsonb            not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_collections_on_topic_id  (topic_id) UNIQUE
#
