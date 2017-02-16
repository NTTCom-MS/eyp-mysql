Puppet::Type.type(:mysql_database).provide(:mysql) do

  commands :mysql => 'mysql'

  def self.instances
    mysql(['-NBe', 'show databases'].compact).split("\n").collect do |name|
      attributes = {}
      mysql(['-NBe', "show variables like '%_database'", name].compact).split("\n").each do |line|
        k,v = line.split(/\s/)
        attributes[k] = v
      end
      new(:name    => name,
          :ensure  => :present,
          :charset => attributes['character_set_database'],
          :collate => attributes['collation_database']
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

  def create
    run_sql_command("create database " + resource[:name] + " CHARACTER SET " + resource[:charset] + " COLLATE " + resource[:collate] + ";")
  end

  def destroy
    run_sql_command("drop database " + resource[:name])
  end

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

  mk_resource_methods

  def charset=(value)
    mysql(['-NBe', "alter database `#{resource[:name]}` CHARACTER SET #{value}"].compact)
    @property_hash[:charset] = value
    charset == value ? (return true) : (return false)
  end

  def collate=(value)
    mysql(['-NBe', "alter database `#{resource[:name]}` COLLATE #{value}"].compact)
    @property_hash[:collate] = value
    collate == value ? (return true) : (return false)
  end

end
