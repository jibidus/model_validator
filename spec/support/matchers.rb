# frozen_string_literal: true

require "rspec/expectations"

RSpec::Matchers.define :have_no_violation do
  match do |actual|
    actual.violations == 0
  end
end

RSpec::Matchers.define :have_violations do |expected|
  match do |actual|
    actual.violations == expected
  end
end

RSpec::Matchers.define :have_total do |expected|
  match do |actual|
    actual.total == expected
  end
end
