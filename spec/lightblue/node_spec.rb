require 'spec_helper'
require 'lightblue'

describe Lightblue::AST::HasNodes do
  it 'Can have dispatchers added' do
    class Foo
      extend Lightblue::AST::HasNodes
      has_nodes :and
    end
    expect(Foo.dispatch_hash[:and]).to eq Lightblue::AST::Nodes::And
  end
end
