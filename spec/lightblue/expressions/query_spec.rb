require 'spec_helper'
require 'ast_helper'
describe Lightblue::Expressions::Query do
  Query = Lightblue::Expressions::Query

  include AstHelper
  use_ast_node_helpers
  let(:bad_param_error) { Lightblue::Expressions::Errors::BadParamForOperator }
  let(:unbound_exp) { Lightblue::Expressions::Field.new(:bar).eq(:batz) }
  let(:unbound_node) do
    new_node(:value_comparison_expression,
             [new_node(:field, [:bar]),
              new_node(:binary_comparison_operator, [:$eq]),
              new_node(:value, [:batz])])
  end

  describe '.new' do
    context 'with an unbound_exp expression' do
      it 'generates a query expression' do
        actual = Query.new(unbound_exp)
        expected = unbound_node
        expect(actual).to match_ast(expected)
      end
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
        actual = Query.new.all([query, query])
        expect(actual).to match_ast(expected)
      end
    end

    context 'when called with an array of unbound_exp expressions' do
      it 'generates a nary_logical_expression' do
        expected = new_node(:nary_logical_expression,
                            [new_node(:nary_logical_operator, [:$all]),
                             new_node(:query_array, [unbound_node, unbound_node])])
        actual = Query.new.all([unbound_exp, unbound_exp])
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
        actual = Query.new.not(query)
        expect(actual).to match_ast(expected)
      end
    end
  end
end
