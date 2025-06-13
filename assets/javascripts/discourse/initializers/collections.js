import { withPluginApi } from "discourse/lib/plugin-api";
import CollectionPostMenuButton from "../components/collection-post-menu-button";
import CollectionSidebarHeader from "../components/collection-sidebar-header";
import sidebarPanelClassBuilder from "../lib/collection-sidebar-panel";
/** @import CollectionSidebar from '../services/collection-sidebar.js' */

export default {
  name: "collections",
  initialize(container) {
    /** @type {CollectionSidebar} */
    const collectionSidebar = container.lookup("service:collection-sidebar");
    const appEvents = container.lookup("service:app-events");

    withPluginApi("2.0.0", (api) => {
      api.addSidebarPanel(sidebarPanelClassBuilder);
      api.renderInOutlet("before-sidebar-sections", CollectionSidebarHeader);

      api.registerCustomPostMessageCallback(
        "collection_updated",
        (topicController) => {
          const topic = topicController.model;
          topic.reload().then(() => {
            topicController.send(
              "postChangedRoute",
              topic.get("post_number") || 1
            );
            topicController.appEvents.trigger("header:update-topic", topic);

            appEvents.trigger("collection:updated", {
              topic,
              collection: topic.get("collection"),
              subcollection: topic.get("subcollection"),
            });
            collectionSidebar.maybeDisplaySidebar();
          });
        }
      );

      api.registerValueTransformer(
        "post-menu-buttons",
        ({ value: dag, context: { post, state } }) => {
          if (!state.currentUser) {
            return;
          }
          if (post.post_number !== 1) {
            return;
          }
          if (
            post.topic.can_create_collection ||
            post.topic.collection?.can_edit_collection ||
            post.topic.subcollection?.can_edit_collection
          ) {
            dag.add("collection", CollectionPostMenuButton, {
              before: ["delete", "showMore"],
              after: ["bookmark", "edit"],
            });
          }
        }
      );
    });
  },
};
