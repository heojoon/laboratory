# nginx Advanced Configuration

1. 특정 request에 대응하는 backend 서버 확인 (access_log 설정에 $upstream_addr 추가)
~~~
log_format main ' $remote_addr - $remote_user [$time_local] "$request" '
                        ' $status $body_bytes_sent "$http_referer" '
                        ' "$http_user_agent" "$http_x_forwarded_for" "$upstream_addr" ';
~~~

