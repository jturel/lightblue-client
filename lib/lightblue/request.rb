module Lightblue
  # The Query class is the primary entry point to the DSL. It exposes builder methods corresponding
  # to each Data API endpoint, which delegate to a Lightblue::Manager subclass, which is responsible for generating
  # and composing expressions.
  # @see Lightblue::Manager
  #  class Request
  #   def find(entity, expression, &blk)
  #   end

  #   def update(entity, expression, &blk)
  #   end

  #   def insert(entity, expression, &blk)
  #   end

  #   def delete(entity, expression, &blk)
  #   end

  #   def save(entity, expression, &blk)
  #   end
  # end
end
