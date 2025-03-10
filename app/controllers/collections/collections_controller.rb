# frozen_string_literal: true

module ::Collections
  class CollectionsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    requires_login except: %i[read, preview]
    before_action :ensure_topic_exists, only: %i[read, create, destroy, bind, unbind]
    before_action :ensure_index_exists, only: %i[bind, unbind]

    def ensure_topic_exists
      @topic = Topic.find(params[:topic_id])
      raise Discourse::NotFound unless @topic
    end

    def ensure_index_exists
      @index = Topic.find(params[:index_id])
      raise Discourse::NotFound unless @index
      @collection = Collections::Collection.find_by_topic_id(params[:index_id])
      raise Discourse::NotFound unless @collection
    end

    def preview
      cooked = params[:cooked]
      raw = params[:raw]
      raise Discourse::InvalidParameters, "Must have 'cooked' or 'raw' field" unless cooked || raw
      if cooked
        render_json_dump(Collections::CollectionHandler.preview_collection(cooked))
      else
        render_json_dump(Collections::CollectionHandler.preview_collection(PrettyText.cook(raw, {})))
      end
    end

    def read
      collection = Collections::Collection.find_by_topic_id(@topic.id)
      raise Discourse::NotFound unless collection
      Collections::CollectionSerializer.new(collection, scope: self, root: false).to_json
    end

    def create
      raise Discourse::InvalidAccess unless current_user.can_change_collection_status?(@topic)
      success = Collections::CollectionHandler.create_collection_for_topic(@topic)
      # TODO add response
      
    end

    def destroy
      raise Discourse::InvalidAccess unless current_user.can_change_collection_status?(@topic)
      collection = Collections::Collection.find_by_topic_id(@topic.id)
      raise Discourse::NotFound, "collection not found" unless collection
      success = collection.destroy

      # TODO add response
    end

    def bind
      raise Discourse::InvalidAccess unless current_user.can_change_collection_index_of_topic?(@topic)

      @index
      @topic
      @collection

      # TODO check index

      # TODO add response

    end

    def unbind
      raise Discourse::InvalidAccess unless current_user.can_change_collection_index_of_topic?(@topic)
      @index
      @topic
      @collection

      # TODO check index

      # TODO add response

    end
  end
end
