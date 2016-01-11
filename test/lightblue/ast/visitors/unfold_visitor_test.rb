require 'test_helper'
require 'ast_helper'

describe 'wip Visitor' do
  include AstHelper

  use_ast_node_helpers
  let(:visitor) do
    Lightblue::AST::Visitors::UnfoldVisitor.new
  end

  let(:entity) { Lightblue::Entity.new(:foo) }
  let(:bin_expr) { entity[:bar].eq(:foo).resolve }

  it 'expanding expression arguments' do
    q2 = s(:regex_match_expression,
           :foo,
           /.*ss12/,
           nil, nil, true, nil)
    act = visitor.process(q2)
    exp = regex_match_exp_node
    assert_ast_equal(exp, act)
  end

  describe 'expanding projections' do
    it 'field projections' do
      actual = visitor.process s(:field_projection, 'foo', true, nil)
      expected = s(:field_projection,
                   s(:pattern, 'foo'),
                   s(:maybe_boolean, s(:boolean, true)),
                   s(:maybe_boolean, s(:empty, nil))
                  )
      assert_ast_equal expected, actual
    end

    it 'visiting the same ast twice wip' do
      actual = visitor.process s(:field_projection, 'foo', true, nil)
      actual = visitor.process actual
      expected = s(:field_projection,
                   s(:pattern, 'foo'),
                   s(:maybe_boolean, s(:boolean, true)),
                   s(:maybe_boolean, s(:empty, nil))
                  )
      assert_ast_equal expected, actual
 
    end

    it 'array match projections' do
      p = s(:array_match_projection, 'foo', true, field_comparison_exp_node, nil, nil)

      actual = visitor.process p
      expected = s(:array_match_projection,
                   s(:pattern, 'foo'),
                   s(:boolean, true),
                   field_comparison_exp_node,
                   s(:maybe_projection, s(:empty, nil)),
                   s(:maybe_sort, s(:empty, nil)))
      assert_ast_equal expected, actual
    end
  end


end
