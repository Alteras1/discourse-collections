import Component from "@glimmer/component";
import { cached, tracked } from "@glimmer/tracking";
import { A } from "@ember/array";
import { Input, Textarea } from "@ember/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { not } from "truth-helpers";
import DButton from "discourse/components/d-button";
import DModal from "discourse/components/d-modal";
import withEventValue from "discourse/helpers/with-event-value";
import { ajax } from "discourse/lib/ajax";
import { extractError } from "discourse/lib/ajax-error";
import { afterRender, bind } from "discourse/lib/decorators";
import { sanitize } from "discourse/lib/text";
import { userPath } from "discourse/lib/url";
import { i18n } from "discourse-i18n";
import { CollectionItem } from "../forms/collection-item";
import CollectionItemForm from "../forms/collection-item-form";
import OwnerMaintainerForm from "../forms/owner-maintainer-form";

class CollectionFormData {
  /** @type {CollectionItem[]} */
  @tracked list;
  @tracked title;
  @tracked desc;
  @tracked owner;
  @tracked maintainers;

  constructor({ list, title, desc, owner, maintainers }) {
    this.list = list;
    this.title = title;
    this.desc = desc;
    this.owner = owner;
    this.maintainers = maintainers;
  }

  get ownerPath() {
    return userPath(this.owner.username);
  }

  get maintainer_usernames() {
    return this.maintainers.mapBy("username");
  }

  get valid() {
    const allLinks = this.list.filter((link) => !link._destroy);
    const validLinks =
      allLinks.length > 0 && allLinks.every((link) => link.valid);
    return validLinks;
  }
}

export default class CollectionForm extends Component {
  @service dialog;
  @service currentUser;
  @service router;
  @service siteSettings;

  @tracked flash;
  @tracked flashType;
  @tracked isLoading = false;

  /** @type {boolean} */
  @tracked isSubcollection = this.args.model.isSubcollection;
  @tracked topic = this.args.model.topic;
  /** @type {boolean} */
  @tracked edit = !!this.args.model.collection;

  nextObjectId = 0;

  get modalTitle() {
    if (this.isSubcollection) {
      if (this.edit) {
        return "collections.post_menu.manage_subcollection";
      } else {
        return "collections.post_menu.create_subcollection";
      }
    } else {
      if (this.edit) {
        return "collections.post_menu.manage_collection";
      } else {
        return "collections.post_menu.create_collection";
      }
    }
  }

  @cached
  get transformedModel() {
    /** @type {Collection} */
    const collection = this.args.model.collection;
    if (!collection) {
      return new CollectionFormData({
        owner: this.topic.details.created_by,
        maintainers: [],
        list: A([
          new CollectionItem({
            router: this.router,
            objectId: this.nextObjectId++,
            url: this.topic.url,
            urlName: this.topic.title,
            canDelete: false,
            disabled: true,
          }),
        ]),
      });
    }

    return new CollectionFormData({
      title: collection.title,
      desc: collection.desc,
      owner: collection.owner,
      maintainers: collection.maintainers,
      list: A(
        collection.collection_items.map((item) => {
          return new CollectionItem({
            router: this.router,
            id: item.id,
            icon: item.icon,
            name: item.name,
            url: item.url,
            position: item.position,
            isSectionHeader: item.is_section_header,
            objectId: this.nextObjectId++,
            urlName: item.topic_name || item.url,
            canDelete: item.can_delete_collection_item,
          });
        })
      ),
    });
  }

  get activeItems() {
    return this.transformedModel.list.filter((item) => !item._destroy);
  }

  @action
  setMaintainers(usernames, users) {
    this.transformedModel.maintainers = users;
  }

  @action
  addLink() {
    this.transformedModel.list.pushObject(
      new CollectionItem({
        router: this.router,
        objectId: this.nextObjectId++,
        canDelete: true,
      })
    );
    this.focusNewRowInput(this.nextObjectId - 1);
  }

  @action
  addSectionHeader() {
    this.transformedModel.list.pushObject(
      new CollectionItem({
        router: this.router,
        objectId: this.nextObjectId++,
        isSectionHeader: true,
        canDelete: true,
      })
    );
    this.focusNewRowInput(this.nextObjectId - 1);
  }

  @afterRender
  focusNewRowInput(id) {
    document
      .querySelector(
        `[data-row-id="${id}"] .icon-picker summary, [data-row-id="${id}"] input`
      )
      ?.focus();
  }

  @bind
  deleteLink(link) {
    if (link.id) {
      link._destroy = "1";
    } else {
      this.transformedModel.list.removeObject(link);
    }
  }

  @bind
  setDraggedLink(link) {
    this.draggedLink = link;
  }

  @bind
  reorder(targetLink, above) {
    if (this.draggedLink === targetLink) {
      return;
    }

    this.transformedModel.list.removeObject(this.draggedLink);

    const toPosition = this.transformedModel.list.indexOf(targetLink);
    this.transformedModel.list.insertAt(
      above ? toPosition : toPosition + 1,
      this.draggedLink
    );
  }

  setPositions() {
    this.activeItems.forEach((item, i) => {
      item.position = i;
    });
  }

  @action
  create() {
    this.isLoading = true;
    this.setPositions();
    const body = {
      title: this.transformedModel.title,
      desc: this.transformedModel.desc,
      user_id: this.transformedModel.owner.id,
      is_single_topic: this.isSubcollection,
      maintainer_ids: this.transformedModel.maintainers.mapBy("id"),
      items: this.transformedModel.list.map((item) => {
        return {
          name: item.name,
          icon: item.icon,
          url: item.url,
          position: item.position,
          is_section_header: item.isSectionHeader,
        };
      }),
    };
    if (this.isSubcollection) {
      body.topic_id = this.topic.id;
    }
    return ajax("/collections", {
      type: "POST",
      contentType: "application/json",
      dataType: "json",
      data: JSON.stringify(body),
    })
      .then(() => {
        this.args.closeModal();
      })
      .catch((e) => {
        this.flash = sanitize(extractError(e));
        this.flashType = "error";
        this.isLoading = false;
      });
  }

  @action
  update() {
    this.isLoading = true;
    this.setPositions();
    const body = {
      title: this.transformedModel.title,
      desc: this.transformedModel.desc,
      user_id: this.transformedModel.owner.id,
      is_single_topic: this.isSubcollection,
      maintainer_ids: this.transformedModel.maintainers.mapBy("id"),
      items: this.transformedModel.list.map((item) => {
        return {
          id: item.id,
          name: item.name,
          icon: item.icon,
          url: item.url,
          position: item.position,
          is_section_header: item.isSectionHeader,
          _destroy: item._destroy,
        };
      }),
    };
    if (this.isSubcollection) {
      body.topic_id = this.topic.id;
    }
    return ajax(`/collections/${this.args.model.collection.id}`, {
      type: "PUT",
      contentType: "application/json",
      dataType: "json",
      data: JSON.stringify(body),
    })
      .then(() => {
        this.args.closeModal();
      })
      .catch((e) => {
        this.flash = sanitize(extractError(e));
        this.flashType = "error";
        this.isLoading = false;
      });
  }

  @action
  delete() {
    return this.dialog.yesNoConfirm({
      message: i18n("sidebar.sections.custom.delete_confirm"),
      didConfirm: () => {
        return ajax(`/collections/${this.args.model.collection.id}`, {
          type: "DELETE",
        })
          .then(() => {
            this.args.closeModal();
          })
          .catch((e) => {
            this.flash = sanitize(extractError(e));
            this.flashType = "error";
            this.isLoading = false;
          });
      },
    });
  }

  <template>
    <DModal
      @closeModal={{@closeModal}}
      @title={{i18n this.modalTitle}}
      @flash={{this.flash}}
      @flashType={{this.flashType}}
      class="collection-modal"
      @bodyClass="collection-modal__body"
    >
      <:body>
        <form class="form-horizontal">
          <p class="collection-modal__desc">{{i18n
              (if
                this.isSubcollection
                "collections.form.subcollection_desc"
                "collections.form.collection_desc"
              )
            }}</p>

          {{#if this.isSubcollection}}
            {{#if this.siteSettings.collection_by_topic_owner}}
              <OwnerMaintainerForm
                @transformedModel={{this.transformedModel}}
                @setMaintainersCallback={{this.setMaintainers}}
              />
            {{/if}}
          {{else}}
            <div class="collection-modal-form__input-wrapper">
              <label for="collection-name">
                {{i18n "collections.form.collection_title"}}
              </label>
              <Input
                name="collection-name"
                @type="text"
                @value={{this.transformedModel.title}}
                id="collection-name"
                {{on
                  "input"
                  (withEventValue (fn (mut this.transformedModel.title)))
                }}
              />
            </div>

            <details class="collection-modal-form__details">
              <summary>
                <span>{{i18n "collections.form.details"}}</span>
              </summary>

              <div class="collection-modal-form__input-wrapper">
                {{! template-lint-disable no-nested-interactive}}
                <label for="collection-desc">
                  {{i18n "collections.form.custom_desc"}}
                </label>
                <Textarea
                  name="collection-desc"
                  @value={{this.transformedModel.desc}}
                  id="collection-desc"
                  rows="2"
                  {{on
                    "input"
                    (withEventValue (fn (mut this.transformedModel.desc)))
                  }}
                />
              </div>

              {{#if this.siteSettings.collection_by_topic_owner}}
                <OwnerMaintainerForm
                  @transformedModel={{this.transformedModel}}
                  @setMaintainersCallback={{this.setMaintainers}}
                />
              {{/if}}
            </details>
          {{/if}}

          <div
            role="table"
            aria-rowcount={{this.activeLinks.length}}
            class="sidebar-section-form__links-wrapper"
          >
            <div class="row-wrapper header primary-header" role="row">
              <div
                class="input-group link-icon"
                role="columnheader"
                aria-sort="none"
              >
                <label>{{i18n "collections.form.icon"}}</label>
              </div>
              <div
                class="input-group link-name"
                role="columnheader"
                aria-sort="none"
              >
                <label>{{i18n "collections.form.name"}}</label>
              </div>
              <div
                class="input-group link-url"
                role="columnheader"
                aria-sort="none"
              >
                <label>{{i18n "collections.form.link"}}</label>
              </div>
            </div>

            {{#each this.activeItems as |item|}}
              <CollectionItemForm
                @link={{item}}
                @isSubcollection={{this.isSubcollection}}
                @deleteLink={{this.deleteLink}}
                @reorderCallback={{this.reorder}}
                @setDraggedLinkCallback={{this.setDraggedLink}}
              />
            {{/each}}

          </div>

          {{#unless this.isSubcollection}}
            <DButton
              @action={{this.addSectionHeader}}
              @title="collections.form.add_section_header"
              @icon="plus"
              @label="collections.form.add_section_header"
              @ariaLabel="collections.form.add_section_header"
              class="btn-flat btn-text add-link"
            />
          {{/unless}}

          <DButton
            @action={{this.addLink}}
            @title="collections.form.add_link"
            @icon="plus"
            @label="collections.form.add_link"
            @ariaLabel="collections.form.add_link"
            class="btn-flat btn-text add-link"
          />
        </form>
      </:body>
      <:footer>
        {{#if this.edit}}
          <DButton
            @label="collections.form.save"
            @action={{this.update}}
            @disabled={{not this.transformedModel.valid}}
            @isLoading={{this.isLoading}}
            class="btn-primary"
          />
        {{else}}
          <DButton
            @label="collections.form.create"
            @action={{this.create}}
            @disabled={{not this.transformedModel.valid}}
            @isLoading={{this.isLoading}}
            class="btn-primary"
          />
        {{/if}}

        <div class="cancel-wrapper">
          <DButton
            @action={{@closeModal}}
            @title="cancel"
            @label="cancel"
            @ariaLabel="cancel"
            class="btn-flat btn-text"
          />
        </div>
        {{#if @model.collection.can_delete_collection}}
          <DButton
            @icon="trash-can"
            @action={{this.delete}}
            @label="delete"
            @ariaLabel="delete"
            id="delete-section"
            class="btn-danger delete"
          />
        {{/if}}
      </:footer>
    </DModal>
  </template>
}
