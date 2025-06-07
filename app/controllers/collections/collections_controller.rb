# frozen_string_literal: true

module ::Collections
  class CollectionsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    requires_login except: %i[show test]
    before_action :ensure_collection_exists, only: %i[show destroy update]
    # before_action :ensure_topic_exists, only: %i[read create destroy bind unbind]
    # before_action :ensure_index_exists, only: %i[bind unbind]

    def items_params
      params.permit(items: %i[id name icon url position is_section_header _destroy])["items"]
    end

    def collection_params
      params.permit(:id, :is_single_topic, :maintainer_ids, maintainer_ids: []).merge!(
        user: current_user,
      )
    end

    def ensure_collection_exists
      @collection = Collections::Collection.find_by(id: params[:id])
      raise Discourse::NotFound unless @collection
    end

    def test
      collection =
        Collections::Collection.new(
          collection_params.merge(collection_items_attributes: items_params),
        )
      p collection
      # debugger

      render_serialized(
        collection,
        ::Collections::CollectionSerializer,
        { scope: guardian, root: false },
      )
    end

    def create
      collection =
        Collections::Collection.new(
          collection_params.merge(collection_items_attributes: items_params),
        )

      # TODO: ADD GUARDS

      if collection.is_single_topic
        topic_id = params.require(:topic_id)
        if Collections::CollectionHandler.topic_has_subcollection?(topic_id)
          return(
            render_json_error I18n.t("collections.errors.subcollection_already_exists"), status: 409
          )
        end

        topic = Topic.find(topic_id)
        collection.transaction do
          collection.save!
          Collections::CollectionHandler.attach_subcollection_to_topic(topic, collection)
        end
      else
        collection.transaction { collection.save! }
      end

      render_serialized(
        collection,
        ::Collections::CollectionSerializer,
        { scope: guardian, root: false },
      )
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
      # TODO: ADD GUARDS!
      # TODO: ADD GUARDS FOR INDIVIUDAL DELETE!!!!
      @collection.update!(collection_params.merge(collection_items_attributes: items_params))
    rescue ActiveRecord::RecordInvalid
      render json: { errors: collection.errors }, status: 422
    end

    def destroy
      # TODO: ADD GUARDS

      guardian.can_delete?(@collection)
      @collection.destroy!
      render json: success_json
    rescue Discourse::InvalidAccess
      render json: failed_json, status: 403
    rescue ActiveRecord::RecordNotDestroyed
      render json: { errors: @collection.errors }, status: 500
    end

    # def destroy
    #   raise Discourse::InvalidAccess unless guardian.change_collection_status_of_topic?(@topic)
    #   collection = Collections::Collection.find_by_topic_id(@topic.id)
    #   raise Discourse::NotFound unless collection
    #   success = false
    #   Collections::Collection.transaction do
    #     success = collection.destroy
    #     @topic.custom_fields.delete(Collections::IS_COLLECTION.to_s)
    #     @topic.save_custom_fields
    #   end

    #   if success
    #     render body: nil, status: 200
    #   else
    #     render_json_error I18n.t("collections.errors.destroy_failed"), status: 500
    #   end
    # end

    # def bind
    #   raise Discourse::InvalidAccess unless guardian.change_collection_index_of_topic?(@topic)

    #   force = params[:force]
    #   if !@collection.bounded_topics_based_on_payload.include?(@topic.id) && !force
    #     return(
    #       render_json_error I18n.t("collections.errors.bind_topic_not_in_collection"), status: 406
    #     )
    #   end

    #   if existing_col_id = @topic.custom_fields[Collections::COLLECTION_INDEX]
    #     # already in a collection
    #     return render body: nil, status: 200 if existing_col_id == @index.id
    #     if existing_col_id && !force
    #       return(
    #         render_json_error I18n.t("collections.errors.bind_topic_in_another_collection"),
    #                           status: 406
    #       )
    #     end
    #   end

    #   @topic.custom_fields[Collections::COLLECTION_INDEX] = @index.id
    #   @topic.save_custom_fields

    #   MessageBus.publish("/topic/#{@topic.id}", type: "collection_updated")
    #   render body: nil, status: 200
    # end

    # def unbind
    #   raise Discourse::InvalidAccess unless guardian.change_collection_index_of_topic?(@topic)

    #   if @topic.custom_fields[Collections::COLLECTION_INDEX] != @index.id
    #     return(
    #       render_json_error I18n.t("collections.errors.unbind_topic_not_in_collection"), status: 406
    #     )
    #   end

    #   TopicCustomField.delete_by(
    #     name: Collections::COLLECTION_INDEX,
    #     value: @index.id,
    #     topic_id: @topic.id,
    #   )
    #   MessageBus.publish("/topic/#{@topic.id}", type: "collection_updated")

    #   render body: nil, status: 200
    # end
  end
end
