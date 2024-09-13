import Component from "@glimmer/component";
import { cached, tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import Form from "discourse/components/form";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class EditCollectionComponent extends Component {
  @tracked savingStatus = false;

  get isNewCollection() {
    return this.args.editCollection === undefined;
  }

  @cached
  get formData() {
    return {
      collection_name: "",
      collection_description: "",
    };
  }

  @action
  async save(data) {
    try {
      this.savingStatus = true;
      await ajax("/collections", {
        type: "POST",
        data: {
          title: data.collection_name,
          description: data.collection_description,
        },
      });
      this.router.transitionTo("collections");
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.savingStatus = false;
    }
  }

  // get the topic chooser from the create-invite.hbs???

  <template>
    <h1>{{#if this.isNewCollection}}New collection{{else}}Edit collection{{/if}}</h1>
    <Form @data={{this.formData}} @onSubmit={{this.save}} as |form|>
      <form.Field
        @name="collection_name"
        @title="collection name"
        @validation="required|length:3,100"
        @format="large"
        as |field|
      >
        <field.Input />
      </form.Field>
      <form.Field
        @name="collection_description"
        @title="collection description"
        @validation="length:0,1000"
        as |field|
      >
        <field.Textarea />
      </form.Field>

      <form.Submit @label="Create collection" @disabled={{@savingStatus}} />
    </Form>
  </template>
}
