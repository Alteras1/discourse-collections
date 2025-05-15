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
      return unless topic_id

      # Check if the topic is already in the collection
      if TopicCustomField.find_by(name: Collections::COLLECTION_INDEX, topic_id: topic_id)
        errors.add(:url, "This topic is already in a collection")
      end
      # Check if the topic is already in the collection items
      if collection.collection_items.exists?(topic_id: topic_id)
        errors.add(:url, "This topic is already in the collection")
      end
    end

    # TODO: add validation & callbacks for computing the URL to Topic and adding custom fields
    # to the topic
  end
end
