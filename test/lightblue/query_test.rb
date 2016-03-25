require 'test_helper'
require 'ast_helper'
include AstHelper
describe 'queryin\'' do
  let(:entity) { Lightblue::Entity.new(:foo) }
  use_ast_node_helpers

  describe 'a single expression' do
    it 'should render the correct hash' do
      expected = { op: :$eq, field: :bar, rvalue: :foo }
      find = entity.find { field[:bar].eq(:foo) }
      assert_equal find.to_hash, expected
    end
  end

  describe 'match expressions' do
    it 'should render the correct hash' do
      expected = { field: :bar, regex: /.*/ }
      find = entity.find { field[:bar].match(/.*/) }
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
          field['bar']
            .eq('foo')
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
            .project { field(:bar).include(false) }
        end

      query.find { field[:bar].eq(:foo) }

      expected = {
        entity: :foo,
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

    it 'should render the correct hash' do
      expected =
        {
          entity: :foo,
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
    describe 'array match projections' do
      it 'should render the correct hash' do
        expected = { entity: :foo,
                     query: { field: :foo, op: :$eq, rvalue: 123 },
                     projection:
                     [
                       { field: :_id, include: true },
                       { field: :field1,
                         include: true,
                         match: { field: :field2, op: :$eq, rvalue: 'bar' },
                         project: [
                           { field: :field2 },
                           { field: :field3 },
                           { field: :field4 },
                           { field: :field5 }
                         ]
                       }
                     ]
                   }
        query = Lightblue::Query.new(entity)
        query2 = Lightblue::Query.new(entity)
        q =
          query.find { field[:foo].eq(123) }
               .project do
                 field(:_id).include
                 field(:field1)
                   .match(query2.find { field[:field2].eq('bar') })
                   .project do
                     field(:field2)
                     field(:field3)
                     field(:field4)
                     field(:field5)
                   end
               end
        assert_equal q.to_hash, expected
      end
    end
    describe 'ranges' do
      it 'adds a range' do
        expected = { entity: :foo,
                     query: { field: :foo, op: :$eq, rvalue: 123 },
                     projection: [{ field: :_id, include: true }],
                     from: 1,
                     to: 20 }

        query = Lightblue::Query.new(entity)
        query = query.find { field[:foo].eq(123) }
                     .project { field(:_id).include }
                     .range(1, 20)

        assert_equal query.to_hash, expected
      end
    end
    describe 'elem match expressions' do
      it 'generates the correct value' do
        expected = { entity: :foo,
                     query: { array: :foo,
                              elemMatch: { field: :foo, op: :$eq, rvalue: :bar }
                            },
                     projection: [{ field: '*' }]
                   }

        query = Lightblue::Query.new(entity)
        query = query.find { field[:foo].elem_match(field[:foo].eq(:bar)) }
                     .project { field('*') }
        assert_equal query.to_hash, expected
      end
    end
  end
end
