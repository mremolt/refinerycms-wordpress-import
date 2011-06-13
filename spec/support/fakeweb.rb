require "fakeweb"

FakeWeb.allow_net_connect = false

# Simulating download of wordpress file attachments. The dump expects the files
# to be at the given URLs
FakeWeb.register_uri(:get, 
  "http://localhost/wordpress/wp-content/uploads/2011/05/200px-Tux.svg_.png", 
  :body => File.new('spec/fixtures/200px-Tux.svg_.png').read, 
  :content_type => "image/png")

FakeWeb.register_uri(:get, "http://localhost/wordpress/wp-content/uploads/2011/05/cv.txt", :body => "Hello World!", :content_type => "text/plain")
