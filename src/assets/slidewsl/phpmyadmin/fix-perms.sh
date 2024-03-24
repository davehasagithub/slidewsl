#!/usr/bin/env bash

chown phpmyadmin:phpmyadmin /etc/phpmyadmin
chmod 644 /etc/phpmyadmin/config.inc.php
touch /etc/phpmyadmin/config.secret.inc.php
touch /etc/phpmyadmin/config.user.inc.php

exec "$@"
