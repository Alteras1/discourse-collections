# frozen_string_literal: true

module ::Collections
  class CollectionSerializer < ApplicationSerializer
    attributes :topic_id, :sections

    def sections
      object.sections.map do |section|
        section.links.map do |link|
          id = Collections::Url.extract_topic_id_from_url(link[:href])
          processed_link = {
            title: link[:title],
            href: link[:href],
            topic_id: id,
            can_view: available_topics.include?(id) || id.nil?
          }
          if link[:sub_links].present?
            sub_links = link[:sub_links]&.map do |sub_link|
              id = Collections::Url.extract_topic_id_from_url(sub_link[:href])
              {
                title: sub_link[:title],
                href: sub_link[:href],
                topic_id: id,
                can_view: available_topics.include?(id)
              }
            end
            processed_link[:sub_links] = sub_links
          end
          processed_link
        end
      end
    end

    def available_topics
      @available_topic_ids ||= scope.can_see_topic_ids topic_ids: object.bounded_topics_based_on_payload
    end
    
  end
end
