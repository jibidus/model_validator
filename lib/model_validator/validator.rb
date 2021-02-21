# frozen_string_literal: true

require "rails"

module ModelValidator
  # ApplicationRecord is the base class used to loop up for all models to validate.
  # So this class is mandatory for ModelValidator to work well.
  class ApplicationRecordNotFound < StandardError
    def message
      <<~MSG
        ApplicationRecord not found.
        model_validator requires that all models extends a super class ApplicationRecord.
        This is expected in a rails application since rails 5.0.
      MSG
    end
  end

  # Validation engine, which fetch, and validate each database records
  class Validator
    def initialize(handlers: [], skip_models: [])
      @handlers = handlers
      @skip_models = skip_models
    end

    def classes_to_validate
      raise ApplicationRecordNotFound unless defined?(ApplicationRecord)

      ApplicationRecord.descendants
                       .reject(&:abstract_class)
                       .select { |type| type.subclasses.empty? }
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
end
