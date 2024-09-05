# frozen_string_literal: true

module ::DiscourseCollections
  class CollectionsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    requires_login only: [:new]

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

    def get_collection
      # TODO: see categories#categories_and_latest for how to do a HTML only response in the event on no JS
      # to basically treat it as a top level route
      Rails.logger.info("collection #{params[:id]}")
      begin
        render json: CollectionSerializer.new(Collection.find(params[:id]), scope: guardian)
      rescue ActiveRecord::RecordNotFound => e
        render_json_error e.message
      end
    end

    def new
      title = params.require(:title)
      opt = params.permit(:description)
      Rails.logger.info("new collection: '#{title}' for #{current_user.id}, with desc #{opt[:description]}")

      begin
        collection = Collection.create(title: title, description: opt[:description], user: current_user)
        collection.save
        render json: CollectionSerializer.new(collection, scope: guardian)
      rescue DiscourseCollections::Error => e
        render_json_error e.message
      end
    end
  end
end
