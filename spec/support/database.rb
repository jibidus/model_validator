# frozen_string_literal: true

module Database
  def self.connect
    require "active_record"
    configuration = {
      adapter: "sqlite3",
      database: "db/test.sqlite3"
    }
    ActiveRecord::Base.establish_connection configuration
  end

  def self.exec(sql)
    ActiveRecord::Base.connection.execute sql
  end
end
