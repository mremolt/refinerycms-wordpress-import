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
end

