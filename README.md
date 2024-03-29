# ModelProbe

## ActiveRecord schema visualization and model organization made easy 🙌

Colorized table info for columns, types, nullables, indexes...
and the actual DDL used by the database to create the table.
_All this and more with ModelProbe!_

1. Get a clear picture of your model's underlying schema with beautiful and informative schema introspection.
1. Generate model class definitions with a well organized, logical structure.
1. Create sensible text fixture stubs.

<!-- Tocer[start]: Auto-generated, don't remove. -->

## Table of Contents

  - [Quick Start](#quick-start)
  - [Supported Databases](#supported-databases)
  - [Videos](#videos)
  - [Screenshots](#screenshots)

<!-- Tocer[finish]: Auto-generated, don't remove. -->

## Quick Start

1. Add the GEM to your project

    ```sh
    bundle add model_probe
    ```

   _ModelProbe auto initializes in the Rails `development` environment._

1. Use in a Rails console

    ```ruby
    # examples for a User model
    User.probe
    User.print_model
    User.print_fixture
    ```
1. Use with Rails (Rake) tasks

    ```sh
    # examples for a User model
    bin/rails model_probe:probe[User]
    bin/rails model_probe:print_model[User]
    bin/rails model_probe:print_fixture[User]
    ```

## Supported Databases

- MySQL
- PostgreSQL
- SQLite
- _...more? contributions welcome ;)_

## Videos

[![image](https://ik.imagekit.io/hopsoft/model_probe_intro_Zf04NFJ1-.webp?updatedAt=1683471619001)](https://youtu.be/Q3IdyKateQE)

## Screenshots

Introspect your ActiveRecord models to build a deep understanding of the underlying database structure.

![ModelProbe probe](https://ik.imagekit.io/hopsoft/mode_probe_probe_3ouJjft48.webp?updatedAt=1683465723169)

Generate a well organized template for your ActiveRecord model's class definition.

![ModelProbe print_model](https://ik.imagekit.io/hopsoft/model_probe_print_model_sGOZWw-D5.webp?updatedAt=1683465723049)

Create fixture stubs to use in the test suite.

![ModelProbe print_fixture](https://ik.imagekit.io/hopsoft/model_probe_print_fixture_ZZ2TavUO7.webp?updatedAt=1683465722977)
