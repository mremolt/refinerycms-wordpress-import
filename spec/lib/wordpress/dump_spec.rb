require 'spec_helper'
require 'wordpress'

describe WordPress::Dump, :type => :model do
  let(:file_name) { File.realpath(File.join(File.dirname(__FILE__), '../../fixtures/wordpress_dump.xml')) }
  let(:dump) { WordPress::Dump.new(file_name) }

  it "should create a Dump object given a xml file" do
    dump.should be_a WordPress::Dump
  end

  it "should include a Nokogiri::XML object" do
    dump.doc.should be_a Nokogiri::XML::Document
  end

  describe "#tags" do
    let(:tags) do
      [ WordPress::Tag.new('css'), WordPress::Tag.new('html'),
        WordPress::Tag.new('php'), WordPress::Tag.new('ruby')]
    end

    it "should return all included tags" do
      tags.each do |tag|
        dump.tags.should include(tag)
      end
    end

    context "the last tag" do
      let(:tag) { dump.tags.last }

      describe "#to_refinery" do
        before do 
          @tag = tag.to_refinery
        end

        it "should create a ActsAsTaggableOn::Tag" do
          ActsAsTaggableOn::Tag.should have(1).record
        end

        it "should copy the name over to the Tag object" do
          @tag.name.should == tag.name
        end
      end
    end
  end

  describe "#categories" do
    let(:categories) do
      [ WordPress::Category.new('Rant'), WordPress::Category.new('Tutorials'),
       WordPress::Category.new('Uncategorized') ]
    end

    it "should return all included categories" do
      categories.each do |cat|
        dump.categories.should include(cat)
      end
    end

    context "the last category" do
      let(:category) { dump.categories.last }

      describe "#to_refinery" do
        before do 
          @category = category.to_refinery
        end

        it "should create a BlogCategory" do
          BlogCategory.should have(1).record
        end

        it "should copy the name over to the BlogCategory object" do
          @category.title.should == category.name
        end
      end
    end

  end

  describe "#pages" do
    it "should return all included pages" do
      dump.pages.should have(3).pages
    end

    context "the About me page" do
      let(:page) { dump.pages.last }

      it { page.title.should == 'About me' }
      it { page.content.should include('Lorem ipsum dolor sit') }
      it { page.creator.should == 'admin' }
      it { page.post_date.should == DateTime.new(2011, 5, 21, 12, 25, 42) }
      it { page.post_id.should == 10 }
      it { page.parent_id.should == 8 }

      it { page.should == dump.pages.last }
      it { page.should_not == dump.pages.first }

      describe "#to_refinery" do
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

        it "should copy the attributes from WordPress::Page" do
          @page.title.should == page.title
          @page.draft.should == page.draft?
          @page.created_at.should == page.post_date
          @page.parts.first.body.should == "<p>#{page.content}</p>"
        end
      end
    end
  end

  describe "#authors" do
    it "should return all authors" do
      dump.authors.should have(1).author
    end

    context "the first author" do
      let(:author) { dump.authors.first }

      it { author.login.should == 'admin' }
      it { author.email.should == 'admin@example.com' }

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

        it "should have copied the attributes from WordPress::Author" do
          author.login.should == @user.username
          author.email.should == @user.email
        end
      end
    end
  end

  describe "#posts" do
    it "should return all posts" do
      dump.posts.should have(3).posts
    end

    context "the last post" do
      let(:post) { dump.posts.last }

      it { post.title.should == 'Third blog post' }
      it { post.content.should include('Lorem ipsum dolor sit') }
      it { post.creator.should == 'admin' }
      it { post.post_date.should == DateTime.new(2011, 5, 21, 12, 24, 45) }
      it { post.post_id.should == 6 }
      it { post.parent_id.should == 0 }
      it { post.status.should == 'publish' }

      it { post.should == dump.posts.last }
      it { post.should_not == dump.posts.first }
      
      describe "#categories" do
        it { post.categories.should have(1).category }
        it { post.categories.first.should == WordPress::Category.new('Rant') }
      end

      describe "#tags" do
        it { post.tags.should have(3).tags }

        it { post.tags.should include(WordPress::Tag.new('css')) }
        it { post.tags.should include(WordPress::Tag.new('html')) }
        it { post.tags.should include(WordPress::Tag.new('php')) }
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

            it "should copy the attributes from WordPress::Comment" do
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
          User.create! :username => 'admin', :email => 'admin@example.com',
            :password => 'password', :password_confirmation => 'password'

          @post = post.to_refinery
        end

        it { BlogPost.should have(1).record } 

        it "should copy the attributes from WordPress::Page" do
          @post.title.should == post.title
          @post.body.should == post.content
          @post.draft.should == post.draft?
          @post.published_at.should == post.post_date
          @post.created_at.should == post.post_date
          @post.author.username.should == post.creator
        end

        it "should assign a category for each WordPress::Category" do
          @post.categories.should have(post.categories.count).records
        end

        it "should assign a comment for each WordPress::Comment" do
          @post.comments.should have(post.comments.count).records
        end

      end
    end
  end
end
