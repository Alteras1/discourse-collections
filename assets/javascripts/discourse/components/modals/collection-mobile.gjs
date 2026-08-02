import Component from "@glimmer/component";
import { service } from "@ember/service";
import { trustHTML } from "@ember/template";
import ApiPanels from "discourse/components/sidebar/api-panels";
import DModal from "discourse/ui-kit/d-modal";
import { i18n } from "discourse-i18n";
import CollectionSidebarFooter from "../collection-sidebar-footer";

export class CollectionMobile extends Component {
  @service currentUser;
  @service collectionSidebar;

  get modalTitle() {
    const title = this.collectionSidebar._collectionData?.title || "";
    if (title) {
      return trustHTML(title);
    }
    return i18n("collections.sidebar.buttons.collection");
  }

  get desc() {
    return trustHTML(this.collectionSidebar._collectionData?.desc || "");
  }

  <template>
    <DModal
      @closeModal={{@closeModal}}
      @title={{this.modalTitle}}
      class="collection-mobile-modal"
      @bodyClass="collection-mobile-modal__body"
    >
      <:body>
        {{#if this.desc}}
          <div class="collection-mobile-modal__desc">
            {{this.desc}}
          </div>
        {{/if}}
        <ApiPanels
          @currentUser={{this.currentUser}}
          @collapsableSections={{true}}
        />
      </:body>
      <:footer>
        <CollectionSidebarFooter />
      </:footer>
    </DModal>
  </template>
}
