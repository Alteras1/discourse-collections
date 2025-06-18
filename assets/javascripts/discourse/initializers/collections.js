import { withPluginApi } from "discourse/lib/plugin-api";
import CollectionPostMenuButton from "../components/collection-post-menu-button";
import CollectionSidebarFooter from "../components/collection-sidebar-footer";
import CollectionSidebarHeader from "../components/collection-sidebar-header";
/** @import CollectionSidebar from '../services/collection-sidebar.js' */
import CollectionForm from "../components/modals/collection-form";
import sidebarPanelClassBuilder from "../lib/collection-sidebar-panel";

export default {
  name: "collections",
  initialize(container) {
    /** @type {CollectionSidebar} */
    const collectionSidebar = container.lookup("service:collection-sidebar");
    const appEvents = container.lookup("service:app-events");

    withPluginApi("2.0.0", (api) => {
      api.addSidebarPanel(sidebarPanelClassBuilder);
      api.renderInOutlet("before-sidebar-sections", CollectionSidebarHeader);
      api.renderInOutlet("sidebar-footer-actions", CollectionSidebarFooter);

      api.addTopicAdminMenuButton((topic) => {
        const collection = topic.get("collection");
        return {
          icon: collection ? "layer-group" : "collections-add",
          label: collection
            ? "collections.post_menu.manage_collection"
            : "collections.post_menu.create_collection",
          action: () => {
            const modal = api.container.lookup("service:modal");
            modal.show(CollectionForm, {
              model: {
                topic,
                collection,
                isSubcollection: false,
              },
            });
          },
        };
      });

      api.addTopicAdminMenuButton((topic) => {
        const subcollection = topic.get("subcollection");
        return {
          icon: subcollection ? "layer-group" : "collections-add",
          label: subcollection
            ? "collections.post_menu.manage_subcollection"
            : "collections.post_menu.create_subcollection",
          action: () => {
            const modal = api.container.lookup("service:modal");
            modal.show(CollectionForm, {
              model: {
                topic,
                collection: subcollection,
                isSubcollection: true,
              },
            });
          },
        };
      });

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
