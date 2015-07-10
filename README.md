# Lightblue::Client

## Arel like queries
```ruby
foo = Lightblue::Entity.new(:foo)
foo.where(foo[:baz_field].eq(10)).build
=> {:op=>"$eq", :field=>:baz_field, :rvalue=>10}

query = foo
  .where foo[:bar].eq(:foo)
  .all entity
    .where foo[:baz].eq(foo[:gorp])
    .or foo[:scrim].eq('scram')
=> {"$all"=>[{:op=>"$eq", :field=>:bar, :rvalue=>:foo}, {"$or"=>[{:op=>"$eq", :field=>:baz, :rfield=>:gorp}, {:op=>"$eq", :field=>:scrim, :rvalue=>"scram"}]}]}
```

Take a look at specs/lightblue/query_spec.rb for better examples
