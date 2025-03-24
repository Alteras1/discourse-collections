import { action } from "@ember/object";
import DButton from "discourse/components/d-button";
import DModal from "discourse/components/d-modal";
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class CollectionRemoveModal extends Component {
  @tracked isLoading = false;

  get collectionIndexUrl() {
    return `/t/-/${this.args.model.collection.collection_index}/1`;
  }

  constructor() {
    super(...arguments);
    console.log(this.args.model);
  }

  @action
  async removeFromCollection() {
    console.log("remove");
    this.isLoading = true;
    try {
      // const remove = await ajax("/collections/" + this.args.model.topic.id, {
      //   type: "POST",
      // });
      // console.log(create);
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.isLoading = false;
      this.args.closeModal();
    }
  }

  <template>
    <DModal
      @closeModal={{@closeModal}}
      @title={{i18n "collections.modal.remove.title"}}
      class="collection-modal"
      @bodyClass="collection-modal__body"
    >
      <:body>
        <p>
          {{i18n "collections.modal.remove.body1"}}
          <a href={{this.collectionIndexUrl}}>{{i18n
              "collections.modal.remove.index"
            }}</a>
          {{i18n "collections.modal.remove.body2"}}
        </p>
      </:body>
      <:footer>
        <DButton
          @icon="trash-can"
          @label="collections.modal.remove.confirm"
          @action={{this.removeFromCollection}}
          @disabled={{this.isDisabled}}
          @isLoading={{this.isLoading}}
          @class="btn-danger"
        />
      </:footer>
    </DModal>
  </template>
}
