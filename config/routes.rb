# frozen_string_literal: true

Collections::Engine.routes.draw do
  post "collections/test" => "collections#test", :format => :json
  resources :collections, only: %i[create show update destroy], defaults: { format: :json }
end

Discourse::Application.routes.draw { mount ::Collections::Engine, at: "/" }
