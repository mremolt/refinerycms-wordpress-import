module WordPress
  class Page
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

      page.parts.create(:title => 'Body', :body => content)
      page
    end
  end
end
