require 'minitest/autorun'
require 'lightblue/client'

describe Lightblue::Client do

  before :each do
    @client = Lightblue::Client.new({data_base_uri: 'dburi', metadata_base_uri: 'mdburi', junk: 'dlete'})
  end

  it 'can be initialized' do
    @client.must_be_instance_of Lightblue::Client
  end

  it 'has a version' do
    Lightblue::Client::VERSION.wont_be_nil
  end

  it 'preserves valid config keys' do
    @client.data_base_uri.must_equal 'dburi'
  end

  it 'forgets invalid config keys' do
    Proc.new {
      @client.junk
    }.must_raise NoMethodError
  end

  it 'is configurable' do
    Lightblue.configure do |config|
      config.data_base_uri = 'custom_uri'
    end
    client = Lightblue::Client.new
    client.data_base_uri.must_equal 'custom_uri'
  end

end
