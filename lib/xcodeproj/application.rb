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

    # Return all installed Xcode applications
    #
    # @return [Array<Application>]
    #
    def self.all
      Dir['/Applications/*Xcode*.app'].map { |path| new(path) }
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

    # Set the receiver system-wide as selected Xcode installation
    #
    # @return [void]
    #
    def select!
      error = `sudo xcode-select -s "#{path.realpath}"`
      raise error unless $?.success?
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

    # A human-readable representation to been printed in a term
    #
    # @return [String]
    #
    def pretty_print
      [
        "#{short_version} (#{product_build_version})",
        "    Path:            #{path}",
        "    Developer Path:  #{contents_path + 'Developer'}",
        "    Data Identifier: #{config_identifier}"
      ].join("\n")
    end

    # Check for equality
    #
    # @return [Bool]
    #
    def ==(other)
      return false unless other.is_a?(self.class)
      self.path == other.path
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
