# ModelProbe

## ActiveRecord schema visualization and model organization made easy

Get a clear picture of your model's underlying schema with our beautiful and informative schema introspection.
Generate model class definitions with a well organized, logical structure.
Also, create sensible text fixture stubs.
_All this and more with ModelProbe._

## Quick Start

1. Add the GEM to your project

    ```sh
    bundle add model_probe
    ```

1. Use in a Rails console

   _ModelProbe auto initializes in the Rails development environment._

    ```ruby
    # examples with a User model
    User.probe
    User.print_model
    User.print_fixture
    ```
1. Use with Rails tasks

    ```sh
    bin/rails model_probe:probe[User]
    bin/rails model_probe:print_model[User]
    bin/rails model_probe:print_fixture[User]
    ```

## Screenshots

## Videos
