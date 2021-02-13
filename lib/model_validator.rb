# frozen_string_literal: true

require_relative "model_validator/version"

module ModelValidator
  require "model_validator/railtie" if defined?(Rails)
end