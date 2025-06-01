# frozen_string_literal: true

module ::Collections
  class CollectionItem < ActiveRecord::Base
    self.table_name = "collection_items"

    belongs_to :collection, class_name: "Collections::Collection"

    validates :name, presence: true
    validates :position, numericality: { only_integer: true }
    validates :is_section_header, inclusion: [true, false]
    validate :has_url_if_not_section_header, if: :is_section_header
    validate :validates_uniquely_belongs_to_topic?, unless: :is_section_header

    after_commit :clean_up_connected_topic, on: :destroy
    after_commit :attach_topic_to_collection, on: %i[create update]
    before_update :clean_up_old_topic, if: :url_changed?

    def has_url_if_not_section_header
      errors.add(:url, "URL must be set if not a section header") if url.blank?
    end

    def topic_id
      return unless url
      ::Collections::Url.extract_topic_id_from_url(url)
    end

    def validates_uniquely_belongs_to_topic?
      return if collection.is_single_topic
      return unless url
      return if topic_id.blank?

      # Check if the topic is already in the collection
      if TopicCustomField.find_by(name: Collections::COLLECTION_ID, topic_id: topic_id)
        errors.add(:url, "This topic is already in a collection")
      end
      # Check if the topic is already in the collection items
      if collection.collection_items.exists?(url: url)
        errors.add(:url, "This topic is already in the collection")
      end
    end

    def attach_topic_to_collection
      return unless topic_id
      return if collection.is_single_topic
      topic = Topic.find_by(id: topic_id)
      return unless topic
      topic.custom_fields[Collections::COLLECTION_ID] = collection.id
      topic.save_custom_fields
    end

    def clean_up_connected_topic
      return unless topic_id

      # Remove the topic from the collection
      TopicCustomField.delete_by(name: Collections::COLLECTION_ID, value: topic_id)
    end

    def clean_up_old_topic
      old_topic_id = ::Collections::Url.extract_topic_id_from_url(url_was)
      return unless old_topic_id
      return if old_topic_id == topic_id

      # Remove the old topic from the collection
      TopicCustomField.delete_by(name: Collections::COLLECTION_ID, value: old_topic_id)
    end
  end
end
