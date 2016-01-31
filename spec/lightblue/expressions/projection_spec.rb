require 'spec_helper'
require 'ast_helper'
describe Lightblue::Expressions::Projection do
  Projection = Lightblue::Expressions::Projection
  Query = Lightblue::Expressions::Query
  Field = Lightblue::Expressions::Field
  include AstHelper
  use_ast_node_helpers
end
