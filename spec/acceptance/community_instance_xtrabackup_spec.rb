require 'spec_helper_acceptance'

describe 'mariadb class' do

  context 'basic setup ' do

    # cleanup
    it 'should work with no errors' do
      pp = <<-EOF

      package { 'mysql-community-server':
        ensure => 'absent',
      }

      EOF

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)

    end

    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOF

      mysql::community::instance { 'test_xtrabackup':
    		port              => '3308',
    		password          => 'password',
    		add_default_mycnf => true,
    		default_instance  => true,
    	}

      ->

      mysql::backup::xtrabackup { 'test_xtrabackup':
        destination => '/backup',
      }

      mysql_database { 'et2blog':
        ensure        => 'present',
        instance_name => 'test_xtrabackup',
      }

      EOF

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)

    end

    it "sleep 60 to make sure mysql is started" do
      expect(shell("sleep 60").exit_code).to be_zero
    end

    it "check db and mysql access" do
      expect(shell("echo show databases | mysql | grep et2blog").exit_code).to be_zero
    end

    #instance tomcat-8080 HTTP connector
    describe port(3307) do
      it { should be_listening }
    end

    describe file("/etc/mysql/my.cnf") do
      it { should be_file }
      its(:content) { should match '[mysqld]' }
    end

    describe file("/etc/mysql/test_xtrabackup/my.cnf") do
      it { should be_file }
      its(:content) { should match '[mysqld]' }
    end

    # /usr/local/bin/backupmysqldump
    describe file("/usr/local/bin/backupmysqldump") do
      it { should be_file }
      its(:content) { should match 'puppet managed file' }
    end

    it "backupmysqldump" do
      expect(shell("/usr/local/bin/backupmysqldump").exit_code).to be_zero
    end

    it "ls backups" do
      expect(shell("ls -l /backup/*").exit_code).to be_zero
    end

    it "check backups" do
      expect(shell("cat  /backup/*/*sql | grep \"MySQL dump\"").exit_code).to be_zero
    end

  end

end
