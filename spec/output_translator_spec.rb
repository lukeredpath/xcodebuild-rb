require 'spec_helper'

describe XcodeBuild::OutputTranslator do
  let(:delegate)   { mock('delegate') }
  let(:translator) { XcodeBuild::OutputTranslator.new(delegate, ignore_global_translations: true) }
  
  it "notifies the delegate of each line received (to assist additional processing elsewhere)" do
    delegate.should_receive(:beginning_translation_of_line).with("the line")
    translator << "the line"
  end
  
  it "treats :beginning_translation_of_line as an optional delegate message" do
    delegate_should_not_respond_to(:beginning_translation_of_line)
    delegate.should_not_receive(:beginning_translation_of_line)
    translator << "anything"
  end
  
  it "asks each translation to attempt to translate a line" do
    translator.use_translation(FakeTranslation.dup)
    translator.use_translation(FakeTranslation.dup)

    translator << "a line"

    translator.translations.each do |translation|
      translation.should have_attempted_to_translate("a line")
    end
  end
  
  private
  
  module FakeTranslation
    def attempt_to_translate(line)
      @attempted_to_translate = line
    end
    
    def has_attempted_to_translate?(line)
      line == @attempted_to_translate
    end
  end
  
  def delegate_should_respond_to(method)
    mock_should_respond?(delegate, method, true)
  end
  
  def delegate_should_not_respond_to(method)
    mock_should_respond?(delegate, method, false)
  end
  
  def mock_should_respond?(mock, method, should_respond)
    mock.stub(:respond_to?).with(method).and_return(should_respond)
  end
end
