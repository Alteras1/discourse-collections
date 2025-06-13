/// <reference path="../typedefs.js" />
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { or } from "truth-helpers";
import DButton from "discourse/components/d-button";
import DropdownMenu from "discourse/components/dropdown-menu";
import { bind } from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";
import DMenu from "float-kit/components/d-menu";
import CollectionForm from "./modals/collection-form";

export default class CollectionPostMenuButton extends Component {
  static hidden(args) {
    const { post } = args;
    const { collection, subcollection } = post.topic;
    if (!collection) {
      return true;
    }
    if (collection.can_edit_collection || subcollection?.can_edit_collection) {
      return false;
    }

    return true;
  }

  @service modal;
  @service router;
  @service appEvents;

  /** @type {Collection} */
  @tracked collection = this.args.post.topic.collection;
  /** @type {Collection} */
  @tracked subcollection = this.args.post.topic.subcollection;
  /** @type {boolean} */
  @tracked canCreate = this.args.post.topic.can_create_collection;

  constructor() {
    super(...arguments);
    this.appEvents.on("collection:updated", this, this.onCollectionUpdate);
  }

  @bind
  onCollectionUpdate({ topic, collection, subcollection }) {
    // I don't really like this, feels kinda like spaghetti code
    // but the only other way to refresh this list seems to be
    // to refresh the post stream, which is not ideal

    if (topic.id === this.args.post.topic.id) {
      this.collection = collection;
      this.subcollection = subcollection;
    }
  }

  @action
  manageCollection() {
    this.modal.show(CollectionForm, {
      model: {
        post: this.args.post,
        topic: this.args.post.topic,
        collection: this.collection,
        isSubcollection: false,
      },
    });
  }

  @action
  manageSubcollection() {
    this.modal.show(CollectionForm, {
      model: {
        post: this.args.post,
        topic: this.args.post.topic,
        collection: this.subcollection,
        isSubcollection: true,
      },
    });
  }

  <template>
    <DMenu
      class="post-action-menu__collection"
      ...attributes
      @icon="layer-group"
      @label={{if @showLabel (i18n "collections.post_menu.title")}}
      @title={{i18n "collections.post_menu.title"}}
    >
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
                @icon={{if this.subcollection "layer-group" "collections-add"}}
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
  </template>
}
