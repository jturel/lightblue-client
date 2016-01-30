require 'rspec/expectations'
require 'ast_helper'
require 'json'

RSpec::Matchers.define :match_ast do |expected|
  match { |actual| expected == actual.send(:ast) }
  failure_message do |actual|
    AstHelper.pretty_diff(expected, actual.send(:ast))
  end
end
