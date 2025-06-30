# frozen_string_literal: true

module ::Collections
  class CollectionsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    requires_login except: %i[show test]
    before_action :ensure_collection_exists, only: %i[show destroy update]

    def items_params
      params.permit(items: %i[id name icon url position is_section_header _destroy])["items"]
    end

    def collection_params
      params.permit(:id, :title, :desc, :is_single_topic, :maintainer_ids, maintainer_ids: [])
    end

    def ensure_collection_exists
      @collection = Collections::Collection.find_by(id: params[:id])
      raise Discourse::NotFound unless @collection
    end

    def create
      collection =
        Collections::Collection.new(
          collection_params.merge(collection_items_attributes: items_params),
        )
      user_id = params.permit(:user_id)[:user_id]

      if collection.is_single_topic
        topic_id = params.require(:topic_id)
        topic = Topic.find(topic_id)
        if Collections::CollectionHandler.topic_has_subcollection?(topic_id)
          return(
            render_json_error I18n.t("collections.errors.subcollection_already_exists"), status: 409
          )
        end

        if user_id && User.exists?(user_id)
          collection.user_id = user_id
        else
          collection.user_id = topic.user_id
        end

        raise Discourse::InvalidAccess unless guardian.can_create_collection_for_topic?(topic)
        collection.transaction do
          collection.save!
          Collections::CollectionHandler.attach_subcollection_to_topic(topic, collection)
        end
      else
        items = collection.collection_items
        items
          .filter_map { |item| Topic.find_by(id: item.topic_id) if item.topic_id }
          .each do |t|
            raise Discourse::InvalidAccess unless guardian.can_create_collection_item?(t)
          end
        if user_id && User.exists?(user_id)
          collection.user_id = user_id
        else
          firstTopicItem = items.detect { |item| item.topic_id.present? }
          user_id = Topic.where(id: firstTopicItem.topic_id).pick(:user_id)
        end
        collection.user_id = user_id || current_user.id
        collection.transaction { collection.save! }
      end

      push_messagebus_event collection

      render_serialized(
        collection,
        ::Collections::CollectionSerializer,
        { scope: guardian, root: false },
      )
    rescue Discourse::InvalidAccess
      render json: failed_json, status: 403
    rescue ActiveRecord::RecordInvalid
      render json: { errors: collection.errors }, status: 422
    end

    def show
      render_serialized(
        @collection,
        ::Collections::CollectionSerializer,
        { scope: guardian, root: false },
      )
    end

    def update
      raise Discourse::InvalidAccess unless guardian.can_edit?(@collection)
      user_id = params.permit(:user_id)[:user_id]

      @collection.assign_attributes(
        collection_params.merge(collection_items_attributes: items_params),
      )
      unless @collection.is_single_topic
        # If the item is marked for destruction or its URL has changed, we need to check if the user has perms

        items = @collection.collection_items
        items
          .filter { |item| item.marked_for_destruction? }
          .each do |item|
            raise Discourse::InvalidAccess unless guardian.can_delete_collection_item?(item)
          end

        items
          .filter { |item| item.url_changed? }
          .each do |item|
            raise Discourse::InvalidAccess unless guardian.can_edit_collection_item?(item)
          end

        items
          .filter { |item| item.topic_id.present? && item.new_record? }
          .each do |item|
            raise Discourse::InvalidAccess unless guardian.can_create_collection_item?(item)
          end
      end

      @collection.user_id = user_id if user_id && User.exists?(user_id)

      @collection.save!

      push_messagebus_event @collection

      render_serialized(
        @collection.reload,
        ::Collections::CollectionSerializer,
        { scope: guardian, root: false },
      )
    rescue Discourse::InvalidAccess
      render json: failed_json, status: 403
    rescue ActiveRecord::RecordInvalid
      render json: { errors: collection.errors }, status: 422
    end

    def destroy
      raise Discourse::InvalidAccess unless guardian.can_delete?(@collection)
      @collection.destroy!

      push_messagebus_event @collection

      render json: success_json
    rescue Discourse::InvalidAccess
      render json: failed_json, status: 403
    rescue ActiveRecord::RecordNotDestroyed
      render json: { errors: @collection.errors }, status: 500
    end

    private

    def push_messagebus_event(collection)
      items = collection.collection_items
      items
        .filter do |item|
          item.url_changed? && ::Collections::Url.extract_topic_id_from_url(item.url_was)
        end
        .each do |item|
          topic_id = ::Collections::Url.extract_topic_id_from_url(item.url_was)
          MessageBus.publish("/topic/#{topic_id}", type: "collection_updated")
        end
      items
        .filter { |item| item.topic_id.present? }
        .each { |item| MessageBus.publish("/topic/#{item.topic_id}", type: "collection_updated") }
      if collection.is_single_topic
        topic_id =
          TopicCustomField.where(name: Collections::SUBCOLLECTION_ID, value: collection.id).pick(
            :topic_id,
          )
        MessageBus.publish("/topic/#{topic_id}", type: "collection_updated")
      end
    end
  end
end
