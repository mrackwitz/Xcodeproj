require File.expand_path('../spec_helper', __FILE__)

module ProjectSpecs

  describe Xcodeproj::TargetConfiguration do

    def subject
      Xcodeproj::TargetConfiguration
    end

    before do
      app = stub('App', {
        :version               => '5.1.1',
        :product_build_version => '5B1008',
        :config_identifier     => '5.1.1_5B1008',
      })
      app.stubs(:is_a?).with(Xcodeproj::Application).returns(true)
      Xcodeproj::Application.stubs(:current).returns(app)
      @config_path = Pathname('data') + app.config_identifier
    end

    describe '#initialize' do
      it 'raises fail if platform is not given' do
        lambda {
          subject.new(:product_type => :application)
        }.should.raise?(ArgumentError, "[Xcodeproj] Type checking error: got nil for attribute: platform")
      end

      it 'raises if product_type is not given' do
        lambda {
          subject.new(:platform => :ios)
        }.should.raise?(ArgumentError, "[Xcodeproj] Type checking error: got nil for attribute: product_type")
      end

      it 'does not raise if all required attributes are provided' do
        lambda {
          subject.new(:product_type => :application, :platform => :ios)
        }.should.not.raise?
      end

      it 'sets the provided attributes' do
        config = subject.new({
          :platform => :ios,
          :deployment_target => '6.0',
          :product_type => :application,
          :language => :swift,
          :type => :debug
        })
        config.platform.should.be.eql?(:ios)
        config.deployment_target.should.be.eql?('6.0')
        config.product_type.should.be.eql?(:application)
        config.language.should.be.eql?(:swift)
        config.type.should.be.eql?(:debug)
      end
    end

    describe 'attributes' do
      before do
        @subject = subject.new(:product_type => :application, :platform => :ios)
      end

      describe '#platform=' do
        it 'accepts valid values' do
          @subject.platform = :ios
          @subject.platform.should.be.eql?(:ios)
          @subject.platform = :osx
          @subject.platform.should.be.eql?(:osx)
        end

        it 'raises for invalid values' do
          # Provoking an all of sudden fail of an existing test
          lambda { @subject.platform = :iwatch }.should.raise?(ArgumentError)
        end
      end

      describe '#deployment_target=' do
        it 'accepts valid values' do
          @subject.deployment_target = '10.10'
          @subject.deployment_target.should.be.eql?('10.10')
        end
      end

      describe '#product_type=' do
        it 'accepts valid values' do
          @subject.product_type = :application
          @subject.product_type.should.be.eql?(:application)
          @subject.product_type = :framework
          @subject.product_type.should.be.eql?(:framework)
          @subject.product_type = :dynamic_library
          @subject.product_type.should.be.eql?(:dynamic_library)
          @subject.product_type = :static_library
          @subject.product_type.should.be.eql?(:static_library)
          @subject.product_type = :bundle
          @subject.product_type.should.be.eql?(:bundle)
        end

        it 'raises for invalid values' do
          lambda { @subject.product_type = :trashcan }.should.raise?(ArgumentError)
        end
      end

      describe '#language=' do
        it 'accepts valid values' do
          @subject.language = :objc
          @subject.language.should.be.eql?(:objc)
          @subject.language = :swift
          @subject.language.should.be.eql?(:swift)
        end

        it 'raises for invalid values' do
          lambda { @subject.language = :haskell }.should.raise?(ArgumentError)
        end
      end

      describe '#type=' do
        it 'accepts valid values' do
          @subject.type = :debug
          @subject.type.should.be.eql?(:debug)
          @subject.type = :release
          @subject.type.should.be.eql?(:release)
        end

        it 'raises for invalid values' do
          lambda { @subject.type = :beta }.should.raise?(ArgumentError)
        end
      end
    end

    describe '#platform_name' do
      it 'returns the correct value for iOS' do
        subject.new(:product_type => :application, :platform => :ios)
          .platform_name.should.be.eql?('iOS')
      end

      it 'returns the correct value for OSX' do
        subject.new(:product_type => :application, :platform => :osx)
          .platform_name.should.be.eql?('OSX')
      end
    end

    describe '#config_dir_name' do
      it 'match the expected dir for applications' do
        subject.new(:product_type => :application, :platform => :ios, :language => :objc)
          .config_dir_name.should.eql?('Objc_iOS_Native')
      end

      it 'match the expected dir for bundles' do
        subject.new(:product_type => :bundle, :platform => :osx)
          .config_dir_name.should.eql?('OSX_Bundle')

        # yes OSX_, there is no Xcode template for iOS
        subject.new(:product_type => :bundle, :platform => :ios)
          .config_dir_name.should.eql?('OSX_Bundle')
      end
    end

    describe '#config_file_path' do
      it 'match the expected file for Objective-C iOS applications' do
        subject.new(:product_type => :application, :platform => :ios, :language => :objc, :type => :release)
          .config_file_path.should.eql?(Pathname('Objc_iOS_Native/Objc_iOS_Native_release.xcconfig'))
      end
    end

    describe '#base_config_file_path' do
      it 'match the expected file for Objective-C iOS applications' do
        subject.new(:product_type => :application, :platform => :ios, :language => :objc, :type => :release)
          .base_config_file_path.should.eql?(Pathname('Objc_iOS_Native/Objc_iOS_Native_base.xcconfig'))
      end
    end

    describe '#settings' do
      it 'sets the deployment target for iOS apps' do
        subject.new(:product_type => :application, :platform => :ios, :deployment_target => '1.0', :language => :objc, :type => :debug)
          .settings['IPHONEOS_DEPLOYMENT_TARGET'].should.be.eql?('1.0')
      end

      it 'sets the deployment target for OSX apps' do
        subject.new(:product_type => :application, :platform => :osx, :deployment_target => '10.3', :language => :objc, :type => :debug)
          .settings['MACOSX_DEPLOYMENT_TARGET'].should.be.eql?('10.3')
      end

      it 'sets the expected SDK for iOS bundles' do
        subject.new(:product_type => :bundle, :platform => :ios, :type => :debug)
          .settings['SDKROOT'].should.be.eql?('iphoneos')
      end
    end

    describe '#deployment_target_setting_key' do
      it 'returns the correct value for iOS' do
        subject.new(:product_type => :application, :platform => :ios)
          .deployment_target_setting_key.should.be.eql?('IPHONEOS_DEPLOYMENT_TARGET')
      end

      it 'returns the correct value for OSX' do
        subject.new(:product_type => :application, :platform => :osx)
          .deployment_target_setting_key.should.be.eql?('MACOSX_DEPLOYMENT_TARGET')
      end
    end

    describe '#sdk_root' do
      it 'returns the correct value for iOS' do
        subject.new(:product_type => :application, :platform => :ios)
          .sdk_root.should.be.eql?('iphoneos')
      end

      it 'returns the correct value for OSX' do
        subject.new(:product_type => :application, :platform => :osx)
          .sdk_root.should.be.eql?('macosx')
      end
    end

    describe '#config_dir_for_version' do
      it 'returns the dir for the current Xcode app by default' do
        subject.config_dir_for_version
          .should.be.eql?(Pathname('data/5.1.1_5B1008/configs'))
      end

      it 'returns the dir for the specified version if it exists' do
        subject.config_dir_for_version('6.0_6A279r')
          .should.be.eql?(Pathname('data/6.0_6A279r/configs'))
      end

      it 'raises on ambiguous version specifier' do
        lambda {
          subject.config_dir_for_version('_')
        }.should.raise?(StandardError)
      end

      it 'raises on unknown version' do
        lambda {
          subject.config_dir_for_version('5.3.0_5B1337')
        }.should.raise?(StandardError, "No config found for version '5.3.0_5B1337'.")
      end
    end

  end

end
