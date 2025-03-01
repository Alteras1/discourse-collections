# frozen_string_literal: true

# Parses the collection index from a topic's cooked text.
# Must be initialized with a cooked text string.
# only intakes the text to parse. Topic validation must be done externally
# based on https://github.com/discourse/discourse-doc-categories/blob/main/lib/doc_categories/doc_index_topic_parser.rb
module ::DiscourseCollections
  class CollectionIndexTopicParser
    HEADING_TAGS = %w[h1 h2 h3 h4 h5 h6]
    LIST_TAGS = %w[ol ul]

    def initialize(cooked_text)
      @cooked_text = cooked_text
      parse
    end

    def sections
      return if @sections.blank?
      return if (valid_sections = @sections.select { |section| section[:links].present? }).blank?

      valid_sections
    end

    private

    def parse
      nodes = Nokogiri::HTML5.fragment(@cooked_text, max_tree_depth: -1)
      # <div data-collection-index>
      if nodes.css('div[data-collection-index]').present?
        nodes = nodes.css('div[data-collection-index]').first
      end

      # keep track of processed links to avoid duplicates
      # ideally not needed, but our CSS selector will pick up nested lists
      # and can cause duplicates when building sublists
      @processed_links = []

      nodes.css(*HEADING_TAGS, *LIST_TAGS).each do |node|
        if heading?(node)
          add_section(node)
        elsif list?(node)
          add_list(node)
        end
      end
    end

    def heading?(node)
      HEADING_TAGS.include?(node.name)
    end

    def list?(node)
      LIST_TAGS.include?(node.name)
    end

    def list_item?(node)
      node.name == 'li'
    end

    def add_section(node, root: false)
      @sections ||= []
      @sections << { text: (node.text.strip unless root), links: [] }
    end

    def add_list(node, sub_list = nil)
      node.children.each do |child|
        next unless list_item?(child)
        next if @processed_links.include?(child)

        add_link(child, sub_list)
        @processed_links << child

        if child.css(*LIST_TAGS).present?
          has_last_link = @sections.last[:links].last.present?
          add_list(child.css(*LIST_TAGS), has_last_link)
        end
      end
    end

    def add_link(node, sub_list = false)
      nodes = node.children
      anchor = nodes.reverse.find { |child| child.name == "a" }
      return unless anchor

      title = nodes.first(nodes.index(anchor)).map(&:text).join.strip
      if title.present? && title.end_with?(":")
        title.chop!
      else
        title = anchor.text.strip
      end

      return if title.blank?

      add_section(nil, root: true) if @sections.blank?

      if sub_list
        @sections.last[:links].last[:sub_links] ||= []
        @sections.last[:links].last[:sub_links] << { text: title, href: anchor[:href] }
        return
      end
      @sections.last[:links] << { text: title, href: anchor[:href] }
    end
  end
end