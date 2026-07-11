import { click, visit } from "@ember/test-helpers";
import { test } from "qunit";
import {
  acceptance,
  updateCurrentUser,
} from "discourse/tests/helpers/qunit-helpers";

acceptance("Collections | Topic admin menu", function (needs) {
  needs.user();
  needs.settings({
    collections_enabled: true,
  });

  test("hides collections buttons when the user cannot create or manage collections", async function (assert) {
    updateCurrentUser({ moderator: false, admin: false, trust_level: 1 });

    await visit("/t/topic-for-group-moderators/2480");
    await click(".toggle-admin-menu");

    assert
      .dom(".topic-admin-collections")
      .doesNotExist(
        "does not show the collection button without collection permissions"
      );
    assert
      .dom(".topic-admin-subcollections")
      .doesNotExist(
        "does not show the subcollection button without collection permissions"
      );
  });
});
