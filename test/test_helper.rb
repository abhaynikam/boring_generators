$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "boring_generators"

require "minitest/autorun"
require "byebug"
require "generator_helper"

require 'rails/generators'
require 'rails/generators/test_case'
require_relative '../tmp/templates/app_template/config/environment'
require "rails/test_help"

def assert_gem(gem, constraint = nil, app_path = ".")
  if constraint
    assert_file File.join(app_path, "Gemfile"), /^\s*gem\s+["']#{gem}["'], #{constraint}$*/
  else
    assert_file File.join(app_path, "Gemfile"), /^\s*gem\s+["']#{gem}["']$*/
  end
end
