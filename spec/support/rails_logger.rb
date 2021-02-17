# frozen_string_literal: true

require "rails"

RSpec.configure do |config|
  config.before(:each) do
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:error)
  end
end
