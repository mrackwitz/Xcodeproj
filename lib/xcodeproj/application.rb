require 'pathname'

module Xcodeproj

  # Represents an Xcode application installation
  #
  class Application

    # Return the currently system-wide selected Xcode installation
    #
    # @return [Application]
    #
    def self.current
      @current ||= Application.new(Pathname(`xcode-select -p`.chomp) + '../..')
    end

    # @return [Pathname]
    #         the path of the .app bundle
    attr_reader :path

    # Init an app installation representation
    #
    # @param  [Pathname] path
    #         see #path
    #
    def initialize(path)
      raise "Directory '#{path}' doesn't exist!" unless File.directory?(path)
      @path = Pathname(path)
    end

    # Return Contents path of the app bundle
    #
    # @return [Pathname]
    #
    def contents_path
      path + 'Contents'
    end

    # Return the Info.plist path
    #
    # @return [Pathname]
    #
    def info_plist_path
      contents_path + 'Info.plist'
    end

    # Return the version.plist path
    #
    # @return [Pathname]
    #
    def version_plist_path
      contents_path + 'version.plist'
    end

    # The release-version-number string
    #
    # @return [String]
    #
    def short_version
      @short_version ||= plist_read(info_plist_path, :CFBundleShortVersionString)
    end

    # The build-version-number string
    #
    # @return [String]
    #
    def version
      @version ||= plist_read(info_plist_path, :CFBundleVersion)
    end

    # Return the product build version
    #
    # @return [String]
    #
    def product_build_version
      @product_build_version ||= plist_read(version_plist_path, :ProductBuildVersion)
    end

    # The identifier, which is used for the default configuration
    #
    # @return [String]
    #
    def config_identifier
      "#{short_version}_#{product_build_version}"
    end

    private

    # Read a plist key
    #
    # @param  [Pathname|String] file
    #         the file of the plist
    #
    # @param  [#to_s] key
    #         the key to read
    #
    # @return [String]
    #
    def plist_read(file, key)
      raise ArgumentError, "File #{file} doesn't exist!" unless File.exist? file
      value_or_error = `/usr/libexec/PlistBuddy #{file} -c "Print #{key}"`.chomp
      raise StandardError, value_or_error unless $?.success?
      value_or_error
    end

  end

end
