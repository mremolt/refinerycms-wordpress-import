module Refinery
  module WordPress
    class Attachment
      attr_reader :node
      attr_reader :refinery_image
      attr_reader :refinery_resource

      def initialize(node)
        @node = node
      end

      def title
        node.xpath("title").text
      end

      def description
        node.xpath("description").text
      end

      def file_name
        url.split('/').last
      end

      def post_date
        DateTime.parse node.xpath("wp:post_date").text
      end

      def url
        node.xpath("wp:attachment_url").text
      end

      def url_pattern
        url_parts = url.split('.')
        extension = url_parts.pop
        url_without_extension = url_parts.join('.')

        /#{url_without_extension}(-\d+x\d+)?\.#{extension}/
      end

      def image?
        url.match /\.(png|jpg|jpeg|gif)$/ 
      end

      def to_refinery
        if image?
          to_image
        else
          to_resource
        end
      end

      def replace_url
        if image?
          replace_image_url
        else
          replace_resource_url
        end
      end

      private

      def to_image
        image = ::Image.new
        image.created_at = post_date
        image.image_url = url
        image.save!

        @refinery_image = image
        image
      end

      def to_resource
        resource = ::Resource.new
        resource.created_at = post_date
        resource.file_url = url
        resource.save!

        @refinery_resource = resource
        resource
      end

      def replace_image_url
        replace_image_url_in_blog_posts
        replace_image_url_in_pages
      end

      def replace_resource_url
        replace_resource_url_in_blog_posts
        replace_resource_url_in_pages
      end

      def replace_image_url_in_blog_posts
        replace_url_in_blog_posts(refinery_image.image.url)
      end
      
      def replace_image_url_in_pages
        replace_url_in_pages(refinery_image.image.url)
      end

      def replace_resource_url_in_blog_posts
        replace_url_in_blog_posts(refinery_resource.file.url)
      end
      
      def replace_resource_url_in_pages
        replace_url_in_pages(refinery_resource.file.url)
      end

      def replace_url_in_blog_posts(new_url)
        ::BlogPost.all.each do |post|
          if (! post.body.empty?) && post.body.include?(url)
            post.body = post.body.gsub(url_pattern, new_url)
            post.save!
          end
        end
      end

      def replace_url_in_pages(new_url)
        ::Page.all.each do |page|
          page.parts.each do |part|
            if (! part.body.to_s.blank?) && part.body.include?(url)
              part.body = part.body.gsub(url_pattern, new_url)
              part.save!
            end
          end
        end
      end

    end
  end
end
