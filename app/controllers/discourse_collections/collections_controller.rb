# frozen_string_literal: true

module ::DiscourseCollections
  class CollectionsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    requires_login only: [:new]

    def show
      guardian.ensure_can_see!(@collection)

      render_serialized(@collection, CollectionSerializer)
    end

    def get_all_collections
      respond_to do |format|
        format.html { render layout: false }
        format.json do
          collections = Collection.all
          if collections.empty?
            render json: {collections: []}
          end
          render json: {collections: serialize_data(Collection.all, CollectionSerializer)}
        end
      end
    end

    def search
      # TODO: consider implementing a more advanced search later (e.g. via tsvector)

      results = Collections.where("title ILIKE ?", "%#{params[:q]}%")
      # collections = Collection.search(params[:q])
      # render json: {collections: serialize_data(collections, CollectionSerializer)}
    end

    def get_collection
      # TODO: see categories#categories_and_latest for how to do a HTML only response in the event on no JS
      # to basically treat it as a top level route
      Rails.logger.info("collection #{params[:id]}")
      begin
        render json: CollectionSerializer.new(Collection.find(params[:id]), scope: guardian, root: false)
        # render_serialized(Collection.find(params[:id]), CollectionSerializer)
      rescue ActiveRecord::RecordNotFound => e
        render_json_error e.message
      end
    end

    def create
      title = params.require(:title)
      Rails.logger.info("new collection: '#{title}' for #{current_user.id}, with desc #{params[:description]}")

      begin
        collection = Collection.new(title: title, description: params[:description], user: current_user)
        collection.save
        render json: CollectionSerializer.new(collection, scope: guardian)
      rescue DiscourseCollections::Error => e
        render_json_error e.message
      end
    end

    def fetch_collection
      @collection = Collection.find(params[:id])
      raise Discourse::NotFound if @collection.blank?
    end
  end
end
