# frozen_string_literal: true

require "./rakelib/release/repository"
require "./rakelib/release/version"
require "./lib/model_validator/version"

AUTHORIZED_BRANCH = "main"

# All commit message prefix to include in changelog
COMMIT_TYPES = {
  "tada" => "Feature",
  "bug" => "Bug fix"
}.freeze

# This class can create and publish a new version of the current gem
class Release
  GEM_NAME = "model_validator"
  VERSION_FILE = "lib/model_validator/version.rb"
  GEMFILE_LOCK = "Gemfile.lock"

  def initialize(type)
    @type = type
  end

  def current_version
    Version.new(*ModelValidator::VERSION.split(".").map(&:to_i))
  end

  def new_version
    @new_version ||= current_version.bump(@type)
  end

  def apply!
    if Repository.current_branch != AUTHORIZED_BRANCH
      raise <<~MSG
        You can only release new version from '#{AUTHORIZED_BRANCH}' branch.
        Current branch: '#{Repository.current_branch}'
      MSG
    end

    sub_file_content VERSION_FILE, current_version.to_s, new_version.to_s
    sub_file_content GEMFILE_LOCK, "#{GEM_NAME} (#{current_version})", "#{GEM_NAME} (#{new_version})"
  end

  def changelog
    commits_by_type.map do |type, commits|
      messages_list = commits.map { |commit| "- #{commit.message}\n" }.join
      "# #{COMMIT_TYPES[type]}\n#{messages_list}"
    end.join("\n")
  end

  def git_commit!
    `git add #{VERSION_FILE} #{GEMFILE_LOCK}`
    `git commit -m ":label: release version #{new_version}"`
  end

  private

  def sub_file_content(file_path, from, to)
    current_content = File.read(file_path)
    modified_content = current_content.sub(from, to)
    raise "Cannot find regexp '#{from}' in file #{file_path}" if modified_content == current_content

    File.open(file_path, "w") { |file| file << modified_content }
  end

  def commits_by_type
    Repository.commits_from(current_version)
              .select { |commit| commit.type?(COMMIT_TYPES.keys) }
              .group_by(&:type)
  end
end
