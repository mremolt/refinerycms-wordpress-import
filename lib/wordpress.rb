module Refinery
  module WordPress
  end
end

require 'nokogiri'
require 'wordpress/author'
require 'wordpress/tag'
require 'wordpress/category'
require 'wordpress/page'
require 'wordpress/post'
require 'wordpress/comment'
require 'wordpress/dump'

require "wordpress/railtie" 
