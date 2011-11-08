#
# Author:: Ticean Bennett <tbenn@guidance.com>
# Cookbook Name:: magento
# Recipe:: php
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

# Configure PHP.
%w{php5-cli php5-common php5-curl php5-gd php5-mcrypt php5-mysql php-pear php-apc}.each do |package|
  package "#{package}" do
    action :upgrade
  end
end


# Install ioncube
# Threaded php not supported.
directory "/opt/ioncube/" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

remote_file "#{Chef::Config[:file_cache_path]}/ioncube.tar.gz" do
  source node[:magento][:ioncube][:url]
  mode "0644"
  notifies :run, "bash[ioncube-loaders]", :immediately
  action :create_if_missing
end

bash "ioncube-loaders" do
  cwd "#{Chef::Config[:file_cache_path]}"
  code <<-EOH
    mkdir -p "#{name}"
    cd "#{name}"
    tar --strip-components 1 -xzf "#{Chef::Config[:file_cache_path]}/ioncube.tar.gz"
    cd ..
    cp ioncube-loaders/* "/opt/ioncube/"
    #rm -rf #{name}
  EOH
  action :nothing
end

phpversion = "#{node[:php][:version]}"[0..2]
ioncube_bin = "/opt/ioncube/ioncube_loader_lin_#{phpversion}.so"
file "#{node[:php][:ext_conf_dir]}/ioncube.ini" do
  owner "root"
  group "root"
  content "zend_extension = #{ioncube_bin}"
  only_if {File.exists?(ioncube_bin)}
  notifies :reload, "service[apache2]", :delayed
end