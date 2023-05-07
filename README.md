# ModelProbe

## ActiveRecord schema visualization and model organization made easy

Get a clear view of your ActiveRecord models' underlying schema with ModelProbe's schema introspection.
Generate model class definitions with an organized, logical structure and create sensible text fixture stubs.
All this and more with __ModelProbe__.

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
