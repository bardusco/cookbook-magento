#
# Author:: Ticean Bennett <tbenn@guidance.com>
# Cookbook Name:: magento
# Attributes:: magento
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

::Chef::Node.send(:include, Opscode::OpenSSL::Password)

default[:magento][:url] = nil
default[:magento][:aliases] = Array.new
default[:magento][:port] = nil
default[:magento][:dir] = "/var/www/magento"
default[:magento][:user] = "magento"
default[:magento][:group] = "www-data"
default[:magento][:repository] = "https://github.com/LokeyCoding/magento-mirror.git"
default[:magento][:revision] = "HEAD"
default[:magento][:deploy_key] = nil
default[:magento][:force_deploy] = false

default[:magento][:db][:host] = "localhost"
default[:magento][:db][:database] = "magento"
default[:magento][:db][:username] = "magento"
default[:magento][:db][:password] = nil
default[:magento][:db][:prefix] = ""

default[:magento][:session][:save] = "files"
default[:magento][:locale] = "en_US"
default[:magento][:timezone] = "US/Pacific"
default[:magento][:default_currency] = "USD"
default[:magento][:skip_url_validation] = "yes"
default[:magento][:use_rewrites] = "yes"
default[:magento][:use_secure] = "yes"
default[:magento][:use_secure_admin] = "yes"
default[:magento][:admin][:frontname] = "admin"

default[:magento][:admin][:firstname] = "Admin"
default[:magento][:admin][:lastname] = "User"
default[:magento][:admin][:email] = "ops@example.com"
default[:magento][:admin][:username] = "admin"
default[:magento][:admin][:password] = nil

default[:magento][:enckey] = nil

default[:magento][:developer_mode] = "0"
default[:magento][:enable_profiler] = "0"

default[:magento][:sample_data][:url] = "http://www.magentocommerce.com/downloads/assets/1.2.0/magento-sample-data-1.2.0.tar.gz"
default[:magento][:sample_data][:checksum] = "bb53b15c081e1f437ffb9a31178b9db8"

ionarch = kernel['machine'] =~ /x86_64/ ? '-64' : ''
default[:magento][:ioncube][:url] = "http://downloads2.ioncube.com/loader_downloads/ioncube_loaders_lin_x86#{ionarch}.tar.gz"

