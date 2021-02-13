# frozen_string_literal: true

require "model_validator"
require "rails"

module MyGem
  class Railtie < Rails::Railtie
    railtie_name :model_validator

    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
    end
  end
end