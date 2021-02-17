# frozen_string_literal: true

require "active_record"

class DummyModel < ActiveRecord::Base
  validates :value, presence: true
end
