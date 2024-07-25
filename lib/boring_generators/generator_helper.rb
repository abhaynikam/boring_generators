module BoringGenerators
  module GeneratorHelper
    include Rails::Generators::Actions

    def app_ruby_version
      with_ruby_string = `grep "^ruby.*$" Gemfile` || `cat .ruby-version`

      # only keep 3.3.0
      with_ruby_string.gsub(/[^\d\.]/, "").squish
    end

    def gem_installed?(gem_name)
      gem_regex = /^\s*gem\s*['"]#{gem_name}['"]/

      File.read("Gemfile").match?(gem_regex)
    end

    def bundle_install
      Bundler.with_unbundled_env { run "bundle install" }
    end

    def check_and_install_gem(*args)
      gem_name, = args

      if gem_installed?(gem_name)
        say "#{gem_name} is already in the Gemfile, skipping it...", :yellow
      else
        gem *args unless gem_installed?(gem_name)
      end

      bundle_install
    end
  end
end
