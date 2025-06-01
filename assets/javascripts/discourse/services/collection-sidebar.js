/// <reference path="../collection.d.ts" />
import { tracked } from "@glimmer/tracking";
import Service, { service } from "@ember/service";
import { bind } from "discourse/lib/decorators";
import { deepEqual } from "discourse/lib/object";
import { ADMIN_PANEL, MAIN_PANEL } from "discourse/lib/sidebar/panels";

export const SIDEBAR_COLLECTIONS_PANEL = "discourse-collections-sidebar";

export default class CollectionSidebar extends Service {
  @service appEvents;
  @service router;
  @service sidebarState;

  /** @type {CollectionTypes.ProcessedSection[]} */
  @tracked _sections = [];
  /** @type {CollectionTypes.Collection} */
  @tracked _collectionData = null;
  /** @type {number} */
  @tracked _collectionId = null;

  constructor() {
    super(...arguments);

    this.router.on("routeDidChange", this, this.currentRouteChanged);
  }

  willDestroy() {
    super.willDestroy(...arguments);

    this.router.off("routeDidChange", this, this.currentRouteChanged);
  }

  get topicCollectionInfo() {
    return (
      this.router.currentRoute?.attributes?.collection ||
      this.router.currentRoute?.parent?.attributes?.collection ||
      {}
    );
  }

  /**
   * Returns the collection information
   * @type {CollectionTypes.Collection}
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

    if (
      this._collectionId !== collection.id ||
      !deepEqual(this._collectionData, collection)
    ) {
      this.setSidebarContent(collection);
    }
  }

  /**
   * @param {CollectionTypes.Collection} collection
   */
  setSidebarContent(collection) {
    if (!collection) {
      this.disableCollectionSidebar();
      return;
    }
    this._collectionId = collection.id;
    this._collectionData = collection;

    /** @type {CollectionTypes.ProcessedSection[]} */
    const sections = [];
    let section = {
      name: null,
      links: [],
    };
    for (const item of collection.collection_items) {
      if (item.is_section_header) {
        sections.push(section);
        section = {
          name: item.name,
          links: [],
        };
      } else {
        section.links.push(item);
      }
    }
    if (section.name || section.links.length) {
      sections.push(section);
    }

    this._sections = sections;
    this.showCollectionSidebar();
  }
}
