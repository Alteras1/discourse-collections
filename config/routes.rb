# frozen_string_literal: true

Collections::Engine.routes.draw do
  get "collections" => "collections#index", format: :json
  # define routes here
end

Discourse::Application.routes.draw { mount ::Collections::Engine, at: "/" }
