import { withPluginApi } from "discourse/lib/plugin-api";
import TopicCollectionModal from "../components/topic-collection-modal";

function initializeAddCollectionFeaturesToTopic(api) {
  api.addPostMenuButton(
    "add-to-collection",
    (attrs, state, siteSettings, settings, currentUser) => {
      // TODO: add additional checks for staff, TL, etc.
      if (!attrs.yours || attrs.post_number !== 1) {
        return null;
      }
      console.log(attrs, state, siteSettings, settings, currentUser);
      return {
        action: ({ post }) => {
          api.container.lookup("service:modal").show(TopicCollectionModal, {
            model: {
              post,
            },
          });
        },
        icon: "plus-circle",
        className: "add-to-collection",
        title: "discourse_collections.add_to_collection",
        position: "second-last-hidden",
      };
    }
  );
}

export default {
  name: "collections-to-topic",
  initialize() {
    // This initializer is used to add collection features to the topic
    withPluginApi("1.37.0", initializeAddCollectionFeaturesToTopic);
  },
};
