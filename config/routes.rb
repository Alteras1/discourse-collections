# frozen_string_literal: true

DiscourseCollections::Engine.routes.draw do
  get "collections" => "collections#get_all_collections"
  post "collections" => "collections#create", format: :json
  scope "/collections", format: :json do
    get ":id" => "collections#get_collection"
    post ":collection_id/items" => "collection_items#create"
    delete ":collection_id/items/:collection_item_id" => "collection_items#destroy"
  end

  # dummy routes to allow fallthrough to ember
  get "new-collection" => "collections#show"
end

Discourse::Application.routes.draw { mount ::DiscourseCollections::Engine, at: "/" }
