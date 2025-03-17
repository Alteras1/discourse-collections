import { cached } from "@glimmer/tracking";
import { computed } from "@ember/object";
import { getOwnerWithFallback } from "discourse/lib/get-owner";
import { SIDEBAR_COLLECTIONS_PANEL } from "../services/collection-sidebar";
import { samePrefix } from "discourse/lib/get-url";
import BaseCustomSidebarSection from "discourse/lib/sidebar/base-custom-sidebar-section";
import BaseCustomSidebarSectionLink from "discourse/lib/sidebar/base-custom-sidebar-section-link";
import DiscourseURL from "discourse/lib/url";
import { escapeExpression, unicodeSlugify } from "discourse/lib/utilities";
import { i18n } from "discourse-i18n";

const sidebarPanelClassBuilder = (BaseCustomSidebarPanel) =>
  class CollectionSidebarPanel extends BaseCustomSidebarPanel {
    key = SIDEBAR_COLLECTIONS_PANEL;
    hidden = true; // temporary value set to stop not implemented error
    expandActiveSection = true;
    scrollActiveLinkIntoView = true;
    filtered = true;

    get collectionSidebar() {
      return getOwnerWithFallback(this).lookup("service:collection-sidebar");
    }

    @cached
    get sections() {
      const router = getOwnerWithFallback(this).lookup("service:router");
      const sidebarState = getOwnerWithFallback(this).lookup(
        "service:sidebar-state"
      );
      const collectionSections = this.collectionSidebar.collectionData.map(
        (config) => {
          return prepareCollectionSection({ config, router });
        }
      );
      return [...collectionSections];
    }
  };

export default sidebarPanelClassBuilder;

function prepareCollectionSection({ config, router }) {
  return class extends BaseCustomSidebarSection {
    _section = config;

    get sectionLinks() {
      return this._section.links;
    }

    get text() {
      return this._section.text;
    }

    get name() {
      return this.text
        ? `${SIDEBAR_COLLECTIONS_PANEL}__${unicodeSlugify(this.text)}`
        : `${SIDEBAR_COLLECTIONS_PANEL}::root`;
    }

    get title() {
      return this.text;
    }

    get links() {
      return this.sectionLinks.map(
        (link) =>
          new CollectionSidebarSectionLink({
            data: link,
            panelName: this.name,
            router,
          })
      );
    }

    get displaySection() {
      return true;
    }

    get hideSectionHeader() {
      return !this.text;
    }

    get collapsedByDefault() {
      return false;
    }
  };
}

class CollectionSidebarSectionLink extends BaseCustomSidebarSectionLink {
  _data;
  _panelName;
  _router;

  constructor({ data, panelName, router }) {
    super(...arguments);

    this._data = data;
    this._panelName = panelName;
    this._router = router;
  }

  get currentWhen() {
    if (DiscourseURL.isInternal(this.href) && samePrefix(this.href)) {
      const currentTopicRouteInfo = this._router.currentRoute.find(
        (route) => route.name === "topic"
      );
      console.log(currentTopicRouteInfo);

      return this._data.topic_id === currentTopicRouteInfo?.params?.id;
    }

    return false;
  }

  get name() {
    return `${this._panelName}___${unicodeSlugify(this.text)}`;
  }

  get classNames() {
    const list = ["collection-sidebar-link"];
    return list.join(" ");
  }

  get href() {
    return this._data.href;
  }

  get text() {
    return this._data.text;
  }

  get title() {
    return this.text;
  }

  @computed("data.text")
  get keywords() {
    return {
      navigation: this._data.text.toLowerCase().split(/s+/g),
    };
  }

  get prefixType() {
    return "icon";
  }

  get prefixValue() {
    return "far-square";
  }
}
