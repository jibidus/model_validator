# frozen_string_literal: true

module ModelValidator
  # Validations summary, with:
  # - violations: number of violations (i.e. number of model which validation failed)
  # - total: total number of validated models
  Result = Struct.new(:violations, :total)

  # This handler computes validation statistics
  class StatsHandler
    attr_reader :result

    def initialize
      @result = Result.new(0, 0)
    end

    def on_violation(_)
      @result.violations += 1
    end

    def after_validation(_)
      @result.total += 1
    end
  end
end
