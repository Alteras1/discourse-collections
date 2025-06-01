declare namespace CollectionTypes {
  type Collection = {
    id: number;
    is_single_topic: boolean;
    maintainers: number[];
    owner: any;
    collection_items: (CollectionLink | CollectionHeader)[];
  };

  type CollectionLink = {
    id: number;
    collection_id: number;
    name: string;
    url: string;
    position: number;
    is_section_header: false;
    topic_id: number | null;
  };

  type CollectionHeader = {
    id: number;
    collection_id: number;
    name: string;
    url: null;
    position: number;
    is_section_header: true;
    topic_id: null;
  };

  type ProcessedSection = {
    name: string | null;
    links: CollectionLink[];
  };
}
