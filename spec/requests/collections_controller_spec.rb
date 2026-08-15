# frozen_string_literal: true

RSpec.describe Collections::CollectionsController do
  fab!(:user)
  fab!(:other_user) { Fabricate(:user) }
  fab!(:maintainer) { Fabricate(:user) }
  fab!(:other_maintainer) { Fabricate(:user) }

  fab!(:create_topic) { Fabricate(:topic, user: user) }
  fab!(:other_users_topic) { Fabricate(:topic, user: other_user) }
  fab!(:collection_topic) { Fabricate(:topic, user: user) }
  fab!(:maintainer_topic) { Fabricate(:topic, user: maintainer) }
  fab!(:other_maintainer_topic) { Fabricate(:topic, user: other_maintainer) }

  fab!(:collection) do
    Collections::Collection.create!(
      user: user,
      maintainer_ids: [maintainer.id, other_maintainer.id],
      is_single_topic: false,
      collection_items_attributes: [
        {
          name: collection_topic.title,
          url: collection_topic.url,
          position: 0,
          is_section_header: false,
        },
      ],
    )
  end

  describe "#create" do
    before { sign_in(user) }

    it "allows an eligible topic owner to create a subcollection" do
      SiteSetting.subcollection_by_topic_owner_allow_groups = Group::AUTO_GROUPS[:trust_level_1]
      user.change_trust_level!(TrustLevel[1])

      expect do
        post "/collections.json",
             params: {
               topic_id: create_topic.id,
               is_single_topic: true,
               maintainer_ids: [],
               items: [
                 {
                   name: "Related resource",
                   url: "https://example.com/resource",
                   position: 0,
                   is_section_header: false,
                 },
               ],
             },
             as: :json
      end.to change(Collections::Collection, :count).by(1)

      expect(response.status).to eq(200)
      expect(Collections::Collection.order(:id).last).to be_is_single_topic
    end

    it "forbids a topic owner outside the allowed subcollection groups" do
      SiteSetting.subcollection_by_topic_owner_allow_groups = Group::AUTO_GROUPS[:trust_level_4]

      expect do
        post "/collections.json",
             params: {
               topic_id: create_topic.id,
               is_single_topic: true,
               maintainer_ids: [],
               items: [
                 {
                   name: "Related resource",
                   url: "https://example.com/resource",
                   position: 0,
                   is_section_header: false,
                 },
               ],
             },
             as: :json
      end.not_to change(Collections::Collection, :count)

      expect(response.status).to eq(403)
    end

    it "lets globally allowed groups create a subcollection on another user's topic" do
      sign_in(Fabricate(:admin))

      expect do
        post "/collections.json",
             params: {
               topic_id: other_users_topic.id,
               is_single_topic: true,
               maintainer_ids: [],
               items: [
                 {
                   name: "Related resource",
                   url: "https://example.com/resource",
                   position: 0,
                   is_section_header: false,
                 },
               ],
             },
             as: :json
      end.to change(Collections::Collection, :count).by(1)

      expect(response.status).to eq(200)
    end

    it "creates a collection with the current user's topic", :aggregate_failures do
      expect do
        post "/collections.json",
             params: {
               is_single_topic: false,
               maintainer_ids: [],
               items: [
                 {
                   name: create_topic.title,
                   url: create_topic.url,
                   position: 0,
                   is_section_header: false,
                 },
               ],
             },
             as: :json
      end.to change(Collections::Collection, :count).by(1)

      created_collection = Collections::Collection.order(:id).last

      expect(response.status).to eq(200)
      expect(created_collection.user_id).to eq(user.id)
      expect(created_collection.collection_items.map(&:topic_id)).to contain_exactly(
        create_topic.id,
      )
    end

    it "returns forbidden when the payload includes another user's topic" do
      expect do
        post "/collections.json",
             params: {
               is_single_topic: false,
               maintainer_ids: [],
               items: [
                 {
                   name: other_users_topic.title,
                   url: other_users_topic.url,
                   position: 0,
                   is_section_header: false,
                 },
               ],
             },
             as: :json
      end.not_to change(Collections::Collection, :count)

      expect(response.status).to eq(403)
    end

    it "returns validation errors for an invalid payload" do
      post "/collections.json",
           params: {
             is_single_topic: false,
             maintainer_ids: [],
             items: [{ name: "", url: "", position: 0, is_section_header: false }],
           },
           as: :json

      expect(response.status).to eq(422)
      expect(response.parsed_body["errors"]).to be_present
    end

    it "stores all selected maintainers when creating a collection", :aggregate_failures do
      expect do
        post "/collections.json",
             params: {
               is_single_topic: false,
               maintainer_ids: [maintainer.id, other_maintainer.id],
               items: [
                 {
                   name: create_topic.title,
                   url: create_topic.url,
                   position: 0,
                   is_section_header: false,
                 },
               ],
             },
             as: :json
      end.to change(Collections::Collection, :count).by(1)

      created_collection = Collections::Collection.order(:id).last

      expect(response.status).to eq(200)
      expect(created_collection.maintainer_ids).to contain_exactly(
        maintainer.id,
        other_maintainer.id,
      )
    end
  end

  describe "#update" do
    it "allows a maintainer to add their own topic", :aggregate_failures do
      sign_in(maintainer)

      put "/collections/#{collection.id}.json",
          params: {
            user_id: user.id,
            is_single_topic: false,
            maintainer_ids: [maintainer.id, other_maintainer.id],
            items: [
              {
                id: collection.collection_items.first.id,
                name: collection.collection_items.first.name,
                url: collection.collection_items.first.url,
                position: 0,
                is_section_header: false,
              },
              {
                name: maintainer_topic.title,
                url: maintainer_topic.url,
                position: 1,
                is_section_header: false,
              },
            ],
          },
          as: :json

      expect(response.status).to eq(200)
      expect(collection.reload.collection_items.map(&:topic_id)).to contain_exactly(
        collection_topic.id,
        maintainer_topic.id,
      )
    end

    it "returns forbidden when a maintainer adds another maintainer's topic" do
      sign_in(maintainer)

      put "/collections/#{collection.id}.json",
          params: {
            user_id: user.id,
            is_single_topic: false,
            maintainer_ids: [maintainer.id, other_maintainer.id],
            items: [
              {
                id: collection.collection_items.first.id,
                name: collection.collection_items.first.name,
                url: collection.collection_items.first.url,
                position: 0,
                is_section_header: false,
              },
              {
                name: other_maintainer_topic.title,
                url: other_maintainer_topic.url,
                position: 1,
                is_section_header: false,
              },
            ],
          },
          as: :json

      expect(response.status).to eq(403)
      expect(collection.reload.collection_items.map(&:topic_id)).to contain_exactly(
        collection_topic.id,
      )
    end

    it "allows each maintainer to manage the collection", :aggregate_failures do
      sign_in(maintainer)

      put "/collections/#{collection.id}.json",
          params: {
            user_id: user.id,
            title: "Maintainer A update",
            is_single_topic: false,
            maintainer_ids: [maintainer.id, other_maintainer.id],
            items: [
              {
                id: collection.collection_items.first.id,
                name: collection.collection_items.first.name,
                url: collection.collection_items.first.url,
                position: 0,
                is_section_header: false,
              },
            ],
          },
          as: :json

      expect(response.status).to eq(200)
      expect(collection.reload.title).to eq("Maintainer A update")

      sign_in(other_maintainer)

      put "/collections/#{collection.id}.json",
          params: {
            user_id: user.id,
            title: "Maintainer B update",
            is_single_topic: false,
            maintainer_ids: [maintainer.id, other_maintainer.id],
            items: [
              {
                id: collection.collection_items.first.id,
                name: collection.collection_items.first.name,
                url: collection.collection_items.first.url,
                position: 0,
                is_section_header: false,
              },
            ],
          },
          as: :json

      expect(response.status).to eq(200)
      expect(collection.reload.title).to eq("Maintainer B update")
    end

    it "returns validation errors for an invalid payload" do
      sign_in(user)

      put "/collections/#{collection.id}.json",
          params: {
            user_id: user.id,
            is_single_topic: false,
            maintainer_ids: [maintainer.id, other_maintainer.id],
            items: [
              {
                id: collection.collection_items.first.id,
                name: collection.collection_items.first.name,
                url: collection.collection_items.first.url,
                position: 0,
                is_section_header: false,
                _destroy: "1",
              },
            ],
          },
          as: :json

      expect(response.status).to eq(422)
      expect(response.parsed_body["errors"]).to be_present
    end

    it "rejects maintainer list updates by maintainers", :aggregate_failures do
      sign_in(maintainer)

      put "/collections/#{collection.id}.json",
          params: {
            user_id: user.id,
            title: "Maintainer update",
            is_single_topic: false,
            maintainer_ids: [maintainer.id],
            items: [
              {
                id: collection.collection_items.first.id,
                name: collection.collection_items.first.name,
                url: collection.collection_items.first.url,
                position: 0,
                is_section_header: false,
              },
            ],
          },
          as: :json

      expect(response.status).to eq(403)
      expect(collection.reload.maintainer_ids).to contain_exactly(
        maintainer.id,
        other_maintainer.id,
      )
    end

    it "allows the owner to update the maintainer list", :aggregate_failures do
      sign_in(user)

      put "/collections/#{collection.id}.json",
          params: {
            user_id: user.id,
            title: "Owner update",
            is_single_topic: false,
            maintainer_ids: [maintainer.id],
            items: [
              {
                id: collection.collection_items.first.id,
                name: collection.collection_items.first.name,
                url: collection.collection_items.first.url,
                position: 0,
                is_section_header: false,
              },
            ],
          },
          as: :json

      expect(response.status).to eq(200)
      expect(collection.reload.maintainer_ids).to contain_exactly(maintainer.id)
    end
  end
end
