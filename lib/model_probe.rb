require "model_probe/version"
require "model_probe/color"

module ModelProbe
  include ModelProbe::Color

  # Pretty prints column meta data for an ActiveModel
  def probe
    name_pad = columns.map{ |c| c.name.length }.max + 1
    type_pad = columns.map{ |c| c.type.length }.max + 2
    sql_type_pad = columns.map{ |c| c.sql_type.length }.max + 1

    columns.sort{ |a, b| a.name <=> b.name }.map do |column|
      name = column.name
      name = "* #{name}" if column.name == primary_key
      print yellow(name.to_s.rjust(name_pad))
      print " "
      print blue(column.type.to_s.ljust(type_pad, "."))
      print magenta(column.sql_type.to_s.ljust(sql_type_pad))
      column.null ? print(red("NULL")) : print("    ")
      print " [#{column.default}]" if column.default
      puts
    end
    nil
  end

  # Prints a stub that can be used for a test fixture
  def print_fixture
    name = self.name.underscore
    hash = { name => {} }

    columns.sort{ |a, b| a.name <=> b.name }.map do |column|
      next if column.name =~ /^(created_at|updated_at)$/
      hash[name][column.name] = column.default || "value"
    end

    puts hash.to_yaml
    nil
  end

  # Prints a new model definition based on the database schema
  def print_model
    puts "class #{name} < #{superclass.name}"
    puts "  # extends ..................................................................."
    puts "  # includes .................................................................."
    puts if relation_columns.size > 0
    puts "  # relationships ............................................................."
    relation_columns.sort_by(&:name).each do |column|
      next if column.name == primary_key
      puts "  belongs_to :#{column.name.sub(/_id\z/, "")}" if column.name =~ /_id\z/
    end
    puts if relation_columns.size > 0 || validation_columns.size > 0
    puts "  # validations ..............................................................."
    validation_columns.sort_by(&:name).each do |column|
      next if column.name == primary_key
      puts "  validates :#{column.name}, presence: :true" unless column.null
      if %i(text string).include?(column.type) && column.limit.to_i > 0
        puts "  validates :#{column.name}, length: { maximum: #{column.limit} }"
      end
    end
    puts if validation_columns.size > 0
    puts "  # callbacks ................................................................."
    puts "  # scopes ...................................................................."
    puts "  # additional config (i.e. accepts_nested_attribute_for etc...) .............."
    puts "  # class methods ............................................................."
    puts "  # public instance methods ..................................................."
    puts "  # protected instance methods ................................................"
    puts "  # private instance methods .................................................."
    puts "end"
  end

  private

  def relation_columns
    @relation_columns ||= begin
      columns.select { |column| relation_column? column }
    end
  end

  def validation_columns
    @validation_columns ||= begin
      columns.select { |column| validation_column? column }
    end
  end

  def relation_column?(column)
    return false if column.name == primary_key
    column.name.end_with?("_id")
  end

  def validation_column?(column)
    return false if column.name == primary_key
    return true if column.null
    %i(text string).include?(column.type) && column.limit.to_i > 0
  end

end
