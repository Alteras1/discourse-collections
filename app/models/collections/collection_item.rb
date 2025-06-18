# frozen_string_literal: true

module ::Collections
  class CollectionItem < ActiveRecord::Base
    self.table_name = "collection_items"

    belongs_to :collection, class_name: "Collections::Collection"

    validates :name, presence: true
    validates :position, numericality: { only_integer: true }
    validates :is_section_header, inclusion: [true, false]
    validate :has_url_if_not_section_header, unless: :is_section_header

    after_commit :clean_up_connected_topic, on: :destroy
    after_commit :attach_topic_to_collection, on: %i[create update]
    before_update :clean_up_old_topic, if: :url_changed?

    def has_url_if_not_section_header
      errors.add(:name, "URL must be set if not a section header") if url.blank?
    end

    def topic_id
      return unless url
      ::Collections::Url.extract_topic_id_from_url(url)
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
      TopicCustomField.delete_by(
        name: Collections::COLLECTION_ID,
        topic_id: topic_id,
        value: collection.id,
      )
    end

    def clean_up_old_topic
      return if collection.is_single_topic
      old_topic_id = ::Collections::Url.extract_topic_id_from_url(url_was)
      return unless old_topic_id
      return if old_topic_id == topic_id

      # Remove the old topic from the collection
      TopicCustomField.delete_by(
        name: Collections::COLLECTION_ID,
        topic_id: old_topic_id,
        value: collection.id,
      )
    end
  end
end

# == Schema Information
#
# Table name: collection_items
#
#  id                :bigint           not null, primary key
#  collection_id     :bigint           not null
#  name              :string           not null
#  icon              :string
#  url               :string
#  is_section_header :boolean          default(FALSE), not null
#  position          :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_collection_items_on_collection_id  (collection_id)
#
# Foreign Keys
#
#  fk_rails_...  (collection_id => collections.id)
#
