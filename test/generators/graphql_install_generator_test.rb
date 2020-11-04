# frozen_string_literal: true

require "test_helper"
require "generators/boring/graphql/install/install_generator"

class GraphqlInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Graphql::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_install_graphql_successfully
    Dir.chdir(app_path) do
      run_generator

      assert_file "Gemfile" do |content|
        assert_match(/graphql/, content)
        assert_match(/graphiql-rails/, content)
      end

      assert_file "config/initializers/assets.rb" do |content|
        assert_match("graphiql/rails/application.js", content)
        assert_match("graphiql/rails/application.css", content)
      end

      assert_file "app/graphql/resolvers/base_resolver.rb"
      assert_file "app/graphql/resolvers/hello_world_resolver.rb"

      assert_file "app/graphql/types/query_type.rb" do |content|
        assert_match("field :hello, resolver: Resolvers::HelloWorldResolver", content)
      end
    end
  end

  def test_should_skip_adding_resolver_setup
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--skip_resolver_setup"] }

      assert_no_file "app/graphql/resolvers/base_resolver.rb"
      assert_no_file "app/graphql/resolvers/hello_world_resolver.rb"
    end
  end
end
