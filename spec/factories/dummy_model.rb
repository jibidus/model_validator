# frozen_string_literal: true

FactoryBot.define do
  factory :dummy_model do
    value { "my value" }
    trait :invalid do
      value { nil }
    end
  end
end
