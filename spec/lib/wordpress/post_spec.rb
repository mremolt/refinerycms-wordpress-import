require 'spec_helper'

describe Refinery::WordPress::Post, :type => :model do
  let(:post) { test_dump.posts.last  }

  it { post.title.should == 'Third blog post' }
  it { post.content.should include('Lorem ipsum dolor sit') }
  it { post.content_formatted.should include('Lorem ipsum dolor sit') }
  it { post.creator.should == 'admin' }
  it { post.post_date.should == DateTime.new(2011, 5, 21, 12, 24, 45) }
  it { post.post_id.should == 6 }
  it { post.parent_id.should == nil }
  it { post.status.should == 'publish' }

  it { post.should == test_dump.posts.last }
  it { post.should_not == test_dump.posts.first }

  describe "#categories" do
    it { post.categories.should have(1).category }
    it { post.categories.first.should == Refinery::WordPress::Category.new('Rant') }
  end

  describe "#tags" do
    it { post.tags.should have(3).tags }

    it { post.tags.should include(Refinery::WordPress::Tag.new('css')) }
    it { post.tags.should include(Refinery::WordPress::Tag.new('html')) }
    it { post.tags.should include(Refinery::WordPress::Tag.new('php')) }
  end

  it { post.tag_list.should == 'css,html,php' }

  describe "#comments" do
    it "should return all attached comments" do
      post.comments.should have(2).comments
    end

    context "the last comment" do
      let(:comment) { post.comments.last }

      it { comment.author.should == 'admin' }
      it { comment.email.should == 'admin@example.com' }
      it { comment.url.should == 'http://www.example.com/' }
      it { comment.date.should == DateTime.new(2011, 5, 21, 12, 26, 30) }
      it { comment.content.should include('Another one!') }
      it { comment.should be_approved }

      it { comment.should == post.comments.last }

      describe "#to_refinery" do
        before do 
          @comment = comment.to_refinery
        end

        it "should not save the comment, only initialize it" do
          BlogComment.should have(0).records
          @comment.should be_new_record
        end

        it "should copy the attributes from Refinery::WordPress::Comment" do
          @comment.name.should == comment.author
          @comment.email.should == comment.email
          @comment.body.should == comment.content
          @comment.state.should == 'approved'
          @comment.created_at.should == comment.date
        end
      end
    end
  end

  describe "#to_refinery" do
    before do
      @user = User.create! :username => 'admin', :email => 'admin@example.com',
        :password => 'password', :password_confirmation => 'password'
    end

    context "with a unique title" do
      before do 
        @post = post.to_refinery
      end

      it { BlogPost.should have(1).record } 

      it "should copy the attributes from Refinery::WordPress::Post" do
        @post.title.should == post.title
        @post.body.should == post.content_formatted
        @post.draft.should == post.draft?
        @post.published_at.should == post.post_date
        @post.created_at.should == post.post_date
        @post.author.username.should == post.creator
      end

      it "should assign a category for each Refinery::WordPress::Category" do
        @post.categories.should have(post.categories.count).records
      end

      it "should assign a comment for each Refinery::WordPress::Comment" do
        @post.comments.should have(post.comments.count).records
      end
    end

    context "with a duplicate title" do
      before do
        BlogPost.create! :title => post.title, :body => 'Lorem', :author => @user
        @post = post.to_refinery

      end

      it { BlogPost.should have(2).records } 

      it "should create the BlogPost with #post_id attached" do
        @post.title.should == "#{post.title}-#{post.post_id}"
      end
    end
  end
end
