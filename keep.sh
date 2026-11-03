#!/bin/bash
pgrep -f "[n]ode app.js" >/dev/null || {
  cd /root/ftvpn
  setsid env PATH=/opt/node20/bin:/usr/bin:/bin node app.js >> /root/ftvpn/logs/ftvpn.log 2>&1 < /dev/null &
}
