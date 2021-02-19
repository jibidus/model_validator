# frozen_string_literal: true

require "rails"

module ModelValidator
  # Validation engine, which fetch, and validate each database records
  class Validator
    def initialize(handlers: [], skip_models: [])
      @handlers = handlers
      @skip_models = skip_models
    end

    def classes_to_validate
      ActiveRecord::Base.descendants
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
