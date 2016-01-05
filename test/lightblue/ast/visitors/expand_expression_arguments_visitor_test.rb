require 'test_helper'
require 'ast_helper'

describe ' Visitor' do
  include AstHelper

  let(:visitor) do
    Lightblue::AST::Visitors::DepthFirst.new do |v|
      v.pre_order Lightblue::AST::Visitors::ExpandExpressionArgumentsVisitor.new
      v.pre_order Lightblue::AST::Visitors::Validation.new
    end
  end

  it 'expanding expression arguments' do
    q2 = s(:regex_match_expression,
           :foo,
           /.*ss12/,
           nil, nil, true, nil)
    act = visitor.process(q2)
    exp = s(:regex_match_expression,
            s(:field, :foo),
            s(:pattern, /.*ss12/),
            s(:maybe_boolean, s(:empty, nil)),
            s(:maybe_boolean, s(:empty, nil)),
            s(:maybe_boolean, s(:boolean, true)),
            s(:maybe_boolean, s(:empty, nil)))
    assert_ast_equal(exp, act)
  end
end
