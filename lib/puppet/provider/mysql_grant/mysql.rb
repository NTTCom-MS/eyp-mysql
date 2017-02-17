Puppet::Type.type(:mysql_grant).provide(:mysql) do

  mk_resource_methods

  def create
    run_sql_command("create database " + resource[:name] + " CHARACTER SET " + resource[:charset] + " COLLATE " + resource[:collate] + ";")
    @property_hash[:ensure] = :present
  end

  def destroy
    run_sql_command("drop database " + resource[:name])
    @property_hash[:ensure].clear
  end

  def exists?
    run_sql_command("show grants for " + resource[:name]).split("\n")[0] == resource[:name]
  end

  # # # # # # #
  # auxiliars #
  # # # # # # #

  def run_sql_command(sql)

    # mysql --defaults-group-suffix=slave

    command = [resource[:mysql_path]]
    command.push("--defaults-group-suffix=" + resource[:instance_name]) if resource[:instance_name]
    command.push("-S", resource[:socket]) if resource[:socket]
    command.push("-p" + resource[:password]) if resource[:password]
    command.push("-NB")
    command.push("-e", '"' + sql.gsub('"', '\"') + '"')

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
    output
  end

end
