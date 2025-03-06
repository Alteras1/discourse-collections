# frozen_string_literal: true

module ::Collections
  module Initializers

    # add/remove collection object depending on is_collection
    # after lifecycle event so that normal topic save can't be interrupted

    class HandleTopicChanges < Initializer
      def apply

        # handles put /t/-/topic-id.json update method
        PostRevisor.track_topic_field(Collections::IS_COLLECTION.to_sym) do |tc, is_collection|
          prev_is_collection = tc.topic.custom_fields[Collections::IS_COLLECTION]
          next if prev_is_collection == is_collection
          if !tc.guardian.can_edit_topic?(tc.topic)
            tc.topic.errors.add(:base, "you can't change the collection status of this topic")
            tc.check_result(false)
            next
          end
          if !!is_collection != is_collection
            tc.topic.errors.add(:base, "is_collection must be a boolean")
            tc.check_result(false)
            next
          end

          PostRevisor.track_and_revise(tc, Collections::IS_COLLECTION, is_collection)
          if is_collection
            # build the collection\
            # TODO: refactor this to occur in an async job????? or not
            # if this only happens on update, we want it to be synchronous and return values/errors
            Collections::BuildCollection.create_collection_for_topic(tc.topic)
          else
            # remove the collection
            collection = Collections::Collection.find_by_topic_id(tc.topic.id)
            next unless collection
            success = collection.destroy
            if !success
              tc.topic.errors.add(:base, "failed to remove collection")
              tc.check_result(false)
            end
          end
        end

        # plugin.add_model_callback(:topic, :after_commit) do
        #   is_collection = topic.custom_fields[Collections::IS_COLLECTION]
        #   collection_obj = topic.custom_fields[Collections::COLLECTION]

        #   return unless !is_collection && collection_obj.present?
        #   return unless is_collection && collection_obj.nil?

        #   # TODO: add StaffActionLogger

        #   if (!is_collection && collection_obj.present?)
        #     topic.custom_fields[Collections::COLLECTION] = nil
        #     topic.save_custom_fields
        #   end

        #   if (is_collection && collection_obj.nil?)
        #     # need to create collection object
        #     collection_obj = ::Collections::CollectionIndexTopicParser.new(topic.cooked).sections
        #     topic.custom_fields[Collections::COLLECTION] = collection_obj
        #     topic.save_custom_fields
        #   end
        # end
      end
    end
  end
end