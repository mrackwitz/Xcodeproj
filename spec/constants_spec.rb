require File.expand_path('../spec_helper', __FILE__)

describe Xcodeproj::Constants do
  describe 'COMMON_BUILD_SETTINGS' do
    def subject
      Xcodeproj::Constants::COMMON_BUILD_SETTINGS
    end

    it 'has a key :all' do
      subject[:all].should.not.be.nil
    end

    it 'has keys which are arrays' do
      (subject.keys - [:all]).should.all_conform? { |k| k.instance_of? Array }
    end

    it 'has values which are all frozen' do
      subject.should.all_conform? { |_,v| v.frozen? }
    end
  end

  describe 'TARGET_CONFIGURATIONS' do
    def subject
      Xcodeproj::Constants::TARGET_CONFIGURATIONS
    end

    it 'has keys which matches their config_dir_name' do
      subject.should.all_conform? { |k,v| v.config_dir_name == k }
    end

    it 'has values which are TargetConfigurations' do
      subject.should.all_conform? { |_,v| v.is_a?(Xcodeproj::TargetConfiguration) }
    end

    it 'has for each value a dumped base config file for latest Xcode version' do
      dir = Pathname(Dir[data_path('*/configs')].sort.last)
      subject.map { |_,v| dir + v.base_config_file_path }.should.all_conform? &:exist?
    end
  end
end
