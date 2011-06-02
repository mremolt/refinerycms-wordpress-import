require 'nokogiri'
require 'wordpress'

namespace :wordpress do
  desc "Reset the blog relevant tables for a clean import"
  task :reset_blog do
    Rake::Task["environment"].invoke

    %w(taggings tags blog_comments blog_categories blog_posts).each do |table_name|
      p "Truncating #{table_name} ..."
      ActiveRecord::Base.connection.execute "DELETE FROM #{table_name}"
    end
  end


  desc "import blog data from a Refinery::WordPress XML dump"
  task :import_blog, :file_name do |task, params|
    Rake::Task["environment"].invoke
    dump = Refinery::WordPress::Dump.new(params[:file_name])

    dump.authors.each(&:to_refinery)
    dump.posts.each(&:to_refinery)
  end









  desc "Import data from a Refinery::WordPress XML dump"
  task :import, :file_name do |task, params|
    Rake::Task["environment"].invoke
  end

  desc "New import (testing)"
  task :new_import, :file_name do |task, params|
    Rake::Task["environment"].invoke

    file_name = File.absolute_path(params[:file_name])
    unless File.file?(file_name) && File.readable?(file_name)
      raise "Given file '#{file_name}' no file or not readable."
    end

    dump = Refinery::WordPress::Dump.new(file_name)
    p dump.authors
    p dump.pages
    dump.posts.each do |post|
      p post.title
      p post.categories
      p post.tags
      p post.creator
      #p post.content
    end
  end

  
  desc "Import data from a Refinery::WordPress XML dump into a clean database (reset first)"
  task :import_clean, :file_name do |task, params|
    Rake::Task["wordpress:reset"].invoke
    Rake::Task["wordpress:import"].invoke(params[:file_name])

  end
end
