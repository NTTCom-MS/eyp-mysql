Puppet::Type.type(:mysql_user).provide(:mysql) do
  desc 'MySQL users'

  #suposem que esta al path
  commands :mysql => 'mysql'

  def self.instances
    mysql(['--defaults-extra-file=/root/.my.cnf', '-NBe', 'select concat(user,\'@\',host) from mysql.user']).split("\n").collect do |user|
      username, host = user.match(/^([^@]+)@(.*)$/).captures
      begin
        grants = mysql(['--defaults-extra-file=/root/.my.cnf', '-NBe', 'show grants for \''+username+'\'@'+'\''+host+'\''])
      rescue Puppet::ExecutionFailure => e
        #ignoro errors
        next
      end
      grants.split("\n").collect do |grantline|
        new(
          :ensure => :present,
          :username => username,
          :host => host,
          )
      end
    end
  end

  # def self.prefetch(resources)
  #   dbs=instances
  #   resources.keys.each do |name|
  #     if provider = dbs.find{ |db| db.name == name }
  #       resources[name].provider = provider
  #     end
  #   end
  # end

  def exists?
    @property_hash[:ensure] == :present || false
  end

  #TODO
  def create
    mysql(['--defaults-extra-file=/root/.my.cnf', '-NBe', "select version()"])
  end

  def destroy
    mysql(['--defaults-extra-file=/root/.my.cnf', '-NBe', "select version()"])
  end

end
