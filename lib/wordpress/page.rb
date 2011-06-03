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
        formatted = simple_format(content)

        # Support for SyntaxHighlighter (http://alexgorbatchev.com/SyntaxHighlighter/):
        # In WordPress you can (via a plugin) enclose code in [lang][/lang]
        # blocks, which are converted to a <pre>-tag with a class corresponding
        # to the language.
        # 
        # Example:
        # [ruby]p "Hello World"[/ruby] 
        # -> <pre class="brush: ruby">p "Hello world"</pre> 
        formatted.gsub!(/\[(\w+)\](.+?)\[\/\1\]/m, '<pre class="brush: \1">\2</pre>')

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
        dump_id = node.xpath("wp:post_parent").text.to_i
        dump_id == 0 ? nil : dump_id
      end

      def status
        node.xpath("wp:status").text
      end

      def draft?
        status != 'publish'
      end

      def published?
        ! draft?
      end

      def ==(other)
        post_id == other.post_id
      end

      def to_refinery
        page = ::Page.create!(:id => post_id, :title => title, 
          :created_at => post_date, :draft => draft?)

        page.parts.create(:title => 'Body', :body => content_formatted)
        page
      end

      private 

      def simple_format(text, html_options={})
        text = ''.html_safe if text.nil?
        start_tag = tag('p', html_options, true)
        
        text.gsub!(/\r\n?/, "\n")                    # \r\n and \r -> \n
        text.gsub!(/\n\n+/, "</p>\n\n#{start_tag}")  # 2+ newline  -> paragraph
        text.insert 0, start_tag

        text.html_safe.safe_concat("</p>")
      end
    end
  end
end
