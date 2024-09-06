# frozen_string_literal: true

DiscourseCollections::Engine.routes.draw do
  get "collections" => "collections#get_all_collections"
  post "collections" => "collections#new", format: :json
  scope "/collections", format: :json do
    get ":id" => "collections#get_collection"
  end

  # dummy routes to allow fallthrough to ember
  get "new-collection" => "collections#show"
end

Discourse::Application.routes.draw { mount ::DiscourseCollections::Engine, at: "/" }
