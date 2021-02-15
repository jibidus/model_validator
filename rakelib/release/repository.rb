# frozen_string_literal: true

require "./rakelib/release/commit"

# This module contains many methods to manipulate current git repository
module Repository
  def self.current_branch
    `git rev-parse --abbrev-ref HEAD`.strip
  end

  def self.commits_from(tag)
    logs_from("v#{tag}").sort
                        .uniq
                        .map do |commit_message|
      _, type, message = commit_message.split(":", 3).map(&:strip)
      if message.nil?
        message = type
        type = "unknown"
      end
      Commit.new(type, message)
    end
  end

  def self.logs_from(revision)
    `git log #{revision}..HEAD --pretty=format:"%s"`.split("\n")
  end
end
