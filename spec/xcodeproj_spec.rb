require File.expand_path('../spec_helper', __FILE__)

describe Xcodeproj do

  describe 'autoload' do

    # These specs have to be interpreted separated, to ensure that we have
    # a clean namespace.
    def expression(expression)
      `ruby -e "require 'xcodeproj'; #{expression.gsub('"', '\\"')}"`
      $?
    end

    describe 'access Constants first' do
      it 'succeeds to load the module' do
        expression('Xcodeproj::Constants; Xcodeproj::TargetConfiguration').
          should.success
      end
    end

    describe 'access TargetConfiguration first' do
      it 'succeeds to load the module' do
        expression('Xcodeproj::TargetConfiguration; Xcodeproj::Constants').
          should.success
      end
    end

  end

end
