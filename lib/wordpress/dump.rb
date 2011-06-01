require 'nokogiri'

module WordPress
  class Dump
    attr_reader :doc

    def initialize(file_name)
      file = File.open(file_name)
      @doc = Nokogiri::XML(file)
    end

    def authors
      doc.xpath("//wp:author").collect do |author|
        WordPress::Author.new(author)
      end
    end

    def pages
      doc.xpath("//item[wp:post_type = 'page']").collect do |page|
        WordPress::Page.new(page)
      end
    end

    def posts
      doc.xpath("//item[wp:post_type = 'post']").collect do |post|
        WordPress::Post.new(post)
      end
    end

    def tags
      doc.xpath("//wp:tag/wp:tag_slug").collect do |tag|
        WordPress::Tag.new(tag.text)
      end
    end

    def categories
      doc.xpath("//wp:category/wp:cat_name").collect do |category|
        WordPress::Category.new(category.text)
      end
    end
  end
end
