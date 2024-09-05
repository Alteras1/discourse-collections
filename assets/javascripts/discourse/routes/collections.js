import DiscourseRoute from "discourse/routes/discourse";
import I18n from "discourse-i18n";

export default class CollectionsRoute extends DiscourseRoute {
  titleToken() {
    return I18n.t("collections.title");
  }

  model() {
    return this.store.findAll("collection");
  }
}
