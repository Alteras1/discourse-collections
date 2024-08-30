# frozen_string_literal: true

DiscourseCollections::Engine.routes.draw do
  get "all" => "collections#get_all_collections"
  get "examples" => "collections#index"
end

Discourse::Application.routes.draw { mount ::DiscourseCollections::Engine, at: "/collections" }
