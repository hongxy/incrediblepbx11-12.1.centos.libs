#!/bin/bash

#    Incredible PBX Copyright (C) 2005-2015, Ward Mundy & Associates LLC.
#    This program installs Asterisk, Incredible PBX and GUI on CentOS7. 
#    All programs copyrighted and licensed by their respective companies.
#
#    Portions Copyright (C) 1999-2015,  Digium, Inc.
#    Portions Copyright (C) 2005-2015,  Sangoma Technologies
#    Portions Copyright (C) 2005-2015,  Ward Mundy & Associates LLC
#    Portions Copyright (C) 2014-2015,  Eric Teeter teetere@charter.net
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#    GPL2 license file can be found at /root/COPYING after installation.
#

clear

if [ -e "/etc/pbx/.incredible" ]; then
 echo "Incredible PBX is already installed."
 exit 1
fi

#These are the varables required to make the install script work
#Do NOT change them
version="11-12.1"

clear
echo ".-.                          .-. _ .-.   .-.            .---. .---. .-..-."
echo ": :                          : ::_;: :   : :  v$version  : .; :: .; :: \`' :"
echo ": :,-.,-. .--. .--.  .--.  .-' :.-.: \`-. : :   .--.     :  _.':   .' \`  ' "
#echo $version
echo ": :: ,. :'  ..': ..'' '_.'' .; :: :' .; :: :_ ' '_.'    : :   : .; :.'  \`."
echo ":_;:_;:_;\`.__.':_;  \`.__.'\`.__.':_;\`.__.'\`.__;\`.__.'    :_;   :___.':_;:_;"
echo "Copyright (c) 2005-2015, Ward Mundy & Associates LLC. All rights reserved."
echo " "
echo "WARNING: This install will erase ALL existing GUI configurations!"
echo " "
echo "BY USING THE INCREDIBLE PBX, YOU AGREE TO ASSUME ALL RESPONSIBILITY"
echo "FOR USE OF THE PROGRAMS INCLUDED IN THIS INSTALLATION. NO WARRANTIES"
echo "EXPRESS OR IMPLIED INCLUDING MERCHANTABILITY AND FITNESS FOR PARTICULAR"
echo "USE ARE PROVIDED. YOU ASSUME ALL RISKS KNOWN AND UNKNOWN AND AGREE TO"
echo "HOLD WARD MUNDY, WARD MUNDY & ASSOCIATES LLC, NERD VITTLES, AND THE PBX"
echo "IN A FLASH DEVELOPMENT TEAM HARMLESS FROM ANY AND ALL LOSS OR DAMAGE"
echo "WHICH RESULTS FROM YOUR USE OF THIS SOFTWARE. AS CONFIGURED, THIS"
echo "SOFTWARE CANNOT BE USED TO MAKE 911 CALLS, AND YOU AGREE TO PROVIDE"
echo "AN ALTERNATE PHONE CAPABLE OF MAKING EMERGENCY CALLS. IF ANY OF THESE TERMS"
echo "AND CONDITIONS ARE RULED TO BE UNENFORCEABLE, YOU AGREE TO ACCEPT ONE"
echo "DOLLAR IN U.S. CURRENCY AS COMPENSATORY AND PUNITIVE LIQUIDATED DAMAGES"
echo "FOR ANY AND ALL CLAIMS YOU AND ANY USERS OF THIS SOFTWARE MIGHT HAVE."
echo " "

echo "If you do not agree with these terms and conditions of use, press Ctrl-C now."
read -p "Otherwise, press Enter to proceed at your own risk..."

clear
echo ".-.                          .-. _ .-.   .-.            .---. .---. .-..-."
echo ": :                          : ::_;: :   : :  v$version  : .; :: .; :: \`' :"
echo ": :,-.,-. .--. .--.  .--.  .-' :.-.: \`-. : :   .--.     :  _.':   .' \`  ' "
#echo $version
echo ": :: ,. :'  ..': ..'' '_.'' .; :: :' .; :: :_ ' '_.'    : :   : .; :.'  \`."
echo ":_;:_;:_;\`.__.':_;  \`.__.'\`.__.':_;\`.__.'\`.__;\`.__.'    :_;   :___.':_;:_;"
echo "Copyright (c) 2005-2015, Ward Mundy & Associates LLC. All rights reserved."
echo " "
echo "Installing The Incredible PBX. Please wait. This installer runs unattended."
echo "Consider a modest donation to Nerd Vittles while waiting. Return in 30 minutes."
echo "Do NOT press any keys while the installation is underway. Be patient!"
echo " "


# First is the FreePBX-compatible version number
export VER_FREEPBX=12.0

# Second is the Asterisk Database Password
export ASTERISK_DB_PW=amp109

# Third is the MySQL Admin password. Must be the same as when you install MySQL!!
export ADMIN_PASS=passw0rd


centos=x86_64
test=`uname -m`
if [[ "$centos" = "$test" ]]; then
 echo " "
else
 echo "This installer requires a 64-bit operating system."
 exit 1
fi

test=`cat /etc/redhat-release | grep 7`
if [[ -z $test ]]; then
 release="6"
else
 release="7"
fi

# getting CentOS7 up to speed
setenforce 0
yum -y update
sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config
yum -y install deltarpm yum-presto
yum -y install net-tools wget nano kernel-devel kernel-headers
mkdir -p /etc/pbx

# Installing packages needed to work with Asterisk
yum -y install glibc* yum-fastestmirror opens* anaconda* poppler-utils perl-Digest-SHA1 perl-Crypt-SSLeay xorg-x11-drv-qxl dialog binutils* mc sqlite sqlite-devel libstdc++-devel tzdata SDL* syslog-ng syslog-ng-libdbi texinfo uuid-devel libuuid-devel
yum -y install cairo* atk* freetds freetds-devel
# can't find lame
#yum -y install lame lame-devel
# can't find fail2ban
#yum -y install fail2ban
yum -y install redhat-lsb-core
yum -y groupinstall additional-devel base cifs-file-server compat-libraries console-internet core debugging development mail-server ftp-server hardware-monitoring java-platform legacy-unix mysql network-file-system-client network-tools php performance perl-runtime security-tools server-platform server-policy system-management system-admin-tools web-server
yum -y install gnutls-devel gnutls-utils mysql* mariadb* libtool-ltdl-devel lua-devel libsrtp-devel speex* php-mysql php-mbstring perl-JSON

if [[ "$release" = "7" ]]; then
 ln -s /usr/lib/systemd/system/mariadb.service /usr/lib/systemd/system/mysqld.service
 echo "#\!/bin/bash" > /etc/init.d/mysqld
 sed -i 's|\\||' /etc/init.d/mysqld
 echo "service mariadb \$1" >> /etc/init.d/mysqld
 chmod +x /etc/init.d/mysqld
 chkconfig --levels 235 mariadb on
fi
chkconfig --levels 235 mysqld on

cd /usr/src
# wget --no-check-certificate https://iksemel.googlecode.com/files/iksemel-1.4.tar.gz
wget http://pkgs.fedoraproject.org/repo/pkgs/iksemel/iksemel-1.4.tar.gz/532e77181694f87ad5eb59435d11c1ca/iksemel-1.4.tar.gz
tar zxvf iksemel*
cd iksemel*
./configure --prefix=/usr --with-libgnutls-prefix=/usr
make
make check
make install
echo "/usr/local/lib" > /etc/ld.so.conf.d/iksemel.conf 
ldconfig
# http://rpmfind.net/linux/rpm2html/search.php?query=spandsp
wget ftp://ftp.pbone.net/mirror/ftp5.gwdg.de/pub/opensuse/repositories/home:/dkdegroot:/asterisk/CentOS_CentOS-6/x86_64/spandsp-0.0.6-35.1.x86_64.rpm
wget ftp://ftp.pbone.net/mirror/ftp5.gwdg.de/pub/opensuse/repositories/home:/dkdegroot:/asterisk/CentOS_CentOS-6/x86_64/spandsp-devel-0.0.6-35.1.x86_64.rpm
rpm -ivh spandsp*
wait

# Installing RPM Forge repo
if [[ "$release" = "7" ]]; then
 wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm
else
 wget http://repository.it4i.cz/mirrors/repoforge/redhat/el6/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
fi
rpm -Uvh rpmforge*
cd /root
yum -y install $(cat yumlist.txt)

# get the epel repo
if [[ "$release" = "6" ]]; then
 wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
 rpm -Uvh epel-release-6-8.noarch.rpm
 yum -y install freetds freetds-devel
fi

# set up NTP
/usr/sbin/ntpdate -su pool.ntp.org

#setup database
echo "----> Setup database"
pear channel-update pear.php.net
pear install -Z db-1.7.14
wait

#install Asterisk packages
echo "----> Install Asterisk packages"
#apt-get install -y asterisk asterisk-moh-opsound-gsm asterisk-voicemail libvorbis-dev asterisk-ooh323 asterisk-vpb asterisk-mobile asterisk-mysql asterisk-sounds-extra 
#wait

#apt-get install -y libiksemel-utils sox libjson-perl flac
wait

# get the kernel source linkage correct. Thanks to?
# http://linuxmoz.com/asterisk-you-do-not-appear-to-have-the-sources-for-kernel-installed/
cd /lib/modules/`uname -r`
ln -fs /usr/src/kernels/`ls -d /usr/src/kernels/*.x86_64 | cut -f 5 -d "/"` build

#from source by Billy Chia
cd /usr/src
wget http://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/dahdi-linux-complete-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/libpri/libpri-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-11-current.tar.gz
tar zxvf dahdi-linux-complete*
tar zxvf libpri*
tar zxvf asterisk*
mv *.tar.gz /tmp

cd /usr/src/dahdi-linux-complete*
make && make install && make config

cd /usr/src/libpri*
make && make install

cd /usr/src
wget ftp://ftp.gtlib.gatech.edu/nv/ao1/lxmirror/finkmirrors.net/distfiles/md5/7b0ffbfad9bbaf33d397027e031cb35a/srtp-1.4.2.tgz
tar zxvf srtp-1.4.2.tgz
cd srtp
./configure CFLAGS=-fPIC
make && make install

cd /usr/src/asterisk*
contrib/scripts/get_mp3_source.sh 

if [[ "$release" = "7" ]]; then
 wget http://pbxinaflash.com/menuselect-centos7.tar.gz
 tar zxvf menuselect-centos7.tar.gz
 rm -f menuselect-centos7.tar.gz
else
 wget -U firefox http://pbxinaflash.com/menuselect-centos6.tar.gz
 tar zxvf menuselect-centos6.tar.gz
 rm -f menuselect-centos6.tar.gz
fi

#./configure && make menuselect && make && make install && make config && make samples
#./configure CFLAGS=-mtune=native --libdir=/usr/lib64 && make && make install && make config && make samples

./configure

make menuselect.makeopts
menuselect/menuselect --disable app_mysql --disable app_saycountpl --disable cdr_mysql menuselect.makeopts
menuselect/menuselect --enable-category  MENUSELECT_APPS menuselect.makeopts
menuselect/menuselect --disable app_skel --disable app_fax --disable app_ivrdemo --disable app_meetme --disable app_osplookup --disable app_saycounted --disable app_dahdibarge --disable app_readfile --disable app_setcallerid menuselect.makeopts
menuselect/menuselect --enable-category  MENUSELECT_BRIDGES menuselect.makeopts
menuselect/menuselect --enable-category  MENUSELECT_CDR menuselect.makeopts
menuselect/menuselect --disable cdr_sqlite  MENUSELECT_APPS menuselect.makeopts
menuselect/menuselect --enable-category  MENUSELECT_CEL menuselect.makeopts
menuselect/menuselect --enable-category  MENUSELECT_CHANNELS menuselect.makeopts
menuselect/menuselect --disable chan_console --disable chan_misdn --disable chan_nbs --disable chan_vpb --disable chan_gtalk --disable chan_h323 --disable chan_jingle menuselect.makeopts
menuselect/menuselect --enable-category  MENUSELECT_CODECS menuselect.makeopt
menuselect/menuselect --enable-category  MENUSELECT_FORMATS menuselect.makeopts
menuselect/menuselect --enable-category  MENUSELECT_FUNCS menuselect.makeopts
menuselect/menuselect --enable-category  MENUSELECT_PBX menuselect.makeopts
menuselect/menuselect --enable-category  MENUSELECT_RES menuselect.makeopts
menuselect/menuselect --disable res_http_post --disable res_pktccops --disable res_timing_kqueue --disable res_jabber menuselect.makeopts
menuselect/menuselect --disable-category MENUSELECT_TESTS menuselect.makeopt
menuselect/menuselect --enable LOADABLE_MODULES --enable BUILD_NATIVE --enable FILE_STORAGE menuselect.makeopts
menuselect/menuselect --enable astcanary --enable astdb2sqlite3 --enable astdb2bdb menuselect.makeopts
menuselect/menuselect --enable CORE-SOUNDS-EN-GSM --enable MOH-OPSOUND-WAV --enable EXTRA-SOUNDS-EN-GSM menuselect.makeopts
menuselect/menuselect --enable-category  MENUSELECT_ADDONS menuselect.makeopts
menuselect/menuselect --enable chan_mobile --enable chan_ooh323 --enable format_mp3 --enable res_config_mysql menuselect.makeopts


#expect -c 'set timeout 30;spawn make menuselect;expect "Save";send "\t\t\r";interact'
# make menuselect

make && make install && make config && make samples
ldconfig

#Add Flite support
#apt-get install libsdl1.2-dev libflite1 flite1-dev flite -y
cd /usr/src
# git clone https://github.com/zaf/Asterisk-Flite.git
#wget --no-check-certificate https://github.com/downloads/zaf/Asterisk-Flite/Asterisk-Flite-2.2-rc1-flite1.3.tar.gz
if [[ "$release" = "7" ]]; then
 wget http://incrediblepbx.com/Asterisk-Flite-2.2-rc1-flite1.3.tar.gz
 tar zxvf Asterisk-Flite*
 cd Asterisk-Flite*
else
 yum -y install flite flite-devel
 sed -i 's|enabled=1|enabled=0|' /etc/yum.repos.d/epel.repo
 wget http://incrediblepbx.com/Asterisk-Flite-2.2-rc1-flite1.3.tar.gz
 tar zxvf Asterisk-Flite*
 cd Asterisk-Flite*
fi
ldconfig
make
make install

#Add MP3 support
cd /usr/src
wget http://sourceforge.net/projects/mpg123/files/mpg123/1.16.0/mpg123-1.16.0.tar.bz2/download
mv download mpg123.tar.bz2
tar -xjvf mpg123*
cd mpg123*/
./configure && make && make install && ldconfig
ln -s /usr/local/bin/mpg123 /usr/bin/mpg123

# Reconfigure Apache for Asterisk
sed -i "s/User apache/User asterisk/" /etc/httpd/conf/httpd.conf
sed -i "s/Group apache/Group asterisk/" /etc/httpd/conf/httpd.conf

if [[ "$release" = "7" ]]; then
 /etc/init.d/dahdi start
 /etc/init.d/asterisk start
else
 service dahdi start
 service asterisk start
 sed -i 's|module.so|mcrypt.so|' /etc/php.d/mcrypt.ini
fi

#Now create the Asterisk user and set ownership permissions.
echo "----> Create the Asterisk user and set ownership permissions and modify Apache"
adduser asterisk -M -d /var/lib/asterisk -s /sbin/nologin -c "Asterisk User"
chown asterisk. /var/run/asterisk
chown -R asterisk. /etc/asterisk
chown -R asterisk. /var/{lib,log,spool}/asterisk
chown -R asterisk. /usr/lib/asterisk
mkdir /var/www/html
chown -R asterisk. /var/www/

#A few small modifications to Apache.
sed -i 's/\(^upload_max_filesize = \).*/\120M/' /etc/php.ini
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf_orig
sed -i 's/^\(User\|Group\).*/\1 asterisk/' /etc/httpd/conf/httpd.conf
service httpd restart


#Download and extract FreePBX GPL framework module to get started 
echo "----> Download and extract FreePBX GPL framework module"
cd /usr/src
#git clone http://git.freepbx.org/scm/freepbx/framework.git freepbx
git clone https://github.com/wardmundy/framework.git freepbx
wait
ln -s /var/lib/asterisk/moh /var/lib/asterisk/mohmp3
cd freepbx
git checkout release/${VER_FREEPBX}
wait



# Set MyISAM as default MySQL storage so we can make quick backups
sed -i '/\[mysqld\]/a default-storage-engine=MyISAM' /etc/my.cnf
service mysqld restart

#Configure Asterisk database in MYSQL.
echo "----> Configure Asterisk database in MYSQL and set permissions"

export ASTERISK_DB_PW=amp109
mysqladmin -u root create asterisk
mysqladmin -u root create asteriskcdrdb
mysql -u root asterisk < SQL/newinstall.sql
wait
mysql -u root asteriskcdrdb < SQL/cdr_mysql_table.sql
wait

#Set permissions on MYSQL database.

mysql -u root -e "GRANT ALL PRIVILEGES ON asterisk.* TO asteriskuser@localhost IDENTIFIED BY '{ASTERISK_DB_PW}';"
mysql -u root -e "GRANT ALL PRIVILEGES ON asteriskcdrdb.* TO asteriskuser@localhost IDENTIFIED BY '{ASTERISK_DB_PW}';"

mysql -u root -e "update mysql.user set Select_priv='Y',Insert_priv='Y',Update_priv='Y',Delete_priv='Y',Create_priv='Y',Drop_priv='Y',Reload_priv='Y',Shutdown_priv='Y',Process_priv='Y',File_priv='Y',Grant_priv='Y',References_priv='Y',Index_priv='Y',Alter_priv='Y',Show_db_priv='Y',Super_priv='Y',Create_tmp_table_priv='Y',Lock_tables_priv='Y',Execute_priv='Y',Repl_slave_priv='Y',Repl_client_priv='Y',Create_view_priv='Y',Show_view_priv='Y',Create_routine_priv='Y',Alter_routine_priv='Y',Create_user_priv='Y',Event_priv='Y',Trigger_priv='Y' where User = 'asteriskuser' limit 1;"

mysql -u root -e "DELETE FROM mysql.user WHERE user.Host = CAST(0x6c6f63616c686f7374 AS BINARY) AND user.User = CAST(0x6176616e74666178 AS BINARY);"

mysql -u root -e "flush privileges;"


mysqladmin -u root password 'passw0rd'

#Restart Asterisk and install the GUI.

echo "----> Restart Asterisk and install the GUI."

./start_asterisk start
./install_amp --username=root --password=passw0rd --scripted --webroot /var/www/html

#Finally, a few last mods and start the GUI."

mkdir /var/lib/asterisk/sounds/custom
mkdir /var/lib/asterisk/sounds/tts
chown asterisk:asterisk /var/lib/asterisk/sounds/custom
chown asterisk:asterisk /var/lib/asterisk/sounds/tts
amportal restart 

# Installing Incredible PBX stuff
cd /tmp
wget --progress=dot:mega http://incrediblepbx.com/incredible12e.tgz
echo -n "Verifying Incredible PBX 12 payload... "
TEST=`md5sum incredible12e.tgz | cut -f 1 -d " "`
if [ "$TEST" = "de732338209393dc44904594c17f15a8" ]; then
 echo "PASSED"
else
 echo "FAILED"
 echo "Please try your install again. If it fails again, please alert us!"
 echo "Send us an EMAIL here: http://pbxinaflash.com/about/comment.php"
 exit 6
fi

chown -R asterisk:asterisk /var/www/html/*

amportal stop
service httpd stop
service mysqld stop
echo " "
echo "Installing Incredible PBX 12 payload..."
cd /
tar zxvf /tmp/incredible12e.tgz
rm -f /tmp/incredible12e.tgz
sed -i 's|$ttspick = 1|$ttspick = 0|' /var/www/html/reminders/index.php


# trim the number of Apache processes
echo " " >> /etc/httpd/conf/httpd.conf
echo "<IfModule prefork.c>" >> /etc/httpd/conf/httpd.conf
echo "StartServers       3" >> /etc/httpd/conf/httpd.conf
echo "MinSpareServers    3" >> /etc/httpd/conf/httpd.conf
echo "MaxSpareServers   4" >> /etc/httpd/conf/httpd.conf
echo "ServerLimit      5" >> /etc/httpd/conf/httpd.conf
echo "MaxClients       256" >> /etc/httpd/conf/httpd.conf
echo "MaxRequestsPerChild  4000" >> /etc/httpd/conf/httpd.conf
echo "</IfModule>" >> /etc/httpd/conf/httpd.conf
echo " " >> /etc/httpd/conf/httpd.conf

# fix phpMyAdmin for CentOS 7
sed -i 's|localhost|127.0.0.1|' /var/www/html/maint/phpMyAdmin/config.inc.php
service mysqld start
service httpd start
amportal start
amportal a r
asterisk -rx "database deltree dundi"
mkdir /etc/pbx
touch /etc/pbx/.incredible

# reset GUI privs and passwords
mysql -u root -p${ADMIN_PASS} -e "update mysql.user set Select_priv='Y',Insert_priv='Y',Update_priv='Y',Delete_priv='Y',Create_priv='Y',Drop_priv='Y',Reload_priv='Y',Shutdown_priv='Y',Process_priv='Y',File_priv='Y',Grant_priv='Y',References_priv='Y',Index_priv='Y',Alter_priv='Y',Show_db_priv='Y',Super_priv='Y',Create_tmp_table_priv='Y',Lock_tables_priv='Y',Execute_priv='Y',Repl_slave_priv='Y',Repl_client_priv='Y',Create_view_priv='Y',Show_view_priv='Y',Create_routine_priv='Y',Alter_routine_priv='Y',Create_user_priv='Y',Event_priv='Y',Trigger_priv='Y' where User = 'asteriskuser' limit 1;"
mysql -u root -p${ADMIN_PASS} -e "flush privileges;"
echo " "

# ******************

echo "Randomizing all of your extension 701 and DISA passwords..."
lowest=111337
highest=982766
ext701=$[ ( $RANDOM % ( $[ $highest - $lowest ] + 1 ) ) + $lowest ]
disapw=$[ ( $RANDOM % ( $[ $highest - $lowest ] + 1 ) ) + $lowest ]
vm701=$[ ( $RANDOM % ( $[ $highest - $lowest ] + 1 ) ) + $lowest ]
adminpw=$[ ( $RANDOM % ( $[ $highest - $lowest ] + 1 ) ) + $lowest ]
mysql -uroot -ppassw0rd asterisk <<EOF
use asterisk;
update sip set data="$ext701" where id="701" and keyword="secret";
update disa set pin="$disapw" where disa_id=1;
update admin set value='true' where variable="need_reload";
EOF
sed -i 's|1234|'$vm701'|' /etc/asterisk/voicemail.conf
sed -i 's|701 =|;701 =|' /etc/asterisk/voicemail.conf
sed -i 's|1234 =|;1234 =|' /etc/asterisk/voicemail.conf
echo "701 => $vm701,701,yourname98199x@gmail.com,,attach=yes|saycid=yes|envelope=yes|delete=no" > /tmp/email.txt
sed -i '/\[default\]/r /tmp/email.txt' /etc/asterisk/voicemail.conf
rm -f /tmp/email.txt

/var/lib/asterisk/bin/module_admin reload
rm -f /var/www/html/piaf-index.tar.gz

# something in here changes the security model back to none
# or maybe it's already set that way and this just restarts it to load it
/var/lib/asterisk/bin/module_admin upgrade framework
/var/lib/asterisk/bin/module_admin upgrade core
/var/lib/asterisk/bin/module_admin upgradeall
/var/lib/asterisk/bin/module_admin upgradeall
/var/lib/asterisk/bin/module_admin upgradeall
/var/lib/asterisk/bin/module_admin upgrade cidlookup
/var/lib/asterisk/bin/module_admin upgrade digium_phones
/var/lib/asterisk/bin/module_admin upgrade digiumaddoninstaller
/var/lib/asterisk/bin/retrieve_conf
amportal a r
amportal a an

# anyway we fix it again here before the reload
mysql -u root -ppassw0rd -e "update asterisk.freepbx_settings set value = 'database' where keyword = 'AUTHTYPE' limit 1;"
sed -i 's|AUTHTYPE=none|AUTHTYPE=database|' /etc/amportal.conf
mysql -u root -ppassw0rd -e "update asterisk.admin set value='true' where variable='need_reload';"
/var/lib/asterisk/bin/module_admin reload

# now we set the randomized admin password
mysql -u root -ppassw0rd -e "update asterisk.ampusers set password_sha1 = '`echo -n $adminpw | sha1sum`' where username = 'admin' limit 1;"


echo " "

# Configuring IPtables
# Rules are saved in /etc/iptables
# /etc/init.d/iptables-persistent restart 
#apt-get install iptables-persistent -y
# add TM3 rules here
sed -i 's|INPUT ACCEPT|INPUT DROP|' /etc/sysconfig/ip6tables
# Here's the culprit...
# changing the next rule to DROP will kill the GUI on some hosted platforms like Digital Ocean
# but you get constant noise in the log where they're doing some heartbeat stuff
sed -i '/OUTPUT ACCEPT/a -A INPUT -s ::1 -j ACCEPT' /etc/sysconfig/ip6tables
# server IP address is?
if [[ "$release" = "7" ]]; then
 serverip=`ifconfig | grep "inet" | head -1 | cut -f 2 -d ":" | tail -1 | cut -f 10 -d " "`
else
 serverip=`ifconfig | grep "inet" | head -1 | cut -f 2 -d ":" | tail -1 | cut -f 1 -d " "`
fi
# user IP address while logged into SSH is?
userip=`echo $SSH_CONNECTION | cut -f 1 -d " "`
# public IP address in case we're on private LAN
publicip=`curl -s -S --user-agent "Mozilla/4.0" http://myip.pbxinaflash.com | awk 'NR==2'`
# WhiteList all of them by replacing 8.8.4.4 and 8.8.8.8 and 74.86.213.25 entries
cp /etc/sysconfig/iptables /etc/sysconfig/iptables.orig
cd /etc/sysconfig
# yep we use the same iptables rules on the Ubuntu platform
wget -U firefox http://pbxinaflash.com/iptables4-ubuntu14.tar.gz
tar zxvf iptables4-ubuntu14.tar.gz
rm -f iptables4-ubuntu14.tar.gz
cp rules.v4.ubuntu14 iptables
sed -i 's|8.8.4.4|'$serverip'|' /etc/sysconfig/iptables
sed -i 's|8.8.8.8|'$userip'|' /etc/sysconfig/iptables
sed -i 's|74.86.213.25|'$publicip'|' /etc/sysconfig/iptables
badline=`grep -n "\-s  \-p" /etc/sysconfig/iptables | cut -f1 -d: | tail -1`
while [[ "$badline" != "" ]]; do
sed -i "${badline}d" /etc/sysconfig/iptables
badline=`grep -n "\-s  \-p" /etc/sysconfig/iptables | cut -f1 -d: | tail -1`
done
#Installing Fail2Ban
yum -y install fail2ban
# chronyd causes problems
if [[ "$release" = "7" ]]; then
 chkconfig chronyd off
 service chronyd stop
 systemctl disable firewalld.service
 systemctl stop firewalld.service
else
 cd /usr/local/sbin
 wget http://incrediblepbx.com/iptables-restart-6.tar.gz
 tar zxvf iptables-restart-6.tar.gz
 rm -f iptables-restart-6.tar.gz
fi
service iptables restart
service ip6tables restart
chkconfig iptables on
chkconfig ip6tables on
chkconfig httpd on
service httpd restart
if [[ "$release" = "7" ]]; then
 systemctl enable ntpd.service
 systemctl start ntpd.service
else
 chkconfig ntpd on
 service ntpd start
fi
sed -i '/Starting/a mkdir /var/run/fail2ban' /etc/rc.d/rc3.d/S92fail2ban
sed -i '/Starting/a mkdir /var/run/fail2ban' /etc/init.d/fail2ban
cd /etc/fail2ban
wget http://incrediblepbx.com/jail-R.tar.gz
tar zxvf jail-R.tar.gz
rm -f jail-R.tar.gz
service fail2ban start
chkconfig fail2ban on
service sendmail start
chkconfig sendmail on
if [[ "$release" = "7" ]]; then
 systemctl enable sshd.service
else
 chkconfig sshd on
fi

# Installing SendMail
#echo "Installing SendMail..."
#apt-get install sendmail -y

# Installing WebMin from /root rpm
# you may not get the latest but it won't blow up either
echo "Installing WebMin..."
cd /root
wget http://prdownloads.sourceforge.net/webadmin/webmin-1.750-1.noarch.rpm
rpm -Uvh webmin*
sed -i 's|10000|9001|g' /etc/webmin/miniserv.conf
service webmin restart
chkconfig webmin on

echo "Installing command line gvoice for SMS messaging..."
cd /root
#mkdir pygooglevoice
easy_install -U setuptools
easy_install simplejson
#cd pygooglevoice
#wget http://nerdvittles.dreamhosters.com/pbxinaflash/source/pygooglevoice/pygooglevoice.tar.gz
#tar zxvf pygooglevoice.tar.gz
#python setup.py install
#rm -f pygooglevoice.tar.gz
#cp /root/pygooglevoice/bin/gvoice /usr/bin/.
yum -y install mercurial
#hg clone https://code.google.com/r/kkleidal-pygooglevoiceupdate/
#have to just upload to the folder
cd kk*
python setup.py install
cp -p bin/gvoice /usr/bin/.

echo "asterisk ALL = NOPASSWD: /sbin/shutdown" >> /etc/sudoers
echo "asterisk ALL = NOPASSWD: /sbin/reboot" >> /etc/sudoers
echo "asterisk ALL = NOPASSWD: /usr/bin/gvoice" >> /etc/sudoers
cd /root
wget http://incrediblepbx.com/morestuff.tar.gz
tar zxvf morestuff.tar.gz
rm -f morestuff.tar.gz
rm -fr neorouter
echo " "

echo "Installing NeoRouter client..."
cd /root
wget http://download.neorouter.com/Downloads/NRFree/Update_2.1.2.4326/Linux/CentOS/nrclient-2.1.2.4326-free-centos-x86_64.rpm
yum -y install nrclient*

# this needs some more work
# adjusting DNS entries for PPTP access to Google DNS servers
# sed -i 's|#ms-dns 10.0.0.1|ms-dns 8.8.8.8|' /etc/ppp/pptpd-options
#sed -i 's|#ms-dns 10.0.0.2|ms-dns 8.8.4.4|' /etc/ppp/pptpd-options
# Administrator still must do the following to bring PPTP on line
# 1. edit /etc/pptpd.conf and add localip and remoteip address ranges
# 2. edit /etc/ppp/chap-secrets and add credentials for PPTP access:
#  mybox pptpd 1234 * (would give everyone access to mybox using 1234 pw)
# 3. restart PPTPD: service pptpd restart

# Installing status and mime-construct apps as well as automatic updater
#rm -f /sbin/status
#cd /usr/local/sbin
#wget http://pbxinaflash.com/status-ubuntu14.tar.gz
#tar zxvf status-ubuntu14.tar.gz
#rm -f status-ubuntu14.tar.gz
#sed -i 's|mesg n|/root/update-IncrediblePBX \&\& /usr/local/sbin/status \&\& echo "Always run Incredible PBX behind a hardware-based firewall." \&\& mesg n|' /root/.profile
#chattr +i update-IncrediblePBX
echo "$version" > /etc/pbx/.version

# Installing local mail
#apt-get install mailutils -y

# recompile Flite just to be sure
cd /usr/src/Asterisk-Flite*
make
make install

# tidy up stuff for CentOS 6.5
if [[ "$release" = "6" ]]; then
 cd /usr/local/sbin
 wget http://incrediblepbx.com/status6.tar.gz
 tar zxvf status6.tar.gz
 rm -f status6.tar.gz
 cd /usr/src/asterisk*
 make
 make install
 asterisk -rx "module load app_confbridge"
fi

# Substitute Yahoo News for Google's defunct News app
cd /root
wget http://incrediblepbx.com/nv-news-yahoo.tar.gz
cd /
tar zxvf /root/nv-news-yahoo.tar.gz
sed -i '\:// BEGIN nv-news-google:,\:// END nv-news-google:d' /etc/asterisk/extensions_custom.conf
sed -i '\:// BEGIN nv-news-yahoo:,\:// END nv-news-yahoo:d' /etc/asterisk/extensions_custom.conf
sed -i '/\[from-internal-custom\]/r /tmp/nv-news-yahoo.txt' /etc/asterisk/extensions_custom.conf
rm /tmp/nv-news-yahoo.txt
rm /root/nv-news-yahoo.tar.gz

amportal restart

# Adding timezone-setup module
cd /root
wget -U firefox http://pbxinaflash.com/timezone-setup.tar.gz
tar zxvf timezone-setup.tar.gz
rm -f timezone-setup.tar.gz

# Adding confbridge app (this bug has been fixed )
# cp /usr/lib64/asterisk/modules/app_confbridge.so /usr/lib/asterisk/modules/.
# amportal restart

# Patching Wolfram Alpha installer for Ubuntu
#sed -i '/wget http:\/\/nerd.bz\/A7umMK/a mv A7umMK 4747.tgz' /root/wolfram/wolframalpha-oneclick.sh

# Patching grub so Ubuntu will shutdown and reboot by issuing command twice
# which sure beats NEVER which was the previous situation. Thanks, @jeff.h
#sed -i 's|GRUB_CMDLINE_LINUX_DEFAULT=""|GRUB_CMDLINE_LINUX_DEFAULT="quiet splash acpi=force"|' /etc/default/grub
#update-grub

# patching PHP and AGI apps that didn't have <?php prefix
for f in /var/lib/asterisk/agi-bin/*.php; do echo "Updating $f..." && sed -i ':a;N;$!ba;s/<?\n/<?php\n/' $f; done
for f in /var/lib/asterisk/agi-bin/*.agi; do echo "Updating $f..." && sed -i ':a;N;$!ba;s/<?\n/<?php\n/' $f; done

# set up directories for Telephone Reminders
mkdir /var/spool/asterisk/reminders
mkdir /var/spool/asterisk/recurring
chown asterisk:asterisk /var/spool/asterisk/reminders
chown asterisk:asterisk /var/spool/asterisk/recurring

# fix /etc/hosts so SendMail works with Asterisk
sed -i 's|localhost |pbx.local localhost |' /etc/hosts

# install Incredible Backup and Restore
cd /root
wget http://incrediblepbx.com/incrediblebackup11.tar.gz
tar zxvf incrediblebackup11.tar.gz
rm -f incrediblebackup11.tar.gz

# adding Port Knock daemon: knockd
cd /root
yum -y install libpcap* curl gawk
wget http://nerdvittles.dreamhosters.com/pbxinaflash//source/knock/knock-server-0.5-7.el6.nux.x86_64.rpm
rpm -ivh knock-server*
rm -f knock-server*.rpm
echo "[options]" > /etc/knockd.conf
echo "       logfile = /var/log/knockd.log" >> /etc/knockd.conf
echo "" >> /etc/knockd.conf
echo "[opencloseALL]" >> /etc/knockd.conf
echo "        sequence      = 7:udp,8:udp,9:udp" >> /etc/knockd.conf
echo "        seq_timeout   = 15" >> /etc/knockd.conf
echo "        tcpflags      = syn" >> /etc/knockd.conf
echo "        start_command = /sbin/iptables -A INPUT -s %IP% -j ACCEPT" >> /etc/knockd.conf
echo "        cmd_timeout   = 3600" >> /etc/knockd.conf
echo "        stop_command  = /sbin/iptables -D INPUT -s %IP% -j ACCEPT" >> /etc/knockd.conf
chmod 640 /etc/knockd.conf
# randomize ports here
lowest=6001
highest=9950
knock1=$[ ( $RANDOM % ( $[ $highest - $lowest ] + 1 ) ) + $lowest ]
knock2=$[ ( $RANDOM % ( $[ $highest - $lowest ] + 1 ) ) + $lowest ]
knock3=$[ ( $RANDOM % ( $[ $highest - $lowest ] + 1 ) ) + $lowest ]
sed -i 's|7:udp|'$knock1':tcp|' /etc/knockd.conf
sed -i 's|8:udp|'$knock2':tcp|' /etc/knockd.conf
sed -i 's|9:udp|'$knock3':tcp|' /etc/knockd.conf
if [[ "$release" = "7" ]]; then
 EPORT=`ifconfig | head -1 | cut -f 1 -d ":"`
 echo "OPTIONS=\"-i $EPORT\"" > /etc/sysconfig/knockd
else
 chkconfig --level 2345 knockd on
 service knockd start
fi

/var/lib/asterisk/bin/module_admin reload
rm -f /var/www/html/index_custom.php
cp /var/www/html/index.php /var/www/html/index_custom.php

#patch status
mv /root/status /usr/local/sbin/status
chattr +i /usr/local/sbin/status

# web root
cd /var/www/html
mv index_custom.php index_custom2.php


# clear out proprietary logos and final cleanup
chattr -i /usr/local/sbin/status
sed -i 's|       FreePBX|Incredible GUI|' /usr/local/sbin/status
cd /root
/root/logos-b-gone
rm -f anaconda*
rm -f epel*
rm -f install.*
rm -f nrclient*
rm -f rpmforge*
rm -f yumlist.*

#sendmailmp3 support
cd /usr/sbin
wget -U firefox http://pbxinaflash.com/sendmailmp3.tar.gz
tar zxvf sendmailmp3.tar.gz
rm sendmailmp3.tar.gz
chmod 0755 sendmailmp3
yum -y install lame
yum -y install flac
yum -y install dos2unix
yum -y install unix2dos
ln -s /usr/sbin/sendmailmp3 /usr/bin/sendmailmp3
cd /root

# and some bug fixes
chmod 664 /var/log/asterisk/full
/root/odbc-gen.sh
echo "[cel]" >> /etc/asterisk/cel_odbc_custom.conf
echo "connection=MySQL-asteriskcdrdb" >> /etc/asterisk/cel_odbc_custom.conf
echo "loguniqueid=yes" >> /etc/asterisk/cel_odbc_custom.conf
echo "table=cel" >> /etc/asterisk/cel_odbc_custom.conf
sed -i "s|''|'localhost'|" /etc/freepbx.conf
sed -i "s|'localhost'; //for sqlite3|''; //for sqlite3|" /etc/freepbx.conf
cd /var/www/html
rm -f favicon.ico
wget http://incrediblepbx.com/favicon.ico
chown asterisk:asterisk favicon.ico
cp -p favicon.ico /var/www/manual/images/.
cp -p favicon.ico /var/www/html/reminders/.
cp -p favicon.ico /var/www/html/admin/modules/framework/amp_conf/htdocs/admin/images/.
cp -p favicon.ico /var/www/html/admin/images/.
cp -p favicon.ico /usr/src/freepbx/amp_conf/htdocs/admin/images/.
mysql -u root -ppassw0rd mysql -e "SET PASSWORD FOR 'asteriskuser'@'localhost' = PASSWORD('amp109');"
amportal restart
echo "/usr/local/sbin/iptables-restart"	>> /etc/rc.local
echo "exit 0" >> /etc/rc.local
sed -i 's|AllowOverride None|AllowOverride All|' /etc/httpd/conf/httpd.conf
service httpd restart
/var/lib/asterisk/bin/freepbx_setting SIGNATURECHECK 0
amportal a r
sed -i 's|1024:65535|9999:65535|' /etc/sysconfig/iptables
sed -i 's|1024:65535|9999:65535|' /etc/sysconfig/rules.v4.ubuntu14
iptables-restart

# version 11-12.1 additions
cd /usr/local/sbin
wget http://incrediblepbx.com/gui-fix.tar.gz
tar zxvf gui-fix.tar.gz
rm -f gui-fix.tar.gz

cd /var/lib/asterisk/agi-bin
mv speech-recog.agi speech-recog.last.agi
wget --no-check-certificate https://raw.githubusercontent.com/zaf/asterisk-speech-recog/master/speech-recog.agi
chown asterisk:asterisk speech*
chmod 775 speech*

# Add Kennonsoft menus
cd /var/www/html
wget http://incrediblepbx.com/kennonsoft.tar.gz
tar zxvf kennonsoft.tar.gz
rm -f kennonsoft.tar.gz

# Add HTTP security
cd /etc/pbx
wget http://incrediblepbx.com/http-security.tar.gz
tar zxvf http-security.tar.gz
rm -f http-security.tar.gz
echo "Include /etc/pbx/httpdconf/*" >> /etc/httpd/conf/httpd.conf
service httpd restart

cd /root
rm -r wolfram*

#GV patch
sed -i 's| noload = res_jabber.so|;noload = res_jabber.so|' /etc/asterisk/modules.conf
sed -i 's| noload = chan_gtalk.so|;noload = chan_gtalk.so|' /etc/asterisk/modules.conf

# July 8 patches
sed -i 's|<? |<?php|' /var/lib/asterisk/agi-bin/nv-callwho.php
sed -i 's|<? |<?php|' /var/lib/asterisk/agi-bin/reminder.php
sed -i 's|<? |<?php|' /var/lib/asterisk/agi-bin/checkdate.php
sed -i 's|<? |<?php|' /var/lib/asterisk/agi-bin/checktime.php
sed -i 's|<? |<?php|' /var/lib/asterisk/agi-bin/nv-callwho2.php
echo srvlookup=yes >> /etc/asterisk/sip_general_custom.conf

amportal restart


clear
echo "Knock ports for access to $publicip set to TCP: $knock1 $knock2 $knock3" > /root/knock.FAQ
echo "To enable knockd on your server, issue the following commands:" >> /root/knock.FAQ
echo "  chkconfig --level 2345 knockd on" >> /root/knock.FAQ
echo "  service knockd start" >> /root/knock.FAQ
echo "To enable remote access, issue these commands from any remote server:" >> /root/knock.FAQ
echo "nmap -p $knock1 $publicip && nmap -p $knock2 $publicip && nmap -p $knock3 $publicip" >> /root/knock.FAQ
echo "Or install iOS PortKnock or Android DroidKnocker on remote device." >> /root/knock.FAQ
echo " "

echo "*** Reset your Incredible PBX GUI admin password. Run /root/admin-pw-change NOW!"
echo "*** Configure your correct time zone by running: /root/timezone-setup"
echo "*** For fax support, run: /root/incrediblefax11.sh"
echo " "
echo "WARNING: Server access locked down to server IP address and current IP address."
echo "*** Modify /etc/sysconfig/iptables and restart IPtables BEFORE logging out!"
echo "To restart IPtables, issue command: service iptables restart"
echo " "
echo "Knock ports for access to $publicip set to TCP: $knock1 $knock2 $knock3"
echo "To enable knockd server for remote access, read /root/knock.FAQ"
echo " "
echo "You may access webmin as root at https://$serverip:9001"
echo " "
systemctl restart sshd.service
iptables-restart

echo "Have a great day!     "
