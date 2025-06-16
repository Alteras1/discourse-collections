import { tracked } from "@glimmer/tracking";
import { isEmpty } from "@ember/utils";
import { i18n } from "discourse-i18n";
import { COLLECTION_URL } from "../../constants";

export class CollectionItem {
  @tracked icon;
  @tracked name;
  /** @type {string} */
  @tracked url;
  /** @type {number} */
  @tracked position;
  /** @type {string} */
  @tracked urlName;
  @tracked _destroy;

  constructor({
    router,
    id,
    icon,
    name,
    url,
    position,
    isSectionHeader = false,
    objectId,
    urlName,
    canDelete,
    disabled,
  }) {
    this.router = router;
    this.id = id;
    this.icon = icon || (isSectionHeader ? undefined : "collection-pip");
    this.name = name;
    this.url = url;
    this.position = position;
    this.isSectionHeader = isSectionHeader;
    this.httpHost = "http://" + window.location.host;
    this.httpsHost = "https://" + window.location.host;
    this.objectId = objectId;
    this.urlName = urlName;
    this.canDelete = canDelete;
    this.disabled = disabled;
  }

  get path() {
    return this.url?.replace(this.httpHost, "").replace(this.httpsHost, "");
  }

  get valid() {
    if (this.isSectionHeader) {
      return this.validName;
    }
    return this.validIcon && this.validName && this.validValue;
  }

  get validIcon() {
    return !this.#blankIcon && !this.#tooLongIcon;
  }

  get validName() {
    return !this.#blankName && !this.#tooLongName;
  }

  get validValue() {
    return !this.#blankValue && !this.#tooLongValue && !this.#invalidValue;
  }

  get invalidIconMessage() {
    if (this.#blankIcon) {
      return i18n("sidebar.sections.custom.links.icon.validation.blank");
    }
    if (this.#tooLongIcon) {
      return i18n("sidebar.sections.custom.links.icon.validation.maximum", {
        count: COLLECTION_URL.max_icon_length,
      });
    }
  }

  get invalidNameMessage() {
    if (this.name === undefined) {
      return;
    }
    if (this.#blankName) {
      return i18n("sidebar.sections.custom.links.name.validation.blank");
    }
    if (this.#tooLongName) {
      return i18n("sidebar.sections.custom.links.name.validation.maximum", {
        count: COLLECTION_URL.max_name_length,
      });
    }
  }

  get invalidValueMessage() {
    if (this.url === undefined) {
      return;
    }
    if (this.#blankValue) {
      return i18n("sidebar.sections.custom.links.value.validation.blank");
    }
    if (this.#tooLongValue) {
      return i18n("sidebar.sections.custom.links.value.validation.maximum", {
        count: COLLECTION_URL.max_value_length,
      });
    }
    if (this.#invalidValue) {
      return i18n("sidebar.sections.custom.links.value.validation.invalid");
    }
  }

  get iconCssClass() {
    return this.icon === undefined || this.validIcon ? "" : "warning";
  }

  get nameCssClass() {
    return this.name === undefined || this.validName ? "" : "warning";
  }

  get valueCssClass() {
    return this.url === undefined || this.validValue ? "" : "warning";
  }

  get isPrimary() {
    return this.segment === "primary";
  }

  get #blankIcon() {
    return isEmpty(this.icon);
  }

  get #tooLongIcon() {
    return this.icon.length > COLLECTION_URL.max_icon_length;
  }

  get #blankName() {
    return isEmpty(this.name);
  }

  get #tooLongName() {
    return this.name.length > COLLECTION_URL.max_name_length;
  }

  get #blankValue() {
    return isEmpty(this.url);
  }

  get #tooLongValue() {
    return this.url.length > COLLECTION_URL.max_value_length;
  }

  get #invalidValue() {
    return this.path && !this.#validLink();
  }

  #validLink() {
    try {
      return new URL(this.url, document.location.origin);
    } catch {
      return false;
    }
  }
}
