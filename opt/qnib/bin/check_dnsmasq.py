#!/usr/bin/env python

import re

with  open("/var/lib/misc/dnsmasq.leases", "r") as fd:
   lines = fd.readlines()
reg = "(?P<lease>\d+) (?P<mac_addr>[\d\:a-f]+) (?P<ip_addr>[\d\.]+) (?P<hostname>[a-zA-Z\d\*]+)"
for line in lines:
    mat = re.match(reg, line)
    if mat:
        print "HOSTNAME:%(hostname)-15s IP:%(ip_addr)-20s MAC:%(mac_addr)-20s" % mat.groupdict()
