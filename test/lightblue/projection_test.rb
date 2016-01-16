
require 'test_helper'
include AstHelper
describe 'projections' do
  let(:entity) { Lightblue::Entity.new(:foo) }
  let(:field_projection) { Lightblue::Projection.new(:foo, entity) }
  let(:match_query) { Expression.new.apply_ast(query_exp_node) }
  let(:match_projection) { Lightblue::Projection.new(:foo, entity).match(match_query) }

  use_ast_node_helpers
  describe 'projections' do
    describe 'field projections' do
      it 'ast' do
        expected =
          s(:projection,
            s(:basic_projection, field_projection_node))
        assert_ast_equal expected, entity.project(field_projection).ast
      end

      it 'to_hash with no properties' do
        assert_equal({ field: :foo }, field_projection.to_hash)
      end

      it 'with include' do
        assert_equal({ field: :foo, include: true }, field_projection.include.to_hash)
      end

      it 'with recursive' do
        assert_equal({ field: :foo, recursive: true }, field_projection.recursive.to_hash)
      end
    end

    describe 'array match projections' do
      it 'ast' do
        p = match_projection.project(field_projection)
        expected =
          s(:projection,
            s(:basic_projection,
              s(:array_projection,
                array_match_projection_node)))
        assert_ast_equal expected, p.ast
      end

      it 'to_hash with no properties' do
        p = match_projection.project(field_projection)
        expected = { field: :foo,
                     include: true,
                     match: {
                       field: :bar,
                       op: :!=,
                       rfield: :batz
                     },
                     project: { field: :foo }
                   }
        assert_equal(expected, p.to_hash)
      end
    end
  end
end
