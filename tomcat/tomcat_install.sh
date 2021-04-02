#!/bin/bash

#
# tomcat 8.5.x Install script v0.2
#

#
# You need root privileges to run this script.
# Run as the root directly or non-root user with root privileges.  (ex. in sudoer file)
#

# Custom variables
Owner="hanse"

Tomcat_Version="8.5.64"
pathInstall="/app/was"
pathDownload="/home/${Owner}"
downFile="apache-tomcat-${Tomcat_Version}.tar.gz"
srcDownUrl="https://downloads.apache.org/tomcat/tomcat-8/v${Tomcat_Version}/bin/${downFile}"

# Already installed apache directory path
pathApacheInstalled="/app/web/apache"

# Path Check
fn_pathCheck() {
    if [ -e "${pathInstall}/apache-tomcat-${Tomcat_Version}" ];then
        echo "[Error] Already Installed in ${pathInstall}/apache-tomcat-${Tomcat_Version}"
        exit 0
    fi

    if [ ! -e ${pathApacheInstalled} ] ;then
        echo "[Error] Directory : ${pathApacheInstalled} is not exist !!"
        echo -n "Do you want Create Directory ? (y|n) : " ; read answer
        case ${answer} in
            y|Y)
                mkdir -p ${pathApacheInstalled} ;;
            n|N)
                exit 0 ;;
            *)
                exit 0 ;;
        esac
    else
        if [ ! -e ${pathInstall} ];then
            echo "[Error] Directory : ${pathInstall} is not exist !!"
            echo -n "Do you want Create Directory ? (y|n) : " ; read answer
            case ${answer} in
            y|Y)
                mkdir -p ${pathInstall} ;;
            n|N)
                exit 0 ;;
            *)
                exit 0 ;;
            esac
        fi
    fi
}

fn_insTomcat() {
    cd ${pathInstall}
    curl -O ${srcDownUrl}
    tar zxvf ${downFile} -C ${pathInstall}
    chown -R ${Owner}:${Owner} ${pathInstall}
    rm -f ${downFile}
}

# Install tomcat-connector
fn_insTomcatCon() {
    cd ${pathDownload}
    curl -O "https://archive.apache.org/dist/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.48-src.tar.gz"
    tar zxvf tomcat-connectors-1.2.48-src.tar.gz
    cd tomcat-connectors-1.2.48-src/
    cd native
    ./buildconf.sh
    ./configure --with-apxs=${pathApacheInstalled}/bin/apxs  && make && make install
}

fn_removeDownfile() {
    cd ${pathInstall}
    rm ${downFile}

    cd ${pathDownload}
    rm tomcat-connectors-1.2.48-src.tar.gz
    rm tomcat-connectors-1.2.48
}

fn_pathCheck
fn_insTomcat
fn_insTomcatCon
fn_removeDownfile
