require File.expand_path('../spec_helper', __FILE__)

describe Xcodeproj::Application do

  def subject
    Xcodeproj::Application
  end

  before do
    @app_path = fixture_path('FakeXcode.app')
    @app = subject.new(@app_path)
  end

  describe '#self.current' do
    it 'should eval xcode-select' do
      subject.expects(:`).returns("#{@app_path}/Contents/Developer")
      subject.current.path.should.eql?(Pathname(@app_path))
    end
  end

  describe '#initialize' do
    it 'should set the first argument as attribute path' do
      @app.path.should.eql?(Pathname(@app_path))
    end

    it 'should fail if the given path doesn\'t exist' do
      @fixture_path = fixture_path('FakeXcode-beta.app')
      lambda {
        subject.new(@fixture_path)
      }.should.raise?(StandardError, "File doesn't exist #{@fixture_path}!")
    end
  end

  describe '#info_plist_path' do
    it 'should be the expected path' do
      @app.info_plist_path.should \
        .eql?(Pathname("#{@app_path}/Contents/Info.plist"))
    end
  end

  describe '#version_plist_path' do
    it 'should be the expected path' do
      @app.version_plist_path.should \
        .eql?(Pathname("#{@app_path}/Contents/version.plist"))
    end
  end

  describe '#short_version' do
    it 'should return the expected value of the fixture app' do
      @app.short_version.should.eql?('5.1.1')
    end
  end

  describe '#version' do
    it 'should return the expected value of the fixture app' do
      @app.version.should.eql?('5085')
    end
  end

  describe '#product_build_version' do
    it 'should return the expected value of the fixture app' do
      @app.product_build_version.should.eql?('5B1008')
    end
  end

  describe '#config_identifier' do
    it 'should return the expected value for the fixture app' do
      @app.config_identifier.should.eql?('5.1.1_5B1008')
    end
  end

end
