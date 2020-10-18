<h3 align="center">
  Boring Generators
</h3>

<p align="center">
  <a href="https://rubygems.org/gems/boring_generators"><img alt="Gem" src="https://img.shields.io/gem/dt/boring_generators?style=flat-square"></a>
  <a href="https://github.com/abhaynikam/boring_generators/blob/master/LICENSE.txt"><img alt="GitHub" src="https://img.shields.io/github/license/abhaynikam/boring_generators?style=flat-square"></a>
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

## Usage

The boring generator introduces following generators:
- Install Tailwind CSS: `rails generate boring:tailwind:install`
- Install Bootstrap: `rails generate boring:bootstrap:install`
- Install JQuery: `rails generate boring:jquery:install`
- Install FontAwesome via Yarn: `rails generate boring:font_awesome:yarn:install`
- Install FontAwesome via RubyGems: `rails generate boring:font_awesome:ruby_gem:install`
- Install Bullet: `rails generate boring:bullet:install`
- Install Audit gems(bundler-audit, ruby_audit): `rails generate boring:audit:install`
- Install Pry gems for easy debugging: `rails generate boring:pry:install`
- Install Active Storage for Google Cloud Service: `rails generate boring:active_storage:google:install`
- Install Active Storage for AWS: `rails generate boring:active_storage:aws:install`
- Install Active Storage for Azure: `rails generate boring:active_storage:azure:install`
- Install CircleCI: `rails generate boring:ci:circleci:install --repository_name=<name> --ruby_version=<version>`
- Install GitHub Actions: `rails generate boring:ci:github_action:install --repository_name=<name> --ruby_version=<version>`
- Install Travis CI: `rails generate boring:ci:travisci:install --ruby_version=<version>`
- Install Rubocop: `rails generate boring:rubocop:install --ruby_version=<version>`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/abhaynikam/boring_generators. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/abhaynikam/boring_generators/blob/master/CODE_OF_CONDUCT.md).

## Changelog

Boring Generators changelog is available [here](https://github.com/abhaynikam/boring_generators/blob/master/CHANGELOG.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the BoringGenerators project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/abhaynikam/boring_generators/blob/master/CODE_OF_CONDUCT.md).
