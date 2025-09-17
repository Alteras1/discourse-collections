/// <reference path="../typedefs.js" />
import { tracked } from "@glimmer/tracking";
import Service, { service } from "@ember/service";
import { bind } from "discourse/lib/decorators";
import { deepEqual } from "discourse/lib/object";
import { ADMIN_PANEL, MAIN_PANEL } from "discourse/lib/sidebar/panels";

export const SIDEBAR_COLLECTIONS_PANEL = "discourse-collections-sidebar";

export default class CollectionSidebar extends Service {
  @service site;
  @service appEvents;
  @service router;
  @service sidebarState;

  /** @type {ProcessedSection[]} */
  @tracked _sections = [];
  /** @type {Collection} */
  @tracked _collectionData = null;
  /** @type {number} */
  @tracked _collectionId = null;
  /** @type {Collection} */
  @tracked _subcollection = null;

  constructor() {
    super(...arguments);

    this.router.on("routeDidChange", this, this.currentRouteChanged);
  }

  willDestroy() {
    super.willDestroy(...arguments);

    this.router.off("routeDidChange", this, this.currentRouteChanged);
  }

  /**
   * @type {`${number}`} string containing the current topic ID
   */
  get currentTopicId() {
    return (
      this.router.currentRoute?.find((route) => route.name === "topic")?.params
        ?.id || null
    );
  }

  get topicCollectionInfo() {
    return (
      this.router.currentRoute?.attributes?.collection ||
      this.router.currentRoute?.parent?.attributes?.collection ||
      this.router.currentRoute?.attributes?.subcollection ||
      this.router.currentRoute?.parent?.attributes?.subcollection ||
      {}
    );
  }

  /**
   * Returns the collection information
   * @type {Collection}
   */
  get activeCollection() {
    if (this.sidebarState.currentPanel?.key === ADMIN_PANEL) {
      return {};
    }

    return this.topicCollectionInfo || {};
  }

  get currentTopicHasCollection() {
    if (this.sidebarState.currentPanel?.key === ADMIN_PANEL) {
      return;
    }
    return !!this.topicCollectionInfo?.id;
  }

  get hasNestedCollection() {
    return (
      this.topicSubcollection &&
      this.activeCollection.id !== this.topicSubcollection.id
    );
  }

  /**
   * @type {Collection}
   */
  get topicSubcollection() {
    return (
      this.router.currentRoute?.attributes?.subcollection ||
      this.router.currentRoute?.parent?.attributes?.subcollection ||
      null
    );
  }

  get isVisible() {
    return this.sidebarState.isCurrentPanel(SIDEBAR_COLLECTIONS_PANEL);
  }

  get collectionData() {
    return this._collectionData || {};
  }

  get collectionId() {
    return this._collectionId;
  }

  get sectionsConfig() {
    return this._sections || [];
  }

  hideCollectionSidebar() {
    if (!this.isVisible) {
      return;
    }
    this.sidebarState.setPanel(MAIN_PANEL);
  }

  showCollectionSidebar() {
    this.sidebarState.setPanel(SIDEBAR_COLLECTIONS_PANEL);
    this.sidebarState.setSeparatedMode();
    this.sidebarState.hideSwitchPanelButtons();
  }

  disableCollectionSidebar() {
    this.hideCollectionSidebar();
    this._collectionData = null;
    this._collectionId = null;
  }

  @bind
  currentRouteChanged(transition) {
    if (transition.isAborted) {
      return;
    }
    this.maybeDisplaySidebar();
  }

  maybeDisplaySidebar() {
    const collection = this.activeCollection;

    if (!collection?.id) {
      this.disableCollectionSidebar();
      return;
    }

    let subcollection = null;
    if (this.hasNestedCollection) {
      subcollection = this.topicSubcollection;
    }

    if (
      this._collectionId !== collection.id ||
      !deepEqual(this._collectionData, collection) ||
      !deepEqual(this._subcollection, subcollection)
    ) {
      this.setSidebarContent(collection, subcollection);
    }
  }

  /**
   * @param {Collection} collection
   * @param {Collection} subcollection
   */
  setSidebarContent(collection, subcollection) {
    if (!collection) {
      this.disableCollectionSidebar();
      return;
    }
    this._collectionId = collection.id;
    this._collectionData = collection;
    this._subcollection = subcollection;

    /** @type {ProcessedSection[]} */
    let sections = [];

    if (subcollection?.id) {
      let subcollectionSection = {
        name: null,
        isSub: true,
        links: [],
      };
      for (const item of subcollection.collection_items) {
        if (item.is_section_header) {
          sections.push(subcollectionSection);
          subcollectionSection = {
            name: item.name,
            isSub: true,
            links: [],
          };
          continue;
        }
        subcollectionSection.links.push(item);
      }
      if (subcollectionSection.name || subcollectionSection.links.length) {
        sections.push(subcollectionSection);
      }
    }

    let section = {
      name: null,
      isSub: false,
      links: [],
    };
    for (const item of collection.collection_items) {
      if (item.is_section_header) {
        sections.push(section);
        section = {
          name: item.name,
          isSub: false,
          links: [],
        };
        continue;
      }
      section.links.push(item);
    }
    if (section.name || section.links.length) {
      sections.push(section);
    }

    sections = sections.filter((s) => s.links.length > 0 || s.name);

    this._sections = sections;
    if (!this.site.mobileView) {
      this.showCollectionSidebar();
    }
  }
}
