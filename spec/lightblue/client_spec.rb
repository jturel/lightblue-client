require 'minitest/autorun'
require 'lightblue/client'

describe Lightblue::Client do
  subject do
    Lightblue::Client.new(
      data_uri: 'dburi', metadata_uri: 'mdburi', foo: 'bar')
  end

  it 'can be initialized' do
    subject.must_be_instance_of Lightblue::Client
  end

  it 'has a version' do
    Lightblue::Client::VERSION.wont_be_nil
  end

  it 'preserves valid config keys' do
    subject.data_uri.must_equal 'dburi'
  end

  it 'forgets invalid config keys' do
    proc { subject.foo }.must_raise NoMethodError
  end

  it 'is configurable' do
    Lightblue.configure do |config|
      config.data_uri = 'custom_uri'
    end
    client = Lightblue::Client.new
    client.data_uri.must_equal 'custom_uri'
  end
end
