module BoringGenerators
  module GeneratorHelper
    include Rails::Generators::Actions

    def app_ruby_version
      with_ruby_string = `grep "^ruby.*$" Gemfile` || `cat .ruby-version`
  
      # only keep 3.3.0
      with_ruby_string.gsub(/[^\d\.]/, '').squish
    end
  
    def check_and_install_gem(*args)
      gem_name, = args

      gem_file_content_array = File.readlines("Gemfile")
  
      gem_exists = gem_file_content_array.any? { |line| line.include?(gem_name) }

      if gem_exists
        say "#{gem_name} is already in the Gemfile, skipping it ...", :yellow
      else
        gem *args
      end
    end
  end
end
