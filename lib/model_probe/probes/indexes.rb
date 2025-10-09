# frozen_string_literal: true

module ModelProbe::Probes::Indexes
  def probe_indexes
    indexes = connection.indexes(table_name)
    names = indexes.map(&:name).reject { |name| name.to_s.strip.empty? }
    return puts Rainbow("    N/A").skyblue.faint if names.none?
    name_pad = names.map(&:size).max + 1
    indexes.sort_by(&:name).each do |index|
      probe_index index, name_pad: name_pad
    end
  end

  private

  def probe_index(index, name_pad:)
    print Rainbow(index.name.to_s.rjust(name_pad)).yellow
    print_index_columns(index)
    print Rainbow(" UNIQUE").green.bright if index.unique
    if index.where
      print Rainbow(" where(#{index.where})").dimgray
    end

    if index.using
      print Rainbow(" using(#{index.using})").dimgray
    end
    puts
  end

  def print_index_columns(index)
    print Rainbow(" [").dimgray
    Array(index.columns).each_with_index do |column, idx|
      print Rainbow(", ").dimgray if idx > 0
      print Rainbow(column).magenta
    end
    print Rainbow("]").dimgray
  end
end
