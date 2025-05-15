# frozen_string_literal: true

module ::Collections
  class CollectionsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    requires_login except: %i[read preview test]
    before_action :ensure_topic_exists, only: %i[read create destroy bind unbind]
    before_action :ensure_index_exists, only: %i[bind unbind]

    def test
      collection =
        Collections::Collection.new(
          collection_params.merge(collection_items_attributes: items_params),
        )
      p collection
      debugger

      # TODO: check if the collection has at least one topic

      render json: collection.to_json
    end

    def items_params
      params.permit(items: %i[id name icon url position is_section_header _destroy])["items"]
    end

    def collection_params
      params.permit(:id, :is_single_topic, maintainer_ids: []).merge!(user: current_user)
    end

    def ensure_topic_exists
      @topic = Topic.find_by(id: params[:topic_id])
      raise Discourse::NotFound unless @topic
      guardian.ensure_can_see!(@topic)
    end

    def ensure_index_exists
      @index = Topic.find_by(id: params[:index_id])
      raise Discourse::NotFound unless @index
      @collection = Collections::Collection.find_by_topic_id(params[:index_id])
      raise Discourse::NotFound unless @collection
    end

    def preview
      cooked = params[:cooked]
      raw = params[:raw]
      unless cooked || raw
        raise Discourse::InvalidParameters, I18n.t("collections.errors.preview_params_missing")
      end
      if cooked
        render_json_dump(Collections::CollectionHandler.preview_collection(cooked))
      else
        render_json_dump(
          Collections::CollectionHandler.preview_collection(PrettyText.cook(raw, {})),
        )
      end
    end

    def read
      collection = Collections::Collection.find_by_topic_id(@topic.id)
      raise Discourse::NotFound unless collection
      render_serialized(
        collection,
        Collections::CollectionIndexSerializer,
        { scope: guardian, root: false },
      )
    end

    def create
      raise Discourse::InvalidAccess unless guardian.change_collection_status_of_topic?(@topic)
      success = Collections::CollectionHandler.create_collection_for_topic(@topic)

      unless success
        return render_json_error I18n.t("collections.errors.create_failed"), status: 500
      end
      render_serialized(
        Collections::Collection.find_by_topic_id(@topic.id),
        Collections::CollectionIndexSerializer,
        { scope: guardian, root: false },
      )
    end

    def destroy
      raise Discourse::InvalidAccess unless guardian.change_collection_status_of_topic?(@topic)
      collection = Collections::Collection.find_by_topic_id(@topic.id)
      raise Discourse::NotFound unless collection
      success = false
      Collections::Collection.transaction do
        success = collection.destroy
        @topic.custom_fields.delete(Collections::IS_COLLECTION.to_s)
        @topic.save_custom_fields
      end

      if success
        render body: nil, status: 200
      else
        render_json_error I18n.t("collections.errors.destroy_failed"), status: 500
      end
    end

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
