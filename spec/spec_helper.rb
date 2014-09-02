# Set up coverage analysis
#-----------------------------------------------------------------------------#

if RUBY_VERSION >= '1.9.3'
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.configure do |config|
    config.logger.level = Logger::WARN
  end
  CodeClimate::TestReporter.start
end

# Set up
#-----------------------------------------------------------------------------#

require 'rubygems'
require 'bacon'
require 'mocha-on-bacon'
require 'pretty_bacon'
require 'pathname'

ROOT = Pathname.new(File.expand_path('../../', __FILE__))

$:.unshift((ROOT + 'ext').to_s)
$:.unshift((ROOT + 'lib').to_s)
require 'xcodeproj'

$:.unshift((ROOT + 'spec').to_s)
require 'spec_helper/project'
require 'spec_helper/project_helper'
require 'spec_helper/temporary_directory'


def data_path(*paths)
  File.join(File.dirname(__FILE__), "../data", *paths)
end

def fixture_path(path)
  File.join(File.dirname(__FILE__), "fixtures", path)
end

# Define custom matchers
class Should

  # Checks if all values satisfy a given predicate
  #
  def all_conform?(&predicate)
    non_conforming = @object.reject &predicate
    list = non_conforming.map { |v| "  * #{v}" }.join("\n")
    satisfy("Not all elements conform predicate:\n#{list}") do
      non_conforming.empty?
    end
  end

end

class Hash
  def recursive_diff(other, self_key = 'self', other_key = 'other')
    Xcodeproj::Differ.project_diff(self, other, self_key, other_key)
  end

  def recursive_delete(key_to_delete)
    Xcodeproj::Differ.project_diff!(self, key_to_delete)
  end
end

class Array
  def recursive_diff(other, self_key = 'self', other_key = 'other')
    Xcodeproj::Differ.project_diff(self, other, self_key, other_key)
  end
end

class Object
  def recursive_diff(other, self_key = 'self', other_key = 'other')
    Xcodeproj::Differ.project_diff(self, other, self_key, other_key)
  end
end
