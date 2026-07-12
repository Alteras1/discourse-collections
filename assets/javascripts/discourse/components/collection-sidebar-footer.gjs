/// <reference path="../typedefs.js" />
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DMenu from "discourse/float-kit/components/d-menu";
import { bind } from "discourse/lib/decorators";
import DButton from "discourse/ui-kit/d-button";
import DDropdownMenu from "discourse/ui-kit/d-dropdown-menu";
import dIcon from "discourse/ui-kit/helpers/d-icon";

export default class CollectionSidebarFooter extends Component {
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

  get canManageCollection() {
    return this.canCreate || this.collection?.can_edit_collection;
  }

  get canManageSubcollection() {
    return this.canCreate || this.subcollection?.can_edit_collection;
  }

  get canManageAnyCollection() {
    return this.canManageCollection || this.canManageSubcollection;
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
    {{#if this.canManageAnyCollection}}
      <DMenu
        @modalForMobile={{true}}
        @contentClass="collection-edit-menu"
        class="btn no-text btn-icon btn-flat sidebar-footer-actions-button collection-sidebar-footer-menu"
      >
        <:trigger>
          {{dIcon "layer-group"}}
        </:trigger>
        <:content>
          <DDropdownMenu as |dropdown|>
            {{#if this.canManageCollection}}
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

            {{#if this.canManageSubcollection}}
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
          </DDropdownMenu>
        </:content>
      </DMenu>
    {{/if}}
  </template>
}
