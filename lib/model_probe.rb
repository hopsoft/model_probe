# frozen_string_literal: true

require "erb"
require_relative "model_probe/version"
require_relative "model_probe/color"
require_relative "model_probe/railtie" if defined?(Rails)

module ModelProbe
  include ModelProbe::Color

  # Pretty prints column meta data for an ActiveModel
  def probe
    probe_header
    probe_ddl
    probe_columns
    probe_indexes
    probe_footer
    nil
  end

  # Prints a stub that can be used for a test fixture
  def print_fixture
    template = erb_template("model_probe/templates/fixture.yml.erb")
    puts template.result_with_hash(name: name, fixture_columns: fixture_columns)
    nil
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
    nil
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

  def ddl
    config = connection_db_config.configuration_hash
    @ddl ||= begin
      case connection.adapter_name
      when /sqlite/i
        `sqlite3 #{config[:database]} '.schema #{table_name}'`
      when /postgresql/i
        port = connection_port_from config
        `PGPASSWORD=#{config[:password]} pg_dump --host=#{config[:host]} --port=#{port} --username=#{config[:username]} --schema-only --table=#{table_name} #{config[:database]}`
      when /mysql/i
        `mysqldump --host=#{config[:host]} --user=#{config[:username]} --password=#{config[:password]} --no-data --compact #{config[:database]} #{table_name}`
      else
        "DDL output is not yet supported for #{connection.adapter_name}!"
      end
    rescue => e
      Color.red "Failed to generate DDL string! #{e.message}"
    end
  end

  def probe_header
    puts Color.gray "".ljust(110, "=")
    print connection.adapter_name
    print Color.gray(" (#{connection.database_version}) - ")
    puts Color.green(table_name)
    puts Color.gray "".ljust(110, "=")
    puts
  end

  def probe_ddl(pad: 2)
    return unless ddl
    lines = ddl.split("\n")
    lines.each do |line|
      next if line.strip.blank?
      next if line.strip.start_with?("--")
      next if line.strip.start_with?("/*")
      print " ".ljust(pad)
      puts Color.gray(line)
    end
    puts
  end

  def probe_column(column, name_pad:, type_pad:, sql_type_pad:)
    name = column.name
    if primary_key_column?(column)
      print Color.pink("*#{name}".rjust(name_pad))
    else
      print Color.magenta(name.to_s.rjust(name_pad))
    end
    print " "
    print column.type.to_s.ljust(type_pad, ".")
    print Color.gray(column.sql_type.to_s.ljust(sql_type_pad))
    print Color.gray("NULLABLE ") if column.null
    print Color.pink("REQUIRED ") unless column.null
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
    print Color.yellow_light(index.name.to_s.rjust(name_pad))
    print Color.gray(" [")
    index.columns.each_with_index do |column, index|
      print Color.gray(", ") if index > 0
      print Color.magenta(column)
    end
    print Color.gray("]")
    print Color.green_light(" UNIQUE") if index.unique

    if index.where
      print Color.gray(" where(#{index.where})")
    end

    if index.using
      print Color.gray(" using(#{index.using})")
    end
    puts
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

  def connection_port_from(config)
    return nil unless config.key?(:port)
    return nil if config[:port].nil? || config[:port].empty?

    config[:port]
  end
end
