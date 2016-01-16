require 'test_helper'
require 'ast_helper'
describe 'Search Test' do
  include AstHelper
  let(:search) { Lightblue::Expressions::Search }

  describe '#ast_node' do
    it 'should return an instance of a query_expression node' do
      expected = Lightblue::AST::Node.new(:query_expression, [])
      actual = search.send(:ast_root)
      assert_ast_equal expected, actual, "Expected #{expected}, got #{actual}"
    end
  end

  describe '#field' do
    describe 'with a root ast' do
      it 'appends the field node to the root ast' do
        expected = Lightblue::AST::Node.new(:query_expression,
                                            [Lightblue::AST::Node.new(:field,
                                                                     [:foo])])
          actual = search.new.field(:foo).send(:ast)

          assert_ast_equal expected, actual, "Expected #{expected}, got #{actual}"
      end

    end

  end
end


