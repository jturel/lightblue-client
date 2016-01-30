require 'spec_helper'
require 'ast_helper'
describe 'Search Test' do
  include AstHelper
  let(:search) { Lightblue::Expressions::Search }

  describe '#ast_node' do
    it 'should return an instance of a query_expression node' do
      expected = new_node(:query_expression, []) #
      actual = search.send(:ast_root)
      assert_ast_equal expected, actual, "Expected #{expected}, got #{actual}"
    end
  end

  describe '#field' do
    describe 'with a root ast' do
      it 'appends the field node to the root ast' do
        expected = new_node(:query_expression, [new_node(:field, [:foo])])
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
      expected = new_node(:query_expression, [new_node(:field, [:bar]),
                                              new_node(:binary_comparison_operator, [:$eq]),
                                              value_node(10)])
      actual = field_exp.eq(10).send(:ast)
      assert_ast_equal expected, actual, "Expected #{expected}, got #{actual}"
    end

    it 'accepts a symbol' do
      expected = new_node(:query_expression, [new_node(:field, [:bar]),
                                              new_node(:binary_comparison_operator, [:$eq]),
                                              value_node(:foo)])
      actual = field_exp.eq(:foo).send(:ast)
      assert_ast_equal expected, actual, "Expected #{expected}, got #{actual}"
    end

    it 'accepts a string' do
      expected = new_node(:query_expression, [new_node(:field, [:bar]),
                                              new_node(:binary_comparison_operator, [:$eq]),
                                              value_node('foo')])
      actual = field_exp.eq('foo').send(:ast)
      assert_ast_equal expected, actual, "Expected #{expected}, got #{actual}"
    end
  end

  describe 'nary comparison operators' do
    let(:field_exp) { search.new[:bar] }

    it 'raise an error if called on an expression that does not have a field in /0' do
      skip
      assert_raises(Lightblue::AST::Visitors::ValidationVisitor::UnresolveableExpression) { search.new.eq(10) }
    end

    it 'does not accept an integer' do
      skip
      assert_raises(Lightblue::AST::Visitors::ValidationVisitor::UnresolveableExpression) { field_exp.in(10) }
      assert_ast_equal expected, actual, "Expected #{expected}, got #{actual}"
    end

    it 'accepts a symbol' do
      expected = new_node(:query_expression, [new_node(:field, [:bar]),
                                              new_node(:nary_comparison_operator, [:$not_in]),
                                              new_node(:field, [:foo])])
      actual = field_exp.not_in(:foo).send(:ast)
      assert_ast_equal expected, actual, "Expected #{expected}, got #{actual}"
    end

    it 'accepts a string' do
      expected = new_node(:query_expression, [new_node(:field, [:bar]),
                                              new_node(:nary_comparison_operator, [:$nin]),
                                              new_node(:field, ['foo'])])
      actual = field_exp.nin(search.new['foo']).send(:ast)
      assert_ast_equal expected, actual, "Expected #{expected}, got #{actual}"
    end
  end
end
