#
# Author:: Ticean Bennett <tbenn@guidance.com>
# Cookbook Name:: magento
# Recipe:: bootstrap_data
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

remote_file "#{Chef::Config[:file_cache_path]}/magento-sample-data.tar.gz" do
  checksum node[:magento][:sample_data][:checksum]
  source node[:magento][:sample_data][:url]
  mode "0644"
end

bash "install-magento-sample-data" do
Chef::Log.info("Installing Magento sample data...")
code <<-EOH
  cd "#{Chef::Config[:file_cache_path]}"
  tar -xzf "#{Chef::Config[:file_cache_path]}/magento-sample-data.tar.gz"
  cd #{Chef::Config[:file_cache_path]}/magento-sample-data-*
  cp *.sql data.sql
  /usr/bin/mysql -u#{node[:magento][:db][:username]} -p#{node[:magento][:db][:password]} #{node[:magento][:db][:database]} < "data.sql"
  #rm -rf #{name}
EOH
end
