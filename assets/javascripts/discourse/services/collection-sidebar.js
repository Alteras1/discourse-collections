import { tracked } from "@glimmer/tracking";
import Service, { service } from "@ember/service";
import { bind } from "discourse/lib/decorators";
import { deepEqual } from "discourse/lib/object";
import { ADMIN_PANEL, MAIN_PANEL } from "discourse/lib/sidebar/panels";

export const SIDEBAR_COLLECTIONS_PANEL = "discourse-collections-sidebar";

export default class CollectionSidebarService extends Service {
  @service appEvents;
  @service router;
  @service sidebarState;

  @tracked _collectionData = null;
  @tracked _collectionIndexId = null;

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

  get activeCollection() {
    if (this.sidebarState.currentPanel?.key === ADMIN_PANEL) {
      return {};
    }

    return (
      this.topicCollectionInfo?.owned_collection ||
      this.topicCollectionInfo?.collection ||
      {}
    );
  }

  get currentTopicIsIndex() {
    if (this.sidebarState.currentPanel?.key === ADMIN_PANEL) {
      return;
    }
    return this.topicCollectionInfo?.is_collection;
  }

  get isVisible() {
    return this.sidebarState.isCurrentPanel(SIDEBAR_COLLECTIONS_PANEL);
  }

  get collectionData() {
    return this._collectionData || [];
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
    this._collectionIndexId = null;
  }

  @bind
  currentRouteChanged(transition) {
    if (transition.isAborted) {
      return;
    }
    this.maybeDisplaySidebar();
  }

  maybeDisplaySidebar() {
    const { topic_id: collectionIndex, sections: collectionData } =
      this.activeCollection;

    if (!collectionIndex) {
      this.disableCollectionSidebar();
      return;
    }

    if (
      this._collectionIndexId !== collectionIndex ||
      !deepEqual(this._collectionData, collectionData)
    ) {
      this.setSidebarContent(collectionIndex, collectionData);
    }
  }

  setSidebarContent(collectionId, collectionData) {
    if (!collectionData) {
      this.disableCollectionSidebar();
      return;
    }
    this._collectionIndexId = collectionId;
    this._collectionData = collectionData;
    this.showCollectionSidebar();
  }
}
