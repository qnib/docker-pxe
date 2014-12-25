#!/usr/bin/env python

import re
import os

dnsmasq_file = "/var/lib/misc/dnsmasq.leases"
if not os.path.exists(dnsmasq_file):
    print "No dnsmasq lease file '%s'" % dnsmasq_file

with  open(dnsmasq_file, "r") as fd:
   lines = fd.readlines()
reg = "(?P<lease>\d+) (?P<mac_addr>[\d\:a-f]+) (?P<ip_addr>[\d\.]+) (?P<hostname>[a-zA-Z\d\*]+)"
for line in lines:
    mat = re.match(reg, line)
    if mat:
        print "HOSTNAME:%(hostname)-15s IP:%(ip_addr)-20s MAC:%(mac_addr)-20s" % mat.groupdict()
