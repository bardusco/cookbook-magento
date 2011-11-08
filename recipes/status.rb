#
# Author:: Seth Chisamore <schisamo@opscode.com>
# Contributers:: Ticean Bennett <tbenn@guidance.com>
# Cookbook Name:: magento
# Recipe:: status
#

users = []

title = "Magento Cookbook"
organization = Chef::Config[:chef_server_url].split('/').last
pretty_run_list = node.run_list.run_list_items.collect do |item|
  "#{item.name} (#{item.type.to_s})"
end.join(", ")

template "#{::File.join(node[:magento][:dir], "current")}/status.html" do
  source "status.html.erb"
  owner node[:magento][:user]
  group node[:magento]["group"]
  mode "0755"
  variables(
    :app => "Magento",
    :title => title,
    :organization => organization,
    :run_list => pretty_run_list,
    :users => users
  )
end
