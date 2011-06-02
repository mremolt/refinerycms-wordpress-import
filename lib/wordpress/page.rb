module Refinery
  module WordPress
    class Page
      include ::ActionView::Helpers::TagHelper
      include ::ActionView::Helpers::TextHelper

      attr_reader :node

      def initialize(node)
        @node = node
      end

      def inspect
        "WordPress::Page(#{post_id}): #{title}"     
      end

      def title
        node.xpath("title").text
      end

      def content
        node.xpath("content:encoded").text
      end

      def content_formatted
        # WordPress doesn't export <p>-Tags, so let's run a simple_format over
        # the content. As we trust ourselves, no sanatize.
        formatted = simple_format(content, {}, { :sanitize => false })

        # Support for SyntaxHighlighter (http://alexgorbatchev.com/SyntaxHighlighter/):
        # In WordPress you can (via a plugin) enclose code in [lang][/lang]
        # blocks, which are converted to a <pre>-tag with a class corresponding
        # to the language.
        # 
        # Example:
        # [ruby]p "Hello World"[/ruby] 
        # -> <pre class="brush: ruby">p "Hello world"</pre> 
        formatted.gsub!(/\[(\w+)\]/, '<pre class="brush: \1">')
        formatted.gsub!(/\[\/\w+\]/, '</pre>')

        # remove all tags inside <pre> that simple_format created
        # TODO: replace simple_format with a method, that ignores pre-tags
        formatted.gsub!(/(<pre.*?>)(.+?)(<\/pre>)/m) do |match| 
          "#{$1}#{strip_tags($2)}#{$3}"
        end
          
        formatted
      end

      def creator
        node.xpath("dc:creator").text
      end

      def post_date
        DateTime.parse node.xpath("wp:post_date").text
      end

      def post_id
        node.xpath("wp:post_id").text.to_i
      end

      def parent_id
        node.xpath("wp:post_parent").text.to_i
      end

      def status
        node.xpath("wp:status").text
      end

      def draft?
        status != 'publish'
      end

      def ==(other)
        post_id == other.post_id
      end

      def to_refinery
        page = ::Page.create!(:title => title, :created_at => post_date, 
                              :draft => draft?, :parent_id => parent_id)

        page.parts.create(:title => 'Body', :body => content_formatted)
        page
      end
    end
  end
end
