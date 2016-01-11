require 'test_helper'

describe 'Lightblue::AST::Visitors::UnfoldVisitor' do
  include AstHelper
  use_ast_node_helpers

  let(:visitor) do
    Lightblue::AST::Visitors::UnfoldVisitor.new
  end

  it 'expands expression arguments into an ast' do
    actual = visitor.process(
      s(:regex_match_expression,
        :foo,
        /.*ss12/,
        nil, nil, true, nil))
    assert_ast_equal(regex_match_exp_node, actual)
  end

  describe 'expanding projections' do
    it 'expands field projections' do
      actual = visitor.process s(:field_projection, 'foo', true, nil)
      expected = s(:field_projection,
                   s(:pattern, 'foo'),
                   s(:maybe_boolean, s(:boolean, true)),
                   s(:maybe_boolean, s(:empty, nil))
                  )
      assert_ast_equal expected, actual
    end

    it 'visiting the same ast twice yields the same value' do
      actual = visitor.process s(:field_projection, 'foo', true, nil)
      actual = visitor.process actual
      expected = s(:field_projection,
                   s(:pattern, 'foo'),
                   s(:maybe_boolean, s(:boolean, true)),
                   s(:maybe_boolean, s(:empty, nil))
                  )
      assert_ast_equal expected, actual
    end

    it 'expands array match projections' do
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
