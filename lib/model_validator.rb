# frozen_string_literal: true

require "rails"

# Validate models in database according Active Record model validation rules
module ModelValidator
  require "model_validator/railtie" if defined?(Rails)

  def self.validate_all(skipped_models: [])
    if skipped_models.empty?
      Rails.logger.info "No model skipped"
    else
      Rails.logger.info "Skipped model(s): #{skipped_models.map(&:to_s).join(", ")}"
    end
    handler = LogHandler.new
    Validator.new(handler, skip_models: skipped_models).run
    handler.violations_count
  end

  # Validation engine, which fetch, and validate each database records
  class Validator
    def initialize(handler, skip_models: [])
      @handler = handler
      @skip_models = skip_models
    end

    def models_to_validate
      ActiveRecord::Base.subclasses
                        .reject { |type| type.to_s.include? "::" } # subclassed classes are not our own models
                        .reject { |type| @skip_models.include? type }
    end

    def run
      models_to_validate.each do |type|
        @handler.start_model type
        type.unscoped.find_each do |record|
          @handler.on_violation(type, record) unless record.valid?
        end
      end
    end
  end

  # Validation handler, which logs each violation
  class LogHandler
    attr_reader :violations_count

    def initialize
      @violations_count = 0
    end

    def start_model(type)
      Rails.logger.info "Checking #{type}..."
    end

    def on_violation(type, record)
      Rails.logger.error "#<#{type} id: #{record.id}, errors: #{record.errors.full_messages}>" unless record.valid?
      @violations_count += 1
    end
  end
end
