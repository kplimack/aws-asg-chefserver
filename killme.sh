#!/bin/bash

### BEGIN INIT INFO
# Provides:          killme.sh
# Default-Start:
# Required-Start:
# Required-Stop:     0 6
# Default-Stop:      0 6
# Short-Description: killme.sh
# Description:       de-bootstrap auto-scaling worker
### END INIT INFO

function getmeta() {
    wget -qO- http://169.254.169.254/latest$1
}

DOMAIN="autoscale.domain"

hostname="use1d-worker-$(getmeta /meta-data/instance-id).$DOMAIN"

echo "kill me called on $(date)" > /var/log/killme.log
/usr/bin/knife node delete -y -c /etc/chef/knife.rb $hostname 2>&1 >> /var/log/killme.log
/usr/bin/knife client delete -y -c /etc/chef/knife.rb $hostname 2>&1 >> /var/log/killme.log
rm -f /etc/chef/client.pem
echo "Completed deleting myself from chef-server and deleting my client.pem, goodbye ;("
