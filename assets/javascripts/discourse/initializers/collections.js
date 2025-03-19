import { withPluginApi } from "discourse/lib/plugin-api";
import sidebarPanelClassBuilder from "../lib/collection-sidebar-panel";
import CollectionPostMenuButton from "../components/collection-post-menu-button";

export default {
  name: "collections",
  initialize(container) {
    console.log(container.lookup("service:collection-sidebar"));

    withPluginApi("2.0.0", (api) => {
      api.addSidebarPanel(sidebarPanelClassBuilder);
      api.registerValueTransformer(
        "post-menu-buttons",
        ({ value: dag, context: { post } }) => {
          if (post.post_number !== 1) {
            return;
          }

          dag.add("collection", CollectionPostMenuButton, {
            before: "delete",
            after: "bookmark",
          });
        }
      );
    });
  },
};
