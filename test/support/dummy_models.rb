# frozen_string_literal: true

require "active_record"

# Silence migration output in test output
ActiveRecord::Migration.verbose = false

# SQLite setup (always available)
class DummyUser < ActiveRecord::Base
  establish_connection(adapter: "sqlite3", database: ":memory:")
  extend ModelProbe
end

DummyUser.connection.instance_eval do
  create_table :dummy_users, force: true do |t|
    t.string :name
    t.string :email
    t.string :address_city
    t.timestamps

    t.index :name
  end

  add_index :dummy_users, :email, unique: true
end

# PostgreSQL setup (if available in CI)
if ENV["POSTGRES_HOST"]
  begin
    require "pg"

    class DummyUserPostgres < ActiveRecord::Base
      self.table_name = "dummy_users"
      establish_connection(
        adapter: "postgresql",
        host: ENV["POSTGRES_HOST"],
        port: ENV["POSTGRES_PORT"],
        username: ENV["POSTGRES_USER"],
        password: ENV["POSTGRES_PASSWORD"],
        database: ENV["POSTGRES_DB"]
      )
      extend ModelProbe
    end

    DummyUserPostgres.connection.instance_eval do
      create_table :dummy_users, force: true do |t|
        t.string :name
        t.string :email
        t.string :address_city
        t.timestamps

        t.index :name
      end

      add_index :dummy_users, :email, unique: true
    end
  rescue LoadError, PG::Error => e
    warn "PostgreSQL not available: #{e.message}"
  end
end

# MySQL setup (if available in CI)
if ENV["MYSQL_HOST"]
  begin
    require "mysql2"

    class DummyUserMysql < ActiveRecord::Base
      self.table_name = "dummy_users"
      establish_connection(
        adapter: "mysql2",
        host: ENV["MYSQL_HOST"],
        port: ENV["MYSQL_PORT"],
        username: ENV["MYSQL_USER"],
        password: ENV["MYSQL_PASSWORD"],
        database: ENV["MYSQL_DB"]
      )
      extend ModelProbe
    end

    DummyUserMysql.connection.instance_eval do
      create_table :dummy_users, force: true do |t|
        t.string :name
        t.string :email
        t.string :address_city
        t.timestamps

        t.index :name
      end

      add_index :dummy_users, :email, unique: true
    end
  rescue LoadError, Mysql2::Error => e
    warn "MySQL not available: #{e.message}"
  end
end

# Reset memoized ivar between test runs to avoid flaky tests
def reset_dummy_user_dll
  DummyUser.instance_variable_set(:@ddl, nil)
  DummyUserPostgres.instance_variable_set(:@ddl, nil) if defined?(DummyUserPostgres)
  DummyUserMysql.instance_variable_set(:@ddl, nil) if defined?(DummyUserMysql)
end
