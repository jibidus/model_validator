# frozen_string_literal: true

require "rails"

# Validate models in database according Active Record model validation rules
module ModelValidator
  require "model_validator/railtie" if defined?(Rails)

  # Validations summary, with:
  # - violations: number of violations (i.e. number of model which validation failed)
  # - total: total number of validated models
  class Result
    attr_accessor :violations, :total

    def initialize(violations: 0, total: 0)
      @violations = violations
      @total = total
    end
  end

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

  # Validation engine, which fetch, and validate each database records
  class Validator
    def initialize(handlers: [], skip_models: [])
      @handlers = handlers
      @skip_models = skip_models
    end

    def classes_to_validate
      ActiveRecord::Base.subclasses
                        .reject { |type| type.to_s.include? "::" } # subclassed classes are not our own models
                        .reject { |type| @skip_models.include? type }
    end

    def run
      classes_to_validate.each do |model_class|
        @handlers.each { |h| h.try(:on_new_class, model_class) }
        model_class.unscoped.find_each do |model|
          @handlers.each { |h| h.try(:on_violation, model) } unless model.valid?
          @handlers.each { |h| h.try(:after_validation, model) }
        end
      end
    end
  end

  # This handler logs validation progression
  class LogHandler
    def on_new_class(model_class)
      Rails.logger.info "Checking #{model_class}..."
    end

    def on_violation(model)
      Rails.logger.error "#<#{model.class} id: #{model.id}, errors: #{model.errors.full_messages}>" unless model.valid?
    end
  end

  # This handler computes validation statistics
  class StatsHandler
    attr_reader :result

    def initialize
      @result = Result.new(violations: 0, total: 0)
    end

    def on_new_class(_) end

    def on_violation(_)
      @result.violations += 1
    end

    def after_validation(_)
      @result.total += 1
    end
  end
end
