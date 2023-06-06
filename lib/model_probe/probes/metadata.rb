# frozen_string_literal: true

module ModelProbe::Probes::Metadata
  def probe_metadata
    puts Rainbow(name).green + Rainbow(" < #{superclass.name}").dimgray.faint
    puts Rainbow("  Database Engine ".ljust(24, ".")).dimgray + " " + Rainbow(connection.adapter_name).skyblue.bright + " " + Rainbow(connection.database_version).skyblue.faint
    puts Rainbow("  Database Name ".ljust(24, ".")).dimgray + " " + Rainbow(connection_db_config.database).skyblue
    puts Rainbow("  Table Name ".ljust(24, ".")).dimgray + " " + Rainbow(table_name).skyblue
    puts Rainbow("  Default Role".ljust(24, ".")).dimgray + " " + Rainbow(default_role).skyblue
    puts Rainbow("  Connection Config ".ljust(24, ".")).dimgray
    connection_db_config.configuration_hash.to_yaml.split("\n")[1..].each { |line| puts "    " + Rainbow(line).skyblue.faint }
    puts
    puts Rainbow("  DDL ".ljust(24, ".")).dimgray
    ok = /create/i.match(ddl)
    ddl.split("\n").each do |line|
      next if line.strip.blank?
      next if line.strip.start_with?("--")
      next if line.strip.start_with?("/*")
      print "    "
      puts ok ? Rainbow(line).skyblue.faint : Rainbow(line).indianred.faint
    end
    puts
  end

  private

  def ddl
    config = connection_db_config.configuration_hash
    @ddl ||= begin
      case connection.adapter_name
      when /sqlite/i
        `sqlite3 #{config[:database]} '.schema #{table_name}' 2>&1`
      when /postgresql/i
        `PGPASSWORD=#{config[:password]} pg_dump --host=#{config[:host]} --port=#{config[:port]} --username=#{config[:username]} --schema-only --table=#{table_name} #{config[:database]} 2>&1`
      when /mysql/i
        `mysqldump --host=#{config[:host]} --port=#{config[:port]} --user=#{config[:username]} --password=#{config[:password]} --skip-lock-tables --no-data --compact #{config[:database]} #{table_name} 2>&1`
      else
        "DDL output is not yet supported for #{connection.adapter_name}!"
      end
    rescue => e
      "Failed to generate DDL string! #{e.message}"
    end
  end
end
