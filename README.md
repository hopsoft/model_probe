# ModelProbe

## Schema introspection for ActiveRecord

Provides a detailed view of the underlying schema that backs an ActiveRecord model.

*This functionality can be added to any object that implements [ActiveRecord's columns interface](http://rubydoc.info/docs/rails/ActiveRecord/ModelSchema/ClassMethods#columns-instance_method).*

## Installation

Add this line to your application's Gemfile:

    gem 'model_probe'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install model_probe

## Usage

```ruby
MyModel.extend ModelProbe
MyModel.probe
MyModel.print_fixture
MyModel.print_model
```

## Rails Integration

Create `config/initializers/model_probe.rb`

```ruby
ActiveRecord::Base.extend ModelProbe if Rails.env.development?
```

## Rake Task

Create `lib/tasks/model.rake`

```ruby
namespace :model do
  desc <<~DESC
    Print model. Usage: `rails model:probe[User]`
  DESC
  task :probe, [:klass] => :environment do |task, args|
    klass = args.klass
    puts klass.constantize.print_model
  end
end
```
