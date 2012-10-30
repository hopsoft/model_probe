require "model_probe/version"

module ModelProbe
  colors = {
    :red     => 31,
    :green   => 32,
    :yellow  => 33,
    :blue    => 34,
    :magenta => 35,
    :cyan    => 36,
    :white   => 37
  }

  colors.each do |name, code|
    define_method name do |text|
    "\e[#{code}m#{text}\e[0m"
    end
  end

  # Pretty prints column meta data for an ActiveModel.
  def probe
    name_pad = columns.map{|c| c.name.length}.max + 1
    type_pad = columns.map{|c| c.type.length}.max + 2
    sql_type_pad = columns.map{|c| c.sql_type.length}.max + 1

    columns.sort{ |a, b| a.name <=> b.name }.map do |column|
      name = column.name
      name = "* #{name}" if column.primary
      print yellow(name.to_s.rjust(name_pad))
      print " "
      print blue(column.type.to_s.ljust(type_pad, "."))
      print magenta(column.sql_type.to_s.ljust(sql_type_pad))
      print red("NULL") if column.null
      puts
    end
    nil
  end

  # Prints a stub that can be used for a test fixture.
  def fixture
    name = self.name.underscore
    hash = { name => {} }

    columns.sort{ |a, b| a.name <=> b.name }.map do |column|
      next if column.name =~ /^(created_at|updated_at)$/
      hash[name][column.name] = "value"
    end

    puts hash.to_yaml
    nil
  end

end
