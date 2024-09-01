# frozen_string_literal: true

DiscourseCollections::Engine.routes.draw do
  get "all" => "collections#get_all_collections"
  get ":id" => "collections#get_collection"
end

Discourse::Application.routes.draw { mount ::DiscourseCollections::Engine, at: "/collections" }
