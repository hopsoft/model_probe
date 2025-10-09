# frozen_string_literal: true

require "active_record"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

# Silence migration output in test output
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :dummy_users, force: true do |t|
    t.string :name
    t.string :email
    t.string :address_city
    t.timestamps

    t.index :name
  end

  add_index :dummy_users, :email, unique: true
end

# Define test model with ModelProbe behavior
class DummyUser < ActiveRecord::Base
  extend ModelProbe
end

# Reset memoized ivar between test runs to avoid flaky tests
def reset_dummy_user_dll
  DummyUser.instance_variable_set(:@ddl, nil)
end
