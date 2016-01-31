require 'spec_helper'
require 'ast_helper'
describe Lightblue::Expressions::Field do
  Field = Lightblue::Expressions::Field

  include AstHelper
  use_ast_node_helpers
  let(:bad_param_error) { Lightblue::Expressions::Errors::BadParamForOperator }

  describe 'binary_operators' do
    let(:field_exp) { Field.new(:bar) }

    it 'accepts an integer' do
      expected = new_node(:unbound_value_comparison_expression,
                          [new_node(:field, [:bar]),
                           new_node(:binary_comparison_operator, [:$eq]),
                           value_node(10)])
      actual = field_exp.eq(10)
      expect(actual).to match_ast(expected)
    end

    it 'accepts a symbol' do
      expected = new_node(:unbound_value_comparison_expression,
                          [new_node(:field, [:bar]),
                           new_node(:binary_comparison_operator, [:$eq]),
                           value_node(:foo)])
      actual = field_exp.eq(:foo)
      expect(actual).to match_ast(expected)
    end

    it 'accepts a string' do
      expected = new_node(:unbound_value_comparison_expression,
                          [new_node(:field, [:bar]),
                           new_node(:binary_comparison_operator, [:$eq]),
                           value_node('foo')])

      actual = field_exp.eq('foo')
      expect(actual).to match_ast(expected)
    end

    it 'accepts a field' do
      expected = new_node(:unbound_field_comparison_expression,
                          [new_node(:field, [:bar]),
                           new_node(:binary_comparison_operator, [:$eq]),
                           new_node(:field, ['foo'])])

      actual = field_exp.eq(Lightblue::Expressions::Field.new('foo'))
      expect(actual).to match_ast(expected)
    end
  end

  describe 'nary comparison operators' do
    let(:field_exp) { Field.new(:bar) }

    context 'when called with a Field' do
      it 'generates a field node' do
        expected = new_node(:unbound_nary_field_comparison_expression,
                            [new_node(:field, [:bar]),
                             new_node(:nary_comparison_operator, [:$nin]),
                             new_node(:field, ['foo'])])

        actual = field_exp.nin(Lightblue::Expressions::Field.new('foo'))
        expect(actual).to match_ast(expected)
      end
    end

    context 'when called with an array' do
      it 'generates a value list array' do
        expected = new_node(:unbound_nary_value_comparison_expression,
                            [new_node(:field, [:bar]),
                             new_node(:nary_comparison_operator, [:$nin]),
                             new_node(:value_list_array, [%w('foo', 'batz')])])

        actual = field_exp.nin(%w('foo', 'batz'))
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
  describe 'array match operators' do
    context 'when called with an array' do
      it 'generates an array_contains_expression' do
        expected = new_node(:unbound_array_contains_expression,
                            [new_node(:field, [:bar]),
                             new_node(:array_contains_operator, [:$all]),
                             new_node(:value_list_array, [%w(foo batz)])])

        actual = Field.new(:bar).all(%w(foo batz))
        expect(actual).to match_ast(expected)
      end
    end
  end

  describe '#match' do
    context 'when called with a query' do
      it 'generates an array_match_expression' do
        expected = unbound_match_node
        actual = Field.new(:bar).match(Field.new(:bar).eq(:foo))
        expect(actual).to match_ast(expected)
      end
    end

    context 'when called with a string' do
      it 'generates a regex_match_expression' do
        expected = new_node(:unbound_regex_match_expression,
                            [new_node(:field, [:bar]),
                             new_node(:pattern, ['foo']),
                             new_node(:maybe_boolean, [nil]),
                             new_node(:maybe_boolean, [nil]),
                             new_node(:maybe_boolean, [nil]),
                             new_node(:maybe_boolean, [nil])])

        actual = Field.new(:bar).match('foo')
        expect(actual).to match_ast(expected)
      end

      context 'with options' do
        it 'generates a regex_match_expression with options' do
          expected = new_node(:unbound_regex_match_expression,
                              [new_node(:field, [:bar]),
                               new_node(:pattern, ['foo']),
                               new_node(:maybe_boolean, [nil]),
                               new_node(:maybe_boolean, [nil]),
                               new_node(:maybe_boolean, [true]),
                               new_node(:maybe_boolean, [true])])

          actual = Field.new(:bar).match('foo', dotall: true, caseInsensitive: true)
          expect(actual).to match_ast(expected)
        end
      end
    end

    context 'when called with a regexp' do
      it 'generates a regex_match_expression' do
        expected = new_node(:unbound_regex_match_expression,
                            [new_node(:field, [:bar]),
                             new_node(:pattern, [/foo/]),
                             new_node(:maybe_boolean, [nil]),
                             new_node(:maybe_boolean, [nil]),
                             new_node(:maybe_boolean, [nil]),
                             new_node(:maybe_boolean, [nil])])

        actual = Field.new(:bar).match(/foo/)
        expect(actual).to match_ast(expected)
      end
    end
  end
end
