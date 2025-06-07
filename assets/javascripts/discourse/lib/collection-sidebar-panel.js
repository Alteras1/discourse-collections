/// <reference path="../collection.d.ts" />
import { cached } from "@glimmer/tracking";
import { computed } from "@ember/object";
import { getOwnerWithFallback } from "discourse/lib/get-owner";
import { samePrefix } from "discourse/lib/get-url";
import BaseCustomSidebarSection from "discourse/lib/sidebar/base-custom-sidebar-section";
import BaseCustomSidebarSectionLink from "discourse/lib/sidebar/base-custom-sidebar-section-link";
import DiscourseURL from "discourse/lib/url";
import { unicodeSlugify } from "discourse/lib/utilities";
import { SIDEBAR_COLLECTIONS_PANEL } from "../services/collection-sidebar";

const sidebarPanelClassBuilder = (BaseCustomSidebarPanel) =>
  class CollectionSidebarPanel extends BaseCustomSidebarPanel {
    key = SIDEBAR_COLLECTIONS_PANEL;
    hidden = true;
    expandActiveSection = true;
    scrollActiveLinkIntoView = true;
    filterable = true;
    displayHeader = true;

    /** @returns {import('../services/collection-sidebar').default} */
    get collectionSidebar() {
      return getOwnerWithFallback(this).lookup("service:collection-sidebar");
    }

    @cached
    get sections() {
      const router = getOwnerWithFallback(this).lookup("service:router");
      return this.collectionSidebar.sectionsConfig.map((config) => {
        return prepareCollectionSection({ config, router });
      });
    }
  };

export default sidebarPanelClassBuilder;

/**
 * Builds the class tree for the collection sidebar section.
 * @param {Object} obj
 * @param {CollectionTypes.ProcessedSection} obj.config
 * @param {Object} obj.router
 */
function prepareCollectionSection({ config, router }) {
  return class extends BaseCustomSidebarSection {
    #section = config;

    get sectionLinks() {
      return this.#section.links;
    }

    get text() {
      return this.#section.name;
    }

    get isSub() {
      return this.#section.isSub;
    }

    get name() {
      if (this.text) {
        return `${SIDEBAR_COLLECTIONS_PANEL}__${unicodeSlugify(this.text)}`;
      } else if (this.isSub) {
        return `${SIDEBAR_COLLECTIONS_PANEL}__subcollection`;
      } else {
        return `${SIDEBAR_COLLECTIONS_PANEL}::root`;
      }
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
            sub: this.isSub,
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
  #data;
  #panelName;
  #router;
  #sub;

  /**
   * @param {Object} obj
   * @param {CollectionTypes.ProcessedSection['links'][number]} obj.data
   * @param {string} obj.panelName
   * @param {Object} obj.router
   * @param {boolean} obj.sub
   */
  constructor({ data, panelName, router, sub = false }) {
    super(...arguments);

    this.#data = data;
    this.#panelName = panelName;
    this.#router = router;
    this.#sub = sub;
  }

  get currentWhen() {
    if (this.#sub) {
      return false;
    }
    if (DiscourseURL.isInternal(this.href) && samePrefix(this.href)) {
      const currentTopicRouteInfo = this.#router.currentRoute.find(
        (route) => route.name === "topic"
      );

      return (
        this.#data.topic_id?.toString() === currentTopicRouteInfo?.params?.id
      );
    }

    return false;
  }

  get name() {
    return `${this.#panelName}___${unicodeSlugify(this.text)}`;
  }

  get classNames() {
    const list = ["collection-sidebar-link"];
    return list.join(" ");
  }

  get href() {
    return this.#data.url;
  }

  get text() {
    return this.#data.name;
  }

  get title() {
    return this.text;
  }

  @computed("data.name")
  get keywords() {
    return {
      navigation: this.#data.name.toLowerCase().split(/s+/g),
    };
  }

  get prefixType() {
    return "icon";
  }

  get prefixValue() {
    return "collection-pip";
  }
}
