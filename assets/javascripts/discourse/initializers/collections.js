import { withPluginApi } from "discourse/lib/plugin-api";
import sidebarPanelClassBuilder from "../lib/collection-sidebar-panel";

export default {
  name: "collections",
  initialize(container) {
    console.log(container.lookup("service:collection-sidebar"));

    withPluginApi("2.0.0", (api) => {
      api.addSidebarPanel(sidebarPanelClassBuilder);
    });
  },
};
