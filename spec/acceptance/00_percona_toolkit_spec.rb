require 'spec_helper_acceptance'

describe 'percona toolkit class' do

  context 'basic setup ' do

    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOF

      class { 'mysql::tools::perconatoolkit': }

      EOF

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)

    end

    it "check pt-query-digest" do
      expect(shell("echo | pt-query-digest").exit_code).to be_zero
    end

    it 'should work with no errors' do
      pp = <<-EOF

      class { 'mysql::tools::perconatoolkit':
        package_ensure => 'absent',
      }

      EOF

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)

    end

  end

end

#echo | pt-query-digest
