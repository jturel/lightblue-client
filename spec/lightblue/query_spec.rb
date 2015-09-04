require 'spec_helper'
require 'lightblue'

describe 'queryin\'' do
  let(:entity) { Lightblue::Entity.new(:foo) }

  describe 'a single expression' do
    it 'should render the correct json' do
      expected = { 'op' => '$eq', 'field' => 'bar', 'rvalue' => 'foo' }

      query = entity
        .where entity[:bar].eq(:foo)

      expect(JSON.parse(query.json)).to match(expected)
    end
  end

  describe 'binary expressions' do
    it 'should render the correct json' do
      expected =
        { '$and' => [
          { 'op' => '$eq', 'field' => 'bar', 'rvalue' => 'foo' },
          { 'op' => '$eq', 'field' => 'baz', 'rfield' => 'gorp' },
        ]}

      query = entity
        .where entity[:bar].eq(:foo)
        .and   entity[:baz].eq(entity[:gorp])

      expect(JSON.parse(query.json)).to match(expected)
    end
  end

  describe 'nary relational expressions' do
    it 'value comparisons should render the correct json' do
      expected =
          { 'op' => '$in', 'field' => 'bar', 'values' => ['foo', 'bar', 'batz'] }

      query = entity
        .where(entity[:bar]).in([:foo, :bar, :batz])

      expect(JSON.parse(query.json)).to match(expected)
    end

    it 'field comparisons should render the correct json' do
      expected =
          { 'op' => '$in', 'field' => 'bar', 'rfield' => ['foo', 'bar', 'batz'] }

      query = entity
        .where(entity[:bar]).in([entity[:foo], entity[:bar], entity[:batz]])
      expect(JSON.parse(query.json)).to match(expected)
    end

  end

  describe 'subqueryin\'' do
    it 'should render the correct json' do

      # this is gonna get tiring
      expected =
        { '$all' =>
          [
            { 'op' => '$eq', 'field' => 'bar', 'rvalue' => 'foo' },
            { '$or' =>
              [
                {'op' => '$eq', 'field' => 'baz', 'rfield' => 'gorp' },
                {'op' => '$eq', 'field' => 'scrim', 'rvalue' => 'scram' },
              ]
            }
          ]
        }
      subquery = entity
        .where entity[:baz].eq(entity[:gorp])
        .or    entity[:scrim].eq('scram')

      # I have no idea how ruby manages to parse this 'correctly' without parens
      query = entity
        .where entity[:bar].eq(:foo)
        .all entity
          .where entity[:baz].eq(entity[:gorp])
          .or   entity[:scrim].eq('scram')

      expect(JSON.parse(entity.where(query).json)).to match(expected)
    end
  end

  # not really sure yet if it makes sense to be able to chain arbitrary expressions
  # it works in limited cases but not sure about doing say, query.where(q).and(q).or(q)
  describe 'chaining expressions' do
    it 'should render the correct json' do
      expected =
        { '$and' =>
          [
            { 'op' => '$eq', 'field' => 'bar', 'rvalue' => 'foo' },
            { 'op' => '$eq', 'field' => 'baz', 'rvalue' => 10 }
          ]
        }

      query = entity
        .where(entity[:bar].eq(:foo))
        .and entity[:baz].eq(10)
      expect(JSON.parse(query.json)).to match(expected)
    end
  end

  # chaining wheres just aliases to and, i think
  describe 'chaining wheres' do
    it 'should render the correct json' do
      expected =
        { '$and' =>
          [
            { 'op' => '$eq', 'field' => 'bar', 'rvalue' => 'foo' },
            { 'op' => '$eq', 'field' => 'baz', 'rvalue' => 10 }
          ]
        }

      query = entity
        .where(entity[:bar].eq(:foo))
        .where(entity[:baz].eq(10))
      expect(JSON.parse(query.json)).to match(expected)
    end
  end
end
