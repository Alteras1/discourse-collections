/**
 * This is a copy of app/assets/javascripts/admin/addon/components/color-input.gjs
 * and a workaround for the component being admin-only.
 */

import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import DTextField from "discourse/ui-kit/d-text-field";

/**
  An input field for a color.

  @param hexValue is a reference to the color's hex value.
  @param brightnessValue is a number from 0 to 255 representing the brightness of the color. See ColorSchemeColor.
  @params valid is a boolean indicating if the input field is a valid color.
**/

export default class ColorInput extends Component {
  get onlyHex() {
    return this.args.onlyHex ?? true;
  }

  get maxlength() {
    return this.onlyHex ? 6 : null;
  }

  get normalizedHexValue() {
    return this.#normalize(this.args.hexValue);
  }

  #normalize(color) {
    if (this.#valid(color)) {
      if (!color.startsWith("#")) {
        color = "#" + color;
      }
      if (color.length === 4) {
        color =
          "#" +
          color
            .slice(1)
            .split("")
            .map((hex) => hex + hex)
            .join("");
      }
    }
    return color;
  }

  #valid(color = this.args.hexValue) {
    return /^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/.test(color);
  }

  @action
  onHexInput(event) {
    this.args.onChangeColor?.(this.#normalize(event.target.value || ""));
  }

  @action
  onPickerInput(event) {
    this.args.onChangeColor?.(event.target.value.replace("#", ""));
  }

  @action
  handleBlur() {
    this.args.onBlur?.(this.#normalize(this.args.hexValue));
  }

  <template>
    <div class="color-picker">
      {{#if this.onlyHex}}<span class="add-on">#</span>{{/if}}<DTextField
        @value={{@hexValue}}
        @maxlength={{this.maxlength}}
        @input={{this.onHexInput}}
        class="hex-input"
        aria-labelledby={{@ariaLabelledby}}
        {{on "blur" this.handleBlur}}
      />
      <input
        class="picker"
        type="color"
        value={{this.normalizedHexValue}}
        {{on "input" this.onPickerInput}}
        aria-labelledby={{@ariaLabelledby}}
      />
    </div>
  </template>
}
