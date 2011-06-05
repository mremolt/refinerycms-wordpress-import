require 'wordpress'

namespace :wordpress do
  desc "Reset the blog relevant tables for a clean import"
  task :reset_blog do
    Rake::Task["environment"].invoke

    %w(taggings tags blog_comments blog_categories blog_categories_blog_posts 
       blog_posts).each do |table_name|
      p "Truncating #{table_name} ..."
      ActiveRecord::Base.connection.execute "DELETE FROM #{table_name}"
    end

  end

  desc "import blog data from a Refinery::WordPress XML dump"
  task :import_blog, :file_name do |task, params|
    Rake::Task["environment"].invoke
    dump = Refinery::WordPress::Dump.new(params[:file_name])

    dump.authors.each(&:to_refinery)
    attachments = dump.attachments.each(&:to_refinery)
    
    only_published = ENV['ONLY_PUBLISHED'] == 'true' ? true : false
    dump.posts(only_published).each(&:to_refinery)

    Refinery::WordPress::Post.create_blog_page_if_necessary

    ENV["MODEL"] = 'BlogPost'
    Rake::Task["friendly_id:redo_slugs"].invoke
    ENV.delete("MODEL")

    # parse all created BlogPosts bodys and replace the old wordpress image uls 
    # with the newly created ones
    attachments.each do |attachment|
      attachment.replace_image_url_in_blog_posts
    end
  end

  desc "reset blog tables and then import blog data from a Refinery::WordPress XML dump"
  task :reset_and_import_blog, :file_name do |task, params|
    Rake::Task["environment"].invoke
    Rake::Task["wordpress:reset_blog"].invoke
    Rake::Task["wordpress:import_blog"].invoke(params[:file_name])
  end


  desc "Reset the cms relevant tables for a clean import"
  task :reset_pages do
    Rake::Task["environment"].invoke

    %w(page_part_translations page_translations page_parts pages).each do |table_name|
      p "Truncating #{table_name} ..."
      ActiveRecord::Base.connection.execute "DELETE FROM #{table_name}"
    end
  end

  desc "import cms data from a Refinery::WordPress XML dump"
  task :import_pages, :file_name do |task, params|
    Rake::Task["environment"].invoke
    dump = Refinery::WordPress::Dump.new(params[:file_name])

    only_published = ENV['ONLY_PUBLISHED'] == 'true' ? true : false
    dump.pages(only_published).each(&:to_refinery)

    # After all pages are persisted we can now create the parent - child
    # relationships. This is necessary, as WordPress doesn't dump the pages in
    # a correct order. 
    dump.pages(only_published).each do |dump_page|
      page = ::Page.find(dump_page.post_id)
      page.parent_id = dump_page.parent_id
      page.save!
    end

    Refinery::WordPress::Post.create_blog_page_if_necessary
        
    ENV["MODEL"] = 'Page'
    Rake::Task["friendly_id:redo_slugs"].invoke
    ENV.delete("MODEL")
  end
  
  desc "reset cms tables and then import cms data from a Refinery::WordPress XML dump"
  task :reset_and_import_pages, :file_name do |task, params|
    Rake::Task["environment"].invoke
    Rake::Task["wordpress:reset_pages"].invoke
    Rake::Task["wordpress:import_pages"].invoke(params[:file_name])
  end
end
