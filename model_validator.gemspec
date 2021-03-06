# frozen_string_literal: true

require_relative "lib/model_validator/version"

Gem::Specification.new do |spec| # rubocop:disable Metrics/BlockLength
  spec.name = "model_validator"
  spec.version = ModelValidator::VERSION
  spec.authors = ["Jibidus"]
  spec.email = ["jibidus@gmail.com"]

  spec.summary = "Validate database against Active Record model validations"
  spec.description = <<~DESC
    Find models in database which violate Active Record validation rules.
    Invalid models may raise unexpected error when updated.
  DESC
  spec.homepage = "https://github.com/jibidus/model_validator"
  spec.license = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/jibidus/model_validator"
  spec.metadata["changelog_uri"] = "https://github.com/jibidus/model_validator"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rails", ">= 5.0"

  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "factory_bot"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.7"
  spec.add_development_dependency "rubocop-rake", "~> 0.5.1"
  spec.add_development_dependency "rubocop-rspec", "~> 2.2"
  spec.add_development_dependency "sqlite3", "~> 1.4"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
