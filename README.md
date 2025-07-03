# Discourse Collections

For more information, please see: [Discourse Meta - Collections](https://meta.discourse.org/t/collections/372817)

This plugin allows users to create collections out of topics, by creating a list of links. If the link is a topic, the topic is attached to the collection and automatically views all of the list.

Users can only add their own topics to the collection, and must add maintainers to allow others to add theirs to the same collection. Users can organize the collection via section headers (optional). A Collection **must** contain at least one topic.

Users can also create subcollections, collections that are tied to only a single topic. This does not create any additional associations, and can coexist with a collection. Section headers are not possible.

<details>
<summary>Example Collection</summary>

```md
// Collection

# Header 2

- Topic A
- Topic B
- Topic C

# Header 2

- External Link
- External Link
```

```md
// Subcollection for Topic A

- Post 1
- Post 20
- External Link
- Topic X
```

In this setup, Topic A, B, and C will have the main Collection visible and attached. There will be two sections.

For Topic A, there will be an additional section that displays the subcollection. No association to Topic X is created.

</details>

## Architecture

Plugin created a `collections` table and uses custom fields on Topics to manually create associations.

### collections

| column          | type            | comment                                                       |
| --------------- | --------------- | ------------------------------------------------------------- |
| id              | integer primary |                                                               |
| title           | string          | optional title (collection only)                              |
| desc            | string          | option description (collection only)                          |
| user_id         | integer         | owner of the collection                                       |
| mantainer_ids   | integer array   | ids of users who can add/edit the collection                  |
| is_single_topic | boolean         | if true, is considered a subcollection tied to a single topic |
| created_at      | timestamp       |                                                               |
| updated_at      | timestamp       |                                                               |

### collection_items

| column            | type            | comment                                            |
| ----------------- | --------------- | -------------------------------------------------- |
| id                | integer default |                                                    |
| collection_id     | integer fk      | id of the collection                               |
| name              | string          | custom name of the item                            |
| icon              | string          | custom icon of the item. can be empty              |
| url               | string          | URL of the item                                    |
| is_section_header | boolean         | true if item is actually a header (no url allowed) |
| position          | integer         | position of item in collection                     |
| created_at        | timestamp       |                                                    |
| updated_at        | timestamp       |                                                    |

### Topic Custom Fields

possible key values are:

- `collection_id` - Attached to topics found in the URLs of Collections
- `subcollection_id` - Attached to only the Topic containing the Subcollection
