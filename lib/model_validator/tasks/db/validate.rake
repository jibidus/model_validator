# frozen_string_literal: true

require "rails"

namespace :db do
  desc "Validates database against model validation rule. Skip models with DB_VALIDATE_SKIP var ex (comma separated)."
  task validate: :environment do
    Rails.logger.info "Validate database (this will take some time)…"
    skipped_models = (ENV["DB_VALIDATE_SKIP"] || "").split(",")
    ModelValidator.validate_all skipped_models: skipped_models
  end
end
