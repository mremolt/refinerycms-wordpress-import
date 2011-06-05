require 'spec_helper'

describe Refinery::WordPress::Author, :type => :model do
  let(:author) { test_dump.authors.first }

  specify { author.login.should == 'admin' }
  specify { author.email.should == 'admin@example.com' }

  describe "#to_refinery" do
    before do 
      @user = author.to_refinery
    end

    it "should create a User object" do
      User.should have(1).record
      @user.should be_a(User)
    end

    it "the @user should be persisted" do
      @user.should be_persisted
    end

    it "should have copied the attributes from Refinery::WordPress::Author" do
      author.login.should == @user.username
      author.email.should == @user.email
    end
  end
end
