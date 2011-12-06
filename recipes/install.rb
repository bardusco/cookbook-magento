#
# Author:: Ticean Bennett <tbenn@guidance.com>
# Cookbook Name:: magento
# Recipe:: install
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

if node.has_key?("magento_url")
  url = node.cloud.public_hostname
elsif node.has_key?("cloud")
  url = node.cloud.public_hostname
else
  url = node.fqdn
end

if node.run_list.include?("recipe[magento::deploy]")
  site_root = "#{node[:magento][:dir]}/current"
else
  site_root = node[:magento][:dir]
end

#Create passwords.
node.set_unless[:magento][:admin][:password] = secure_password
node.set_unless[:magento][:enckey] = secure_password

unless Chef::Config[:solo]
  ruby_block "save node data" do
    block do
      node.save
    end
    action :create
  end
end

# Executes Magento CLI installer.
execute "magento-install" do
  command "#{Chef::Config[:file_cache_path]}/install"
  action :nothing
  notifies :create, "ruby_block[remove_magento_install]", :immediately
  #notifies :delete, "file[#{Chef::Config[:file_cache_path]}/install]", :immediately
end

#file "#{Chef::Config[:file_cache_path]}/install" do
#  action :nothing
#end

#Remove install from the run_list
ruby_block "remove_magento_install" do
  block do
    Chef::Log.info("Magento installation completed, removing recipe[magento::install]")
    node.run_list.remove("recipe[magento::install]") if node.run_list.include?("recipe[magento::install]")
  end
  action :nothing
end

# Write the magento install script.
template "#{Chef::Config[:file_cache_path]}/install" do
  source "install.erb"
  owner "root"
  group "root"
  mode "0744"
  variables(
        :server_name        => url,
        :server_aliases     => node[:magento][:server_aliases],
        :deploy_to          => site_root,
        :host               => node[:magento][:db][:host],
        :database           => node[:magento][:db][:database],
        :username           => node[:magento][:db][:username],
        :password           => node[:magento][:db][:password],
        :prefix             => node[:magento][:db][:prefix],
        :locale             => node[:magento][:locale],
        :default_currency   => node[:magento][:default_currency],
        :timezone           => node[:magento][:timezone],
        :session_save       => node[:magento][:session][:save],
        :admin_frontname    => node[:magento][:admin][:frontname],
        :admin_firstname    => node[:magento][:admin][:firstname],
        :admin_lastname     => node[:magento][:admin][:lastname],
        :admin_email        => node[:magento][:admin][:email],
        :admin_username     => node[:magento][:admin][:username],
        :admin_password     => node[:magento][:admin][:password],
        :use_rewrites       => node[:magento][:use_rewrites],
        :use_secure         => node[:magento][:use_secure],
        :use_secure_admin   => node[:magento][:use_secure_admin],
        :enc_key            => node[:magento][:enc_key]
  )
  notifies :run, resources(:execute => "magento-install"), :immediately
end
