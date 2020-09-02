require "test_helper"
require "boring/generators"

class Boring::GeneratorsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Boring::Generators::VERSION
  end
end
