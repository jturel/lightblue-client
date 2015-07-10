# Lightblue::Client

## Arel like queries
```ruby
foo = Lightblue::Entity.new(:foo)
foo.where(foo[:baz_field].eq(10)).build
=> {:op=>"$eq", :field=>:baz_field, :rvalue=>10}

// Syntax should generally use parentheses, because this is really ambiguous, 
// but it seems to work apparently. 
// Need to think about that

query = foo
  .where foo[:bar].eq(:foo)
  .all entity
    .where foo[:baz].eq(foo[:gorp])
    .or foo[:scrim].eq('scram')

query.build
=> {"$all"=>[{:op=>"$eq", :field=>:bar, :rvalue=>:foo}, {"$or"=>[{:op=>"$eq", :field=>:baz, :rfield=>:gorp}, {:op=>"$eq", :field=>:scrim, :rvalue=>"scram"}]}]}
```

Take a look at specs/lightblue/query_spec.rb for better examples
https://github.com/daviswahl/lightblue-client/blob/master/spec/lightblue/query_spec.rb

TODO: 

Add projections

Add nodes for the rest of the tokens outlined in the spec: http://jewzaam.gitbooks.io/lightblue-specifications/content/language_specification/search_criteria.html

Add update/create/delete

See what can be done with metadata

Entities are currently arbitrary. They could be linked to a schema, although I'm not sure if it would benefit the AST.  
I don't fully understand how Lightblue does field comparisons (can you compare foo_entity[:field] to bar_entity[:field] ?). Need to experiment with this and consider some kind of join syntax. 
