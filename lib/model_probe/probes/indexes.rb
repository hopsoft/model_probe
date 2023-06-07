# frozen_string_literal: true

module ModelProbe::Probes::Indexes
  def probe_indexes
    indexes = connection.indexes(table_name)
    name_pad = indexes.map { |c| c.name.length }.max + 1
    indexes.sort_by(&:name).each do |index|
      probe_index index, name_pad: name_pad
    end
  end

  private

  def probe_index(index, name_pad:)
    print Rainbow(index.name.to_s.rjust(name_pad)).yellow
    print Rainbow(" [").dimgray
    index.columns.each_with_index do |column, index|
      print Rainbow(", ").dimgray if index > 0
      print Rainbow(column).magenta
    end
    print Rainbow("]").dimgray
    print Rainbow(" UNIQUE").green.bright if index.unique

    if index.where
      print Rainbow(" where(#{index.where})").dimgray
    end

    if index.using
      print Rainbow(" using(#{index.using})").dimgray
    end
  end
end
