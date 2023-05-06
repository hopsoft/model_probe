# frozen_string_literal: true

require "erb"
require "model_probe/version"
require "model_probe/color"
require "model_probe/railtie" if defined?(Rails)

module ModelProbe
  include ModelProbe::Color

  # Pretty prints column meta data for an ActiveModel
  def probe
    probe_header
    probe_columns
    probe_indexes
    probe_ddl
    probe_footer
    self
  end

  # Prints a stub that can be used for a test fixture
  def print_fixture
    template = erb_template("model_probe/templates/fixture.yml.erb")
    puts template.result_with_hash(
      name: name,
      fixture_columns: fixture_columns,
      fixture_values_by_type: fixture_values_by_type
    )
    self
  end

  # Prints a new model definition based on the database schema
  def print_model
    template = erb_template("model_probe/templates/model.rb.erb")
    puts template.result_with_hash(
      name: name,
      superclass_name: superclass.name,
      primary_key_columns: primary_key_columns,
      foreign_key_columns: foreign_key_columns,
      relation_columns: relation_columns,
      required_columns: required_columns,
      limit_columns: limit_columns,
      validation_columns: validation_columns
    )
    self
  end

  private

  def erb_template(relative_path)
    template_path = File.expand_path(relative_path, __dir__)
    template_text = File.read(template_path)
    # trim_mode doesn't seem to work regardless of how it's passed with Ruby 2.7.5
    ERB.new template_text, trim_mode: "-"
  end

  def primary_key_column?(column)
    column.name == primary_key
  end

  def foreign_key_column?(column)
    return false if primary_key_column?(column)
    column.name.end_with? "_id"
  end

  def timestamp_column?(column)
    column.type == :datetime && column.name =~ /(created|updated|modified)/
  end

  def required_column?(column)
    return false if primary_key_column?(column)
    return false if foreign_key_column?(column)
    return false if timestamp_column?(column)
    !column.null
  end

  def limit_column?(column)
    return false if primary_key_column?(column)
    return false if foreign_key_column?(column)
    return false if timestamp_column?(column)
    %i[text string].include?(column.type) && column.limit.to_i > 0
  end

  def primary_key_columns
    columns.select { |column| primary_key_column? column }.sort_by(&:name)
  end

  def foreign_key_columns
    columns.select { |column| foreign_key_column? column }.sort_by(&:name)
  end

  def relation_columns
    columns.select { |column| relation_column? column }.sort_by(&:name)
  end

  def required_columns
    columns.select { |column| required_column? column }.sort_by(&:name)
  end

  def limit_columns
    columns.select { |column| limit_column? column }.sort_by(&:name)
  end

  def validation_columns
    (required_columns + limit_columns).uniq.sort_by(&:name)
  end

  def relation_column?(column)
    return false if column.name == primary_key
    column.name.end_with?("_id")
  end

  def fixture_columns
    columns.sort_by(&:name).select do |column|
      !primary_key_column?(column) && !timestamp_column?(column)
    end
  end

  def fixture_values_by_type
    {
      integer: "0",
      bigint: "0",
      float: "0.0",
      decimal: "0.0",
      datetime: "<%= Time.current %>",
      timestamp: "<%= Time.current %>",
      time: "<%= Time.current %>",
      date: "<%= Date.current %>",
      boolean: "true",
      string: "string",
      text: "text",
      uuid: "<%= SecureRandom.uuid %>"
    }
  end

  def ddl
    @ddl ||= begin
      query = case connection.adapter_name
      when /sqlite/i then "SELECT sql FROM sqlite_master WHERE type='table' AND name=#{quoted_table_name};"
      when /postgresql/i then "SELECT ddl AS create_table_statement FROM pg_catalog.pg_tables WHERE tablename = #{quoted_table_name};"
      when /mysql/i then "SHOW CREATE TABLE #{quoted_table_name};"
      when /sqlserver/i
        <<~SQL
          SELECT definition AS create_table_statement FROM sys.objects o
          JOIN sys.sql_modules m ON m.object_id = o.object_id
          WHERE o.type = 'U' AND o.name = #{quoted_table_name};
        SQL
      else return "DDL output is not yet supported for #{connection.adapter_name}!"
      end

      ActiveRecord::Base.logger.silence do
        connection.execute(query).first[1]
      end
    rescue => e
      "Failed to generate DDL! #{e.message}"
    end
  end

  def probe_header
    puts Color.gray "".ljust(110, "=")
    print Color.gray "#{connection.adapter_name} (#{connection.database_version}) - "
    puts Color.green(table_name)
    puts Color.gray "".ljust(110, "=")
    puts
  end

  def probe_ddl(pad: 2)
    reutrn unless ddl
    lines = ddl.split("\n")
    lines.each do |line|
      print " ".ljust(pad)
      puts Color.gray(line)
    end
    puts
  end

  def probe_column(column, name_pad:, type_pad:, sql_type_pad:)
    name = column.name
    if primary_key_column?(column)
      print "*#{name}".rjust(name_pad)
    else
      print Color.cyan(name.to_s.rjust(name_pad))
    end
    print " "
    print Color.blue(column.type.to_s.ljust(type_pad, "."))
    print Color.magenta(column.sql_type.to_s.ljust(sql_type_pad))
    print Color.red("NULL ") if column.null
    print Color.gray("default=#{column.default} ") if column.default
    print "- #{Color.gray column.comment}" if column.comment
    puts
  end

  def probe_columns
    name_pad = columns.map { |c| c.name.length }.max + 2
    type_pad = columns.map { |c| c.type.length }.max + 2
    sql_type_pad = columns.map { |c| c.sql_type.length }.max + 1

    columns.sort_by(&:name).each do |column|
      probe_column column, name_pad: name_pad, type_pad: type_pad, sql_type_pad: sql_type_pad
    end
    puts
  end

  def probe_index(index, name_pad:)
    print Color.yellow(index.name.to_s.rjust(name_pad))
    print Color.gray(" [")
    index.columns.each_with_index do |column, index|
      print Color.gray(", ") if index > 0
      print Color.cyan(column)
    end
    print Color.gray("]")
    print Color.red(" UNIQUE") if index.unique
    puts

    if index.where
      print " ".ljust(name_pad + 1)
      print Color.gray("where(#{index.where})")
      puts
    end

    if index.using
      print " ".ljust(name_pad + 1)
      print Color.gray("using(#{index.using})")
      puts
    end
  end

  def probe_indexes
    indexes = connection.indexes(table_name)
    name_pad = indexes.map { |c| c.name.length }.max + 1

    indexes.sort_by(&:name).each do |index|
      probe_index index, name_pad: name_pad
    end
    puts
  end

  def probe_footer
    puts Color.gray "".ljust(110, "=")
  end
end
