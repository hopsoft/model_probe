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
    if name == "ActiveRecord::Base" || abstract_class?
      probe_subclasses
      return nil
    end

    probe_metadata
    puts

    puts Rainbow("  Columns ".ljust(24, ".")).darkgray
    probe_columns
    puts

    puts Rainbow("  Indexes ".ljust(24, ".")).darkgray
    probe_indexes
    puts

    nil
  end
end
