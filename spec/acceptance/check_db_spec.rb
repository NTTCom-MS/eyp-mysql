require 'spec_helper_acceptance'

describe 'mariadb class' do

  context 'basic setup ' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOF

      class { 'mysql::mariadb':
    		rootpw   => 'a',
    		debianpw => 'b',
    	}

    	mysql_database { 'et2blog':
    		ensure => 'present',
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
    describe port(3306) do
      it { should be_listening }
    end

    describe file("/etc/mysql/my.cnf") do
      it { should be_file }
      its(:content) { should match '[mysqld]' }
    end

  end

end
