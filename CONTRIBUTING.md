# Contributing

We love contributions from everyone. Please open a issue for discussion or raise a
pull request with the changes you need in the package.

## Contributing Code
To start contributing to the package. We should follow following steps.

- Fork the repository first to your GitHub account.
- Install all package dependencies by executing `bundle install` in your console.
- Add test cases for the changes made in the pull request. Make sure they are passing by running `rake test`.
- Update documentation for the changes made if needed. Make sure to add new entries in alphabetical order.
- Add a changelog for the new feature or fixes.

Push to your fork. Write a [good commit message][commit]. Submit a pull request.

  [commit]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html

Please do not self reject your thoughts. Let's discuss even smallest feature request as well and make
this package better for everybody's use.

## Notes for Local Development of the Gem

### While running Tests

When running tests, we normally do `bundle exec ruby -w -I test test/generators/rswag_install_generator_test.rb` to run a single test where "rswag_install_generator_test.rb" is the file name of the test we want to run.

And if your global ruby version is not the same as the "tmp/templates/app_template" where we run tests and make changes, tests might fail due to mismatch of ruby version and required gems not being installed correctly.

To tackle this issue you can add `.ruby-version` to the gem root by specifying the ruby version app_template is using. If you use rbenv this can be done with `rbenv local 2.7.0` where "2.7.0" is the app_template ruby-version at the moment.

We shouldn't commit this ".ruby-version" file to git since it's only intended for running tests. So to ignore this file from the git just for you, you can do the following:

- Open the git exclude file `nano .git/info/exclude`
- Add the file name ".ruby-version" to the end of the file and save it.

Now .ruby-version will be ignored by the git in your local machine just for this project.
