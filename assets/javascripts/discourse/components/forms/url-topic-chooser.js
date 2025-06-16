import { set } from "@ember/object";
import { isEmpty } from "@ember/utils";
import { classNames } from "@ember-decorators/component";
import { searchForTerm } from "discourse/lib/search";
import ComboBoxComponent from "select-kit/components/combo-box";
import { selectKitOptions } from "select-kit/components/select-kit";

@classNames("topic-chooser", "url-topic-chooser")
@selectKitOptions({
  clearable: true,
  filterable: true,
  filterPlaceholder: "choose_topic.title.placeholder",
  additionalFilters: "",
})
export default class UrlTopicChooser extends ComboBoxComponent {
  nameProperty = "fancy_title";
  labelProperty = "title";
  titleProperty = "title";

  onOpen() {
    set(this.selectKit, "filter", this.url || null);
  }

  modifyComponentForRow() {
    return "forms/url-topic-row";
  }

  search(filter) {
    if (isEmpty(filter) && isEmpty(this.selectKit.options.additionalFilters)) {
      return [];
    }

    const searchParams = {};
    if (!isEmpty(filter)) {
      searchParams.typeFilter = "topic";
      searchParams.searchForId = true;
    }

    const literalResult = {
      isLiteral: true,
      id: -1,
      fancy_title: filter,
      title: filter,
      name: filter,
    };

    return searchForTerm(
      `${filter} ${this.selectKit.options.additionalFilters}`,
      searchParams
    ).then((results) => {
      if (results?.posts?.length > 0) {
        const res = results.posts.mapBy("topic");
        res.push(literalResult);
        return res;
      } else {
        return [literalResult];
      }
    });
  }
}
