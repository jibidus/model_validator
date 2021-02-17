# frozen_string_literal: true

require "rails"

module ModelValidator
  # This handler logs validation progression
  class LogHandler
    def on_new_class(model_class)
      Rails.logger.info "Checking #{model_class.count} #{model_class}…"
    end

    def on_violation(model)
      Rails.logger.error "#<#{model.class} id: #{model.id}, errors: #{model.errors.full_messages}>" unless model.valid?
    end
  end
end
