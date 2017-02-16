Puppet::Type.type(:mysql_database).provide(:mysql) do

  commands :mysql => 'mysql'

  def self.instances
    run_sql_command('show databases').split("\n").collect do |name|
      attributes = {}

      # charset
      #select DEFAULT_CHARACTER_SET_NAME from information_schema.schemata where schema_name='cacadevaca';
      attributes['charset'] = run_sql_command("select DEFAULT_CHARACTER_SET_NAME from information_schema.schemata where schema_name='" + name + "'")

      #collation
      attributes['collation'] = run_sql_command("select DEFAULT_COLLATION_NAME from information_schema.schemata where schema_name='" + name + "'")

      new(:name    => name,
          :ensure  => :present,
          :charset => attributes['charset'],
          :collate => attributes['collation']
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
