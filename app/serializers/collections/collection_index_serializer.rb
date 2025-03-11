# frozen_string_literal: true

module ::Collections
  class CollectionIndexSerializer < Collections::CollectionSerializer
    attributes :unbound_topics, :orphaned_topics

    def unbound_topics
      unbound = object.bounded_topics_based_on_payload - object.actual_bounded_topics
      unbound.map do |topic_id|
        topic = Topic.find_by(id: topic_id)
        CollectionIndexOrphanSerializer.new(topic, scope: scope, root: false)
      end
    end

    def orphaned_topics
      orphans = object.actual_bounded_topics - object.bounded_topics_based_on_payload
      orphans.map do |topic_id|
        topic = Topic.find_by(id: topic_id)
        CollectionIndexOrphanSerializer.new(topic, scope: scope, root: false)
      end
    end
  end
end