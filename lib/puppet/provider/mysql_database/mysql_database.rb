Puppet::Type.type(:mysql_database).provide(:mysql_database) do

  def self.instances
    self.run_sql_command('show databases').split("\n").collect do |db|
      new(
        :ensure => :present,
        :name => db,
        )
    end
  end

  def self.prefetch(resources)
    dbs=instances
    resources.keys.each do |name|
      if provider = dbs.find{ |db| db.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present || false
  end

  mk_resource_methods

  def create
    self.run_sql_command("create database " + resource[:name] + " CHARACTER SET " + resource[:charset] + " COLLATE " + resource[:collate] + ";")
  end

  def destroy
    self.run_sql_command("drop database " + resource[:name])
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

end
