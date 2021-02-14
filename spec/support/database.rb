# frozen_string_literal: true

require "yaml"
require "pathname"

class Database
  ALL_TYPES = %i[postgres mysql sqlite3].freeze

  attr_accessor :type, :configuration

  def initialize
    config_file = Pathname.new(File.dirname(__FILE__)).join("database.sqlite3.yml")
    @configuration = YAML.load_file(config_file)
    # @configuration["username"] = ENV["DB_USERNAME"] if ENV.has_key? "DB_USERNAME"
    # @configuration["password"] = ENV["DB_PASSWORD"] if ENV.has_key? "DB_PASSWORD"
  end

  def name
    @configuration["database"]
  end

  def connect(database = @configuration["database"])
    require "active_record"
    ActiveRecord::Base.establish_connection @configuration.merge(database: database)
  end

  def exec(sql)
    ActiveRecord::Base.connection.execute sql
  end
end
