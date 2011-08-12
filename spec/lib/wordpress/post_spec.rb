require 'spec_helper'

describe Refinery::WordPress::Post, :type => :model do
  let(:post) { test_dump.posts.last }

   specify { post.title.should == 'Third blog post' }
   specify { post.content.should include('Lorem ipsum dolor sit') }
   specify { post.content_formatted.should include('Lorem ipsum dolor sit') }
   specify { post.creator.should == 'admin' }
   specify { post.post_date.should == DateTime.new(2011, 5, 21, 12, 24, 45) }
   specify { post.post_id.should == 6 }
   specify { post.parent_id.should == nil }
   specify { post.status.should == 'publish' }

   specify { post.should == test_dump.posts.last }
   specify { post.should_not == test_dump.posts.first }

  describe "#categories" do
     specify { post.categories.should have(1).category }
     specify { post.categories.first.should == Refinery::WordPress::Category.new('Rant') }
  end

  describe "#tags" do
     specify { post.tags.should have(3).tags }

     specify { post.tags.should include(Refinery::WordPress::Tag.new('css')) }
     specify { post.tags.should include(Refinery::WordPress::Tag.new('html')) }
     specify { post.tags.should include(Refinery::WordPress::Tag.new('php')) }
  end

   specify { post.tag_list.should == 'css,html,php' }

  describe "#comments" do
    it "should return all attached comments" do
      post.comments.should have(2).comments
    end

    context "the last comment" do
      let(:comment) { post.comments.last }

       specify { comment.author.should == 'admin' }
       specify { comment.email.should == 'admin@example.com' }
       specify { comment.url.should == 'http://www.example.com/' }
       specify { comment.date.should == DateTime.new(2011, 5, 21, 12, 26, 30) }
       specify { comment.content.should include('Another one!') }
       specify { comment.should be_approved }

       specify { comment.should == post.comments.last }

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

      specify { BlogPost.should have(1).record }

      specify { @post.title.should == post.title }
      specify { @post.body.should == post.content_formatted }
      specify { @post.draft.should == post.draft? }
      specify { @post.published_at.should == post.post_date }
      specify { @post.author.username.should == post.creator }

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

       specify { BlogPost.should have(2).records } 

      it "should create the BlogPost with #post_id attached" do
        @post.title.should == "#{post.title}-#{post.post_id}"
      end
    end
  end
end
