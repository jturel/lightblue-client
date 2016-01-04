require 'test_helper'
require 'ast_helper'
include AstHelper
Entity = Lightblue::Entity
describe Entity do
  it '[]' do
    actual = Entity.new(:foo)[:bar].ast.first
    expected = s(:field, :bar)
    assert_ast_equal actual, expected
  end
end
