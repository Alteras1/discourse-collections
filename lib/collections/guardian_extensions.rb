# frozen_string_literal: true

module ::Collections
  module GuardianExtensions
    def can_create_collection_for_topic?(topic)
      if SiteSetting.collection_by_topic_owner &&
           current_user.in_any_groups?(SiteSetting.collection_by_topic_owner_allow_groups)
        return can_edit_topic?(topic)
      end
      current_user.in_any_groups?(SiteSetting.collection_modification_by_allowed_groups_map)
    end

    def can_edit_collection?(collection)
      return true if collection.user_id == current_user.id
      return true if collection.maintainer_ids.include?(current_user.id)
      current_user.in_any_groups?(SiteSetting.collection_modification_by_allowed_groups_map)
    end

    def can_delete_collection?(collection)
      if SiteSetting.collection_by_topic_owner &&
           current_user.in_any_groups?(SiteSetting.collection_by_topic_owner_allow_groups)
        return collection.user_id == current_user.id
      end
      current_user.in_any_groups?(SiteSetting.collection_modification_by_allowed_groups_map)
    end

    # NOTE: collection_item logic is only relevant if the collection is not a single topic collection

    def can_create_collection_item?(collection_item)
      if current_user.in_any_groups?(SiteSetting.collection_modification_by_allowed_groups_map)
        return true
      end
      topic_id = collection_item.topic_id
      if topic_id.present?
        topic = Topic.find_by(id: topic_id)
        return(
          topic.present? && can_edit_topic?(topic) &&
            can_edit_collection(collection_item.collection)
        )
      end
      return true if can_create_collection?
      collection.maintainer_ids.include?(current_user.id)
    end

    def can_edit_collection_item?(collection_item)
      if current_user.in_any_groups?(SiteSetting.collection_modification_by_allowed_groups_map)
        return true
      end
      if current_user.id != collection_item.collection.user_id &&
           !collection_item.collection.maintainer_ids.include?(current_user.id)
        return false
      end

      if collection_item.url_changed?
        old_topic_id = ::Collections::Url.extract_topic_id_from_url(collection_item.url_was)
        new_topic_id = ::Collections::Url.extract_topic_id_from_url(collection_item.url)
        return true if old_topic_id == new_topic_id
        # treat as if this is two different operations. delete & create
        old_topic = Topic.find_by(id: old_topic_id) if old_topic_id.present?
        new_topic = Topic.find_by(id: new_topic_id) if new_topic_id.present?

        error = false
        # delete
        if old_topic.present? && current_user.id != collection_item.collection.user_id
          # user is a maintainer, so check if they own the topic
          error ||= true if old_topic.user_id != current_user.id
          # collection owners or maintainers can delete the topic
        end
        # create
        if new_topic.present? && current_user.id != collection_item.collection.user_id
          # user is a maintainer, so check if they own the topic
          error ||= true if new_topic.user_id != current_user.id
          # collection owners or maintainers can create the topic
        end
        return false if error
      end

      true
    end

    def can_delete_collection_item?(collection_item)
      if current_user.in_any_groups?(SiteSetting.collection_modification_by_allowed_groups_map)
        return true
      end
      if current_user.id != collection_item.collection.user_id &&
           !collection_item.collection.maintainer_ids.include?(current_user.id)
        return false
      end

      topic_id = collection_item.topic_id
      if topic_id.present?
        topic = Topic.find_by(id: topic_id)
        return true if topic.nil?
        return true if topic.user_id == current_user.id # user is the topic owner (already validated maintainer/owner)
        return true if collection_item.collection.user_id == current_user.id
        return false
      end
      true
    end
  end
end
