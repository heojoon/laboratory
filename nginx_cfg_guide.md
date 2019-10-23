# nginx Advanced Configuration

1. 특정 request에 대응하는 backend 서버 확인 (access_log 설정에 $upstream_addr 추가)
~~~
log_format main ' $remote_addr - $remote_user [$time_local] "$request" '
                        ' $status $body_bytes_sent "$http_referer" '
                        ' "$http_user_agent" "$http_x_forwarded_for" "$upstream_addr" ';
~~~

2. nginx 로드밸런싱 설정

2.1. R/R (기본)
2.2. Server Weights

특정 서버에 가중치를 줄 경우 다음과 같이 weight(기본 1) 항목을 설정. was1 서버에 5번 요청한 후에 was2 서버에 요청. backup 으로 지정된 서버는 메인 서버가 모두 다운일 경우에만 서비스.
~~~
upstream phpserver {       
        server was1-ip:1234 weight=5;
        server was2-ip:1234 ;
        server 192.0.0.1 backup;
}
~~~

3. least connection
가장 클라이언트 연결 갯수가 적은 서버로 전달하는 설정.
~~~
upstream backend {
    least_conn ;
    server was1-ip:8080 slow_start=30s;
    server was2-ip:1234;
    server 192.0.0.1 backup;
}
~~~

4. ip hash
클라이언트 IP 를 hash 해서 특정 클라이언트는 특정 서버로 연결하는 설정. 
~~~
upstream backend {
    ip_hash;
 
    server was1-ip:8080 slow_start=30s;
    server was2-ip:1234;
    server 192.0.0.1 backup;
}
~~~
