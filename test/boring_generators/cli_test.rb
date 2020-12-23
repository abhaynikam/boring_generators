require "test_helper"
require "boring_generators/cli"

class CLITest < Minitest::Test
  def test_that_print_correct_version
    assert_output(/#{BoringGenerators::VERSION}/) { BoringGenerators::CLI.new.__print_version }
  end

  def test_that_generate_run_rails_generator_invoke
    mock = MiniTest::Mock.new
    mock.expect(:call, nil, ["boring:cli_test:install", []])
    Rails::Generators.stub(:invoke, mock) do
      BoringGenerators::CLI.new.generate("boring:cli_test:install")
    end
    mock.verify
  end
end
