import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import didUpdate from "@ember/render-modifiers/modifiers/did-update";
import { schedule } from "@ember/runloop";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import ConditionalInElement from "discourse/components/conditional-in-element";
import DButton from "discourse/components/d-button";
import icon from "discourse/helpers/d-icon";
import { MAIN_PANEL } from "discourse/lib/sidebar/panels";
import { i18n } from "discourse-i18n";
import { SIDEBAR_COLLECTIONS_PANEL } from "../services/collection-sidebar";
/** @import CollectionSidebar from '../services/collection-sidebar' */

const COLLECTION_SIDEBAR_HEADER_SELECTOR =
  ".discourse-collections-sidebar-panel .sidebar-panel-header__row:has(a.sidebar-sections__back-to-forum";
const MAIN_SIDEBAR_HEADER_SELECTOR =
  ".sidebar-wrapper .sidebar-container .sidebar-sections";

export default class CollectionSidebarHeader extends Component {
  @service router;
  @service sidebarState;
  /** @type {CollectionSidebar} */
  @service collectionSidebar;

  @tracked containerElement = null;

  get shouldDisplay() {
    return this.collectionSidebar.collectionId;
  }

  get isCollectionDisplayed() {
    return this.sidebarState.isCurrentPanel(SIDEBAR_COLLECTIONS_PANEL);
  }

  get header() {
    const title = this.collectionSidebar.topicCollectionInfo?.title || "";
    if (title) {
      return htmlSafe(title);
    }
    return i18n("collections.sidebar.buttons.collection");
  }

  @action
  getContainerElement() {
    schedule("afterRender", () => {
      if (!this.shouldDisplay) {
        return null;
      }

      const dom = document.querySelector(
        this.isCollectionDisplayed
          ? COLLECTION_SIDEBAR_HEADER_SELECTOR
          : MAIN_SIDEBAR_HEADER_SELECTOR
      );
      this.containerElement = dom;
    });
  }

  @action
  displayMain() {
    this.sidebarState.setPanel(MAIN_PANEL);
  }

  @action
  displayCollection() {
    this.sidebarState.setPanel(SIDEBAR_COLLECTIONS_PANEL);
  }

  <template>
    {{#if this.shouldDisplay}}
      <div
        class="hidden"
        {{didInsert this.getContainerElement}}
        {{didUpdate this.getContainerElement this.sidebarState.currentPanelKey}}
      >
      </div>
      <ConditionalInElement
        @element={{this.containerElement}}
        @inline={{false}}
        @append={{true}}
      >
        {{#if this.isCollectionDisplayed}}
          <DButton
            class="collection-sidebar__main-btn btn-transparent btn-flat btn-text btn-default"
            @action={{this.displayMain}}
            @icon="arrow-left"
            @label="collections.sidebar.buttons.main"
            @title="collections.sidebar.buttons.main_desc"
          />
        {{else}}
          <div class="sidebar-panel-header sidebar-panel-header__collection">
            <div class="sidebar-panel-header__row">
              <DButton
                class="sidebar-panel-header__col-btn btn-transparent btn-flat btn-text btn-default"
                @action={{this.displayCollection}}
                @icon="layer-group"
                @translatedLabel={{this.header}}
                @title="collections.sidebar.buttons.collection_desc"
              >
                {{icon "arrow-right"}}
              </DButton>
            </div>
          </div>
        {{/if}}
      </ConditionalInElement>
    {{/if}}
  </template>
}
