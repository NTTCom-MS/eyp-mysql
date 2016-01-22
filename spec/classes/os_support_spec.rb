require 'spec_helper'
describe 'mysql' do

  context 'default class' do
    let(:params) { {:rootpw => '1234', :debianpw => '4321'} }
    let :facts do
    {
            :osfamily => 'Debian',
            :operatingsystem => 'Ubuntu',
            :operatingsystemrelease => '14.0',
    }
    end

    it { should contain_class('mysql') }
  end

  context 'unsupported OS' do
    let(:params) { {:rootpw => '1234', :debianpw => '4321'} }
    let :facts do
    {
            :osfamily => 'SOFriki',
    }
    end

    it {
      expect { should raise_error(Puppet::Error) }
    }
  end

end
