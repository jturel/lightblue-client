require 'spec_helper'
require 'ast_helper'
describe Lightblue::Expressions::Projection do
  Projection = Lightblue::Expressions::Projection
  Query = Lightblue::Expressions::Query
  Field = Lightblue::Expressions::Field
  include AstHelper
  use_ast_node_helpers
  let(:unbound_match_expression) { field.match(Field.new(:bar).eq(:foo)) }
  describe '.new' do
    let(:field) { Field.new(:foo) }
    let(:field_projection) { s(:field_projection, s(:field, :foo)) }
    let(:array_match) do
      s(:array_match_projection,
        s(:field, :foo),
        s(:boolean, true),
        s(:value_comparison_expression,
          s(:field, :bar),
          s(:binary_comparison_operator, :$eq),
          s(:value, :foo)),
        empty_projection,
        empty_sort)
    end

    context 'with an unbound field expression' do
      it 'should bind as a field projection' do
        actual = Projection.new(field)
        expected = field_projection
        expect(actual).to match_ast(expected)
      end
    end

    context 'with an unbound match expression' do
      it 'should bind as an array match projection' do
        actual = Projection.new(unbound_match_expression)
        expect(actual).to match_ast(array_match)
      end
    end

    context 'with an array of unbound expressions' do
      it 'they should bind to an array of projections' do
        actual = Projection.new([unbound_match_expression, field])
        expect(actual).to match_ast(s(:projection,
                                      s(:basic_projection_array,
                                        array_match, field_projection)))
      end
    end
  end
end
