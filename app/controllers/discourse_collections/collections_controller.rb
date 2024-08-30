# frozen_string_literal: true

module ::DiscourseCollections
  class CollectionsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    def index
      render json: { hello: "world" }
    end

    def get_all_collections
      Rails.logger.info("get_all_collections")
      render json: Collection.all
    end
  end
end
