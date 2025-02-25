import { withPluginApi } from "discourse/lib/plugin-api";
import TopicCollectionModal from "../components/topic-collection-modal";

function initializeAddCollectionFeaturesToTopic(api) {
  // deprecated
  // [PLUGIN discourse-collections] Deprecation notice: `api.addPostMenuButton` has been deprecated. Use the value transformer `post-menu-buttons` instead. [deprecated since Discourse v3.4.0.beta3-dev] [deprecation id: discourse.post-menu-widget-overrides] [info: https://meta.discourse.org/t/341014]
  // api.addPostMenuButton(
  //   "add-to-collection",
  //   (attrs, state, siteSettings, settings, currentUser) => {
  //     // TODO: add additional checks for staff, TL, etc.
  //     if (!attrs.yours || attrs.post_number !== 1) {
  //       return null;
  //     }
  //     console.log(attrs, state, siteSettings, settings, currentUser);
  //     return {
  //       action: ({ post }) => {
  //         api.container.lookup("service:modal").show(TopicCollectionModal, {
  //           model: {
  //             post,
  //           },
  //         });
  //       },
  //       icon: "collections-library",
  //       className: "add-to-collection",
  //       title: "discourse_collections.add_to_collection",
  //       position: "second-last-hidden",
  //     };
  //   }
  // );
}

export default {
  name: "collections-to-topic",
  initialize() {
    // This initializer is used to add collection features to the topic
    withPluginApi("1.37.0", initializeAddCollectionFeaturesToTopic);
  },
};
