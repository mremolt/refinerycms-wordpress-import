require 'nokogiri'
require "wordpress/railtie" 

module Refinery
  module WordPress
    autoload :Author, 'wordpress/author' 
    autoload :Tag, 'wordpress/tag'
    autoload :Category, 'wordpress/category'
    autoload :Page, 'wordpress/page'
    autoload :Post, 'wordpress/post'
    autoload :Comment, 'wordpress/comment'
    autoload :Dump, 'wordpress/dump'
    autoload :Attachment, 'wordpress/attachment'
  end
end

