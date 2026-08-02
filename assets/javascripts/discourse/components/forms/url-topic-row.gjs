import { classNames } from "@ember-decorators/component";
import TopicStatus from "discourse/components/topic-status";
import SelectKitRowComponent from "discourse/select-kit/components/select-kit/select-kit-row";
import dBoundCategoryLink from "discourse/ui-kit/helpers/d-bound-category-link";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import dReplaceEmoji from "discourse/ui-kit/helpers/d-replace-emoji";
import { i18n } from "discourse-i18n";

@classNames("url-topic-row")
export default class UrlTopicRow extends SelectKitRowComponent {
  <template>
    {{#if this.item.isLiteral}}
      <div class="topic-title">“{{this.item.title}}”</div>
      <div class="topic-categories use-url">
        {{dIcon "link"}}
        {{i18n "collections.url_topic_chooser.use_url"}}
      </div>
    {{else}}
      <TopicStatus @topic={{this.item}} @disableActions={{true}} />
      <div class="topic-title">{{dReplaceEmoji this.item.title}}</div>
      <div class="topic-categories">
        {{dBoundCategoryLink
          this.item.category
          ancestors=this.item.category.predecessors
          hideParent=true
          link=false
        }}
      </div>
    {{/if}}
  </template>
}
