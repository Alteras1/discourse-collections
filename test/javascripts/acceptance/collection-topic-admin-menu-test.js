import { click, visit } from "@ember/test-helpers";
import { test } from "qunit";
import { cloneJSON } from "discourse/lib/object";
import topicFixtures from "discourse/tests/fixtures/topic";
import {
  acceptance,
  currentUser,
  updateCurrentUser,
} from "discourse/tests/helpers/qunit-helpers";
import selectKit from "discourse/tests/helpers/select-kit-helper";

const maintainerUsers = {
  101: {
    id: 101,
    username: "maintainer_a",
    name: "Maintainer A",
    avatar_template: "/letter_avatar_proxy/v4/letter/m/111111/{size}.png",
  },
  102: {
    id: 102,
    username: "maintainer_b",
    name: "Maintainer B",
    avatar_template: "/letter_avatar_proxy/v4/letter/m/222222/{size}.png",
  },
};

function collectionResponse(
  maintainers,
  owner = currentUser(),
  canEditMaintainers = true
) {
  return {
    id: 1,
    title: "Collection",
    desc: "Collection description",
    owner: {
      id: owner.id,
      username: owner.username,
      name: owner.name,
      avatar_template: owner.avatar_template,
    },
    maintainers,
    collection_items: [
      {
        id: 1,
        icon: null,
        icon_type: null,
        name: "Topic",
        url: "/t/topic-for-group-moderators/2480",
        position: 0,
        is_section_header: false,
        can_delete_collection_item: true,
        topic_name: "Topic",
      },
    ],
    can_edit_collection: true,
    can_edit_maintainers: canEditMaintainers,
  };
}

acceptance("Collections | Topic admin menu", function (needs) {
  let savedMaintainerIds;

  needs.user();
  needs.settings({
    collections_enabled: true,
  });
  needs.pretender((server, helper) => {
    let collectionMaintainers = [maintainerUsers[101]];

    function topicResponse() {
      const response = cloneJSON(topicFixtures["/t/2480/1.json"]);
      if (currentUser().username === "maintainer_a") {
        response.collection = collectionResponse(collectionMaintainers);
      }

      return response;
    }

    server.get("/u/search/users", () => {
      return helper.response({
        users: Object.values(maintainerUsers),
      });
    });

    server.get("/t/2480.json", () => {
      return helper.response(topicResponse());
    });

    server.get("/t/2480", () => {
      return helper.response(topicResponse());
    });

    server.put("/collections/1", (request) => {
      const payload = JSON.parse(request.requestBody);
      savedMaintainerIds = payload.maintainer_ids;
      collectionMaintainers = payload.maintainer_ids.map((id) => {
        return maintainerUsers[id];
      });

      return helper.response({ success: true });
    });
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

  test("shows collection admin controls for maintainers", async function (assert) {
    updateCurrentUser({
      id: 101,
      username: "maintainer_a",
      moderator: false,
      admin: false,
      trust_level: 1,
      groups: [{ id: 123, name: "regular_users" }],
    });
    this.siteSettings.collection_modification_by_allowed_groups = "9999";

    await visit("/t/topic-for-group-moderators/2480");

    const topic = this.owner.lookup("controller:topic").model;
    topic.set("can_create_collection", false);
    topic.set("collection", { can_edit_collection: true });
    topic.set("subcollection", null);

    await click(".toggle-admin-menu");

    assert
      .dom(".topic-admin-collections")
      .exists("shows the collection button for maintainers");
  });

  test("saves multiple maintainers through the collection modal", async function (assert) {
    updateCurrentUser({
      username: "maintainer_a",
      moderator: false,
      admin: false,
      trust_level: 1,
    });

    await visit("/t/topic-for-group-moderators/2480");

    const topic = this.owner.lookup("controller:topic").model;
    topic.set("collection", collectionResponse([maintainerUsers[101]]));
    topic.set("subcollection", null);

    await click(".toggle-admin-menu");
    await click(".topic-admin-collections");

    const maintainers = selectKit(
      ".collection-modal .maintainers .user-chooser"
    );
    assert.strictEqual(maintainers.header().name(), "maintainer_a");
    await maintainers.expand();
    await maintainers.fillInFilter("maintainer");
    await maintainers.selectRowByValue("maintainer_b");

    await click(".collection-modal .btn-primary");
    assert.deepEqual(savedMaintainerIds, [101, 102]);
  });

  test("shows maintainer list as read-only for maintainers who are not the owner", async function (assert) {
    updateCurrentUser({
      username: "maintainer_a",
      moderator: false,
      admin: false,
      trust_level: 1,
    });

    await visit("/t/topic-for-group-moderators/2480");

    const topic = this.owner.lookup("controller:topic").model;
    topic.set(
      "collection",
      collectionResponse(
        [maintainerUsers[101]],
        {
          id: 9999,
          username: "collection_owner",
          name: "Collection Owner",
          avatar_template: "/letter_avatar_proxy/v4/letter/c/333333/{size}.png",
        },
        false
      )
    );
    topic.set("subcollection", null);

    await click(".toggle-admin-menu");
    await click(".topic-admin-collections");

    assert
      .dom(".collection-modal .maintainers [data-readonly-maintainers]")
      .exists(
        "maintainers cannot edit the maintainer list when they are not the owner"
      );
    assert
      .dom(".collection-modal .maintainers .user-chooser")
      .doesNotExist(
        "does not render the maintainer dropdown for non-owner maintainers"
      );
  });
});
