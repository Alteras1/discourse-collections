# frozen_string_literal: true

module ::DiscourseCollections
  class CollectionsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    def get_all_collections
      Rails.logger.info("get_all_collections")
      render json: {collections: serialize_data(Collection.all, CollectionSerializer)}
    end

    def get_collection
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
