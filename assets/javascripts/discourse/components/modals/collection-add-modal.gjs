import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { Input } from "@ember/component";
import { fn, hash } from "@ember/helper";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import DModal from "discourse/components/d-modal";
import Form from "discourse/components/form";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";
import TopicChooser from "select-kit/components/topic-chooser";

export default class CollectionAddModal extends Component {
  @service store;

  @tracked preview = [];
  @tracked isLoading = false;
  @tracked selectedTopic = [];
  @tracked selectedCollectionId;
  @tracked needsCheckbox = false;
  @tracked collectionError = false;
  @tracked isForce = false;

  get collectionIndexUrl() {
    return `/t/-/${this.selectedCollectionId}/1`;
  }

  get isDisabled() {
    if (this.needsCheckbox) {
      return !this.isForce || !this.selectedCollectionId;
    }
    return !this.selectedCollectionId;
  }

  @action
  async addCollectionIndex() {
    this.isLoading = true;
    try {
      await ajax(
        `/collections/${this.selectedCollectionId}/${this.args.model.topic.id}`,
        {
          type: "POST",
          data: {
            force: this.isForce,
          },
        }
      );
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.isLoading = false;
      this.args.closeModal();
    }
    // todo: perform refresh
  }

  @action
  async onChangeTopic(fieldSet, topicId, topic) {
    this.selectedTopic = [topic];
    fieldSet(topicId);
    this.selectedCollectionId = null;
    if (await this.validateTopicCollection(topicId)) {
      this.selectedCollectionId = topicId;
    }
  }

  async validateTopicCollection(testId) {
    this.collectionError = false;
    this.needsCheckbox = false;

    if (!testId) {
      return false;
    }

    let col;
    try {
      col = await ajax("/collections/" + testId, {
        type: "GET",
      });
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error(error);
      this.collectionError = true;
      return false;
    }
    if (!col?.unbound_topics.some((t) => t.id === this.args.model.topic.id)) {
      this.needsCheckbox = true;
    }
    return true;
  }

  @action
  onChangeCheckbox(fieldSet, value) {
    this.isForce = value;
    fieldSet(value);
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
                @options={{hash additionalFilters="is:collection"}}
              />
              {{#if this.collectionError}}
                <span class="collection-modal__error">{{i18n
                    "collections.modal.add.not_collection"
                  }}</span>
              {{/if}}
            </field.Custom>
          </form.Field>
        </Form>
        {{#if this.needsCheckbox}}
          <p class="collection-modal__warning">
            {{i18n "collections.modal.add.warning"}}
            <a href={{this.collectionIndexUrl}}>{{i18n
                "collections.modal.add.index"
              }}</a>
            {{i18n "collections.modal.add.warning2"}}
          </p>
        {{/if}}
      </:body>
      <:footer>
        <DButton
          @label="collections.modal.add.confirm"
          @action={{this.addCollectionIndex}}
          @disabled={{this.isDisabled}}
          @isLoading={{this.isLoading}}
          @class="btn-primary"
        />
        {{#if this.needsCheckbox}}
          <label class="collection-modal__force-add-label">
            <Input
              name="collection-modal__force-add"
              @checked={{this.isForce}}
              @type="checkbox"
              @disabled={{this.isLoading}}
              required
            />
            {{i18n "collections.modal.add.force"}}
          </label>
        {{/if}}
      </:footer>
    </DModal>
  </template>
}
