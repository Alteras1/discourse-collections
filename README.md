# Discourse Collections

For more information, please see: **url to meta topic**

To create a collection, first create a list of the topics in the first post of the topic which will serve as the index of the collection. Then in the post action menu, follow the actions for creating a collection.

```md
# Section Name

- link name: https://url.here
- 2nd link name: https://url.here
```

If you only want a portion of the post to be parsed for the collection, you can wrap the list in `<div data-collection-index></div>`. If you want it hidden from view in the post itself, you can use `<div data-collection-index hidden></div>`

```md
<div data-collection-index>
# Section Name

- link name: https://url.here
- 2nd link name: https://url.here
</div>
```

## Architecture

Plugin created a `collections` table and uses custom fields on Topics to manually create associations. Modifications to the collection must occur through changes to the text of the index topic.

**Table**:

```md
# collections

topic_id :integer
payload :jsonb
```

`payload` contains a processed JSON of the index topic cooked text.

**Topic Custom Fields**

- `is_collection`: declares if the current topic is an index for a collection
- `collection_index`: declares the topic id to use as the collection for the current topic
