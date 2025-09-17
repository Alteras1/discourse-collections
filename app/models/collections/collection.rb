# frozen_string_literal: true

module ::Collections
  class Collection < ActiveRecord::Base
    self.table_name = "collections"

    belongs_to :user
    has_many :collection_items, -> { order("position") }, dependent: :destroy
    validates_presence_of :collection_items
    validates :user_id, presence: true
    validates :maintainer_ids, presence: true, allow_blank: true
    validates :is_single_topic, inclusion: [true, false]
    validates :title, absence: true, if: :is_single_topic
    validates :desc, absence: true, if: :is_single_topic
    validate :includes_one_topic, unless: :is_single_topic
    validate :items_uniquely_belongs_to_topic, unless: :is_single_topic

    accepts_nested_attributes_for :collection_items, allow_destroy: true

    after_destroy :remove_subcollection_id_from_topic_custom_fields, if: :is_single_topic

    def includes_one_topic
      unless collection_items.any? { |item| item.topic_id != nil }
        errors.add_to_base(I18n.t("collections.errors.topic_required"))
      end
    end

    def items_uniquely_belongs_to_topic
      topic_ids = collection_items.filter_map { |item| item.topic_id if item.topic_id.present? }
      if topic_ids.detect { |i| topic_ids.count(i) > 1 }
        errors.add(:url, "This topic is already in the collection")
      end

      values =
        TopicCustomField
          .where(name: Collections::COLLECTION_ID, topic_id: topic_ids)
          .pluck(:value)
          .map(&:to_i)

      if values.any? { |v| v != id && v != nil }
        errors.add(:url, I18n.t("collections.errors.topic_in_another_collection"))
      end
    end

    def remove_subcollection_id_from_topic_custom_fields
      TopicCustomField.delete_by(name: Collections::SUBCOLLECTION_ID, value: id)
    end
  end
end

# == Schema Information
#
# Table name: collections
#
#  id              :bigint           not null, primary key
#  title           :string           default(""), not null
#  desc            :string           default(""), not null
#  user_id         :integer          not null
#  maintainer_ids  :integer          default([]), is an Array
#  is_single_topic :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
