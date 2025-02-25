# frozen_string_literal: true

DiscourseCollections::Engine.routes.draw do
  get "/examples" => "examples#index"
  # define routes here
end

Discourse::Application.routes.draw { mount ::DiscourseCollections::Engine, at: "collections" }
