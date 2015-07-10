require 'spec_helper'
require 'lightblue/client'

describe Lightblue::Client do
  subject do
    Lightblue::Client.new(
      data_uri: 'dburi', metadata_uri: 'mdburi', foo: 'bar')
  end

  it 'can be initialized' do
    expect(subject).to be_instance_of Lightblue::Client
  end

  it 'has a version' do
    expect(Lightblue::Client::VERSION).not_to be nil
  end

  it 'preserves valid config keys' do
    expect(subject.data_uri).to eq 'dburi'
  end

  it 'forgets invalid config keys' do
    expect { subject.foo }.to raise_error NoMethodError
  end

  it 'is configurable' do
    Lightblue.configure do |config|
      config.data_uri = 'custom_uri'
    end
    client = Lightblue::Client.new
    expect(client.data_uri).to eq 'custom_uri'
  end
end
