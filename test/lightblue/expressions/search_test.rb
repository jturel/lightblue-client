require 'test_helper'
require 'ast_helper'
describe 'Search Test' do
  include AstHelper
  let(:search) { Lightblue::Expressions::Search }

  NODE = Lightblue::AST::Node
  describe '#ast_node' do
    it 'should return an instance of a query_expression node' do
      expected = NODE.new(:query_expression, []) #
      actual = search.send(:ast_root)
      assert_ast_equal expected, actual, "Expected #{expected}, got #{actual}"
    end
  end

  describe '#field' do
    describe 'with a root ast' do
      it 'appends the field node to the root ast' do
        expected = NODE.new(:query_expression, [NODE.new(:field, [:foo])])
        actual = search.new.field(:foo).send(:ast)
        assert_ast_equal expected, actual, "Expected #{expected}, got #{actual}"
      end
    end
  end

  describe 'binary_operators' do
    let(:field_exp){ search.new[:bar] }

    it 'raise an error if called on an expression that does not have a field in /0' do
      assert_raises(Lightblue::Expressions::Operators::BadParamOrdering) { search.new.eq(10) }
    end

    it 'accepts a integer' do
      expected = new_node(:query_expression, [new_node(:field, [:bar]) , new_node(:op, [:$eq]), value_node(10)])
      actual = field_exp.eq(10).send(:ast)
      assert_ast_equal expected, actual, "Expected #{expected}, got #{actual}"
    end

    it 'accepts a symbol' do
      expected = new_node(:query_expression, [new_node(:field, [:bar]) , new_node(:op, [:$eq]), value_node(:foo)])
      actual = field_exp.eq(:foo).send(:ast)
      assert_ast_equal expected, actual, "Expected #{expected}, got #{actual}"
    end

    it 'accepts a string' do
      expected = new_node(:query_expression, [new_node(:field, [:bar]) , new_node(:op, [:$eq]), value_node('foo')])
      actual = field_exp.eq('foo').send(:ast)
      assert_ast_equal expected, actual, "Expected #{expected}, got #{actual}"
    end
  end
end
