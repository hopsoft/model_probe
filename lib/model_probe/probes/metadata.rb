# frozen_string_literal: true

module ModelProbe::Probes::Metadata
  def probe_metadata
    puts Rainbow(name).green + Rainbow(" < ").dimgray.faint + Rainbow(superclass.name).green.faint
    puts Rainbow("  Database engine ".ljust(24, ".")).darkgray + " " + Rainbow(connection.adapter_name).skyblue.bright + " " + Rainbow(connection.database_version).skyblue.faint
    puts Rainbow("  Database name ".ljust(24, ".")).darkgray + " " + Rainbow(connection_db_config.database).skyblue
    puts Rainbow("  Table name ".ljust(24, ".")).darkgray + " " + Rainbow(table_name).skyblue
    puts Rainbow("  Default role".ljust(24, ".")).darkgray + " " + Rainbow(default_role).skyblue
    puts Rainbow("  Connection config ".ljust(24, ".")).darkgray
    connection_db_config.configuration_hash.to_yaml.split("\n")[1..].each { |line| puts "    " + Rainbow(line).skyblue.faint }
    puts
    puts Rainbow("  DDL ".ljust(24, ".")).darkgray
    if /create table/i.match?(ddl)
      ddl.split("\n").each do |line|
        line = line.squish
        next if line.blank?
        next if line.start_with?("--")
        next if line.start_with?("/*")
        next if /error|warning|Couldn't execute/i.match?(line)
        puts Rainbow("    #{line}").skyblue.faint
      end
    else
      puts Rainbow("    Failed to generate DDL string! #{ddl}").indianred
    end
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
