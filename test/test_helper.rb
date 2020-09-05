$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "boring_generators"

require "minitest/autorun"
require "byebug"
require "generator_helper"

require 'rails/generators'
require 'rails/generators/test_case'
