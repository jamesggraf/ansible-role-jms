require 'serverspec'
set :backend, :exec

describe file('/u01/app/oracle/middleware/user_projects/domains/dev_jms_domain') do
  it { should be_directory }
end

describe file('/u01/app/oracle/middleware/user_projects/applications/dev_jms_domain') do
  it { should be_directory }
end

describe file('/u01/app/oracle/middleware/user_projects/applications/dev_jms_domain/config/config.xml') do
  it { should be_file }
end

describe file('/u01/app/oracle/middleware/wlserver_10.3/common/nodemanager/nodemanager.properties') do
  it { should be_file }
end

describe file('/u01/app/oracle/middleware/user_projects/domains/soa_domain/servers/AdminServer/data/nodemanager/startup.properties') do
  it { should be_file }
end

describe file('/u01/app/oracle/middleware/user_projects/domains/soa_domain/servers/AdminServer/security/boot.properties') do
  it { should be_file }
end

# TODO add tests for config.xml
