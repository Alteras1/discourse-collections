import { withPluginApi } from "discourse/lib/plugin-api";
import CollectionPostMenuButton from "../components/collection-post-menu-button";
import sidebarPanelClassBuilder from "../lib/collection-sidebar-panel";

export default {
  name: "collections",
  initialize(container) {
    console.log(container.lookup("service:collection-sidebar"));

    withPluginApi("2.0.0", (api) => {
      api.addSidebarPanel(sidebarPanelClassBuilder);
      api.registerCustomPostMessageCallback(
        "collection_updated",
        (topicController, message) => {
          console.log("collection_updated", message);
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
          dag.add("collection", CollectionPostMenuButton, {
            before: ["delete", "showMore"],
            after: ["bookmark", "edit"],
          });
        }
      );
    });
  },
};
