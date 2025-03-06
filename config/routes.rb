# frozen_string_literal: true

Collections::Engine.routes.draw do
  root to: "collections#index", format: :json
  # define routes here
end

Discourse::Application.routes.draw { mount ::Collections::Engine, at: "/collections" }
