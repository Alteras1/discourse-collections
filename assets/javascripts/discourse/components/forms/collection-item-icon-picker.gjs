import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { concat, fn, hash } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { htmlSafe } from "@ember/template";
import { classNames } from "@ember-decorators/component";
import { eq } from "truth-helpers";
import DToggleSwitch from "discourse/components/d-toggle-switch";
import EmojiPickerDetached from "discourse/components/emoji-picker/detached";
import { isHex } from "discourse/components/sidebar/section-link";
import icon from "discourse/helpers/d-icon";
import replaceEmoji from "discourse/helpers/replace-emoji";
import { i18n } from "discourse-i18n";
import ColorInput from "admin/components/color-input";
import ComboBox from "select-kit/components/combo-box";
import IconPicker from "select-kit/components/icon-picker";
import { selectKitOptions } from "select-kit/components/select-kit";
import DMenu from "float-kit/components/d-menu";

@classNames("collections-detached-icon-picker")
@selectKitOptions({
  headerComponent: <template>
    <summary class="hidden"></summary>
  </template>,
  expandedOnInsert: true,
})
class DetachedIconPicker extends IconPicker {
  search(filter = "") {
    if (filter === null) {
      // js default params don't work with null
      filter = "";
    }
    return super.search(filter);
  }

  // the icon picker likes to scroll to the top on its own after render
  _searchWrapper(filter) {
    super._searchWrapper(filter).then(() => {
      this._safeAfterRender(() => this._scrollToCurrent());
    });
  }

  _close() {
    // noop
  }
}

export default class CollectionItemIconPicker extends Component {
  static iconTypes = [
    { id: "icon", name: i18n("collections.form.icon_picker.icon") },
    {
      id: "emoji",
      name: i18n("collections.form.icon_picker.emoji"),
    },
    {
      id: "square",
      name: i18n("collections.form.icon_picker.square"),
    },
  ];
  @tracked iconType = this.args.iconType;
  @tracked icon = this.args.icon;
  @tracked selectedMenuType = this.args.iconType || "icon";

  get previewValue() {
    if (!this.iconType && !this.icon) {
      return;
    }

    switch (this.iconType) {
      case "emoji":
        return `:${this.icon}:`;
      case "square":
        let hexValues = this.icon;
        hexValues = hexValues.split(",");
        hexValues = hexValues.reduce((acc, color) => {
          const hexCode = isHex(color);

          if (hexCode) {
            acc.push(`#${hexCode} 50%`);
          }

          return acc;
        }, []);

        if (hexValues.length === 1) {
          hexValues.push(hexValues[0]);
        }

        return hexValues.join(", ");
      default:
        return this.icon;
    }
  }

  get previewHexValue0() {
    if (this.iconType !== "square" || !this.icon) {
      return null;
    }
    const colors = this.icon.split(",");
    return colors[0];
  }

  get previewHexValue1() {
    if (this.iconType !== "square" || !this.icon) {
      return null;
    }
    const colors = this.icon.split(",");
    if (colors.length > 1) {
      return colors[1];
    } else {
      return colors[0];
    }
  }

  get squareIsDualColor() {
    if (this.iconType !== "square") {
      return false;
    }
    const colors = this.icon.split(",");
    return colors.length > 1;
  }

  @action
  updateIconIconStyle(icon_value) {
    if (!icon_value || !icon_value.length) {
      this.icon = null;
    } else {
      this.icon = icon_value[icon_value.length - 1];
    }
    this.iconType = "icon";
    this.args.onChange?.(this.icon, this.iconType);
  }

  @action
  updateIconEmojiStyle(emoji) {
    this.icon = emoji;
    this.iconType = "emoji";
    this.args.onChange?.(this.icon, this.iconType);
  }

  @action
  updateIconSquareStyle(color) {
    if (color.startsWith("#")) {
      color = color.substring(1);
    }
    if (this.squareIsDualColor) {
      let colors = this.icon.split(",");
      colors[0] = color;
      this.icon = colors.join(",");
    } else {
      this.icon = color;
    }
    this.iconType = "square";
    this.args.onChange?.(this.icon, this.iconType);
  }

  @action
  updateIconSquareStyleDual(color) {
    if (color.startsWith("#")) {
      color = color.substring(1);
    }
    let colors = this.icon.split(",");
    if (colors.length === 1) {
      colors.push(color);
    } else {
      colors[1] = color;
    }
    this.icon = colors.join(",");
    this.iconType = "square";
    this.args.onChange?.(this.icon, this.iconType);
  }

  @action
  toggleSquareIsDualColor() {
    if (this.squareIsDualColor) {
      this.icon = this.previewHexValue0;
      this.updateIconSquareStyle(this.previewHexValue0);
    } else {
      this.updateIconSquareStyleDual("000000");
    }
  }

  <template>
    <DMenu
      @triggerClass="btn btn-default btn-icon-picker"
      @contentClass="collection-item-icon-picker"
      @identifier="collection-item-icon-picker"
      @inline="true"
    >
      <:trigger>
        {{#if (eq this.iconType "icon")}}
          {{icon this.previewValue class="prefix-icon"}}
        {{else if (eq this.iconType "emoji")}}
          {{replaceEmoji this.previewValue class="prefix-emoji"}}
        {{else if (eq this.iconType "square")}}
          <span
            style={{htmlSafe
              (concat
                "background: linear-gradient(90deg, " this.previewValue ")"
              )
            }}
            class="prefix-square"
          ></span>
        {{/if}}
      </:trigger>

      <:content>
        <ComboBox
          @value={{this.selectedMenuType}}
          @content={{this.constructor.iconTypes}}
          @onChange={{fn (mut this.selectedMenuType)}}
          class="collection-item-icon-picker__icon-types"
        />
        {{#if (eq this.selectedMenuType "icon")}}
          <DetachedIconPicker
            @onlyAvailable={{true}}
            @value={{if (eq this.selectedMenuType "icon") this.icon}}
            @options={{hash icons=this.icon}}
            @onChange={{this.updateIconIconStyle}}
          />
        {{else if (eq this.selectedMenuType "emoji")}}
          <EmojiPickerDetached
            @data={{hash didSelectEmoji=this.updateIconEmojiStyle}}
          />
        {{else if (eq this.selectedMenuType "square")}}
          <div class="collection-item-icon-picker__color">
            <ColorInput
              @hexValue={{readonly this.previewHexValue0}}
              @onChangeColor={{this.updateIconSquareStyle}}
              @fallbackHexValue="000000"
            />
            <DToggleSwitch
              @state={{this.squareIsDualColor}}
              {{on "click" this.toggleSquareIsDualColor}}
              @label="collections.form.icon_picker.dual_color"
            />
            {{#if this.squareIsDualColor}}
              <ColorInput
                @hexValue={{readonly this.previewHexValue1}}
                @onChangeColor={{this.updateIconSquareStyleDual}}
                @fallbackHexValue="000000"
              />
            {{/if}}
          </div>
        {{/if}}
      </:content>
    </DMenu>
  </template>
}
