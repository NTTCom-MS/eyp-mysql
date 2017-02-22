Puppet::Type.newtype(:mysql_grant) do
  @doc = 'manage MySQL databases'

  # GRANT ALL ON db1.* TO 'jeffrey'@'localhost' IDENTIFIED BY 'mypass';

  # mysql> show tables like '%PRIVILEGES%';
  # +---------------------------------------------+
  # | Tables_in_information_schema (%PRIVILEGES%) |
  # +---------------------------------------------+
  # | COLUMN_PRIVILEGES                           |
  # | SCHEMA_PRIVILEGES                           |
  # | TABLE_PRIVILEGES                            |
  # | USER_PRIVILEGES                             |
  # +---------------------------------------------+
  # 4 rows in set (0.01 sec)


  ensurable

  #http://www.rubydoc.info/gems/puppet/Puppet%2FType.autorequire
  autorequire(:file) { '/etc/mysql/my.cnf' }
  autorequire(:class) { '::mysql' }

  newparam(:username, :namevar => true) do
    desc 'The name of the MySQL DB to manage.'

    defaultto { @resource[:name] }

    validate do |value|
      unless value.is_a?(String)
        raise Pupper::Error,
          "not a string, modafuca"
      end
    end
  end

  newproperty(:privileges) do
    desc "Privileges for user"
    defaultto("ALL")
  end

  newproperty(:on) do
    desc "where to apply privileges"
    defaultto("*.*")
  end

  newproperty(:password) do
    desc "password for user"
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

  newparam(:cwd, :parent => Puppet::Parameter::Path) do
    desc "The working directory under which the mysql command should be executed."
    defaultto("/tmp")
  end

end
