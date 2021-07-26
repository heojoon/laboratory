#!/usr/bin/bash

Domain="test.or.kr"
URL="https://${Domain}/main.do"

# 서버 IP 리스트
IP=( 192.168.0.30 192.168.0.31 192.168.0.32 192.168.0.33 192.168.0.34 192.168.0.35)
# 테스트할 메서드 종류
method=(GET POST PUT DELETE TRACE OPTIONS PATCH)

function changeHost() {
        var=$1
        sed -i -e "/${Domain}/ s/192.168.0.3[0-4]/${var}/g" /etc/hosts
}

function main() {
# 호스트 파일을 변경
for i in ${IP[*]};do
        echo "============================="
        echo "change hostfile ... $i"
        echo "============================="
        changeHost $i

        # 정상적으로 바뀌었는지 확인
        grep "${Domain}" /etc/hosts
        ping ${Domain} -c 3

        # 도메인 , 직접 WEB , 직접 WAS 메서드 테스트
        for u in ${URL} "http://$i" "http://$i:8080" ; do
                echo "============================="
                echo " $u "
                echo "============================="

                for i in ${method[*]};do
                        echo -n "Test method : $i  ........ "
                        curl -s -I -X $i ${URL} | grep -i "HTTP/1.1"
                done
        done
done
}

main
