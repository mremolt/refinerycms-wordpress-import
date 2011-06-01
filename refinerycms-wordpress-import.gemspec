# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "refinerycms-wordpress-import"
  s.summary = "Import WordPress XML dumps into refinerycms(-blog)."
  s.description = "Insert Refinerycms-wordpress-import description."
  s.files = Dir["{app,lib,config}/**/*"] + ["MIT-LICENSE", "Rakefile", "Gemfile", "README.rdoc"]
  s.version = "0.0.1"
  
  s.add_dependency 'refinerycms', '~> 1.0.0'
  s.add_dependency 'refinerycms-blog', '~> 1.3.2'
end
