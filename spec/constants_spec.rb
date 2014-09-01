require File.expand_path('../spec_helper', __FILE__)

describe Xcodeproj::Constants do
  describe 'COMMON_BUILD_SETTINGS' do
    def subject
      Xcodeproj::Constants::COMMON_BUILD_SETTINGS
    end

    it 'has a key :all' do
      subject[:all].should != nil
    end

    it 'has keys which are arrays' do
      (subject.keys - [:all]).should.all_conform? { |k| k.instance_of? Array }
    end

    it 'has values which are all frozen' do
      subject.should.all_conform? { |_,v| v.frozen? }
    end
  end
end
