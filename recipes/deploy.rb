#
# Author:: Ticean Bennett <tbenn@guidance.com>
# Cookbook Name:: magento
# Recipe:: deploy
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

user "#{node[:magento][:user]}" do
  system true
end

Array[node[:magento][:dir], "#{node[:magento][:dir]}/shared", "#{node[:magento][:dir]}/shared/app/etc",
  "#{node[:magento][:dir]}/shared/var"].each do |dir|
  directory dir do
    owner node[:magento][:user]
    group node[:magento][:group]
    mode '0755'
  end
end

%w{media var/import var/export}.each do |dir|
  directory "#{node[:magento][:dir]}/shared/#{dir}" do
    owner node[:magento][:user]
    group node[:magento][:group]
    mode '2775'
    recursive true
  end
end

file "#{node[:magento][:dir]}/shared/app/etc/local.xml" do
  owner node[:magento][:user]
  group node[:magento][:group]
  mode '0644'
end



if node[:magento].has_key?("deploy_key")
  ruby_block "write_key" do
    block do
      f = ::File.open("#{node[:magento][:dir]}/id_deploy", "w")
      f.print(node[:magento][:deploy_key])
      f.close
    end
    #not_if do ::File.exists?("#{node[:magento][:dir]}/id_deploy"); end
  end

  file "#{node[:magento][:dir]}/id_deploy" do
    owner node[:magento][:user]
    group node[:magento][:group]
    mode '0600'
  end

  template "#{node[:magento][:dir]}/deploy-ssh-wrapper" do
    source "deploy-ssh-wrapper.erb"
    owner node[:magento][:user]
    group node[:magento][:group]
    mode "0755"
  end
end

## Then, deploy
deploy_revision "#{node[:magento][:dir]}" do
  revision node[:magento][:revision]
  repository node[:magento][:repository]
  user node[:magento][:user]
  group node[:magento][:group]
  deploy_to node[:magento][:dir]
  action node[:magento][:force_deploy] ? :force_deploy : :deploy
  ssh_wrapper "#{node[:magento][:dir]}/deploy-ssh-wrapper" if node[:magento][:deploy_key]
  shallow_clone true
  purge_before_symlink(["media", "var"])
  create_dirs_before_symlink([])
  symlinks({
    "var" => "var",
    "media" => "media"
  })
  symlink_before_migrate({
    "app/etc/local.xml" => "app/etc/local.xml"
  })
  before_symlink do
    %w{media var/import var/export}.each do |dir|
      directory "#{node[:magento][:dir]}/shared/#{dir}" do
        owner node[:magento][:user]
        group node[:magento][:group]
        mode '2775'
        recursive true
      end
    end
  end
end
