# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require "rspec/rails"
require "database_cleaner"
require "fakeweb"

FakeWeb.allow_net_connect = false

# Simulating download of wordpress file attachments. The dump expects the files
# to be at the given URLs
FakeWeb.register_uri(:get, 
  "http://localhost/wordpress/wp-content/uploads/2011/05/200px-Tux.svg_.png", 
  :body => File.new('spec/fixtures/200px-Tux.svg_.png').read, 
  :content_type => "image/png")

FakeWeb.register_uri(:get, "http://localhost/wordpress/wp-content/uploads/2011/05/cv.txt", :body => "Hello World!", :content_type => "text/plain")

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  # Remove this line if you don't want RSpec's should and should_not
  # methods or matchers
  require 'rspec/expectations'
  config.include RSpec::Matchers

  # == Mock Framework
  config.mock_with :rspec

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
