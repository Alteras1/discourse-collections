# frozen_string_literal: true

module ::Collections
  class CollectionsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    requires_login except: %i[read preview]
    before_action :ensure_topic_exists, only: %i[read create destroy bind unbind]
    before_action :ensure_index_exists, only: %i[bind unbind]

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
      raise Discourse::InvalidParameters, I18n.t("collections.errors.preview_params_missing") unless cooked || raw
      if cooked
        render_json_dump(Collections::CollectionHandler.preview_collection(cooked))
      else
        render_json_dump(Collections::CollectionHandler.preview_collection(PrettyText.cook(raw, {})))
      end
    end

    def read
      collection = Collections::Collection.find_by_topic_id(@topic.id)
      raise Discourse::NotFound unless collection
      render_serialized(collection, Collections::CollectionSerializer, {scope: guardian, root: false})
    end

    def create
      raise Discourse::InvalidAccess unless guardian.change_collection_status_of_topic?(@topic)
      success = Collections::CollectionHandler.create_collection_for_topic(@topic)
      # TODO add response
      
      return render_json_error I18n.t("collections.errors.create_failed"), status: 500 unless success
      render_serialized(Collections::Collection.find_by_topic_id(@topic.id), Collections::CollectionSerializer, {scope: guardian, root: false})
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

    def bind
      raise Discourse::InvalidAccess unless guardian.change_collection_index_of_topic?(@topic)

      @index
      @topic
      @collection

      # TODO check index

      # TODO add response

    end

    def unbind
      raise Discourse::InvalidAccess unless guardian.change_collection_index_of_topic?(@topic)
      @index
      @topic
      @collection

      # TODO check index

      # TODO add response

    end
  end
end
