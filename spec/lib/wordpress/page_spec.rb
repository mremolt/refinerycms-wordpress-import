require 'spec_helper'

describe Refinery::WordPress::Page, :type => :model do
  let(:dump) { test_dump }

  let(:page) { test_dump.pages.last }

  it { page.title.should == 'About me' }
  it { page.content.should include('Lorem ipsum dolor sit') }
  it { page.creator.should == 'admin' }
  it { page.post_date.should == DateTime.new(2011, 5, 21, 12, 25, 42) }
  it { page.post_id.should == 10 }
  it { page.parent_id.should == 8 }

  it { page.should == dump.pages.last }
  it { page.should_not == dump.pages.first }

  describe "#to_refinery" do
    include ::ActionView::Helpers::TagHelper
    include ::ActionView::Helpers::TextHelper

    before do
      # "About me" has a parent page with id 8 in the XML  dump, 
      # would otherwise fails creation
      Page.create! :id => 8, :title => 'About'

      @count = Page.count
      @page = page.to_refinery
    end

    it "should create a Page object" do
      Page.should have(@count + 1).record
    end

    it "should copy the attributes from Refinery::WordPress::Page" do
      @page.title.should == page.title
      @page.draft.should == page.draft?
      @page.created_at.should == page.post_date
      @page.parts.first.body.should == "#{simple_format(page.content)}"
    end
  end

  describe "#format_paragraphs" do
    let(:sample_text) do
      text = <<-EOT
        This is sample text.

        Even more text.
        But this time no paragraph.
      EOT
    end

    before do
      @result = page.send(:format_paragraphs, sample_text)
    end

    it "should add paragraphs to the sample text" do
       @result.should include('<p>')
       @result.should include('</p>')
    end
  end

  describe "#format_syntax_highlighter" do
    let(:sample_text) do
      text = <<-EOT
        This is sample text.

        [ruby]
          p "this is ruby code"
        [/ruby]

        This is more sample text.
      EOT
    end

    before do
      @result = page.send(:format_syntax_highlighter, sample_text)
    end

    it "should reformat the [ruby] tag to a pre with correct class" do
      @result.should match(/<pre class="brush: ruby">/)
      @result.should include('</pre>')
    end

    context "without correct code tags" do
      let(:sample_text) do
        text = <<-EOT
          This is sample text.

          [ruby]
            p "this is ruby code"
          [/php]

          This is more sample text.
        EOT
      end

      it "should not reformat the [ruby] tag" do
        @result.should == sample_text
      end

    end
  end
end

