import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import DButton from "discourse/components/d-button";
import DropdownMenu from "discourse/components/dropdown-menu";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";
import DMenu from "float-kit/components/d-menu";
import { and, or, not } from "truth-helpers";
import CollectionAddModal from "./modals/collection-add-modal";
import CollectionCreateModal from "./modals/collection-create-modal";
import CollectionRemoveModal from "./modals/collection-remove-modal";

export default class CollectionPostMenuButton extends Component {
  @service modal;
  @service router;
  static hidden = true;

  collection = this.args.post.topic.collection;

  get collectionIndexUrl() {
    return `/t/-/${this.collection.collection_index}/1`;
  }

  constructor() {
    super(...arguments);
    console.log(this.collection);
    console.log(this);
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
    console.log("add");
    this.modal.show(CollectionAddModal, {
      model: {
        topic: this.args.post.topic,
        collection: this.collection,
      },
    });
  }

  @action
  removeFromCollection() {
    console.log("remove");
    this.modal.show(CollectionRemoveModal, {
      model: {
        topic: this.args.post.topic,
        collection: this.collection,
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
                  @icon="collections-add"
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
