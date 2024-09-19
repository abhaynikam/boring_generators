module BoringGenerators
  module GeneratorHelper
    include Rails::Generators::Actions

    def app_ruby_version
      with_ruby_string = File.read("Gemfile")[/^ruby\s+["']?([\d.]+)["']?/] || File.read(".ruby-version").strip

      # only keep 3.3.0 from ruby-3.3.0
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

    def inject_into_file_if_new(*args)
      file_name, content_to_add, = args

      file_content = File.read(file_name)

      content_exists = file_content.include?(content_to_add)

      return if content_exists

      inject_into_file *args
    end
  end
end
