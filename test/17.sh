#!/bin/bash
# load all modules without external dependencies with db_berkeley

# Copyright (C) 2007 1&1 Internet AG
#
# This file is part of openser, a free SIP server.
#
# openser is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version
#
# openser is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

if [ ! -e ../modules/db_berkeley/db_berkeley.so ] ; then
	echo "db_berkeley driver not found, not run"
	exit 0
fi ;

CFG=17.cfg

tmp_name=""$RANDOM"_openserdb_tmp"

echo "loadmodule \"../modules/db_berkeley/db_berkeley.so\"" >> $CFG
cat 2.cfg >> $CFG
echo "modparam(\"acc|alias_db|auth_db|dialog|dispatcher|domain|domainpolicy|group|imc|lcr|msilo|siptrace|speeddial|uri_db|usrloc|permissions|pdt\", \"db_url\", \"berkeley://`pwd`/../scripts/$tmp_name\")" >> $CFG

cd ../scripts

# setup config file
cp openserctlrc openserctlrc.bak
sed -i "s/# SIP_DOMAIN=openser.org/SIP_DOMAIN=sip.localhost/g" openserctlrc
sed -i "s/# DBENGINE=MYSQL/DBENGINE=DB_BERKELEY/g" openserctlrc
sed -i "s/# INSTALL_EXTRA_TABLES=ask/INSTALL_EXTRA_TABLES=yes/g" openserctlrc
sed -i "s/# INSTALL_PRESENCE_TABLES=ask/INSTALL_PRESENCE_TABLES=yes/g" openserctlrc
sed -i "s/# INSTALL_SERWEB_TABLES=ask/INSTALL_SERWEB_TABLES=yes/g" openserctlrc

./openserdbctl create $tmp_name > /dev/null
ret=$?

if [ "$ret" -eq 0 ] ; then
	../openser -w . -f ../test/$CFG > /dev/null	
	ret=$?
fi ;

sleep 1
killall -9 openser

# cleanup
./openserdbctl drop $tmp_name > /dev/null
mv openserctlrc.bak openserctlrc

cd ../test/
rm $CFG

exit $ret