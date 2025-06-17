import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { hash } from "@ember/helper";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { not } from "truth-helpers";
import DButton from "discourse/components/d-button";
import avatar from "discourse/helpers/avatar";
import { bind } from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";
import UserChooser from "select-kit/components/user-chooser";

export default class OwnerMaintainerForm extends Component {
  @service siteSettings;
  @service site;

  @tracked changeOwner = false;
  @tracked tempOwner;
  @tracked tempOwnerUsername;

  get canEditOwner() {
    const groups = this.site.currentUser.groups.map((i) => i.id);
    return this.siteSettings.collection_modification_by_allowed_groups
      .split("|")
      .map((i) => parseInt(i, 10))
      .some((i) => groups.includes(i));
  }

  get ownerUsername() {
    return [this.args.transformedModel.owner.username];
  }

  @bind
  enableChangeOwner() {
    this.changeOwner = true;
    this.tempOwner = this.args.transformedModel.owner;
    this.tempOwnerUsername = [this.args.transformedModel.owner.username];
  }

  @bind
  updateTempOwner([username], [user]) {
    this.tempOwner = user;
    this.tempOwnerUsername = username;
  }

  @bind
  setNewOwner() {
    this.args.transformedModel.owner = this.tempOwner;
    this.tempOwner = undefined;
    this.tempOwnerUsername = undefined;
    this.changeOwner = false;
  }

  @bind
  cancelNewOwner() {
    this.tempOwner = undefined;
    this.tempOwnerUsername = undefined;
    this.changeOwner = false;
  }

  @action
  setMaintainers(usernames, users) {
    this.args.transformedModel.maintainers = users;
  }

  <template>
    <div class="collection-modal-form__input-wrapper users">
      <div class="owner">
        <label for="collection-owner">
          {{i18n "collections.form.owner"}}
        </label>
        {{#if this.changeOwner}}
          <UserChooser
            @value={{this.tempOwnerUsername}}
            @onChange={{this.updateTempOwner}}
            @options={{hash
              maximum=1
              filterPlaceholder="topic.change_owner.placeholder"
              excludeCurrentUser=false
            }}
          />
          <DButton
            @action={{this.setNewOwner}}
            @icon="check"
            @ariaLabel="admin.settings.save"
            @disabled={{not this.tempOwner}}
            class="ok confirm-cancel"
          />
          <DButton
            @action={{this.cancelNewOwner}}
            @icon="xmark"
            @ariaLabel="admin.settings.cancel"
            class="cancel confirm-cancel"
          />
        {{else}}
          <a
            class="collection-modal-form__owner"
            href={{this.ownerPath}}
            data-user-card={{@transformedModel.owner.username}}
          >
            {{avatar @transformedModel.owner imageSize="small"}}
            {{@transformedModel.owner.username}}
          </a>
          {{#if this.canEditOwner}}
            <DButton
              @action={{this.enableChangeOwner}}
              @title="collections.form.change_owner"
              @icon="pen"
              @ariaLabel="collections.form.change_owner"
              class="btn-small edit-owner"
            />
          {{/if}}
        {{/if}}
      </div>
      <div class="maintainers">
        <label for="collection-maintainers">
          {{i18n "collections.form.maintainers"}}
        </label>
        <UserChooser
          @value={{@transformedModel.maintainer_usernames}}
          @onChange={{@setMaintainersCallback}}
          @options={{hash excludeCurrentUser=false}}
        />
      </div>
    </div>
  </template>
}
