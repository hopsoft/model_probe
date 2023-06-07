# frozen_string_literal: true

module ModelProbe::Probes::Subclasses
  def probe_subclasses
    @count = 0
    @max_name_size = 0
    puts Rainbow(name).green + Rainbow(" < ").dimgray.faint + Rainbow(superclass.name).green.faint
    grouped = subclasses.each_with_object({}) do |model, memo|
      @max_name_size = model.name.size if model.name.size > @max_name_size
      location = Object.const_source_location(model.name)
      case location
      when Array
        path = location.first
        type = "First party" if first_party?(path)
        type = "Third party" if third_party?(path)
        type ||= "Unknown"
        memo[type] ||= []
        memo[type] << {name: model.name, path: path}
      when NilClass
        memo["Dynamic"] ||= []
        memo["Dynamic"] << {name: model.name, path: "defined dynamically at runtime"}
      else
        memo["Unknown"] ||= []
        memo["Unknown"] << {name: model.name, path: nil}
      end
    end

    keys = [
      "First party",
      "Dynamic",
      "Third party",
      "Unknown"
    ]

    keys.each do |key|
      next unless grouped[key]&.any?
      puts Rainbow("  #{key} subclasses ".ljust(35, ".")).dimgray
      grouped[key].sort_by { |entry| entry[:name] }.each do |entry|
        probe_subclass entry[:name], entry[:path]
      end
    end
  end

  private

  def probe_subclass(name, path)
    path = path.split(/\/(?=app\/models\/)/i).last if path.include?("/app/models/") && !path.include?("/ruby/gems/")
    path = path.split(/\/(?=ruby\/gems\/)/i).last if path.include?("/ruby/gems/")
    prefix = (@count += 1).to_s.rjust(8) + " ..."
    puts [
      Rainbow(prefix.to_s.ljust(prefix.size + @max_name_size - name.size, ".")).dimgray.faint,
      Rainbow(name).mediumslateblue,
      Rainbow("<").faint,
      Rainbow(self.name).dimgray.faint,
      Rainbow(path.to_s).faint
    ].join(" ")
  end

  def third_party?(path)
    path.include? "/ruby/gems/"
  end

  def first_party?(path)
    return false if third_party?(path)
    path.include? "/app/models/"
  end
end
