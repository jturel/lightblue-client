require 'minitest/autorun'

describe Lightblue::Client do

  it 'can be initialized' do
    client = Lightblue::Client.new({data_base_uri: 'dburi', metadata_base_uri: 'mdburi', junk: 'dlete'})
  end

  it 'has a version' do
    Lightblue::Client::VERSION.wont_be_nil
  end

  it 'has options' do
    Lightblue::Client.options.wont_be_nil
  end

end
