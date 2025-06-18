import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { or } from "truth-helpers";
import DButton from "discourse/components/d-button";
import { CollectionMobile } from "./modals/collection-mobile";

export class CollectionTopicProgressButton extends Component {
  @service modal;
  @service collectionSidebar;

  @action
  displayCollection() {
    this.collectionSidebar.showCollectionSidebar();
    this.modal.show(CollectionMobile).then(() => {
      this.collectionSidebar.hideCollectionSidebar();
    });
  }

  <template>
    {{#if (or @model.collection @model.subcollection)}}
      <DButton
        class="topic-collection-menu"
        @action={{this.displayCollection}}
        @icon="layer-group"
        @title="collections.sidebar.buttons.collection"
      />
    {{/if}}
  </template>
}
