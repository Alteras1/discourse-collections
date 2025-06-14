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
    validate :no_headers_if_single_topic, if: :is_single_topic
    validate :includes_one_topic, unless: :is_single_topic

    accepts_nested_attributes_for :collection_items, allow_destroy: true

    after_destroy :remove_subcollection_id_from_topic_custom_fields, if: :is_single_topic

    # Do not allow sections to be created for single topic
    # This is a limitation of the current UI design.
    def no_headers_if_single_topic
      collection_items.each do |item|
        if item.is_section_header
          errors.add(item.name, I18n.t("collections.errors.subcollection_no_headers"))
        end
      end
    end

    def includes_one_topic
      unless collection_items.any? { |item| item.topic_id != nil }
        errors.add_to_base(I18n.t("collections.errors.topic_required"))
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
