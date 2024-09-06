import DiscourseRoute from "discourse/routes/discourse";
import I18n from "discourse-i18n";

export default class CollectionNewRoute extends DiscourseRoute {
  titleToken() {
    return I18n.t("discourse_collections.new_collection_title");
  }

  beforeModel() {
    if (!this.currentUser) {
      this.router.replaceWith("login");
    }
  }
}
