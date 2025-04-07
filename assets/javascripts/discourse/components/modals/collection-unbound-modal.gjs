import Component from "@glimmer/component";
import DModal from "discourse/components/d-modal";
import { i18n } from "discourse-i18n";

export default class CollectionUnboundModal extends Component {
  unboundedTopics =
    this.args.model.topic.collection.owned_collection.unbound_topics?.map(
      (topic) => ({
        ...topic,
        url: `/t/${topic.slug}/${topic.id}`,
      })
    );
  orphanedTopics =
    this.args.model.topic.collection.owned_collection.orphaned_topics?.map(
      (topic) => ({
        ...topic,
        url: `/t/${topic.slug}/${topic.id}`,
      })
    );

  <template>
    <DModal
      @closeModal={{@closeModal}}
      @title={{i18n "collections.post_menu.unbound"}}
      class="collection-modal"
      @bodyClass="collection-modal__body"
    >
      <:body>
        <h2>{{i18n "collections.modal.unbound.unbound"}}</h2>
        <p>{{i18n "collections.modal.unbound.unbound_desc"}}</p>
        <ul>
          {{#each this.unboundedTopics as |t|}}
            <li>
              <a href={{t.url}} class="collection-modal__link">
                {{t.title}}
              </a>
            </li>
          {{else}}
            {{i18n "collections.modal.unbound.NA"}}
          {{/each}}
        </ul>
        <hr />
        <h2>{{i18n "collections.modal.unbound.orphaned"}}</h2>
        <p>{{i18n "collections.modal.unbound.orphaned_desc"}}</p>
        <ul>
          {{#each this.orphanedTopics as |t|}}
            <li>
              <a href={{t.url}} class="collection-modal__link">
                {{t.title}}
              </a>
            </li>
          {{else}}
            {{i18n "collections.modal.unbound.NA"}}
          {{/each}}
        </ul>
      </:body>
    </DModal>
  </template>
}
