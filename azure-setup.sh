#!/bin/sh

# credit to https://forum.pfsense.org/index.php?topic=112072.15
# modifications by ben holland

# After installation, log in and choose:
#  14) to enable sshd
#  7) ping www.google.com to make sure connection to internet exists
#  8) to login shell
# curl -O https://raw.githubusercontent.com/benjholla/pfSense-CE-2.4.3-Azure/master/azure-setup.sh
# chmod +x azure-setup.sh

pkg upgrade

pkg install -y python27 py27-setuptools bash git sudo
ln -s /usr/local/bin/python2.7 /usr/bin/python

echo 'ifconfig_hn0="SYNCDHCP"' >> /etc/rc.conf
echo 'console="comconsole vidconsole"' >> /boot/loader.conf
#echo 'comconsole_speed="115200"' >> /boot/loader.conf
echo 'kldload udf'  >> /boot/loader.conf
echo 'vfs.mountroot.timeout=300'  >> /boot/loader.conf

# udf.ko originally from https://download.freebsd.org/ftp/releases/ISO-IMAGES/11.1/FreeBSD-11.1-RELEASE-amd64-bootonly.iso
curl -O https://raw.githubusercontent.com/benjholla/pfSense-CE-2.4.3-Azure/master/udf.ko
mv udf.ko /boot/kernel/

git clone https://github.com/Azure/WALinuxAgent.git
cd WALinuxAgent
git checkout v2.2.14
python setup.py install
ln -sf /usr/local/sbin/waagent /usr/sbin/waagent
ln -sf /usr/local/sbin/waagent2.0 /usr/sbin/waagent2.0
echo '#! /bin/sh' >> /usr/local/etc/rc.d/waagent.sh
echo '/usr/local/sbin/waagent --daemon' >> /usr/local/etc/rc.d/waagent.sh
chmod +x /usr/local/etc/rc.d/waagent.sh
echo "y" |  /usr/local/sbin/waagent -deprovision+user
echo  'waagent_enable="YES"' >> /etc/rc.conf
