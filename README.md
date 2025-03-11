# Discourse Collections

**Plugin Summary**

For more information, please see: **url to meta topic**

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
