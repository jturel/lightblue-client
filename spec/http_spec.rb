require 'spec_helper'

describe Lightblue::Client, skip: true do
  subject do
    Lightblue.configure do |config|
      config.host_uri = ''
    end
    Lightblue::Client.new
  end

  it 'gets' do
    expect{|b| subject.get(&b) }.to yield_control
  end


  it 'posts' do
    expect{|b| subject.post(&b) }.to yield_control
  end

  it 'puts' do
    expect{|b| subject.put(&b) }.to yield_control
  end

  it 'deletes' do
    expect{|b| subject.delete(&b) }.to yield_control
  end

end
