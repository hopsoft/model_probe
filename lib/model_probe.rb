require "model_probe/version"
require "model_probe/color"
require "model_probe/railtie" if defined?(Rails)

module ModelProbe
  include ModelProbe::Color

  # Pretty prints column meta data for an ActiveModel
  def probe
    name_pad = columns.map { |c| c.name.length }.max + 1
    type_pad = columns.map { |c| c.type.length }.max + 2
    sql_type_pad = columns.map { |c| c.sql_type.length }.max + 1

    columns.sort_by(&:name).map do |column|
      name = column.name
      name = "* #{name}" if primary_key_column?(column)
      print yellow(name.to_s.rjust(name_pad))
      print " "
      print blue(column.type.to_s.ljust(type_pad, "."))
      print magenta(column.sql_type.to_s.ljust(sql_type_pad))
      column.null ? print(red("NULL")) : print("    ")
      print " [#{column.default}]" if column.default
      print " #{gray column.comment}" if column.comment
      puts
    end
    nil
  end

  # Prints a stub that can be used for a test fixture
  def print_fixture
    values = columns.sort_by(&:name).each_with_object({}) do |column, memo|
      next if primary_key_column?(column)
      next if timestamp_column?(column)
      memo[column.name] = column.default || "value"
    end

    hash = {name.underscore => values}
    puts hash.to_yaml
    nil
  end

  # Prints a new model definition based on the database schema
  def print_model
    puts "class #{name} < #{superclass.name}"
    puts "  # extends ..................................................................."
    puts "  # includes .................................................................."
    puts "  # class methods ............................................................."
    puts "  class << self"
    puts "  end"
    puts "  # additional config (i.e. accepts_nested_attribute_for etc...) .............."
    puts if relation_columns.size > 0
    puts "  # relationships ............................................................."
    relation_columns.sort_by(&:name).each do |column|
      next if primary_key_column?(column)
      puts "  belongs_to :#{column.name.sub(/_id\z/, "")}" if column.name.end_with?("_id")
    end
    puts if relation_columns.size > 0 || validation_columns.size > 0
    puts "  # validations ..............................................................."
    validation_columns.sort_by(&:name).each do |column|
      next if primary_key_column?(column)
      puts "  validates :#{column.name}, presence: true" unless column.null
      if %i[text string].include?(column.type) && column.limit.to_i > 0
        puts "  validates :#{column.name}, length: { maximum: #{column.limit} }"
      end
    end
    puts if validation_columns.size > 0
    puts "  # callbacks ................................................................."
    puts "  # scopes ...................................................................."
    puts
    puts "  # public instance methods ..................................................."
    puts
    puts "  # protected instance methods ................................................"
    puts
    puts "  # private instance methods .................................................."
    puts "end"
    nil
  end

  private

  def relation_columns
    @relation_columns ||= columns.select { |column| relation_column? column }
  end

  def validation_columns
    @validation_columns ||= columns.select { |column| validation_column? column }
  end

  def primary_key_column?(column)
    column.name == primary_key
  end

  def timestamp_column?(column)
    column.type == :datetime && column.name =~ /(created|updated|modified)/
  end

  def relation_column?(column)
    return false if column.name == primary_key
    column.name.end_with?("_id")
  end

  def validation_column?(column)
    return false if column.name == primary_key
    return false if column.name.end_with?("_id")
    return false if column.name.end_with?("_at") && column.type == "datetime"
    return true unless column.null
    %i[text string].include?(column.type) && column.limit.to_i > 0
  end
end
