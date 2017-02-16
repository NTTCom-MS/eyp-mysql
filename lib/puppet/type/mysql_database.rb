Puppet::Type.newtype(:mysql_database) do
  @doc = 'manage MySQL databases'

  ensurable

  autorequire(:file) { '/etc/mysql/my.cnf' }
  autorequire(:class) { '::mysql' }

  newparam(:database, :namevar => true) do
    desc 'The name of the MySQL DB to manage.'

    defaultto { @resource[:name] }

    validate do |value|
      unless value.is_a?(String)
        raise Pupper::Error,
          "not a string, modafuca"
      end
    end

    def sync
      output, status = provider.run_sql_command(value)
      self.fail("Error executing SQL; mysql returned #{status}: '#{output}'") unless status == 0
    end
  end

  newparam(:mysql_path) do
    desc "The path to mysql executable."
    defaultto("mysql")
  end

  newparam(:instance_name) do
    desc "instance name to connect to"
  end

  newparam(:password) do
    desc "password to connect"
  end

  newparam(:socket) do
    desc "The name of the socked to use"
  end

  newproperty(:charset) do
    desc "database's default charset"
    defaultto("utf8")
  end

  newproperty(:collate) do
    desc "database's default collate"
    defaultto("utf8_general_ci")
  end

  newparam(:cwd, :parent => Puppet::Parameter::Path) do
    desc "The working directory under which the mysql command should be executed."
    defaultto("/tmp")
  end

end
