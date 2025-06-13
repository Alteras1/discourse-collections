import { classNames } from "@ember-decorators/component";
import TopicStatus from "discourse/components/topic-status";
import boundCategoryLink from "discourse/helpers/bound-category-link";
import icon from "discourse/helpers/d-icon";
import replaceEmoji from "discourse/helpers/replace-emoji";
import { i18n } from "discourse-i18n";
import SelectKitRowComponent from "select-kit/components/select-kit/select-kit-row";

@classNames("url-topic-row")
export default class UrlTopicRow extends SelectKitRowComponent {
  <template>
    {{#if this.item.isLiteral}}
      <div class="topic-title">“{{this.item.title}}”</div>
      <div class="topic-categories use-url">
        {{icon "link"}}
        {{i18n "collections.url_topic_chooser.use_url"}}
      </div>
    {{else}}
      <TopicStatus @topic={{this.item}} @disableActions={{true}} />
      <div class="topic-title">{{replaceEmoji this.item.title}}</div>
      <div class="topic-categories">
        {{boundCategoryLink
          this.item.category
          ancestors=this.item.category.predecessors
          hideParent=true
          link=false
        }}
      </div>
    {{/if}}
  </template>
}
