import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { and } from "truth-helpers";
import DButton from "discourse/components/d-button";
import DModal from "discourse/components/d-modal";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class CollectionCreateModal extends Component {
  @tracked preview = [];
  @tracked isLoading = false;
  @tracked isDisabled = true;
  @tracked previewReady = false;

  constructor() {
    super(...arguments);
    this.getCollectionPreview();
  }

  async getCollectionPreview() {
    this.previewReady = false;
    try {
      const previewData = await ajax("/collections/preview", {
        type: "POST",
        data: {
          cooked: this.args.model.post.cooked,
        },
      });
      this.preview = previewData;
      this.isDisabled = !previewData?.length;
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error(error);
    } finally {
      this.previewReady = true;
    }
  }

  @action
  async createCollection() {
    this.isLoading = true;
    try {
      await ajax("/collections/" + this.args.model.topic.id, {
        type: "POST",
      });
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
      @title={{i18n "collections.post_menu.create"}}
      class="collection-modal"
      @bodyClass="collection-modal__body"
    >
      <:body>
        <p>{{i18n "collections.modal.create.preview"}}</p>
        <div class="collection-preview {{if this.isDisabled 'warn'}}">
          {{#if this.previewReady}}
            {{#each this.preview as |section|}}
              {{#if section.text}}
                <label class="collection-preview__section-label">
                  <input type="checkbox" checked />
                  {{icon "angle-down"}}
                  {{icon "angle-right"}}
                  {{section.text}}
                </label>
              {{/if}}
              <div class="collection-preview__section">
                {{#each section.links as |link|}}
                  <a
                    href={{link.href}}
                    target="_blank"
                    class="collection-preview__link"
                  >{{icon "collection-pip"}} {{link.text}}</a>
                  {{#each link.sublinks as |sublink|}}
                    <a
                      href={{sublink.href}}
                      target="_blank"
                      class="collection-preview__sublink"
                    >{{icon "collection-pip"}} {{sublink.text}}</a>
                  {{/each}}
                {{/each}}
              </div>
            {{else}}
              <span class="warning">{{i18n
                  "collections.modal.create.error"
                }}</span>
            {{/each}}
          {{else}}
            <div class="spinner"></div>
          {{/if}}
        </div>
        {{#if (and this.previewReady this.isDisabled)}}
          <p>{{i18n "collections.modal.create.informational"}}</p>
          {{! prettier-ignore }}
          <pre><code class="language-md">{{i18n "collections.template.decorated_start"}}
{{i18n "collections.template.plain"}}
{{i18n "collections.template.end"}}
</code></pre>
        {{/if}}
      </:body>
      <:footer>
        <DButton
          @label="collections.modal.create.create"
          @action={{this.createCollection}}
          @disabled={{this.isDisabled}}
          @isLoading={{this.isLoading}}
          @class="btn-primary"
        />
      </:footer>
    </DModal>
  </template>
}
