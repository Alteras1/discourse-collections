# frozen_string_literal: true

DiscourseCollections::Engine.routes.draw do
  get "collections" => "collections#get_all_collections"
  scope "/collections", format: :json do
    get ":id" => "collections#get_collection"
    post "new" => "collections#new"
  end
end

Discourse::Application.routes.draw { mount ::DiscourseCollections::Engine, at: "/" }
