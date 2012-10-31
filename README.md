# ModelProbe

## Schema introspection for ActiveModel

Provides a detailed view of the underlying schema that backs an ActiveModel.

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
MyModel.fixture
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
