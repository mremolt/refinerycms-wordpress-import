require 'spec_helper'

describe Refinery::WordPress::Tag, :type => :model do
  let(:tag) { Refinery::WordPress::Tag.new('ruby') }

  describe "#name" do
    specify { tag.name.should == 'ruby' }
  end

  describe "#==" do
    specify { tag.should == Refinery::WordPress::Tag.new('ruby') }
    specify { tag.should_not == Refinery::WordPress::Tag.new('php') }
  end

  describe "#to_refinery" do
    before do 
      @tag = tag.to_refinery
    end

    it "should create a ActsAsTaggableOn::Tag" do
      ::ActsAsTaggableOn::Tag.should have(1).record
    end
    
    it "should copy the name over to the Tag object" do
      @tag.name.should == tag.name
    end
  end

end

