import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { Input } from "@ember/component";
import { fn, hash } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { not } from "truth-helpers";
import DButton from "discourse/components/d-button";
import concatClass from "discourse/helpers/concat-class";
import icon from "discourse/helpers/d-icon";
import withEventValue from "discourse/helpers/with-event-value";
import discourseLater from "discourse/lib/later";
import { i18n } from "discourse-i18n";
import IconPicker from "select-kit/components/icon-picker";
import UrlTopicChooser from "./url-topic-chooser";

export default class CollectionItemForm extends Component {
  /** @type {string} */
  @tracked dragCssClass;
  @tracked draggable = false;
  dragCount = 0;

  /**
   * @type {CollectionItem}
   */
  get link() {
    return this.args.link;
  }

  @action
  onChangeURL(id, selected) {
    if (!selected) {
      this.link.urlName = "";
      this.link.url = null;
      return;
    }
    let urlName = "";
    if (selected.isLiteral) {
      this.link.url = selected.name;
    } else {
      this.link.url = selected.url;
    }
    urlName = selected.fancy_title;
    this.link.urlName = urlName;
  }

  isAboveElement(event) {
    event.preventDefault();
    const target = event.currentTarget;
    const domRect = target.getBoundingClientRect();
    return event.offsetY < domRect.height / 2;
  }

  @action
  enableDrag() {
    this.draggable = true;
  }

  @action
  disableDrag() {
    this.draggable = false;
  }

  @action
  dragHasStarted(event) {
    event.dataTransfer.effectAllowed = "move";
    this.args.setDraggedLinkCallback(this.link);
    this.dragCssClass = "dragging";
  }

  @action
  dragOver(event) {
    event.preventDefault();
    if (this.dragCssClass !== "dragging") {
      if (this.isAboveElement(event)) {
        this.dragCssClass = "drag-above";
      } else {
        this.dragCssClass = "drag-below";
      }
    }
  }

  @action
  dragEnter() {
    this.dragCount++;
  }

  @action
  dragLeave() {
    this.dragCount--;
    if (
      this.dragCount === 0 &&
      (this.dragCssClass === "drag-above" || this.dragCssClass === "drag-below")
    ) {
      discourseLater(() => {
        this.dragCssClass = null;
      }, 10);
    }
  }

  @action
  dropItem(event) {
    event.stopPropagation();
    this.dragCount = 0;
    this.args.reorderCallback(this.args.link, this.isAboveElement(event));
    this.dragCssClass = null;
  }

  @action
  dragEnd() {
    this.dragCount = 0;
    this.dragCssClass = null;
    this.disableDrag();
  }

  <template>
    <div
      {{on "dragstart" this.dragHasStarted}}
      {{on "dragover" this.dragOver}}
      {{on "dragenter" this.dragEnter}}
      {{on "dragleave" this.dragLeave}}
      {{on "dragend" this.dragEnd}}
      {{on "drop" this.dropItem}}
      role="row"
      data-row-id={{@link.objectId}}
      draggable={{this.draggable}}
      class={{concatClass
        "sidebar-section-form-link"
        "row-wrapper"
        (if
          @link.isSectionHeader
          "collection-item__section-header"
          "collection-item__item"
        )
        this.dragCssClass
      }}
    >
      {{#if @link.isSectionHeader}}
        <div class="input-group section-name">
          <label>{{i18n "collections.form.section_header"}}</label>
        </div>
      {{/if}}

      <div
        {{on "mousedown" this.enableDrag}}
        {{on "touchstart" this.enableDrag}}
        {{on "mouseup" this.disableDrag}}
        {{on "touchend" this.disableDrag}}
        class="draggable"
        data-link-name={{@link.name}}
      >
        {{icon "grip-lines"}}
      </div>

      {{#if @link.isSectionHeader}}
        <div
          class="input-group section field__section"
          role="cell"
          aria-colindex="2"
        >
          <Input
            {{on "input" (withEventValue (fn (mut @link.name)))}}
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
          <IconPicker
            @name="icon"
            @value={{@link.icon}}
            @options={{hash
              maximum=1
              caretDownIcon="caret-down"
              caretUpIcon="caret-up"
              icons=@link.icon
            }}
            @onlyAvailable={{true}}
            @onChange={{fn (mut @link.icon)}}
            aria-label={{i18n "collections.form.icon"}}
            class={{@link.iconCssClass}}
          />

          {{#if @link.invalidIconMessage}}
            <div class="icon warning" role="alert" aria-live="assertive">
              {{@link.invalidIconMessage}}
            </div>
          {{/if}}
        </div>

        <div class="input-group field__name" role="cell">
          <Input
            {{on "input" (withEventValue (fn (mut @link.name)))}}
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
              {{on "input" (withEventValue (fn (mut @link.url)))}}
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
              class={{concatClass
                @link.valueCssClass
                (if @link.disabled "disabled" "")
              }}
            >
              <UrlTopicChooser
                @value={{@link.urlName}}
                @url={{@link.url}}
                @onChange={{fn this.onChangeURL}}
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
