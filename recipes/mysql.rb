#
# Author:: Ticean Bennett <tbenn@guidance.com>
# Cookbook Name:: magento
# Recipe:: mysql
#
# Copyright 2011, Guidance Solutions, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
include_recipe "mysql::server"
include_recipe "database"

if node.has_key?("ec2")
  server_fqdn = node.ec2.public_hostname
else
  server_fqdn = node.fqdn
end

# generate all passwords
node.set_unless[:magento][:db][:password] = secure_password

mysql_connection_info = {:host => "localhost", :username => 'root', :password => node['mysql']['server_root_password']}

#Create the Magento database if it doesn't already exist.
database "#{node[:magento][:db][:database]}" do
  provider Chef::Provider::Database::Mysql
  connection mysql_connection_info
  action [:create]
end

#Execute the privileges grant.
execute "mysql-install-magento-privileges" do
  command "/usr/bin/mysql -u root -p#{node[:mysql][:server_root_password]} < /etc/mysql/magento-grants.sql"
  action :nothing
end

#Write the grants file.
template "/etc/mysql/magento-grants.sql" do
  path "/etc/mysql/magento-grants.sql"
  source "grants.sql.erb"
  owner "root"
  group "root"
  mode "0600"
  variables(
    :user     => node[:magento][:db][:username],
    :password => node[:magento][:db][:password],
    :database => node[:magento][:db][:database]
  )
  notifies :run, resources(:execute => "mysql-install-magento-privileges"), :immediately
end

# save node data after writing the MYSQL, so that a failed chef-client run that gets this far doesn't
# cause an unknown password to get applied to the box without being saved in the node data.
ruby_block "save node data" do
  block do
    node.save
  end
  action :create
end