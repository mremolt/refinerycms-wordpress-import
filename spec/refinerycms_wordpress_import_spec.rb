require 'spec_helper'

describe Refinery::WordPress do
  it "should be valid" do
    Refinery::WordPress.should be_a(Module)
  end
end
