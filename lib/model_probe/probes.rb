# frozen_string_literal: true

module ModelProbe::Probes; end

require_relative "probes/metadata"
require_relative "probes/columns"
require_relative "probes/indexes"
require_relative "probes/subclasses"

module ModelProbe::Probes
  include Metadata
  include Columns
  include Indexes
  include Subclasses

  def probe
    probe_metadata

    puts Rainbow("  Columns ".ljust(24, ".")).dimgray
    probe_columns

    puts Rainbow("  Indexes ".ljust(24, ".")).dimgray
    probe_indexes

    nil
  end
end
