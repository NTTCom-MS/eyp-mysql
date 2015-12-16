Puppet::Type.newtype(:mysql_database) do
  @doc = 'Manage MySQL databases'

  ensurable

  #per les dades d'access
  autorequire(:file) { '/root/.my.cnf' }

  newparam(:name, :namevar => true) do
    desc 'The name of the MySQL DB to manage.'

    validate do |value|
      unless value.is_a?(String)
        raise Pupper::Error,
          "not a string, modafuca"
      end
    end
  end

end
