# ModelProbe

<a target='_blank' rel='nofollow' href='https://app.codesponsor.io/link/QMSjMHrtPhvfmCnk5Hbikhhr/hopsoft/model_probe'>
  <img alt='Sponsor' width='888' height='68' src='https://app.codesponsor.io/embed/QMSjMHrtPhvfmCnk5Hbikhhr/hopsoft/model_probe.svg' />
</a>

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

ModelProbe auto initializes in the Rails development environment.
This means your models are implicitly extended with this behavior when developing.

It also ships with these convenient rake tasks.

```sh
rails t -T model_probe

# rails model_probe:print_fixture[klass]  # Print fixture
# rails model_probe:print_model[klass]    # Print model
# rails model_probe:probe[klass]          # Probe
```

```sh
rails model_probe:probe[User]

#   confirmation_sent_at datetime..timestamp without time zone NULL
#     confirmation_token string....character varying           NULL
#           confirmed_at datetime..timestamp without time zone NULL
#             created_at datetime..timestamp without time zone
#     current_sign_in_at datetime..timestamp without time zone NULL
#     current_sign_in_ip inet......inet                        NULL
#                  email string....character varying           NULL []
#     encrypted_password string....character varying            []
#        failed_attempts integer...integer                      [0]
#                   * id uuid......uuid
#        last_sign_in_at datetime..timestamp without time zone NULL
#        last_sign_in_ip inet......inet                        NULL
#              locked_at datetime..timestamp without time zone NULL
#       payment_platform string....character varying           NULL
#    payment_platform_id string....character varying           NULL
#        phone_number_id uuid......uuid
#    remember_created_at datetime..timestamp without time zone NULL
# reset_password_sent_at datetime..timestamp without time zone NULL
#   reset_password_token string....character varying           NULL
#          sign_in_count integer...integer                      [0]
#      unconfirmed_email string....character varying           NULL
#           unlock_token string....character varying           NULL
#             updated_at datetime..timestamp without time zone
```

```sh
rails model_probe:print_fixture[User]

# ---
# user:
#   confirmation_sent_at: value
#   confirmation_token: value
#   confirmed_at: value
#   current_sign_in_at: value
#   current_sign_in_ip: value
#   email: ''
#   encrypted_password: ''
#   failed_attempts: '0'
#   last_sign_in_at: value
#   last_sign_in_ip: value
#   locked_at: value
#   payment_platform: value
#   payment_platform_id: value
#   phone_number_id: value
#   reset_password_sent_at: value
#   reset_password_token: value
#   sign_in_count: '0'
#   unconfirmed_email: value
#   unlock_token: value
```

```sh
rails model_probe:print_model[User]

# class User < ApplicationRecord
#   # extends ...................................................................
#   # includes ..................................................................
#
#   # relationships .............................................................
#   belongs_to :payment_platform
#   belongs_to :phone_number
#
#   # validations ...............................................................
#   validates :created_at, presence: true
#   validates :encrypted_password, presence: true
#   validates :failed_attempts, presence: true
#   validates :phone_number_id, presence: true
#   validates :sign_in_count, presence: true
#   validates :updated_at, presence: true
#
#   # callbacks .................................................................
#   # scopes ....................................................................
#   # additional config (i.e. accepts_nested_attribute_for etc...) ..............
#
#   # class methods .............................................................
#   class << self
#   end
#
#   # public instance methods ...................................................
#
#   # protected instance methods ................................................
#   protected
#
#   # private instance methods ..................................................
#   private
# end
```
