# frozen_string_literal: true

module ModelValidator
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
