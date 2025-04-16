import { withPluginApi } from "discourse/lib/plugin-api";
import I18n from "discourse-i18n";
import CollectionPostMenuButton from "../components/collection-post-menu-button";
import CollectionSidebarHeader from "../components/collection-sidebar-header";
import sidebarPanelClassBuilder from "../lib/collection-sidebar-panel";

export default {
  name: "collections",
  initialize(container) {
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
          dag.add("collection", CollectionPostMenuButton, {
            before: ["delete", "showMore"],
            after: ["bookmark", "edit"],
          });
        }
      );

      api.addComposerToolbarPopupMenuOption({
        action: (toolbarEvent) => {
          const collectionTemplate =
            I18n.translations[I18n.currentLocale()].js.collections.template;
          toolbarEvent.applySurround(
            collectionTemplate.decorated_start,
            collectionTemplate.decorated_end,
            collectionTemplate.plain,
            {
              multiline: false,
              useBlockMode: true,
            }
          );
        },
        icon: "layer-group",
        label: "js.collections.composer.label",
        condition: (composer) => {
          return composer.model.topicFirstPost;
        },
      });
    });
  },
};
