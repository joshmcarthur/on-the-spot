require 'spec_helper'

describe Platform do 
  subject { Platform }


  before :each do
    @current_ruby_platform = RUBY_PLATFORM
  end

  after :each do
    RUBY_PLATFORM = @current_ruby_platform
  end

  context "OS X" do
    before :each do
      RUBY_PLATFORM = "darwin os x"
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

  context "Windows" do
    before :each do
      RUBY_PLATFORM = "mswin"
    end

    it "should return false for is_mac?" do
      subject.mac?.should be_false
    end

    it "should return true for is_windows?" do
      subject.windows?.should be_true
    end

    it "should return false for is_linux?" do
      subject.linux?.should be_false
    end
  end

context "Linux" do
    before :each do
      RUBY_PLATFORM = "linux"
    end

    it "should return false for is_mac?" do
      subject.mac?.should be_false
    end

    it "should return false for is_windows?" do
      subject.windows?.should be_false
    end

    it "should return true for is_linux?" do
      subject.linux?.should be_true
    end
  end
end