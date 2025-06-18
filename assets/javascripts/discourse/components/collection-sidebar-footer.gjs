/// <reference path="../typedefs.js" />
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { or } from "truth-helpers";
import DButton from "discourse/components/d-button";
import DropdownMenu from "discourse/components/dropdown-menu";
import icon from "discourse/helpers/d-icon";
import { bind } from "discourse/lib/decorators";
import DMenu from "float-kit/components/d-menu";

export default class CollectionSidebarFooter extends Component {
  @service site;
  @service router;
  @service editCollection;

  @tracked topic;

  /** @type {Collection} */
  @tracked collection;
  /** @type {Collection} */
  @tracked subcollection;
  /** @type {boolean} */
  @tracked canCreate = false;

  constructor() {
    super(...arguments);
    this.router.on("routeDidChange", this, this.currentRouteChanged);
    this.setValues();
  }

  willDestroy() {
    super.willDestroy(...arguments);
    this.router.off("routeDidChange", this, this.currentRouteChanged);
  }

  @bind
  currentRouteChanged(transition) {
    if (transition.isAborted) {
      return;
    }
    this.setValues();
  }

  setValues() {
    if (this.router.currentRoute?.parent?.name !== "topic") {
      this.topic = null;
      this.collection = null;
      this.subcollection = null;
      this.canCreate = false;
    } else {
      this.topic = this.router.currentRoute?.parent.attributes;
      this.collection = this.topic?.collection;
      this.subcollection = this.topic?.subcollection;
      this.canCreate = this.topic?.can_create_collection;
    }
  }

  @action
  manageCollection() {
    this.editCollection.manageCollection(this.topic, this.collection);
  }

  @action
  manageSubcollection() {
    this.editCollection.manageSubcollection(this.topic, this.subcollection);
  }

  <template>
    {{#if this.canCreate}}
      <DMenu
        @modalForMobile={{true}}
        @contentClass="collection-edit-menu"
        class="btn no-text btn-icon btn-flat sidebar-footer-actions-button collection-sidebar-footer-menu"
      >
        <:trigger>
          {{icon "layer-group"}}
        </:trigger>
        <:content>
          <DropdownMenu as |dropdown|>
            {{#if (or this.canCreate this.collection?.can_edit_collection)}}
              <dropdown.item class="collection-post-menu__collection">
                <DButton
                  class="collection-post-menu__btn btn-transparent"
                  @action={{this.manageCollection}}
                  @icon={{if this.collection "layer-group" "collections-add"}}
                  @label={{if
                    this.collection
                    "collections.post_menu.manage_collection"
                    "collections.post_menu.create_collection"
                  }}
                />
              </dropdown.item>
            {{/if}}

            {{#if (or this.canCreate this.subcollection?.can_edit_collection)}}
              <dropdown.item class="collection-post-menu__subcollection">
                <DButton
                  class="collection-post-menu__btn btn-transparent"
                  @action={{this.manageSubcollection}}
                  @icon={{if
                    this.subcollection
                    "layer-group"
                    "collections-add"
                  }}
                  @label={{if
                    this.subcollection
                    "collections.post_menu.manage_subcollection"
                    "collections.post_menu.create_subcollection"
                  }}
                />
              </dropdown.item>
            {{/if}}
          </DropdownMenu>
        </:content>
      </DMenu>
    {{/if}}
  </template>
}
