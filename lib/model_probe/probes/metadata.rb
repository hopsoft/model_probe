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

  def ddl
    config = connection_db_config.configuration_hash
    @ddl ||= begin
      case connection.adapter_name
      when /sqlite/i
        run_command("sqlite3", "#{config[:database]} '.schema #{table_name}'")
      when /postgresql/i
        run_command("PGPASSWORD=#{config[:password]} pg_dump", "--host=#{config[:host]} --port=#{config[:port]} --username=#{config[:username]} --schema-only --table=#{table_name} #{config[:database]}")
      when /mysql/i
        run_command("mysqldump", "--host=#{config[:host]} --port=#{config[:port]} --user=#{config[:username]} --password=#{config[:password]} --skip-lock-tables --no-data --compact #{config[:database]} #{table_name}")
      else
        "DDL output is not yet supported for #{connection.adapter_name}!"
      end
    rescue => e
      handle_ddl_error(e, config[:database])
    end
  end

  def run_command(binary, full_command)
    output = `#{binary} #{full_command} 2>&1`

    unless $?.success?
      raise "Command failed: #{output.strip}"
    end

    output
  end

  private

  def handle_ddl_error(error, db_name)
    case error.message
    when /does not exist/
      "The database #{db_name} does not exist"
    when /not found/
      "The binary was not found in the $PATH"
    when /no such file or directory/i
      "The binary could not be found at the specified path"
    else
      "Unexpected error: #{error.message}"
    end
  end
end
