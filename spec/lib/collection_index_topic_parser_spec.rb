# frozen_string_literal: true

RSpec.configure do |c|
  c.filter_run_when_matching :focus
end

RSpec.describe ::Collections::CollectionIndexTopicParser do
  context 'when parsing sections' do
    it 'extracts the index from a HTML fragment with only a single list and no header' do
      cooked_text = <<-HTML
        <ul>
          <li>Title 1: <a href="/link1">Link 1</a></li>
          <li>Title 2: <a href="/link2">Link 2</a></li>
        </ul>
      HTML
      p = described_class.new(cooked_text)
      sections = p.sections
      expect(sections.size).to eq(1)

      root_section = sections.first
      expect(root_section[:text]).to be_nil
      expect(root_section[:links].size).to eq(2)
      expect(root_section[:links].first).to eq({ text: 'Title 1', href: '/link1' })
      expect(root_section[:links].last).to eq({ text: 'Title 2', href: '/link2' })
    end

    it 'extracts the index from a HTML fragment with a single list and a header' do
      cooked_text = <<-HTML
        <h1>Section 1</h1>
        <ul>
          <li>Title 1: <a href="/link1">Link 1</a></li>
          <li>Title 2: <a href="/link2">Link 2</a></li>
        </ul>
      HTML
      p = described_class.new(cooked_text)
      sections = p.sections
      expect(sections.size).to eq(1)
      expect(sections.first[:text]).to eq('Section 1')
      expect(sections.first[:links].size).to eq(2)
      expect(sections.first[:links].first).to eq({ text: 'Title 1', href: '/link1' })
      expect(sections.first[:links].last).to eq({ text: 'Title 2', href: '/link2' })
    end

    it 'extracts the index only from data-collection-index div if present' do
      cooked_text = <<-HTML
        <ul>
          <li>dummy: <a href="/link1">should not exist</a></li>
        </ul>
        <div data-collection-index>
          <h1>Section 1</h1>
          <ul>
            <li>Title 1: <a href="/link1">Link 1</a></li>
          </ul>
        </div>
      HTML
      p = described_class.new(cooked_text)
      sections = p.sections
      expect(sections.size).to eq(1)

      root_section = sections.first
      expect(root_section[:text]).to eq('Section 1')
      expect(root_section[:links].size).to eq(1)
      expect(root_section[:links].first).to eq({ text: 'Title 1', href: '/link1' })
    end

    it 'extracts the index from a HTML fragment with multiple lists and headers' do
      cooked_text = <<-HTML
        <h1>Section 1</h1>
        <ul>
          <li>Title 1: <a href="/link1">Link 1</a></li>
          <li>Title 2: <a href="/link2">Link 2</a></li>
        </ul>
        <h2>Section 2</h2>
        <ol>
          <li>Title 3: <a href="/link3">Link 3</a></li>
          <li>Title 4: <a href="/link4">Link 4</a></li>
        </ol>
      HTML
      p = described_class.new(cooked_text)
      sections = p.sections
      expect(sections.size).to eq(2)

      first_section = sections.first
      expect(first_section[:text]).to eq('Section 1')
      expect(first_section[:links].size).to eq(2)
      expect(first_section[:links].first).to eq({ text: 'Title 1', href: '/link1' })
      expect(first_section[:links].last).to eq({ text: 'Title 2', href: '/link2' })

      second_section = sections.last
      expect(second_section[:text]).to eq('Section 2')
      expect(second_section[:links].size).to eq(2)
      expect(second_section[:links].first).to eq({ text: 'Title 3', href: '/link3' })
      expect(second_section[:links].last).to eq({ text: 'Title 4', href: '/link4' })

    end

    it 'extracts items before a header is found to a section without text' do
      cooked_text = <<-HTML
        <ul>
          <li>Title 1: <a href="/link1">Link 1</a></li>
          <li>Title 2: <a href="/link2">Link 2</a></li>
        </ul>
        <h1>Section 1</h1>
        <ul>
          <li>Title 3: <a href="/link3">Link 3</a></li>
          <li>Title 4: <a href="/link4">Link 4</a></li>
        </ul>
      HTML
      p = described_class.new(cooked_text)
      sections = p.sections
      expect(sections.size).to eq(2)

      first_section = sections.first
      expect(first_section[:text]).to be_nil
      expect(first_section[:links].size).to eq(2)
      expect(first_section[:links].first).to eq({ text: 'Title 1', href: '/link1' })
      expect(first_section[:links].last).to eq({ text: 'Title 2', href: '/link2' })

      second_section = sections.last
      expect(second_section[:text]).to eq('Section 1')
      expect(second_section[:links].size).to eq(2)
      expect(second_section[:links].first).to eq({ text: 'Title 3', href: '/link3' })
      expect(second_section[:links].last).to eq({ text: 'Title 4', href: '/link4' })
    end

    it 'won\'t create sections for headings without a list' do
      cooked_text = <<-HTML
        <h1>Section 1</h1>
        <p>Some text</p>
        <h2>Section 2</h2>
        <p>Some text</p>
      HTML
      p = described_class.new(cooked_text)
      sections = p.sections
      expect(sections).to be_nil
    end

  end

  context 'when parsing lists' do
    it 'if present, it will extract the text prior to the anchor as the text for the link' do
      cooked_text = <<-HTML
        <ul>
          <li>Title 1: <a href="/link1">Link 1</a></li>
        </ul>
      HTML
      p = described_class.new(cooked_text)
      sections = p.sections
      expect(sections.size).to eq(1)

      root_section = sections.first
      expect(root_section[:text]).to be_nil
      expect(root_section[:links].size).to eq(1)
      expect(root_section[:links].first).to eq({ text: 'Title 1', href: '/link1' })
    end

    it 'will use the text of the anchor if no text is present before the anchor' do
      cooked_text = <<-HTML
        <ul>
          <li><a href="/link1">Link 1</a></li>
        </ul>
      HTML
      p = described_class.new(cooked_text)
      sections = p.sections
      expect(sections.size).to eq(1)

      root_section = sections.first
      expect(root_section[:text]).to be_nil
      expect(root_section[:links].size).to eq(1)
      expect(root_section[:links].first).to eq({ text: 'Link 1', href: '/link1' })
    end

    it 'will use the last anchor if multiple anchors are present' do
      cooked_text = <<-HTML
        <ul>
          <li>Title 1: <a href="/link1">Link 1</a> <a href="/link2">Link 2</a></li>
        </ul>
      HTML
      p = described_class.new(cooked_text)
      sections = p.sections
      expect(sections.size).to eq(1)

      root_section = sections.first
      expect(root_section[:text]).to be_nil
      expect(root_section[:links].size).to eq(1)
      expect(root_section[:links].first).to eq({ text: 'Link 2', href: '/link2' })
    end

    it 'won\'t generate an item if the text can\'t be extracted' do
      cooked_text = <<-HTML
        <ul>
          <li><a href="/empty"></a></li>
          <li><a href="/test">Test</a></li>
        </ul>
      HTML
      p = described_class.new(cooked_text)
      sections = p.sections
      expect(sections.size).to eq(1)

      root_section = sections.first
      expect(root_section[:text]).to be_nil
      expect(root_section[:links].size).to eq(1)
      expect(root_section[:links].first).to eq({ text: 'Test', href: '/test' })
    end

    it 'won\'t generate an item that has no anchor' do
      cooked_text = <<-HTML
        <ul>
          <li>Test:</li>
          <li><a href="/test">Test</a></li>
        </ul>
      HTML
      p = described_class.new(cooked_text)
      sections = p.sections
      expect(sections.size).to eq(1)

      root_section = sections.first
      expect(root_section[:text]).to be_nil
      expect(root_section[:links].size).to eq(1)
      expect(root_section[:links].first).to eq({ text: 'Test', href: '/test' })
    end

    it 'will be fault tolerant and combine lists that are not separated by a header' do
      cooked_text = <<-HTML
        <h1>Section 1</h1>
        <ul>
          <li>Title 1: <a href="/link1">Link 1</a></li>
          <li>Title 2: <a href="/link2">Link 2</a></li>
        </ul>
        <ul>
          <li>Title 3: <a href="/link3">Link 3</a></li>
          <li>Title 4: <a href="/link4">Link 4</a></li>
        </ul>
      HTML
      p = described_class.new(cooked_text)
      sections = p.sections
      expect(sections.size).to eq(1)

      first_section = sections.first
      expect(first_section[:text]).to eq('Section 1')
      expect(first_section[:links].size).to eq(4)
      expect(first_section[:links].first).to eq({ text: 'Title 1', href: '/link1' })
      expect(first_section[:links].last).to eq({ text: 'Title 4', href: '/link4' })
    end

    it 'will create sub-links for items that have a list as a child' do
      cooked_text = <<-HTML
        <ul>
          <li>Title 1: <a href="/link1">Link 1</a>
            <ul>
              <li>Sub 1: <a href="/sub1">Sub 1</a></li>
              <li>Sub 2: <a href="/sub2">Sub 2</a></li>
            </ul>
          </li>
          <li>Title 2: <a href="/link2">Link 2</a></li>
        </ul>
      HTML
      p = described_class.new(cooked_text)
      sections = p.sections
      expect(sections.size).to eq(1)

      root_section = sections.first
      expect(root_section[:text]).to be_nil
      expect(root_section[:links].size).to eq(2)
      expect(root_section[:links].first).to eq({ text: 'Title 1', href: '/link1', sub_links: [
        { text: 'Sub 1', href: '/sub1' },
        { text: 'Sub 2', href: '/sub2' }
      ] })
      expect(root_section[:links].last).to eq({ text: 'Title 2', href: '/link2' })
    end

    it 'will only create sub-links one deep, and flatten any further nested links' do
      cooked_text = <<-HTML
        <ul>
          <li>Title 1: <a href="/link1">Link 1</a>
            <ul>
              <li>Sub 1: <a href="/sub1">Sub 1</a>
                <ul>
                  <li>Sub Sub 1: <a href="/subsub1">Sub Sub 1</a></li>
                </ul>
              </li>
            </ul>
          </li>
        </ul>
      HTML
      p = described_class.new(cooked_text)
      sections = p.sections
      expect(sections.size).to eq(1)

      root_section = sections.first
      expect(root_section[:text]).to be_nil
      expect(root_section[:links].size).to eq(1)
      expect(root_section[:links].first).to eq({ text: 'Title 1', href: '/link1', sub_links: [
        { text: 'Sub 1', href: '/sub1' },
        { text: 'Sub Sub 1', href: '/subsub1' }
      ] })
    end
  end

end
