# frozen_string_literal: true

require "model_validator"

Dir[File.join(__dir__, "support", "*.rb")].sort.each { |file| require file }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

end

# Allow mocking of Rails.logger without warning
RSpec::Mocks.configuration.allow_message_expectations_on_nil = true
