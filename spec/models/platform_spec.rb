require 'spec_helper'

describe Platform do 
  subject { Platform }

  context "OS X" do
    before :each do
      #RUBY_PLATFORM = "darwin os x"
    end

    it "should return true for is_mac?" do
      subject.mac?.should be_true
    end

    it "should return false for is_windows?" do
      subject.windows?.should be_false
    end

    it "should return false for is_linux?" do
      subject.linux?.should be_false
    end
  end

end