# frozen_string_literal: true

require "rails"

namespace :db do
  desc "Validates database against model validation rule"
  task validate: :environment do
    Rails.logger.info "Validate database (this will take some time)…"
    skipped_models = (ENV["MODEL_VALIDATOR_SKIPPED_MODELS"] || "").split(",")
    result = ModelValidator.validate_all(skipped_models: skipped_models)
    Rails.logger.info "Validation finished with #{result.violations}/#{result.total} violation(s)"
  end
end
