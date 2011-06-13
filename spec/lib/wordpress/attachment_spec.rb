require 'spec_helper'

describe Refinery::WordPress::Attachment, :type => :model do
  context "an image attchment" do
    let(:attachment) { test_dump.attachments.first }

    specify { attachment.title.should == '200px-Tux.svg' }
    # doesn't get exported atm. for some reason
    specify { attachment.description.should == '' }
    specify { attachment.url.should == 'http://localhost/wordpress/wp-content/uploads/2011/05/200px-Tux.svg_.png' }
    specify { attachment.file_name.should == '200px-Tux.svg_.png' }
    specify { attachment.post_date.should == DateTime.new(2011, 6, 5, 15, 26, 51) }
    specify { attachment.should be_an_image }

    describe "#to_refinery" do
      before do
        @image = attachment.to_refinery
      end

      it "should create an Image from the Attachment" do
        @image.should be_a(Image)
      end

      it "should copy the attributes from Attachment" do
        @image.created_at.should == attachment.post_date
        @image.image.url.end_with?(attachment.file_name).should be_true
      end
    end

    describe "#replace_url" do
      let(:post) { BlogPost.first }

      before do
        test_dump.authors.each(&:to_refinery)
        test_dump.posts.each(&:to_refinery)

        @image = attachment.to_refinery

        attachment.replace_url
      end

      specify { post.body.should_not include attachment.url }
      specify { post.body.should_not include '200px-Tux.svg_-150x150.png' }
      specify { post.body.should_not include 'wp-content' }

      it "should replace attachment urls in the generated BlogPosts" do
        post.body.should include(@image.image.url)
      end
    end
  end

  context "a file attachment" do
    let(:attachment) { test_dump.attachments.last }

    specify { attachment.title.should == 'cv' }
    specify { attachment.url.should == 'http://localhost/wordpress/wp-content/uploads/2011/05/cv.txt' }
    specify { attachment.file_name.should == 'cv.txt' }
    specify { attachment.post_date.should == DateTime.new(2011, 6, 6, 17, 27, 50) }
    specify { attachment.should_not be_an_image }

    describe '#to_refinery' do
      before do 
        @resource = attachment.to_refinery
      end

      specify { Resource.should have(1).record }
      specify { @resource.should be_a(Resource) }

      it "should copy the attributes from Attachment" do
        @resource.created_at.should == attachment.post_date
        @resource.file.url.end_with?(attachment.file_name).should be_true
      end

    end

    describe '#replace_resource_url' do
      let(:page_part) { Page.last.parts.first }

      before do
        test_dump.pages.each(&:to_refinery)
        @resource = attachment.to_refinery
        attachment.replace_url
      end

      specify { page_part.body.should_not include attachment.url }
      specify { page_part.body.should_not include 'wp-content' }

      it "should replace attachment urls in the generated BlogPosts" do
        page_part.body.should include(@resource.file.url)
      end
    end
  end
end
