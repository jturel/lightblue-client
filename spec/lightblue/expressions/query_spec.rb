require 'spec_helper'
require 'ast_helper'
describe Lightblue::Expressions::Query do
  Query = Lightblue::Expressions::Query

  include AstHelper
  use_ast_node_helpers
  let(:bad_param_error) { Lightblue::Expressions::Errors::BadParamForOperator }

  describe '#field' do
    context 'when called with a value' do
      it 'appends the field node to the root ast' do
        expected = new_node(:query_expression, [new_node(:field, [:foo])])
        actual = Query.new.field(:foo).send(:ast)
        assert_ast_equal expected, actual, "Expected #{expected}, got #{actual}"
      end
    end

    context 'when called with a field' do
      it 'appends to field node to the root ast' do
        expected = new_node(:query_expression, [new_node(:field, [:foo])])
        actual = Query.new.field(Lightblue::Expressions::Field.new(:foo)).send(:ast)
        assert_ast_equal expected, actual, "Expected #{expected}, got #{actual}"
      end
    end
  end

  describe 'binary_operators' do
    let(:field_exp) { Query.new.field(:bar) }

    it 'accepts an integer' do
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

    it 'accepts a field' do
      expected = new_node(:query_expression, [new_node(:field, [:bar]),
                                              new_node(:binary_comparison_operator, [:$eq]),
                                              new_node(:field, ['foo'])])
      actual = field_exp.eq(Lightblue::Expressions::Field.new('foo')).send(:ast)
      assert_ast_equal expected, actual, "Expected #{expected}, got #{actual}"
    end
  end

  describe 'nary comparison operators' do
    let(:field_exp) { Query.new.field(:bar) }

    context 'when called with a Field' do
      it 'generates a field node' do
        expected = new_node(:query_expression, [new_node(:field, [:bar]),
                                                new_node(:nary_comparison_operator, [:$nin]),
                                                new_node(:field, ['foo'])])
        actual = field_exp.nin(Lightblue::Expressions::Field.new('foo')).send(:ast)
        expect(actual).to match_ast(expected)
      end
    end

    context 'when called with an array' do
      it 'generates a value list array' do
        expected = new_node(:query_expression, [new_node(:field, [:bar]),
                                                new_node(:nary_comparison_operator, [:$nin]),
                                                new_node(:value_list_array, [%w('foo', 'batz')])])
        actual = field_exp.nin(%w('foo', 'batz')).send(:ast)
        expect(actual).to match_ast(expected)
      end
    end

    context 'when called with an integer' do
      it('raises BadParamForOperator') { expect { field_exp.in(1) }.to raise_error(bad_param_error) }
    end

    context 'when called with a string' do
      it('raises BadParamForOperator') { expect { field_exp.in('s') }.to raise_error(bad_param_error) }
    end

    context 'when called with a symbol' do
      it('raises BadParamForOperator') { expect { field_exp.in(:s) }.to raise_error(bad_param_error) }
    end
  end

  describe 'nary logical operators' do
    let(:query) { Query.new(query_exp_node) }
    context 'when called with an array of literals' do
      it('raises BadParamForOperator') { expect { Query.new.all([:f, :s]) }.to raise_error(bad_param_error) }
    end

    context 'when called with an expression' do
      it('raises BadParamForOperator') { expect { Query.new.all(query) }.to raise_error(bad_param_error) }
    end

    context 'when called with an array of expressions' do
      it 'generates a nary_logical_expression' do
        expected = new_node(:nary_logical_expression,
                            [new_node(:nary_logical_operator, [:$all]),
                             new_node(:query_array, [query_exp_node, query_exp_node])])
        actual = Query.new.all([query, query]).send(:ast)
        expect(actual).to match_ast(expected)
      end
    end
  end

  describe 'unary logical operators' do
    let(:query) { Query.new(query_exp_node) }
    context 'when called with an array' do
      it('raises BadParamForOperator') { expect { Query.new.not([:f, :s]) }.to raise_error(bad_param_error) }
    end

    context 'when called with a literal' do
      it('raises BadParamForOperator') { expect { Query.new.all(1) }.to raise_error(bad_param_error) }
    end

    context 'when called with an expression' do
      it 'generates a unary_logical_expression' do
        expected = new_node(:unary_logical_expression,
                            [new_node(:unary_logical_operator, [:$not]),
                             query_exp_node])
        actual = Query.new.not(query).send(:ast)
        expect(actual).to match_ast(expected)
      end
    end
  end
end
