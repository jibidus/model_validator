# frozen_string_literal: true

# Represents a commit in a git repository
class Commit
  attr_reader :type, :message

  def initialize(type, message)
    @type = type
    @message = message
  end

  def type?(types)
    types.include? @type
  end
end
