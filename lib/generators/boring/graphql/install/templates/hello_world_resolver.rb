# frozen_string_literal: true

class Resolvers::HelloWorldResolver < Resolvers::BaseResolver
  description "Returns hello world"

  type String, null: false

  def resolve
    "Hello World"
  end
end
