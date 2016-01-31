require 'spec_helper'
require 'ast_helper'
describe Lightblue::Expressions::Unbound do
  include AstHelper
  use_ast_node_helpers
  Unbound = Lightblue::Expressions::Unbound
  Projection = Lightblue::Expressions::Projection
  Query = Lightblue::Expressions::Query
  Field = Lightblue::Expressions::Field

  let(:unbound_expression) { Field.new(:bar).eq(:foo) }

  describe 'binding to expressions' do
    describe 'unbound_value_comparison_expressions' do
      context 'binding to field#match' do
        it 'binds as a value_comparison_expression' do
          actual = Field.new(:bar).match(unbound_expression)
          expect(actual).to match_ast(unbound_match_node)
        end
      end
    end
    describe  'unbound match expressions' do
      context 'binding to queries' do
        it 'binds as an array_match_expression' do
          actual = Query.new(Unbound.new(unbound_match_node))
          expect(actual).to match_ast(array_match_expression_node)
        end
      end
    end
  end
end
