/// <reference path="../typedefs.js" />
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { and, not } from "truth-helpers";
import DButton from "discourse/components/d-button";
import DropdownMenu from "discourse/components/dropdown-menu";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { bind } from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";
import DMenu from "float-kit/components/d-menu";
import CollectionAddModal from "./modals/collection-add-modal";
import CollectionCreateModal from "./modals/collection-create-modal";
import CollectionRemoveModal from "./modals/collection-remove-modal";
import CollectionUnboundModal from "./modals/collection-unbound-modal";

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

  constructor() {
    super(...arguments);
    this.appEvents.on("collection:updated", this, this.onCollectionUpdate);
    console.log(this);
  }

  get collectionIndexUrl() {
    return `/t/-/${this.collection.collection_index}/1`;
  }

  get hasIssues() {
    return !!(
      this.collection.is_collection &&
      (this.collection.owned_collection?.unbound_topics.length ||
        this.collection.owned_collection?.orphaned_topics.length)
    );
  }

  @bind
  onCollectionUpdate({ topic, collection }) {
    // I don't really like this, feels kinda like spaghetti code
    // but the only other way to refresh this list seems to be
    // to refresh the post stream, which is not ideal

    if (topic.id === this.args.post.topic.id) {
      this.collection = collection;
    }
  }

  @action
  displayCollectionUnbound() {
    this.modal.show(CollectionUnboundModal, {
      model: {
        post: this.args.post,
        topic: this.args.post.topic,
        collection: this.collection,
      },
    });
  }

  @action
  createCollection() {
    this.modal.show(CollectionCreateModal, {
      model: {
        post: this.args.post,
        topic: this.args.post.topic,
        collection: this.collection,
      },
    });
  }

  @action
  async deleteCollection() {
    try {
      await ajax("/collections/" + this.collection.owned_collection.topic_id, {
        type: "DELETE",
        data: {
          topic_id: this.args.post.topic.id,
        },
      });
    } catch (error) {
      popupAjaxError(error);
    }
  }

  @action
  addToCollection() {
    this.modal.show(CollectionAddModal, {
      model: {
        topic: this.args.post.topic,
        collection: this.collection,
      },
    });
  }

  @action
  removeFromCollection() {
    this.modal.show(CollectionRemoveModal, {
      model: {
        topic: this.args.post.topic,
        collection: this.collection,
      },
    });
  }

  <template>
    <DMenu
      class="post-action-menu__collection {{if this.hasIssues 'warning'}}"
      ...attributes
      @icon="layer-group"
      @label={{if @showLabel (i18n "collections.post_menu.title")}}
      @title={{i18n "collections.post_menu.title"}}
    >
      <:content>
        <DropdownMenu as |dropdown|>
          {{#if this.collection.collection_index}}
            <dropdown.item class="collection-post-menu_title">
              <DButton
                class="collection-post-menu__btn btn-transparent"
                @href={{this.collectionIndexUrl}}
                @icon="circle-info"
                @label="collections.post_menu.to_index"
              />
            </dropdown.item>
          {{/if}}
          {{#if this.hasIssues}}
            <dropdown.item class="collection-post-menu_unbound">
              <DButton
                class="collection-post-menu__btn btn-transparent btn-danger"
                @action={{this.displayCollectionUnbound}}
                @icon="circle-exclamation"
                @label="collections.post_menu.unbound"
              />
            </dropdown.item>
          {{/if}}
          {{#if
            (and
              this.collection.can_create_delete_collection
              (not this.collection.is_collection)
            )
          }}
            <dropdown.item
              class="collection-post-menu__create"
              data-menu-option-id="create"
            >
              <DButton
                class="collection-post-menu__btn btn-transparent"
                @action={{this.createCollection}}
                @icon="layer-group"
                @label="collections.post_menu.create"
              />
            </dropdown.item>
          {{/if}}
          {{#if this.collection.can_add_remove_from_collection}}
            {{#if this.collection.collection_index}}
              <dropdown.item
                class="collection-post-menu__remove"
                data-menu-option-id="remove"
              >
                <DButton
                  class="collection-post-menu__btn btn-transparent"
                  @action={{this.removeFromCollection}}
                  @icon="collections-remove"
                  @label="collections.post_menu.remove"
                />
              </dropdown.item>
            {{else}}
              <dropdown.item
                class="collection-post-menu__add"
                data-menu-option-id="add"
              >
                <DButton
                  class="collection-post-menu__btn btn-transparent"
                  @action={{this.addToCollection}}
                  @icon="collections-add"
                  @label="collections.post_menu.add"
                />
              </dropdown.item>
            {{/if}}
          {{/if}}

          {{#if
            (and
              this.collection.can_create_delete_collection
              this.collection.is_collection
            )
          }}
            <dropdown.item
              class="collection-post-menu__delete"
              data-menu-option-id="delete"
            >
              <DButton
                class="collection-post-menu__btn btn-transparent btn-danger"
                @action={{this.deleteCollection}}
                @icon="trash-can"
                @label="collections.post_menu.delete"
              />
            </dropdown.item>
          {{/if}}
        </DropdownMenu>
      </:content>
    </DMenu>
  </template>
}
