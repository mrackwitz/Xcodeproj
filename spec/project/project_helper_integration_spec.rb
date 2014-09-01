require File.expand_path('../../spec_helper', __FILE__)

module ProjectHelperSpecs
  describe Xcodeproj::Project::ProjectHelper do

    #
    # These specs run `Xcodeproj::Project::ProjectHelper::common_build_settings`
    # against the xcconfig files in data with various parameter combinations.
    #
    # To update the data, you can do the following:
    #
    # 1. Open a new term and check your currently selected Xcode version by:
    #
    #    `rake xcode:current`
    #
    # 2. Select another Xcode version, if needed:
    #
    #    `rake xcode:select[6b6]`
    #
    # 3. Exec the following rake task.
    #
    #    `rake common_build_settings:rebuild`
    #
    #    This will:
    #      * Delete the existing project and its contents.
    #      * Create a new Xcode Project.
    #      * Give an interactive guide to create the needed targets
    #      * Dump the build settings to xcconfig files
    #
    # 4. Run specs and check if all tests still succeed
    #
    #    `rake spec:single[spec/project/project_helper_integration_spec.rb]`
    #
    # 5. Add the files to git and commit
    #
    #    ```
    #    git add data
    #    git commit -m "[Data] Added new samples for <PLACE-XCODE-VERSION-HERE>"
    #    ````
    #
    # 6. Reset your Xcode version, if you changed it.
    #
    #    `rake xcode:select[5]`
    #
    #
    # Note:
    #
    # If there have been introduced new target configurations, you need to add
    # those in lib/xcodeproj/constants.rb to `TARGET_CONFIGURATIONS`.
    # You need to reflect this change here, so the new config will been tested.
    #

    def subject
      Xcodeproj::Project::ProjectHelper
    end

    shared 'configuration settings' do
      extend SpecHelper::ProjectHelper
      built_settings = subject.common_build_settings(configuration, platform, nil, product_type, (language rescue nil))
      compare_settings(built_settings, fixture_settings[configuration], [configuration, platform, product_type, (language rescue nil)])
    end

    shared 'target settings' do
      describe "in Debug configuration" do
        define :configuration => :debug
        behaves_like 'configuration settings'
      end

      describe "in Release configuration" do
        define :configuration => :release
        behaves_like 'configuration settings'
      end
    end

    def target_from_fixtures(path)
      shared path do
        extend SpecHelper::ProjectHelper

        @path = path
        def self.fixture_settings
          Hash[[:debug, :release].map { |c| [c, load_settings(@path, c)] }]
        end

        behaves_like 'target settings'
      end

      return path
    end

    describe '::common_build_settings' do

      def swift_available?
        Xcodeproj::Application.current.short_version.to_i >= 6
      end

      describe "on platform OSX" do
        define :platform => :osx

        describe "for product type bundle" do
          define :product_type => :bundle
          behaves_like target_from_fixtures 'OSX_Bundle'
        end

        describe "in language Objective-C" do
          define :language => :objc

          describe "for product type Dynamic Library" do
            define :product_type => :dynamic_library
            behaves_like target_from_fixtures 'Objc_OSX_DynamicLibrary'
          end

          describe "for product type Framework" do
            define :product_type => :framework
            behaves_like target_from_fixtures 'Objc_OSX_Framework'
          end

          describe "for product type Application" do
            define :product_type => :application
            behaves_like target_from_fixtures 'Objc_OSX_Native'
          end

          describe "for product type Static Library" do
            define :product_type => :static_library
            behaves_like target_from_fixtures 'Objc_OSX_StaticLibrary'
          end
        end

        describe "in language Swift" do
          define :language => :swift

          describe "for product type Framework" do
            define :product_type => :framework
            behaves_like target_from_fixtures 'Swift_OSX_Framework'
          end

          describe "for product type Application" do
            define :product_type => :application
            behaves_like target_from_fixtures 'Swift_OSX_Native'
          end
        end if swift_available?
      end

      describe "on platform iOS" do
        define :platform => :ios

        def frameworks_available?
          swift_available?
        end

        # TODO: Create a target and dump its config
        #describe "for product type Bundle" do
        #  define :product_type => :bundle
        #  behaves_like target_from_fixtures 'iOS_Bundle'
        #end

        describe "in language Objective-C" do
          define :language => :objc

          describe "for product type Framework" do
            define :product_type => :framework
            behaves_like target_from_fixtures 'Objc_iOS_Framework'
          end if frameworks_available?

          describe "for product type Application" do
            define :product_type => :application
            behaves_like target_from_fixtures 'Objc_iOS_Native'
          end

          describe "for product type Static Library" do
            define :product_type => :static_library
            behaves_like target_from_fixtures 'Objc_iOS_StaticLibrary'
          end
        end

        describe "in language Swift" do
          define :language => :swift

          describe "for product type Framework" do
            define :product_type => :framework
            behaves_like target_from_fixtures 'Swift_iOS_Framework'
          end if frameworks_available?

          describe "for product type Application" do
            define :product_type => :application
            behaves_like target_from_fixtures 'Swift_iOS_Native'
          end
        end if swift_available?

      end

    end
  end
end
