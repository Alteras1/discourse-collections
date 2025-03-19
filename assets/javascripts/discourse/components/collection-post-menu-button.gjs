import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import DButton from "discourse/components/d-button";
import DMenu from "float-kit/components/d-menu";
import DropdownMenu from "discourse/components/dropdown-menu";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";

export default class CollectionPostMenuButton extends Component {
  static hidden = true;

  collection = this.args.post.topic.collection;

  constructor() {
    super(...arguments);
    console.log(this.args);
    console.log(this.collection);
  }

  @action
  goToIndex() {
    console.log("redirect");
  }

  @action
  createCollection() {
    console.log("create");
  }

  @action
  deleteCollection() {
    console.log("delete");
  }

  @action
  addToCollection() {
    console.log("add");
  }

  @action
  removeFromCollection() {
    console.log("remove");
  }

  <template>
    <DMenu
      class="post-action-menu__collection"
      ...attributes
      @icon="layer-group"
      @label={{if @showLabel "hello"}}
      @title="collections.collection_post_menu"
    >
      <:content>
        <DropdownMenu as |dropdown|>
          {{!-- {{#if this.collection.is_collection}}
            <dropdown.item class="collection-post-menu_title">
              {{icon "layer-group"}}
              <span>{{i18n "collections.collection_post_menu.title"}}</span>
            </dropdown.item>
          {{/if}} --}}
          {{#if this.collection.collection_index}}
            <dropdown.item
              class="collection-post-menu__index"
              data-menu-option-id="index"
            >
              <DButton
                class="collection-post-menu__btn btn-transparent"
                ...attributes
                @action={{this.goToIndex}}
                @icon="collections-add"
                @label="collections.post_menu.go_to_index"
              />
            </dropdown.item>
          {{/if}}
          {{#unless this.collection.is_collection}}
            <dropdown.item
              class="collection-post-menu__create"
              data-menu-option-id="create"
            >
              <DButton
                class="collection-post-menu__btn btn-transparent"
                ...attributes
                @action={{this.createCollection}}
                @icon="collections-add"
                @label="collections.post_menu.create"
              />
            </dropdown.item>
          {{/unless}}

          {{#if this.collection.collection_index}}
            <dropdown.item
              class="collection-post-menu__remove"
              data-menu-option-id="remove"
            >
              <DButton
                class="collection-post-menu__btn btn-transparent"
                ...attributes
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
                ...attributes
                @action={{this.addToCollection}}
                @icon="collections-add"
                @label="collections.post_menu.add"
              />
            </dropdown.item>
          {{/if}}

          {{#if this.collection.is_collection}}
            <dropdown.divider />
            <dropdown.item
              class="collection-post-menu__delete"
              data-menu-option-id="delete"
            >
              <DButton
                class="collection-post-menu__btn btn-transparent btn-danger"
                ...attributes
                @action={{this.deleteCollection}}
                @icon="trash-can"
                @label="collections.post_menu.delete"
              />
            </dropdown.item>
          {{/if}}
        </DropdownMenu>
      </:content>
    </DMenu>

    {{!-- <DButton
      class="post-action-menu__collection"
      ...attributes
      @action={{this.acceptAnswer}}
      @icon="far-check-square"
      @label="hello"
      @title="solved.accept_answer"
    /> --}}
  </template>
}
