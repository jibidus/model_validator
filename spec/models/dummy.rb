# frozen_string_literal: true

require "active_record"

class DummyModel < ApplicationRecord
  validates :value, presence: true
end
