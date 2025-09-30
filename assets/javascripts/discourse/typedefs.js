/**
 * @typedef {Object} Collection
 * @property {number} id - The unique identifier for the collection.
 * @property {string} title - The title of the collection.
 * @property {string} desc - A brief description of the collection.
 * @property {boolean} is_single_topic - Indicates if the collection is a single topic.
 * @property {Array<CollectionUser>} maintainers - List of maintainers for the collection.
 * @property {CollectionUser} owner - The owner of the collection.
 * @property {Array<CollectionLink | CollectionHeader>} collection_items - Items in the collection, which can be links or headers.
 * @property {boolean} can_edit_collection - Indicates if the user can edit the collection.
 * @property {boolean} can_delete_collection - Indicates if the user can delete the collection.
 * @property {number | undefined} subcollection_topic_id - topic id of the associated topic if is_single_topic true
 */

/**
 * @typedef {Object} CollectionLink
 * @property {number} id - The unique identifier for the collection link.
 * @property {number} collection_id - The ID of the collection this link belongs to.
 * @property {string} name - The name of the collection link.
 * @property {string} url - The URL of the collection link.
 * @property {string} icon - The icon associated with the collection link.
 * @property {string} icon_type - The type of the icon (e.g., 'icon', 'emoji', 'square').
 * @property {number} position - The position of the link in the collection.
 * @property {boolean} is_section_header - Indicates if the link is a section header.
 * @property {number|null} topic_id - The ID of the topic associated with the link, or null if not applicable.
 * @property {string|null} topic_name - The name of the topic associated with the link, or null if not applicable.
 * @property {boolean} can_delete_collection_item - Indicates if the user can delete this collection item.
 */

/**
 * @typedef {Object} CollectionHeader
 * @property {number} id - The unique identifier for the collection header.
 * @property {number} collection_id - The ID of the collection this header belongs to.
 * @property {string} name - The name of the collection header.
 * @property {string} icon - The icon associated with the collection link.
 * @property {null} url - The URL of the collection header, typically null.
 * @property {number} position - The position of the header in the collection.
 * @property {boolean} is_section_header - Indicates that this item is a section header.
 * @property {null} topic_id
 * @property {boolean} can_delete_collection_item - Indicates if the user can delete this collection item.
 */

/**
 * @typedef ProcessedSection
 * @property {string|null} name - The name of the section, or null if not applicable.
 * @property {boolean} isSub - Indicates if this section is a subcollection.
 * @property {Array<CollectionLink>} links - The links in this section, which can be either collection links or headers.
 */

/**
 * @typedef CollectionUser
 * @property {number} id
 * @property {string} username
 * @property {string} name
 * @property {string} avatar_template
 */
