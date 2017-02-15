#
# based on puppetlabs-postgresql's postgresql_psql:
#   https://github.com/puppetlabs/puppetlabs-postgresql/blob/master/lib/puppet/provider/postgresql_psql/ruby.rb
#
Puppet::Type.type(:mysql_sql).provide(:mysql_sql) do

  def run_unless_sql_command(sql)
    # for the 'unless' queries, we wrap the user's query in a 'SELECT COUNT',
    # which makes it easier to parse and process the output.
    run_sql_command('SELECT COUNT(*) FROM (' <<  sql << ') count')
  end

  def run_sql_command(sql)

    # mysql --defaults-group-suffix=slave

    command = [resource[:mysql_path]]
    command.push("--defaults-group-suffix=" + resource[:instance_name]) if resource[:instance_name]
    command.push("-S", resource[:socket]) if resource[:socket]
    command.push("-p" + resource[:password]) if resource[:password]
    command.push("-e", '"' + sql.gsub('"', '\"') + '"')
    command.push(resource[:db]) if resource[:db]

    if resource[:cwd]
      Dir.chdir resource[:cwd] do
        run_command(command)
      end
    else
      run_command(command)
    end
  end

  private

  def run_command(command)
    command = command.join ' '
    output = Puppet::Util::Execution.execute(command, {
      :uid                => 'root',
      :gid                => 'root',
      :failonfail         => false,
      :combine            => true,
      :override_locale    => true,
    })
    [output, $CHILD_STATUS.dup]
  end

end
