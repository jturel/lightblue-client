require 'test_helper'
require 'ast_helper'
include AstHelper
describe 'wip queryin\'' do

  let(:entity) { Lightblue::Entity.new(:foo) }
  use_ast_node_helpers
  describe 'a single expression' do
    it 'should render the correct json' do
      expected = { op: :$eq, field: :bar, rvalue: :foo }

      query = entity
              .find entity[:bar].eq(:foo)
      assert_equal query.to_hash, expected
    end
  end

  describe 'binary expressions' do
    it 'should render the correct json wip' do
      expected =
        { :$and => [
            { op: :$eq, field: 'bar', rvalue: 'foo' },
            { op: :$eq, field: :baz, rfield: :gorp }
          ] }

      query = entity
              .find(entity['bar'].eq('foo')
              .and(entity[:baz].eq(entity[:gorp])))
      assert_equal query.to_hash, expected
    end
  end

  describe 'nary relational expressions' do
    it 'value comparisons should render the correct json' do
      expected =
        { op: :$in, field: :bar, values: [:foo, :bar, :batz ] }

      query = entity
              .find(entity[:bar].in([:foo, :bar, :batz]))
      assert_equal query.to_hash, expected
    end

    it 'field comparisons should render the correct json' do
      expected =
        { op: :$in, field: :bar, rfield: :foo }

      query = entity
              .find(entity[:bar].in(entity[:foo]))
      assert_equal query.to_hash, expected
    end
  end

  describe 'subqueryin\'' do
    it 'should render the correct json' do
      expected =
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
        }

      query = entity.find(
        entity[:bar].eq(:foo).all(
                            entity[:baz].eq(entity[:gorp])
                            .or(entity[:scrim].eq(:scram))
      ))

      assert_equal query.to_hash, expected
    end
  end

  # TODO:  Document precedence
  describe 'chaining expressions' do
    it 'should render the correct json' do
      expected =
        { :$and =>
          [
            { op: :$eq, field:  :bar, rvalue:  :foo },
            { op: :$eq, field:  :baz, rvalue:  10 }
          ]
        }

      query = entity
              .find(entity[:bar].eq(:foo))
              .and entity[:baz].eq(10)

      assert_equal query.to_hash, expected
    end
  end
end
