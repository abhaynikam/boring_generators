require_relative 'lib/boring_generators/version'

Gem::Specification.new do |spec|
  spec.name          = "boring_generators"
  spec.version       = BoringGenerators::VERSION
  spec.authors       = ["Abhay Nikam"]
  spec.email         = ["nikam.abhay1@gmail.com"]

  spec.summary       = %q{Boring generators aims to make your development faster by delegating boring setups to us.}
  spec.description   = %q{Every new project or hobby project of yours needs to setup simple things. Boring generators aims to make your development faster by delegating boring setups to us and let you worry about the core problems project intends to solve.}
  spec.homepage      = "https://github.com/abhaynikam/boring_generators"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/abhaynikam/boring-generators"
  spec.metadata["changelog_uri"] = "https://github.com/abhaynikam/boring_generators/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'railties'
end
