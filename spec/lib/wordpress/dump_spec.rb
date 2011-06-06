require 'spec_helper'

describe Refinery::WordPress::Dump, :type => :model do
  let(:dump) { test_dump }

  it "should create a Dump object given a xml file" do
    dump.should be_a Refinery::WordPress::Dump
  end

  it "should include a Nokogiri::XML object" do
    dump.doc.should be_a Nokogiri::XML::Document
  end

  describe "#tags" do
    let(:tags) do
      [ Refinery::WordPress::Tag.new('css'), Refinery::WordPress::Tag.new('html'),
        Refinery::WordPress::Tag.new('php'), Refinery::WordPress::Tag.new('ruby')]
    end

    specify { dump.tags.count == 4 }
    specify { dump.tags.first.should be_a(Refinery::WordPress::Tag) }

    it "should return all included tags" do
      tags.each do |tag|
        dump.tags.should include(tag)
      end
    end
  end

  describe "#categories" do
    let(:categories) do
      [ Refinery::WordPress::Category.new('Rant'), Refinery::WordPress::Category.new('Tutorials'),
       Refinery::WordPress::Category.new('Uncategorized') ]
    end

    specify { dump.categories.count == 4 }
    specify { dump.categories.first.should be_a(Refinery::WordPress::Category) }

    it "should return all included categories" do
      categories.each do |cat|
        dump.categories.should include(cat)
      end
    end
  end

  describe "#pages" do
    it "should return all included pages" do
      dump.pages.should have(3).pages
    end

    specify { dump.pages.first.should be_a(Refinery::WordPress::Page) }

    it "should return only published pages with only_published=true" do
      dump.pages(true).should have(2).pages
    end
  end

  describe "#authors" do
    it "should return all authors" do
      dump.authors.should have(1).author
    end

    specify { dump.authors.first.should be_a(Refinery::WordPress::Author) }
  end

  describe "#posts" do
    it "should return all posts" do
      dump.posts.should have(3).posts
    end

    specify { dump.posts.first.should be_a(Refinery::WordPress::Post) }

    it "should return only published posts with only_published=true" do
      dump.posts(true).should have(2).posts
    end
  end

  describe "#attachments" do
    it "should return all attachments" do
      dump.attachments.should have(2).attachments
    end

    specify { dump.attachments.first.should be_a(Refinery::WordPress::Attachment) }
  end
end
