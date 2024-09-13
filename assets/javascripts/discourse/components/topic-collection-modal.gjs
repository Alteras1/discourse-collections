import Component from "@glimmer/component";
import { cached, tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import DButton from "discourse/components/d-button";
import DModal from "discourse/components/d-modal";
import DModalCancel from "discourse/components/d-modal-cancel";
import Form from "discourse/components/form";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class TopicCollectionModal extends Component {
  @tracked savingStatus = false;

  constructor() {
    super(...arguments);
    console.log(this.args.model);
  }

  @action
  async save(data) {
    try {
      this.savingStatus = true;
      await ajax("/collections", {
        type: "POST",
        data: {
          title: data.collection_name,
          description: data.collection_description,
        },
      });
      this.router.transitionTo("collections");
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.savingStatus = false;
    }
  }

  <template>
    <DModal @title="Add Topic to Collection" @closeModal={{@closeModal}}>
      <:body>
        Hello world, this is some content in a modal
        <br />
        adding "{{@model.post.topic.title}}" to collection
        {{! add form for collection chooser and collection item name.
            don't use Form since this is very simple }}
      </:body>
      <:footer>
        <DButton class="btn-primary" @translatedLabel="Submit" />
        <DModalCancel @close={{@closeModal}} />
      </:footer>
    </DModal>
  </template>
}
