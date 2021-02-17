# frozen_string_literal: true

require "./rakelib/release/release"

namespace :release do
  desc <<~DESC
    Build new release.
      - bump_type (mandatory): [major|minor|patch|x.y.z]
      - dry_run (optional): skip commit, tag and publishing
  DESC
  task :make, [:bump_type, :dry_run] do |_, args|
    release = Release.new args[:bump_type]
    puts "Bump version from #{release.current_version} to #{release.new_version}"
    release.apply!

    puts
    puts "#{release.new_version} changelog"
    puts "---------------------------------------------------------------------"
    puts release.changelog
    puts "---------------------------------------------------------------------"

    next if args[:dry_run]

    release.git_commit!

    puts <<~MSG
      Release built.

      Run following commands to publish version #{release.new_version}:
       $> git push
       $> bundle exec rake release

      After that, do not forget to report changelog in Github Releases page:
       https://github.com/jibidus/model_validator/releases
    MSG
  end
end
