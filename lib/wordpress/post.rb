module WordPress
  class Post < Page
    def tags
      node.xpath("category[@domain='post_tag']").collect do |tag_node| 
        WordPress::Tag.new(tag_node.text)
      end
    end

    def tag_list
      tags.collect(&:name).join(',')
    end

    def categories
      node.xpath("category[@domain='category']").collect do |cat|
        WordPress::Category.new(cat.text)
      end
    end

    def comments
      node.xpath("wp:comment").collect do |comment_node|
        WordPress::Comment.new(comment_node)
      end
    end

    def to_refinery
      user = User.find_by_username creator
      raise "Referenced User doesn't exist! Make sure the authors are imported first." \
        unless user

      post = BlogPost.create! :title => title, :body => content, :draft => draft?, 
        :published_at => post_date, :created_at => post_date, :author => user,
        :tag_list => tag_list

      BlogPost.transaction do
        categories.each do |category|
          post.categories << category.to_refinery
        end
        
        comments.each do |comment|
          comment = comment.to_refinery
          comment.post = post
          comment.save
        end
      end

      post
    end
  end
end
