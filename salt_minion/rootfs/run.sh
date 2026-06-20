#!/usr/bin/env bashio

/etc/cont-init.d/salt_setup.sh

exec /etc/services.d/salt_minion/run
