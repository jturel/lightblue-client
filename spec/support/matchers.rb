require 'rspec/expectations'
require 'ast_helper'
require 'json'

RSpec::Matchers.define :match_ast do |expected|
  match { |actual| expected == actual.send(:ast) }
  failure_message do |actual|
    str = AstHelper.pretty_diff(expected, actual.send(:ast))
    h, = *Lightblue::AST.to_hash(actual.send(:ast))

    str + "\n======================\n" + JSON.pretty_generate(h)
  end

end
