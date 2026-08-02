import { render } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import { CollectionItem } from "discourse/plugins/discourse-collections/discourse/components/forms/collection-item";
import CollectionItemForm from "discourse/plugins/discourse-collections/discourse/components/forms/collection-item-form";

module(
  "Integration | Component | Forms | CollectionItemForm",
  function (hooks) {
    setupRenderingTest(hooks);

    hooks.beforeEach(function () {
      const router = this.owner.lookup("service:router");

      this.deleteLink = () => {};
      this.reorderCallback = () => {};
      this.setDraggedLinkCallback = () => {};

      this.link = new CollectionItem({
        router,
        objectId: 1,
        name: "Link name",
        url: "/t/example-topic/123",
        urlName: "Example topic",
        position: 0,
        canDelete: true,
      });
    });

    test("renders the topic chooser for collection items", async function (assert) {
      await render(
        <template>
          <CollectionItemForm
            @link={{this.link}}
            @isSubcollection={{false}}
            @deleteLink={{this.deleteLink}}
            @reorderCallback={{this.reorderCallback}}
            @setDraggedLinkCallback={{this.setDraggedLinkCallback}}
          />
        </template>
      );

      assert
        .dom(".url-topic-chooser")
        .exists("renders the topic chooser for main collection items");
      assert
        .dom('input[name="link-url"]')
        .doesNotExist(
          "does not render a plain URL input for main collection items"
        );
    });

    test("renders a plain URL input for subcollection items", async function (assert) {
      await render(
        <template>
          <CollectionItemForm
            @link={{this.link}}
            @isSubcollection={{true}}
            @deleteLink={{this.deleteLink}}
            @reorderCallback={{this.reorderCallback}}
            @setDraggedLinkCallback={{this.setDraggedLinkCallback}}
          />
        </template>
      );

      assert
        .dom('input[name="link-url"]')
        .exists("renders a plain URL input for subcollection items");
      assert
        .dom(".url-topic-chooser")
        .doesNotExist(
          "does not render the topic chooser for subcollection items"
        );
    });
  }
);
