# frozen_string_literal: true

require "active_record"

configuration = {
  adapter: "sqlite3",
  database: "db/test.sqlite3"
}
ActiveRecord::Base.establish_connection configuration

RSpec.configure do |config|
  config.before(:suite) do
    ActiveRecord::Base.connection.execute <<~SQL
      CREATE TABLE IF NOT EXISTS
      dummy_models (id integer PRIMARY KEY AUTOINCREMENT, value TEXT)
    SQL
    %w[models parent_classes].each do |table|
      ActiveRecord::Base.connection.execute <<~SQL
        CREATE TABLE IF NOT EXISTS
        #{table} (id integer PRIMARY KEY AUTOINCREMENT)
      SQL
    end
  end
  config.before(:each) do
    ActiveRecord::Base.connection.execute "DELETE FROM dummy_models"
  end
end

module Database
  def self.exec(sql)
    ActiveRecord::Base.connection.execute sql
  end
end
