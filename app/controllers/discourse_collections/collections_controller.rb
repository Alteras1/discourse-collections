# frozen_string_literal: true

module ::DiscourseCollections
  class CollectionsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    def get_all_collections
      Rails.logger.info("get_all_collections")
      render json: {collections: serialize_data(Collection.all, CollectionSerializer)}
    end

    def get_collection
      Rails.logger.info("get_collection", params[:id])
      render json: CollectionSerializer.new(Collection.find(params[:id]), scope: guardian)
    end
  end
end
