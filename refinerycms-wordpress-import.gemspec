# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name        = "refinerycms-wordpress-import"
  s.summary     = "Import WordPress XML dumps into refinerycms(-blog)."
  s.description = "This gem imports a WordPress XML dump into refinerycms (Page [soon], User) and refinerycms-blog (BlogPost, BlogCategory, Tag, BlogComment)"
  s.version     = "0.1.0"
  s.date        = "2011-06-03"

  s.authors     = ['Marc Remolt']
  s.email       = 'marc.remolt@googlemail.com'
  s.homepage    = 'https://github.com/mremolt/refinerycms-wordpress-import'
  
  s.add_dependency 'bundler', '~> 1.0'
  s.add_dependency 'refinerycms', '~> 1.0.0'
  s.add_dependency 'refinerycms-blog', '~> 1.5.2'
  s.add_dependency 'nokogiri', '~> 1.4.4'

  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'database_cleaner'

  s.files = Dir["{app,lib,config}/**/*"] + ["MIT-LICENSE", "Rakefile", "Gemfile", "README.rdoc"]
end
