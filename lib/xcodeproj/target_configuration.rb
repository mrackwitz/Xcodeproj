require 'active_support/inflector'
require 'xcodeproj/helper'

module Xcodeproj

  # Represents a parameter set to describe a certain target
  # configuration, which has preset build settings
  #
  class TargetConfiguration

    extend Xcodeproj::Helper::EnumAccessor

    # @return [Symbol]
    #         the platform, can be `:ios` or `:osx`.
    enum_accessor :platform, [:ios, :osx]

    # @return [String]
    #         the deployment target for the platform.
    attr_accessor :deployment_target

    # @return [Symbol]
    #         the product type
    enum_accessor :product_type, Constants::PRODUCT_TYPE_UTI.keys

    # @return [Symbol]
    #         the language
    enum_accessor :language, [:objc, :swift]

    # @return [Symbol]
    #         the type of the build configuration, can be `:release` or
    #         `:debug`.
    enum_accessor :type, [:debug, :release]

    # Init a new instance
    #
    # @params [Hash{Symbol => Symbol|String}] params
    #         key-value pairs for the attributes
    #
    def initialize(params)
      params.each do |key,value|
        raise "[Xcodeproj] Invalid option `#{key}` passed to #{self.class} initializer" unless respond_to?(key)
        send "#{key}=", value
      end
    end

    # Return the name of the platform
    #
    # @return [String]
    #
    def platform_name
      case platform
        when :ios then 'iOS'
        when :osx then 'OSX'
      end
    end

    # Return the name of the config directory, where serialized build settings
    # for all type of build configurations can be found.
    #
    # @return [String]
    #
    def config_dir_name
      [
        language.to_s.camelize,
        platform_name,
        product_type == :application ? 'Native' : product_type.to_s.camelize
      ].reject(&:empty?).join('_')
    end

    # Return the path of the config file
    #
    # @return [Pathname]
    #
    def config_file_path
      Pathname("#{config_dir_name}/#{config_dir_name}_#{type}.xcconfig")
    end

    # Return the path of the corresponding base config file
    #
    # @return [Pathname]
    #
    def base_config_file_path
      Pathname("#{config_dir_name}/#{config_dir_name}_base.xcconfig")
    end

  end

end
