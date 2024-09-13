# frozen_string_literal: true

module ::DiscourseCollections
  class CollectionItemsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    requires_login only: [:create, :destroy]

    # POST /collections/:collection_id/items
    # Add a topic/post to a collection
    # @param collection_id [Integer] the id of the collection
    # @param collectable_type ['Topic', 'Post'] the type of the collectable (topic or post)
    # @param collectable_id [Integer] the id of the collectable
    # @param name [String] the name of the collection item (optional)
    def create
      params.require(%i[collection_id collectable_type collectable_id])
      # @type [Integer]
      collection_id = params[:collection_id]
      # @type ['Topic', 'Post']
      collectable_type = params[:collectable_type]
      # @type [Integer]
      collectable_id = params[:collectable_id]
      # @type [String]
      name = params[:name]

      Rails.logger.info("new collection item: '#{collection_id}' for #{current_user.id}, with collectable #{collectable_id}")

      # TODO: validations for user permissions

      begin
        collection = Collection.find(collection_id)
        raise Discourse::NotFound if collection.blank?

        # TODO: check if this is even necessary, or if i can let the model level validations handle this
        # @type [Topic, Post]
        collectable = nil
        if collectable_type == 'Topic'
          topic = Topic.find(collectable_id)
          raise Discourse::NotFound if topic.blank?
          collectable = topic
          name ||= topic.title
        elsif collectable_type == 'Post'
          post = Post.find(collectable_id)
          raise Discourse::NotFound if post.blank?
          collectable = post
          raise Discourse::InvalidParameters if name.blank?
        end

        if collectable.blank?
          raise Discourse::NotFound
        end

        collection_item = CollectionItem.new(collection: collection, collectable: collectable, name: name)
        collection_item.save
        render json: CollectionItemSerializer.new(collection_item, scope: guardian)
      rescue DiscourseCollections::Error => e
        render_json_error e.message
      end
    end

    # DELETE /collections/:collection_id/items/:collection_item_id
    # Remove a topic/post from a collection
    # @param collection_id [Integer] the id of the collection
    # @param collection_item_id [Integer] the id of the collection item
    def destroy
      collection_id = params.require(:collection_id)
      collection_item_id = params.require(:collection_item_id)
      Rails.logger.info("delete collection item: '#{collection_item_id}' for #{current_user.id}, with collectable #{collection_id}")

      collection_item = CollectionItem.find_by(collection_id: collection_id, id: collection_item_id)
      raise Discourse::NotFound if collection_item.blank?

      collection_item.destroy
      render json: success_json
    end
  end
end