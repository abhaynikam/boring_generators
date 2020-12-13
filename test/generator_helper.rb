# frozen_string_literal: true

GEM_ROOT = File.expand_path("../", __dir__)

module GeneratorHelper
  def app_template_path
    File.join GEM_ROOT, "tmp/templates/app_template"
  end

  def tmp_path(*args)
    @tmp_path ||= File.realpath(Dir.mktmpdir(nil, File.join(GEM_ROOT, "tmp")))
    File.join(@tmp_path, *args)
  end

  def app_path(*args)
    path = tmp_path(*%w[app] + args)
    if block_given?
      yield path
    else
      path
    end
  end

  def build_app
    @prev_rails_env = ENV["RAILS_ENV"]
    ENV["RAILS_ENV"] = "development"

    FileUtils.rm_rf(app_path)
    FileUtils.cp_r(app_template_path, app_path)

    routes = File.read("#{app_path}/config/routes.rb")
    if routes =~ /(\n\s*end\s*)\z/
      File.open("#{app_path}/config/routes.rb", "w") do |f|
        f.puts $` + "\nActiveSupport::Deprecation.silence { match ':controller(/:action(/:id))(.:format)', via: :all }\n" + $1
      end
    end

    add_to_config <<-RUBY
      config.hosts << proc { true }
      config.eager_load = false
      config.session_store :cookie_store, key: "_myapp_session"
      config.active_support.deprecation = :log
      config.action_controller.allow_forgery_protection = false
    RUBY
  end

  def add_to_config(str)
    environment = File.read("#{app_path}/config/application.rb")
    if environment =~ /(\n\s*end\s*end\s*)\z/
      File.open("#{app_path}/config/application.rb", "w") do |f|
        f.puts $` + "\n#{str}\n" + $1
      end
    end
  end

  def teardown_app
    FileUtils.rm_rf(tmp_path)
  end
end
