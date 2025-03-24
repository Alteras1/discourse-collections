import { action } from "@ember/object";
import { fn, hash } from "@ember/helper";
import DButton from "discourse/components/d-button";
import DModal from "discourse/components/d-modal";
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import Form from "discourse/components/form";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";
import TopicChooser from "select-kit/components/topic-chooser";
import { and } from "truth-helpers";

export default class CollectionAddModal extends Component {
  @tracked preview = [];
  @tracked isDisabled = true;
  @tracked isLoading = false;
  @tracked selectedTopic = [];

  constructor() {
    super(...arguments);
    console.log(this.args.model);
  }

  @action
  async createCollection() {
    this.isLoading = true;
    try {
      const create = await ajax("/collections/" + this.args.model.topic.id, {
        type: "POST",
      });
      console.log(create);
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.isLoading = false;
      this.args.closeModal();
    }
  }

  @action
  onChangeTopic(fieldSet, topicId, topic) {
    this.selectedTopic = [topic];
    console.log(this.selectedTopic)
    fieldSet(topicId);
  }

  <template>
    <DModal
      @closeModal={{@closeModal}}
      @title={{i18n "collections.modal.add.title"}}
      class="collection-modal"
      @bodyClass="collection-modal__body"
    >
      <:body>
        <p>{{i18n "collections.modal.add.body"}}</p>
        <Form as |form|>
          <form.Field
            @name="collectionTopic"
            @title={{i18n "collections.modal.add.select"}}
            @format="large"
            @validation="required"
            as |field|
          >
            <field.Custom>
              <TopicChooser
                @value={{field.value}}
                @content={{this.selectedTopic}}
                @onChange={{fn this.onChangeTopic field.set}}
                {{!-- @options={{hash additionalFilters="status:public"}} TODO: add search filter --}}
              />
            </field.Custom>
          </form.Field>
        </Form>
      </:body>
      <:footer>
        <DButton
          @label="collections.modal.add.confirm"
          @action={{this.createCollection}}
          @disabled={{this.isDisabled}}
          @isLoading={{this.isLoading}}
          @class="btn-primary"
        />
      </:footer>
    </DModal>
  </template>
}
