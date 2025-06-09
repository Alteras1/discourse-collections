# frozen_string_literal: true

module ::Collections
  class CollectionHandler
    def self.topic_has_subcollection?(topic_id)
      TopicCustomField.find_by(topic_id: topic_id, name: Collections::SUBCOLLECTION_ID).present?
    end

    def self.attach_subcollection_to_topic(topic, subcollection)
      topic.custom_fields[Collections::SUBCOLLECTION_ID] = subcollection.id
      topic.save_custom_fields
    end
  end
end
