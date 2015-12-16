Puppet::Type.type(:mysql_database).provide(:mysql) do
  desc 'MySQL DBs'

  #suposem que esta al path
  commands :mysql => 'mysql'

  def self.instances
    mysql(['--defaults-extra-file=/root/.my.cnf', '-NBe', 'show databases']).split("\n").collect do |db|
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

  def create
    #TODO: parametritzacio charset i collate
    mysql(['--defaults-extra-file=/root/.my.cnf', '-NBe', "create database " + resource[:name] + " CHARACTER SET utf8 COLLATE utf8_general_ci;"])
  end

  def destroy
    mysql(['--defaults-extra-file=/root/.my.cnf', '-NBe', "drop database " + resource[:name]])
  end

end
