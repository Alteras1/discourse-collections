declare namespace CollectionTypes {
  type Collection = {
    topic_id: number;
    sections: CollectionSection[];
    unbound_topics?: any[];
    orphaned_topics?: any[];
  }
  
  type CollectionSection = {
    text: string;
    links: CollectionLink[];
  }
  
  type CollectionLink = {
    text: string;
    href: string;
    topic_id: number | null;
    can_view: boolean;
    sub_links?: CollectionSubLink[];
  }
  
  type CollectionSubLink = {
    text: string;
    href: string;
  }
}

