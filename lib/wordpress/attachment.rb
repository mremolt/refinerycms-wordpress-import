module Refinery
  module WordPress
    class Attachment
      attr_reader :node

      def initialize(node)
        @node = node
      end

      def title
        node.xpath("title").text
      end

      def description
        node.xpath("description").text
      end

      def post_date
        DateTime.parse node.xpath("wp:post_date").text
      end

      def url
        node.xpath("wp:attachment_url").text
      end
    end
  end
end
