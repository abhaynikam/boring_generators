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
    FileUtils.rm_rf(app_path)
    FileUtils.cp_r(app_template_path, app_path)
  end

  def teardown_app
    FileUtils.rm_rf(tmp_path)
  end
end
