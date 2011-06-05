module Refinery
  module WordPress
    class Attachment
      attr_reader :node
      attr_reader :refinery_image

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

      def image?
        url.match /\.(png|jpg|jpeg|gif)$/ 
      end

      def to_refinery
        if image?
          to_image
        else
          to_file
        end
      end

      def replace_image_url_in_blog_posts
        ::BlogPost.all.each do |post|
          if post.body.include? url
            post.body = post.body.gsub(url, refinery_image.image.url)
            post.save!
          end
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

      def to_file
        raise "to_file is not implemented yet, sorry!"
      end

    end
  end
end
