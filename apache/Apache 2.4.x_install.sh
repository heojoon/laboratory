#
# Apache 2.4.x Install script v0.1
#

#
# You need root privileges to run this script.
# Run as the root directly or non-root user with root privileges.  (ex. in sudoer file)
#

# Custom variables
Path_install="/app/web/apache"
Path_download="/home/$(whoami)"
Apache_Version="2.4.46"

# Requirement packages
sudo yum -y install \
gcc openssl openssl-devel apr-util apr-util-devel

cd ${Path_download}
curl -O http://mirror.navercorp.com/apache//apr/apr-1.7.0.tar.gz
curl -O http://mirror.navercorp.com/apache//apr/apr-util-1.6.1.tar.gz

# download
cd ${Path_download}
curl -O http://mirror.navercorp.com/apache//httpd/httpd-${Apache_Version}.tar.gz

# unpacking
tar zxvf httpd-${Apache_Version}.tar.gz

# source download apr and apr-util for set MPM=event
cd httpd-${Apache_Version}/srclib
curl -O http://mirror.navercorp.com/apache//apr/apr-1.7.0.tar.gz
curl -O http://mirror.navercorp.com/apache//apr/apr-util-1.6.1.tar.gz
tar zxvf apr-1.7.0.tar.gz 
tar zxvf apr-util-1.6.1.tar.gz
mv apr-1.7.0 apr
mv apr-util-1.6.1 apr-util
cd ..

# make prefix path 
[ ! -d ${Path_install} ] && mkdir -p ${Path_install}
[ ! -d ${Path_install} ] && echo "[Error] not have install directory"

./configure  \
--prefix=${Path_install} \
--with-mpm=event \
--with-crypto \
--with-included-apr \
--enable-deflate \
--enable-rewrite \
--enable-static-rotatelogs \
--enable-so \
--enable-ssl && \
make

sudo make install

# change owner & auth
sudo chown root ${Path_install}/bin/httpd
sudo chmod u+s ${Path_install}/bin/httpd

# download site.
# http://apache.mirror.cdnetworks.com/apr/
# http://archive.apache.org/dist/httpd/
