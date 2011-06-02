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

    ENV["MODEL"] = 'BlogPost'
    Rake::Task["friendly_id:redo_slugs"].invoke
    ENV["MODEL"] = nil
  end


  desc "reset blog tables and then import blog data from a Refinery::WordPress XML dump"
  task :reset_and_import_blog, :file_name do |task, params|
    Rake::Task["environment"].invoke
    Rake::Task["wordpress:reset_blog"].invoke
    Rake::Task["wordpress:import_blog"].invoke(params[:file_name])
  end

end
