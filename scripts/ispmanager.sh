#!/bin/bash -xe

date "+%Y-%m-%d %H:%M:%S"

apt-get update
apt-get -y --force-yes install software-properties-common jq curl

hostname `hostname`.simplecloud.club

echo "127.0.0.1 $HOSTNAME localhost
::1 $HOSTNAME localhost" > /etc/hosts
 
export DEBIAN_FRONTEND=noninteractive 

apt-get -y --force-yes install \
postfix \
postfix-mysql \
mysql-server \
makepasswd \
pure-ftpd-mysql \
courier-base \
courier-imap \
courier-imap-ssl \
courier-pop \
courier-pop-ssl \
courier-authlib-mysql \
clamav-data \
amavis \
libmail-spamassassin-perl

apt-get -y --force-yes install apache2 apache2-doc apache2-utils libapache2-mod-php5 php5 php5-common php5-gd php5-mysqlnd php5-imap phpmyadmin php5-cli php5-cgi libapache2-mod-fcgid apache2-suexec php-pear php-auth php5-mcrypt mcrypt php5-imagick imagemagick libapache2-mod-suphp libruby libapache2-mod-python php5-curl php5-intl php5-memcache php5-memcached php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl memcached snmp

a2enmod rewrite ssl include actions php5 suexec
service apache2 restart
sleep 5

mysql -e "create database dbispconfig"
PASS=`makepasswd --chars=16`
mysql mysql -e "update user set Password=password('$PASS') where Password=''; flush privileges"
echo "[client]
password=$PASS" > /root/.my.cnf
chmod 600 /root/.my.cnf

cd /tmp
wget http://www.ispconfig.org/downloads/ISPConfig-3-stable.tar.gz
tar xfz ISPConfig-3-stable.tar.gz
cd ispconfig3_install/install/

echo "[install]
language=ru
install_mode=standard
hostname=`hostname -s`.simplecloud.club
mysql_hostname=localhost
mysql_root_user=root
mysql_root_password=$PASS
mysql_database=dbispconfig
mysql_charset=utf8
http_server=apache
ispconfig_port=8080
ispconfig_use_ssl=y

[ssl_cert]
ssl_cert_country=AU
ssl_cert_state=Some-State
ssl_cert_locality=Chicago
ssl_cert_organisation=Internet Widgits Pty Ltd
ssl_cert_organisation_unit=IT department
ssl_cert_common_name=server1.example.com

[expert]
mysql_ispconfig_user=ispconfig
mysql_ispconfig_password=afStEratXBsgatRtsa42CadwhQ
join_multiserver_setup=n
mysql_master_hostname=master.example.com
mysql_master_root_user=root
mysql_master_root_password=ispconfig
mysql_master_database=dbispconfig
configure_mail=y
configure_jailkit=y
configure_ftp=y
configure_dns=y
configure_apache=y
configure_nginx=y
configure_firewall=y
install_ispconfig_web_interface=y

[update]
do_backup=yes
mysql_root_password=ispconfig
mysql_master_hostname=master.example.com
mysql_master_root_user=root
mysql_master_root_password=ispconfig
mysql_master_database=dbispconfig
reconfigure_permissions_in_master_database=no
reconfigure_services=yes
ispconfig_port=8080
create_new_ispconfig_ssl_cert=no
reconfigure_crontab=yes" > autoinstall.ini

php -q install.php --autoinstall=autoinstall.ini

cd /
rm -rf /tmp/ispconfig3_install
