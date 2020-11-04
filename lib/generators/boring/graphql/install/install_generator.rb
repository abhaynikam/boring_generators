# frozen_string_literal: true

module Boring
  module Graphql
    class InstallGenerator < Rails::Generators::Base
      desc "Adds GraphQL to the application"
      source_root File.expand_path("templates", __dir__)

      OPTIONS = %w(relay batch playground no-graphiql schema)

      class_option :skip_resolver_setup, type: :boolean, aliases: "-s",
                                         desc: "Skips adding GraphQL resolver setup to the application"

      def add_graphql_gem
        say "Adding graphql gem", :green
        Bundler.with_unbundled_env do
          run "bundle add graphql"
        end
      end

      def run_graphql_generator
        say "Running GraphQL default generator", :green
        run "bundle exec rails generate graphql:install"
        run "bundle install"

        graphiql_precompile_assets = <<~RUBY
          \n
          if Rails.env.development?
            Rails.application.config.assets.precompile += %w[graphiql/rails/application.js graphiql/rails/application.css]
          end
        RUBY
        append_to_file "config/initializers/assets.rb", graphiql_precompile_assets
      end

      def adds_graphql_resolver
        return if options[:skip_resolver_setup]
        template("base_resolver.rb", "app/graphql/resolvers/base_resolver.rb")
        template("hello_world_resolver.rb", "app/graphql/resolvers/hello_world_resolver.rb")

        insert_into_file "app/graphql/types/query_type.rb", <<~RUBY, after: /class QueryType < Types::BaseObject\n/
          \t\t# TODO: remove me
          \t\tfield :hello, resolver: Resolvers::HelloWorldResolver
        RUBY
      end
    end
  end
end
