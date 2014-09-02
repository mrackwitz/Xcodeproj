module Xcodeproj

  # This modules groups all the constants known to Xcodeproj.
  #
  module Constants

    # @return [String] The last known iOS SDK (stable).
    #
    LAST_KNOWN_IOS_SDK = '7.1'

    # @return [String] The last known OS X SDK (stable).
    #
    LAST_KNOWN_OSX_SDK  = '10.9'

    # @return [String] The last known archive version to Xcodeproj.
    #
    LAST_KNOWN_ARCHIVE_VERSION = 1

    # @return [String] The last known object version to Xcodeproj.
    #
    LAST_KNOWN_OBJECT_VERSION  = 46

    # @return [String] The last known object version to Xcodeproj.
    #
    LAST_UPGRADE_CHECK  = '0510'

    # @return [Hash] The all the known ISAs grouped by superclass.
    #
    KNOWN_ISAS = {
      'AbstractObject' => %w[
        PBXBuildFile
        AbstractBuildPhase
        PBXBuildRule
        XCBuildConfiguration
        XCConfigurationList
        PBXContainerItemProxy
        PBXFileReference
        PBXGroup
        PBXProject
        PBXTargetDependency
        PBXReferenceProxy
      ],

      'AbstractBuildPhase' => %w[
        PBXCopyFilesBuildPhase
        PBXResourcesBuildPhase
        PBXSourcesBuildPhase
        PBXFrameworksBuildPhase
        PBXHeadersBuildPhase
        PBXShellScriptBuildPhase
      ],

      'AbstractTarget' => %w[
        PBXNativeTarget
        PBXAggregateTarget
        PBXLegacyTarget
      ],

      'PBXGroup' => %w[
        XCVersionGroup
        PBXVariantGroup
      ]
    }.freeze

    # @return [Array] The list of the super classes for each ISA.
    #
    ISAS_SUPER_CLASSES = %w[ AbstractObject AbstractBuildPhase PBXGroup ]

    # @return [Hash] The known file types corresponding to each extension.
    #
    FILE_TYPES_BY_EXTENSION = {
      'a'           => 'archive.ar',
      'app'         => 'wrapper.application',
      'dylib'       => 'compiled.mach-o.dylib',
      'framework'   => 'wrapper.framework',
      'bundle'      => 'wrapper.plug-in',
      'h'           => 'sourcecode.c.h',
      'm'           => 'sourcecode.c.objc',
      'pch'         => 'sourcecode.c.h',
      'xcconfig'    => 'text.xcconfig',
      'xcdatamodel' => 'wrapper.xcdatamodel',
      'xib'         => 'file.xib',
      'sh'          => 'text.script.sh',
      'swift'       => 'sourcecode.swift',
      'plist'       => 'text.plist.xml',
      'markdown'    => 'text',
      'xcassets'    => 'folder.assetcatalog',
      'xctest'      => 'wrapper.cfbundle'
    }.freeze

    # @return [Hash] The uniform type identifier of various product types.
    #
    PRODUCT_TYPE_UTI = {
      :application      => 'com.apple.product-type.application',
      :framework        => 'com.apple.product-type.framework',
      :dynamic_library  => 'com.apple.product-type.library.dynamic',
      :static_library   => 'com.apple.product-type.library.static',
      :bundle           => 'com.apple.product-type.bundle',
    }.freeze

    # @return [Hash] The extensions or the various product UTIs.
    #
    PRODUCT_UTI_EXTENSIONS = {
      :application     => 'app',
      :framework       => 'framework',
      :dynamic_library => 'dylib',
      :static_library  => 'a',
      :bundle          => 'bundle',
    }.freeze

    # @return [Hash] All valid {TargetConfigurations}.
    #
    TARGET_CONFIGURATIONS = {
      "Objc_iOS_Native"         => TargetConfiguration.new({ :platform => :ios, :product_type => :application,     :language => :objc  }),
      "Swift_iOS_Native"        => TargetConfiguration.new({ :platform => :ios, :product_type => :application,     :language => :swift }),
      "Objc_iOS_Framework"      => TargetConfiguration.new({ :platform => :ios, :product_type => :framework,       :language => :objc  }),
      "Swift_iOS_Framework"     => TargetConfiguration.new({ :platform => :ios, :product_type => :framework,       :language => :swift }),
      "Objc_iOS_StaticLibrary"  => TargetConfiguration.new({ :platform => :ios, :product_type => :static_library,  :language => :objc  }),
      "Objc_OSX_Native"         => TargetConfiguration.new({ :platform => :osx, :product_type => :application,     :language => :objc  }),
      "Swift_OSX_Native"        => TargetConfiguration.new({ :platform => :osx, :product_type => :application,     :language => :swift }),
      "Objc_OSX_Framework"      => TargetConfiguration.new({ :platform => :osx, :product_type => :framework,       :language => :objc  }),
      "Swift_OSX_Framework"     => TargetConfiguration.new({ :platform => :osx, :product_type => :framework,       :language => :swift }),
      "Objc_OSX_StaticLibrary"  => TargetConfiguration.new({ :platform => :osx, :product_type => :static_library,  :language => :objc  }),
      "Objc_OSX_DynamicLibrary" => TargetConfiguration.new({ :platform => :osx, :product_type => :dynamic_library, :language => :objc  }),
      "OSX_Bundle"              => TargetConfiguration.new({ :platform => :osx, :product_type => :bundle,                              }),
    }.freeze

    # @return [Hash] The default build settings for a new project.
    #
    PROJECT_DEFAULT_BUILD_SETTINGS = {
      :all => {
        'ALWAYS_SEARCH_USER_PATHS'           => 'NO',
        'CLANG_CXX_LANGUAGE_STANDARD'        => "gnu++0x",
        'CLANG_CXX_LIBRARY'                  => "libc++",
        'CLANG_ENABLE_OBJC_ARC'              => 'YES',
        'CLANG_WARN_BOOL_CONVERSION'         => 'YES',
        'CLANG_WARN_CONSTANT_CONVERSION'     => 'YES',
        'CLANG_WARN_DIRECT_OBJC_ISA_USAGE'   => 'YES',
        'CLANG_WARN__DUPLICATE_METHOD_MATCH' => 'YES',
        'CLANG_WARN_EMPTY_BODY'              => 'YES',
        'CLANG_WARN_ENUM_CONVERSION'         => 'YES',
        'CLANG_WARN_INT_CONVERSION'          => 'YES',
        'CLANG_WARN_OBJC_ROOT_CLASS'         => 'YES',
        'CLANG_WARN_UNREACHABLE_CODE'        => 'YES',
        'CLANG_ENABLE_MODULES'               => 'YES',
        'GCC_C_LANGUAGE_STANDARD'            => 'gnu99',
        'GCC_WARN_64_TO_32_BIT_CONVERSION'   => 'YES',
        'GCC_WARN_ABOUT_RETURN_TYPE'         => 'YES',
        'GCC_WARN_UNDECLARED_SELECTOR'       => 'YES',
        'GCC_WARN_UNINITIALIZED_AUTOS'       => 'YES',
        'GCC_WARN_UNUSED_FUNCTION'           => 'YES',
        'GCC_WARN_UNUSED_VARIABLE'           => 'YES',
      },
      :release => {
        'COPY_PHASE_STRIP'                   => 'NO',
        'ENABLE_NS_ASSERTIONS'               => 'NO',
        'VALIDATE_PRODUCT'                   => 'YES',
      }.freeze,
      :debug => {
        'ONLY_ACTIVE_ARCH'                   => 'YES',
        'COPY_PHASE_STRIP'                   => 'YES',
        'GCC_DYNAMIC_NO_PIC'                 => 'NO',
        'GCC_OPTIMIZATION_LEVEL'             => '0',
        'GCC_PREPROCESSOR_DEFINITIONS'       => ["DEBUG=1", "$(inherited)"],
        'GCC_SYMBOLS_PRIVATE_EXTERN'         => 'NO',
      }.freeze,
    }.freeze

    # @return [Hash{String, Proc<(PBXNativeTarget) -> String>}]
    #         The build settings which are part of the defaults, but are
    #         dependent on their file location
    #
    PROJECT_PATH_DEPENDENT_BUILD_SETTINGS = {
      'GCC_PREFIX_HEADER' => lambda { |t| "#{t}/#{t}.plist" },
      'INFOPLIST_FILE'    => lambda { |t| "#{t}/#{t}-Info.plist" },
      'DSTROOT'           => lambda { |t| "/tmp/#{t}.dst" },
      'BUNDLE_LOADER'     => lambda { |t| "$(BUILT_PRODUCTS_DIR)/#{t}.app/#{t}" },
    }.freeze

    # @return [Array<String>]
    #         The keys of build settings which were dumped, but should not been
    #         used as presets for newly created target configurations.
    #
    EXCLUDE_BUILD_SETTINGS_KEYS = PROJECT_PATH_DEPENDENT_BUILD_SETTINGS.keys.freeze

    # @return [Hash] The corresponding numeric value of each copy build phase
    #         destination.
    #
    COPY_FILES_BUILD_PHASE_DESTINATIONS = {
      :absolute_path      =>  '0',
      :products_directory => '16',
      :wrapper            =>  '1',
      :resources          =>  '7', #default
      :executables        =>  '6',
      :java_resources     => '15',
      :frameworks         => '10',
      :shared_frameworks  => '11',
      :shared_support     => '12',
      :plug_ins           => '13'
    }.freeze

    # @return [Hash] The extensions which are associated with header files.
    #
    HEADER_FILES_EXTENSIONS = %w| .h .hh .hpp .ipp |.freeze

  end
end
