require 'spec_helper'

class FakeXcodeRunner
  def initialize(canned_output)
    @canned_output = canned_output
  end

  def run(args, output)
    output << @canned_output
  end
end

describe XcodeBuild, "build_settings" do
  it "returns a hash of settings when there is a single target" do
    output = <<-OUTPUT
Build settings for action build and target ExampleProject:
    ACTION = build
    AD_HOC_CODE_SIGNING_ALLOWED = NO
    ALTERNATE_GROUP = staff
OUTPUT

    settings = XcodeBuild.build_settings("anything", FakeXcodeRunner.new(output))
    
    settings["ExampleProject"].should == {
      "ACTION" => "build",
      "AD_HOC_CODE_SIGNING_ALLOWED" => "NO",
      "ALTERNATE_GROUP" => "staff"
    }
  end
  
  it "returns a hash of settings for each target when there are multiple targets" do
    output = <<-OUTPUT
Build settings for action build and target ExampleProjectOne:
    ACTION = build
    AD_HOC_CODE_SIGNING_ALLOWED = NO
    ALTERNATE_GROUP = staff
    
Build settings for action build and target ExampleProjectTwo:
    ACTION = clean
    AD_HOC_CODE_SIGNING_ALLOWED = NO
    ALTERNATE_GROUP = staff
OUTPUT

    settings = XcodeBuild.build_settings("anything", FakeXcodeRunner.new(output))
    
    settings["ExampleProjectOne"].should == {
      "ACTION" => "build",
      "AD_HOC_CODE_SIGNING_ALLOWED" => "NO",
      "ALTERNATE_GROUP" => "staff"
    }
    
    settings["ExampleProjectTwo"].should == {
      "ACTION" => "clean",
      "AD_HOC_CODE_SIGNING_ALLOWED" => "NO",
      "ALTERNATE_GROUP" => "staff"
    }
  end
end
