#
# Author:: Ticean Bennett <tbenn@guidance.com>
# Cookbook Name:: magento
# Recipe:: apache
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


include_recipe "magento::php"

# Configure Apache
include_recipe %w{apache2 apache2::mod_php5 apache2::mod_rewrite apache2::mod_deflate apache2::mod_expires apache2::mod_headers apache2::mod_ssl}

if node.has_key?("cloud")
  server_fqdn = node.cloud.public_hostname
else
  server_fqdn = node.fqdn
end

if node.has_key?("magento_port")
  server_fqdn = "#{server_fqdn}:#{node[:magento][:port]}"
end

# disable default virtual host
execute "disable-default-site" do
  command "sudo a2dissite default"
  notifies :reload, resources(:service => "apache2"), :delayed
end

# set up the magento app virtual host
web_app "magento" do
  template "vhost.conf.erb"
  docroot "#{node[:magento][:dir]}/current"
  server_name node.fqdn
  server_aliases node[:magento][:aliases]
end
