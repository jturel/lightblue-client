require 'lightblue'

describe Lightblue::AST::HasNodes do
  it 'Can have dispatchers added' do
    class Foo
      extend Lightblue::AST::HasNodes
      nodes :and
    end
    (Foo.dispatch_hash[:and]).must_equal Lightblue::AST::Nodes::And
  end
end
