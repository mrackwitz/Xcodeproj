module Xcodeproj
  module Helper

    # Let define enum accessors
    #
    module EnumAccessor

      # Define a new attribute with enumerated valid values and synthesises the
      # corresponding methods.
      #
      # @param  [String] name
      #         the name of the attribute
      #
      # @return [void]
      #
      def enum_accessor(name, valid_values)
        define_method(name) do
          @simple_attributes_hash ||= {}
          @simple_attributes_hash[name]
        end

        define_method("#{name}=") do |value|
          @simple_attributes_hash ||= {}
          acceptable = valid_values.include?(value)
          raise "[Xcodeproj] Type checking error: got `#{value}` for attribute: #{name}" unless acceptable
          @simple_attributes_hash[name] = value
        end
      end
    end

    class TargetDiff
      attr_reader :project, :target1, :target2

      def initialize(project, target1_name, target2_name)
        @project = project
        unless @target1 = @project.targets.find { |target| target.name == target1_name }
          raise ArgumentError, "Target 1 by name `#{target1_name}' not found in the project."
        end
        unless @target2 = @project.targets.find { |target| target.name == target2_name }
          raise ArgumentError, "Target 1 by name `#{target2_name}' not found in the project."
        end
      end

      # @return [Array<PBXBuildFile>] A list of source files (that will be
      #   compiled) which are in ‘target 2’ but not in ‘target 1’. The list is
      #   sorted by file path.
      #
      def new_source_build_files
        @target2.source_build_phase.files.reject do |target2_build_file|
          @target1.source_build_phase.files.any? do |target1_build_file|
            target1_build_file.file_ref.path == target2_build_file.file_ref.path
          end
        end.sort_by { |build_file| build_file.file_ref.path }
      end
    end
  end
end
