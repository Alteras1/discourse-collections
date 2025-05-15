# frozen_string_literal: true

Collections::Engine.routes.draw do
  post "test" => "collections#test", :format => :json
  post "preview" => "collections#preview", :format => :json
  # get ":topic_id" => "collections#read", :format => :json
  # post ":topic_id" => "collections#create", :format => :json
  # delete ":topic_id" => "collections#destroy", :format => :json
  # post ":index_id/:topic_id" => "collections#bind", :format => :json
  # delete ":index_id/:topic_id" => "collections#unbind", :format => :json
end

Discourse::Application.routes.draw { mount ::Collections::Engine, at: "collections" }
