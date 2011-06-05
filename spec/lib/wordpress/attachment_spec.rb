require 'spec_helper'

describe Refinery::WordPress::Attachment, :type => :model do
  let(:attachment) { test_dump.attachments.first }

  specify { attachment.title.should == '200px-Tux.svg' }
  specify { attachment.description.should == 'Tux, the Linux mascot' }
  specify { attachment.url.should == 'http://localhost/wordpress/wp-content/uploads/2011/05/200px-Tux.svg_.png' }
  specify { attachment.post_date.should == DateTime.new(2011, 6, 5, 15, 26, 51) }
end
