<h3 align="center">
  Boring Generators
</h3>

<p align="center">
  <a href="https://rubygems.org/gems/boring_generators"><img alt="Gem" src="https://img.shields.io/gem/dt/boring_generators?style=flat-square"></a>
  <img alt="GitHub Workflow Status" src="https://img.shields.io/github/workflow/status/abhaynikam/boring_generators/CI?style=flat-square">
</p>

<p>
  Have you ever started a new adventure/hobby project of your and instead of spending time in solving the actual problem statement with the website ended up configuring the application and put a lot of effort into it. Yeah, We felt that too. Boring generator tries to resolve the painful same redundant configuration you do in every application by adding generators to easily configure it.
</p>

<p>
  Check out the generator we support right now. We are planning to add support to most of the mostly used and required gems. We are open to any idea of yours, feel free to raise a discussion by opening up an issue or try contributing.
</p>


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'boring_generators'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install boring_generators

And then you can use it this way:

    $ boring generate boring:simple_form:install --css_framework=<css_framework>
    $ boring g boring:pry:install

To see options provided by each generator with their descriptions and accepted values, you can hit the following command for example:

    $ boring generate boring:simple_form:install --help

## Usage

The boring generator introduces following generators:

- [Install Tailwind CSS](https://www.boringgenerators.com/blog/2020-10-18-install-tailwind/): `rails generate boring:tailwind:install`
- [Install Bootstrap](https://www.boringgenerators.com/blog/2020-11-15-install-bootstrap/): `rails generate boring:bootstrap:install`
- Install JQuery: `rails generate boring:jquery:install`
- [Install FontAwesome via Yarn](https://www.boringgenerators.com/blog/2021-02-28-install-fontawesome-yarn/): `rails generate boring:font_awesome:yarn:install`
- [Install FontAwesome via RubyGems](https://www.boringgenerators.com/blog/2021-02-23-install-fontawesome/): `rails generate boring:font_awesome:ruby_gem:install`
- Install Bullet: `rails generate boring:bullet:install`
- Install Audit gems(bundler-audit, ruby_audit): `rails generate boring:audit:install`
- Install Pry gems for easy debugging: `rails generate boring:pry:install`
- Install Active Storage for Google Cloud Service: `rails generate boring:active_storage:google:install`
- Install Active Storage for AWS: `rails generate boring:active_storage:aws:install`
- Install Active Storage for Azure: `rails generate boring:active_storage:azure:install`
- [Install CircleCI](https://www.boringgenerators.com/blog/2021-01-02-configure-circleci/): `rails generate boring:ci:circleci:install --repository_name=<name> --ruby_version=<version>`
- [Install GitHub Actions](https://www.boringgenerators.com/blog/2020-12-17-configure-github-actions/): `rails generate boring:ci:github_action:install --repository_name=<name> --ruby_version=<version>`
- Install Travis CI: `rails generate boring:ci:travisci:install --ruby_version=<version>`
- Install Rubocop: `rails generate boring:rubocop:install --ruby_version=<version> --test_gem=<test_framework_name>`
- Build Favicon: `rails generate boring:favicon:build --application_name=<application_name> --favico_letter=<favico_letter> --primary_color=<color>`
- Install Pundit: `rails generate boring:pundit:install`
- Install GraphQL: `rails generate boring:graphql:install`
- Install SimpleForm: `rails generate boring:simple_form:install --css_framework=<css_framework>`
- Install Devise: `rails generate boring:devise:install`
- [Install Devise Facebook Omniauth](https://www.boringgenerators.com/blog/2021-02-07-install-oauth-facbook/): `rails generate boring:oauth:facebook:install`
- Install Devise GitHub Omniauth: `rails generate boring:oauth:github:install`
- Install Devise Google Omniauth: `rails generate boring:oauth:google:install`
- Install Devise Twitter Omniauth: `rails generate boring:oauth:twitter:install`
- Install Twilio: `rails generate boring:twilio:install`
- Install Ahoy: `rails generate boring:ahoy:install`
- Install Stripe: `rails generate boring:payments:stripe:install`
- Install Stimulus: `rails generate boring:stimulus:install`
- Install Rails Admin: `rails generate boring:rails_admin:install`
- Install Paper Trail: `rails generate boring:paper_trail:install`
- Install Flipper: `rails generate boring:flipper:install`
- Install RSpec: `rails generate boring:rspec:install`
- Install FactoryBot: `rails generate boring:factory_bot:install`
- Install Faker: `rails generate boring:faker:install`
- Install Overcommit with RuboCop: `rails generate boring:overcommit:pre_commit:rubocop:install`
- Install Letter Opener: `rails generate boring:letter_opener:install`
- Install Whenever: `rails generate boring:whenever:install`
- Install Rswag: `rails generate boring:rswag:install --rails_port=<rails_app_port> --authentication_type=<api_authentication_type> --skip_api_authentication=<skip_api_authentication> --api_authentication_options=<api_authentication_options> --enable_swagger_ui_authentication=<enable_swagger_ui_authentication>`
- Install Webmock: `rails generate boring:webmock:install --app_test_framework=<test_framework>`
- Install Figjam: `rails generate boring:figjam:install`
- Install Pronto with Gitlab CI: `rails generate boring:pronto:gitlab_ci:install`
- Install Pronto with Github Action: `rails generate boring:pronto:github_action:install`
- Install Rack Mini Profiler: `rails generate boring:rack_mini_profiler:install`
- Install VCR: `rails generate boring:vcr:install --testing_framework=<testing_framework> --stubbing_libraries=<stubbing_libraries>`
- Install Avo: `rails generate boring:avo:install`
- Install Doorkeeper with devise: `rails generate boring:devise:doorkeeper:install`
- Install Sentry: `rails generate boring:sentry:install --use_env_variable --breadcrumbs_logger=<breadcrumbs_logger_options>`
- Install Dotenv: `rails generate boring:dotenv:install`
- Install Honeybadger: `rails generate boring:honeybadger:install`

## Screencasts

- [How to use Boring Generators](https://www.youtube.com/watch?v=9vaK9nDMbU8) by [Yaroslav Shmarov](https://twitter.com/yarotheslav)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

You can also run specific test cases using following commands:
```
bundle exec ruby -w -Itest test/generators/tailwind_install_generator_test.rb
```

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/abhaynikam/boring_generators. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/abhaynikam/boring_generators/blob/master/CODE_OF_CONDUCT.md).

## Changelog

Boring Generators changelog is available [here](https://github.com/abhaynikam/boring_generators/blob/master/CHANGELOG.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the BoringGenerators project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/abhaynikam/boring_generators/blob/master/CODE_OF_CONDUCT.md).
