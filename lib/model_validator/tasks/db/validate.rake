# frozen_string_literal: true

require "rails"

namespace :db do
  desc "Validates database against model validation rule"
  task validate: :environment do
    Rails.logger.info "Validate database (this will take some time)..."
    excluded_models = (ENV["EXCLUDED_MODELS"] || "").split(",")
    ModelValidator.validate_all excluded_models: excluded_models
  end
end
