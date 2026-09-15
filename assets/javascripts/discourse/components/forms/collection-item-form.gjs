import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { Input } from "@ember/component";
import { fn, hash } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import withEventValue from "discourse/helpers/with-event-value";
import { not } from "discourse/truth-helpers";
import DButton from "discourse/ui-kit/d-button";
import dConcatClass from "discourse/ui-kit/helpers/d-concat-class";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import dDragAndDropSource from "discourse/ui-kit/modifiers/d-drag-and-drop-source";
import dDragAndDropTarget from "discourse/ui-kit/modifiers/d-drag-and-drop-target";
import { i18n } from "discourse-i18n";
import CollectionItemIconPicker from "./collection-item-icon-picker";
import UrlTopicChooser from "./url-topic-chooser";

export default class CollectionItemForm extends Component {
  @tracked dragHandleEl = null;

  /**
   * @type {CollectionItem}
   */
  get link() {
    return this.args.link;
  }

  @action
  captureDragHandle(el) {
    this.dragHandleEl = el;
  }

  @action
  handleDrop({ source, position }) {
    this.args.reorderCallback(
      source.data.link,
      this.args.link,
      position === "before"
    );
  }

  @action
  onChangeURL(id, selected) {
    if (!selected) {
      this.link.urlName = "";
      this.link.url = null;
      return;
    }
    if (selected.isLiteral) {
      this.link.url = selected.name;
    } else {
      this.link.url = selected.url;
    }
    this.link.urlName = selected.fancy_title;
  }

  @action
  onChangeIcon(icon_value, iconType) {
    this.link.icon = icon_value;
    this.link.icon_type = iconType;
  }

  @action
  setLinkName(value) {
    this.args.link.name = value;
  }

  @action
  setLinkUrl(value) {
    this.args.link.url = value;
  }

  <template>
    {{! eslint-disable ember/template-no-nested-interactive }}
    <div
      {{dDragAndDropSource
        type="collection-item"
        data=(hash link=this.link)
        dragHandle=this.dragHandleEl
      }}
      {{dDragAndDropTarget
        accepts="collection-item"
        acceptsSelf=false
        onDrop=this.handleDrop
      }}
      role="row"
      data-row-id={{@link.objectId}}
      class={{dConcatClass
        "sidebar-section-form-link"
        "row-wrapper"
        (if
          @link.isSectionHeader
          "collection-item__section-header"
          "collection-item__item"
        )
      }}
    >
      {{#if @link.isSectionHeader}}
        <div class="input-group section-name">
          <label>{{i18n "collections.form.section_header"}}</label>
        </div>
      {{/if}}

      <div
        {{didInsert this.captureDragHandle}}
        class="draggable"
        data-link-name={{@link.name}}
      >
        {{dIcon "grip-lines"}}
      </div>

      {{#if @link.isSectionHeader}}
        <div
          class="input-group section field__section"
          role="cell"
          aria-colindex="2"
        >
          <Input
            {{on "input" (withEventValue this.setLinkName)}}
            @type="text"
            @value={{@link.name}}
            name="section-header-name"
            aria-label={{i18n "collections.form.section_header"}}
          />

          {{#if @link.invalidNameMessage}}
            <div role="alert" aria-live="assertive" class="name warning">
              {{@link.invalidNameMessage}}
            </div>
          {{/if}}
        </div>
      {{else}}
        <div class="input-group field__icon" role="cell">
          <CollectionItemIconPicker
            @iconType={{@link.icon_type}}
            @icon={{@link.icon}}
            @onChange={{this.onChangeIcon}}
          />

          {{#if @link.invalidIconMessage}}
            <div class="icon warning" role="alert" aria-live="assertive">
              {{@link.invalidIconMessage}}
            </div>
          {{/if}}
        </div>

        <div class="input-group field__name" role="cell">
          <Input
            {{on "input" (withEventValue this.setLinkName)}}
            @type="text"
            @value={{@link.name}}
            placeholder={{i18n "collections.form.name"}}
            name="link-name"
            aria-label={{i18n "collections.form.name"}}
            class={{@link.nameCssClass}}
            data-1p-ignore
          />

          {{#if @link.invalidNameMessage}}
            <div role="alert" aria-live="assertive" class="name warning">
              {{@link.invalidNameMessage}}
            </div>
          {{/if}}
        </div>

        <div class="input-group field__url" role="cell">
          {{#if @isSubcollection}}
            <Input
              {{on "input" (withEventValue this.setLinkUrl)}}
              @type="text"
              @value={{@link.url}}
              placeholder={{i18n "collections.form.link"}}
              name="link-url"
              aria-label={{i18n "collections.form.link"}}
              class={{@link.valueCssClass}}
              readonly={{@link.disabled}}
            />
          {{else}}
            <span
              data-value={{@link.urlName}}
              data-placeholder={{i18n "collections.form.link"}}
              class={{dConcatClass
                @link.valueCssClass
                (if @link.disabled "disabled" "")
              }}
            >
              <UrlTopicChooser
                @value={{@link.urlName}}
                @url={{@link.url}}
                @onChange={{this.onChangeURL}}
              />
            </span>
          {{/if}}

          {{#if @link.invalidValueMessage}}
            <div role="alert" aria-live="assertive" class="value warning">
              {{@link.invalidValueMessage}}
            </div>
          {{/if}}

        </div>
      {{/if}}

      <DButton
        @icon="trash-can"
        @action={{fn @deleteLink @link}}
        @title="delete"
        role="cell"
        class="btn-flat delete-link"
        disabled={{not @link.canDelete}}
      />

      {{#if @link.isSectionHeader}}
        <div class="input-group link-icon next-labels">
          <label>{{i18n "collections.form.icon"}}</label>
        </div>

        <div class="input-group link-name next-labels">
          <label>{{i18n "collections.form.name"}}</label>
        </div>

        <div class="input-group link-url next-labels">
          <label>{{i18n "collections.form.link"}}</label>
        </div>
      {{/if}}
    </div>
  </template>
}
