require "active_record"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

# Silence migration output in test output
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :dummy_users, force: true do |t|
    t.string :name
    t.string :email
    t.timestamps
  end
end

# Define test model with ModelProbe behavior
class DummyUser < ActiveRecord::Base
  extend ModelProbe
end
