# frozen_string_literal: true

require "rails"
require "./lib/model_validator/stats_handler"
require "./lib/model_validator/log_handler"
require "./lib/model_validator/validator"

# Validate models in database according Active Record model validation rules
module ModelValidator
  require "model_validator/railtie" if defined?(Rails)

  def self.validate_all(skipped_models: [])
    if skipped_models.empty?
      Rails.logger.info "No model skipped"
    else
      Rails.logger.info "Skipped model(s): #{skipped_models.map(&:to_s).join(", ")}"
    end
    stats_handler = StatsHandler.new
    handlers = [LogHandler.new, stats_handler]
    Validator.new(handlers: handlers, skip_models: skipped_models).run
    stats_handler.result
  end
end
