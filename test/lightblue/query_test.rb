require 'test_helper'
require 'ast_helper'
include AstHelper
describe 'queryin\'' do
  let(:entity) { Lightblue::Entity.new(:foo) }
  use_ast_node_helpers

  describe 'a single expression' do
    it 'should render the correct hash' do
      expected = { op: :$eq, field: :bar, rvalue: :foo }
      find = entity.find { f[:bar].eq(:foo) }
      assert_equal find.to_hash, expected
    end
  end

  describe 'binary expressions' do
    it 'should render the correct hash' do
      expected =
        { :$and =>
                [
                  { op: :$eq, field: 'bar', rvalue: 'foo' },
                  { op: :$eq, field: :baz, rfield: :gorp }
                ]
        }

      find =
        entity.find do
          field['bar'].eq('foo')
          .and(field[:baz].eq(field[:gorp]))
        end

      assert_equal find.to_hash, expected
    end
  end

  describe 'nary relational expressions' do
    it 'value comparisons should generate the correct hash' do
      expected =
        { op: :$in, field: :bar, values: [:foo, :bar, :batz] }

      find = entity.find { field[:bar].in([:foo, :bar, :batz]) }
      assert_equal find.to_hash, expected
    end

    it 'field comparisons should render the correct hash' do
      expected = { op: :$in, field: :bar, rfield: :foo }

      find = entity .find { field[:bar].in(field[:foo]) }
      assert_equal find.to_hash, expected
    end
  end

  describe 'subqueryin\'' do
    it 'unary_expressions' do
      find = entity.not { field[:bar].eq(:foo) }
      expected = { :$not => { op: :$eq, field:  :bar, rvalue:  :foo } }
      assert_equal find.to_hash, expected
    end
  end

  describe 'chaining expressions' do
    it 'should render the correct hash' do
      expected =
        { :$and =>
          [
            { op: :$eq, field:  :bar, rvalue:  :foo },
            { op: :$eq, field:  :baz, rvalue:  10 }
          ]
        }

      find = entity.find { field[:bar].eq(:foo).and(field[:baz].eq(10)) }
      assert_equal find.to_hash, expected
    end
  end

  describe 'projecting' do
    it 'should render the correct hash' do
      query =
        Lightblue::Query.new(entity).project do
          field(:foo)
          .range(1, 2)
          .project { !field(:bar) }
        end

      query.find { field[:bar].eq(:foo) }

      expected = {
        objectType: :foo,
        query: {
          field: :bar, op: :$eq, rvalue: :foo
        },
        projection: [{
          field: :foo,
          include: true,
          range: [1, 2],
          project: {
            field: :bar, include: false
          }
        }]
      }
      assert_equal expected, query.to_hash
    end
    describe 'projection arrays' do
      it 'should render the correct hash' do
        q = Lightblue::Query.new(entity).project do
          field(:foo)
          field('bar').recursive
        end
        q.find { field[:batz].eq(:s) }
        assert_equal({ objectType: :foo, query: { field: :batz, op: :$eq, rvalue: :s },
                       projection: [{ field: :foo }, { field: 'bar', recursive: true }] }, q.to_hash)
      end
    end
    it 'should render the correct hash' do
      expected =
        { objectType: :foo,
          query:
            { :$all =>
              [
                { op:  :$eq, field:  :bar, rvalue:  :foo },
                { :$or =>
                       [
                         { op:  :$eq, field:  :baz, rfield:  :gorp },
                         { op:  :$eq, field:  :scrim, rvalue:  :scram }
                       ]
                }
              ]
            },
          projection: [{
            field: :bar,
            include: true,
            match: {
              field: :flim,
              op: :$eq,
              rvalue: :flam }
          }]
        }

      query = Lightblue::Query.new(entity).find do
        field[:bar]
        .eq(:foo)
        .all(field[:baz]
             .eq(field[:gorp])
             .or(field[:scrim].eq(:scram)))
      end
      query = query.project do
        field(:bar).match(entity.find { field[:flim].eq(:flam) })
      end
      assert_equal expected, query.to_hash
    end
  end
end
