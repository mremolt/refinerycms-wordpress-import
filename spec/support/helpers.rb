module Refinery::WordPress::SpecHelpers
  def test_dump
    file_name = File.realpath(File.join(File.dirname(__FILE__), '../fixtures/wordpress_dump.xml'))
    Refinery::WordPress::Dump.new(file_name) 
  end
end

RSpec.configure do |config|
  config.include Refinery::WordPress::SpecHelpers
end

