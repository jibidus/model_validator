# frozen_string_literal: true

# Represent a gem version, which can be bumped for new release.
class Version
  def initialize(major, minor, patch)
    @major = major
    @minor = minor
    @patch = patch
  end

  def bump(release_type)
    case release_type
    when "major"
      Version.new(@major + 1, 0, 0)
    when "minor"
      Version.new(@major, @minor + 1, 0)
    when "patch"
      Version.new(@major, @minor, @patch + 1)
    else
      raise "Unknonwn bump type '#{release_type}'"
    end
  end

  def to_s
    [@major, @minor, @patch].join(".")
  end
end
