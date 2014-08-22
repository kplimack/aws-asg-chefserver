#!/bin/bash

### BEGIN INIT INFO
# Provides:          init.sh
# Default-Start:     2
# Required-Start:
# Required-Stop:
# Default-Stop:
# Short-Description: init.sh
# Description:       bootstrap auto-scaling worker
### END INIT INFO

CHEF_SERVER='https://chef.myorg.derp'
# define a function for later use
function getmeta() {
    wget -qO- http://169.254.169.254/latest$1
}
REGION=$(getmeta /meta-data/placement/availability-zone/)
INSTANCE_ID=$(getmeta /meta-data/instance-id/)
IPV4=$(getmeta /meta-data/local-ipv4)

# get EC2 meta-data
env=production
role=worker

DOMAIN="autoscale.domain"
hostname="use1d-worker-$(getmeta /meta-data/instance-id).$DOMAIN"
echo $hostname > /etc/hostname
echo -e "$IPV4\t$hostname" >> /etc/hosts
hostname $hostname
echo "HOSTNAME: $hostname"
echo "ROLE: $role"

# write first-boot.json to be used by the chef-client command.
# this sets the ROLE of the node.
echo -e "{\"run_list\": [\"role[$role]\"]}" > /etc/chef/first-boot.json

if [ -f /etc/chef/client.pem ] ; then
    rm /etc/chef/client.pem
fi

# write client.rb
# this sets the ENVIRONMENT of the node, along with some basics.
echo > /etc/chef/client.rb
echo -e "log_level               :info" >> /etc/chef/client.rb
echo -e "log_location            STDOUT" >> /etc/chef/client.rb
echo -e "chef_server_url         '$CHEF_SERVER'" >> /etc/chef/client.rb
echo -e "validation_client_name  'chef-validator'" >> /etc/chef/client.rb
echo -e "environment             '$env'" >> /etc/chef/client.rb

# append the node FQDN to knife.fb
echo -e "node_name               '$hostname'" >> /etc/chef/client.rb
echo > /etc/chef/knife.rb
echo -e "chef_server_url         '$CHEF_SERVER'" >> /etc/chef/knife.rb
echo -e "node_name               '$hostname'" >> /etc/chef/knife.rb

# run chef-client to register the node and to bootstrap the instance
chef-client -j /etc/chef/first-boot.json

echo "$hostname : $(date +%Y%m%d)" > /etc/birthday
