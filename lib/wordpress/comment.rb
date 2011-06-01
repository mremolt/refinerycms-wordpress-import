module WordPress
  class Comment
    attr_reader :node

    def initialize(node) 
      @node = node
    end

    def author
      node.xpath('wp:comment_author').text
    end

    def email
      node.xpath('wp:comment_author_email').text
    end

    def url
      node.xpath('wp:comment_author_url').text
    end

    def date
      DateTime.parse node.xpath("wp:comment_date").text
    end

    def content
      node.xpath('wp:comment_content').text
    end

    def approved?
      node.xpath('wp:comment_approved').text.to_i == 1
    end

    def ==(other) 
      (email == other.email) && (date == other.date) && (content == other.content)
    end

    def to_refinery
      comment = BlogComment.new :name => author, :email => email

      comment.body = content
      comment.created_at = date
      comment.state = approved? ? 'approved' : 'rejected'
      comment
    end
  end
end
