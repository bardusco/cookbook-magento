maintainer       "Ticean Bennett"
maintainer_email "tbenn@guidance.com"
license          "Apache 2.0"
description      "Chef cookbook for configuring Magento."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.6.3"
depends          "php"
depends          "apache2"
depends          "mysql"
depends          "database"
depends          "openssl"

recipe "magento::default", "Installs and configures Magento LAMP stack on a single system."
recipe "magento::mysql", "Installs and configures Magento database."
recipe "magento::php", "Installs and configures required PHP."
recipe "magento::apache", "Installs and configures Magento web using php_mod/apache."
recipe "magento::bootstrap_data", "Bootstraps the Magento sample database. Should only be applied before installation."
recipe "magento::bootstrap_media", "Bootstraps the Magento sample media files."
recipe "magento::deploy", "Deploys magento codebase with deploy_revision."
recipe "magento::install", "Runs the CLI Magento installer. Should run only after deployment."
recipe "magento::status", "Outputs Chef info for testing. Don't use in production."

%w{ debian ubuntu }.each do |os|
  supports os
end

attribute "magento/dir",
  :display_name => "Magento installation directory",
  :description => "Location to place magento files.",
  :default => "/var/www"
  
attribute "magento/db/database",
  :display_name => "Magento MySQL database",
  :description => "Magento will use this MySQL database to store its data.",
  :default => "magento"

attribute "magento/db/user",
  :display_name => "Magento MySQL user",
  :description => "Magento will connect to MySQL using this user.",
  :default => "magento"

attribute "magento/db/password",
  :display_name => "Magento MySQL password",
  :description => "Password for the Magento MySQL user.",
  :default => "randomly generated"

attribute "magento/keys/enc",
  :display_name => "Magento encryption key",
  :description => "Magento encryption key.",
  :default => "randomly generated"
