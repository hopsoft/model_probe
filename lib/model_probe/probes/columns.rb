# frozen_string_literal: true

module ModelProbe::Probes::Columns
  def probe_columns
    name_pad = columns.map { |c| c.name.length }.max + 2
    type_pad = columns.map { |c| c.type.length }.max + 2
    sql_type_pad = columns.map { |c| c.sql_type.length }.max + 1
    columns.sort_by(&:name).each do |column|
      probe_column column, name_pad: name_pad, type_pad: type_pad, sql_type_pad: sql_type_pad
    end
  end

  protected

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

  private

  def probe_column(column, name_pad:, type_pad:, sql_type_pad:)
    name = column.name
    if primary_key_column?(column)
      print Rainbow("*#{name}".rjust(name_pad)).magenta.bright
    else
      print Rainbow(name.to_s.rjust(name_pad)).magenta
    end
    print " "
    print column.type.to_s.ljust(type_pad, ".")
    print Rainbow(column.sql_type.to_s.ljust(sql_type_pad)).dimgray
    print Rainbow("NULLABLE ").dimgray.faint if column.null
    print Rainbow("REQUIRED ").indianred unless column.null
    print Rainbow("default=").dimgray + Rainbow("#{column.default} ").skyblue if column.default
    print "- #{Rainbow(column.comment).dimgray}" if column.comment
    puts
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

  def relation_column?(column)
    return false if column.name == primary_key
    column.name.end_with?("_id")
  end

  def fixture_columns
    columns.sort_by(&:name).select do |column|
      !primary_key_column?(column) && !timestamp_column?(column)
    end
  end
end
