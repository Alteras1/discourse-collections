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

    // const sidebarState = getOwnerWithFallback(this).lookup(
    //   "service:sidebar-state"
    // );

    /** @returns {import('../services/collection-sidebar').default} */
    get collectionSidebar() {
      return getOwnerWithFallback(this).lookup("service:collection-sidebar");
    }

    @cached
    get sections() {
      const router = getOwnerWithFallback(this).lookup("service:router");

      const collectionSections = this.collectionSidebar.collectionData.map(
        (config) => {
          return prepareCollectionSection({ config, router });
        }
      );
      return [...collectionSections];
    }
  };

export default sidebarPanelClassBuilder;

/**
 * Builds the class tree for the collection sidebar section.
 * @param {Object} obj
 * @param {CollectionTypes.CollectionSection} obj.config
 * @param {Object} obj.router
 */
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
      return this.sectionLinks
        .flatMap((link) => [
          {
            data: link,
            panelName: this.name,
            router,
          },
          ...(link.sub_links || []).map((sublink) => ({
            data: sublink,
            panelName: this.name,
            router,
            parent: link,
          })),
        ])
        .map((link) => new CollectionSidebarSectionLink(link));
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
  _parent;

  /**
   * @param {Object} obj
   * @param {CollectionTypes.CollectionLink | CollectionTypes.CollectionSubLink} obj.data
   * @param {string} obj.panelName
   * @param {Object} obj.router
   * @param {CollectionTypes.CollectionLink} [obj.parent]
   */
  constructor({ data, panelName, router, parent }) {
    super(...arguments);

    this._data = data;
    this._panelName = panelName;
    this._router = router;
    this._parent = parent;
  }

  get currentWhen() {
    if (this._parent) {
      return false;
    }
    if (DiscourseURL.isInternal(this.href) && samePrefix(this.href)) {
      const currentTopicRouteInfo = this._router.currentRoute.find(
        (route) => route.name === "topic"
      );

      return (
        this._data.topic_id.toString() === currentTopicRouteInfo?.params?.id
      );
    }

    return false;
  }

  get parentCurrentWhen() {
    if (!this._parent) {
      return false;
    }
    if (
      DiscourseURL.isInternal(this._parent.href) &&
      samePrefix(this._parent.href)
    ) {
      const currentTopicRouteInfo = this._router.currentRoute.find(
        (route) => route.name === "topic"
      );

      return (
        this._parent.topic_id.toString() === currentTopicRouteInfo?.params?.id
      );
    }

    return false;
  }

  get name() {
    return `${this._panelName}___${unicodeSlugify(this.text)}`;
  }

  get classNames() {
    const list = ["collection-sidebar-link"];
    if (this._parent) {
      list.push("sublink");
      if (this.parentCurrentWhen) {
        list.push("active-parent");
      }
    }
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
    return "collection-pip";
  }
}
