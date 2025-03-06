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

    after_commit :clean_up_connected_topics, on: :destroy
    def clean_up_connected_topics
      TopicCustomField.where(name: Collections::COLLECTION_INDEX, value: topic_id).delete_all
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
#  id         :integer          not null, primary key
#  topic_id   :integer          not null
#  payload    :jsonb            not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_collections_on_topic_id  (topic_id) UNIQUE
#
