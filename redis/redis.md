## Redis 설치

### 설치

* 설치 디렉토리 : /app/sol/redis-버전
* 데이터(work) 디렉토리 : /app/sol/redis/data
* log 디렉토리 : /app/sol/redis/log
* conf 디렉토리 : /app/sol/redis/conf
* bin 디렉토리 : /app/sol/redis/bin

> 참고 : https://redis.io/topics/quickstart

1. 다운로드 및 컴파일

   ~~~bash
   cd ~	# 홈디렉토리 이동 (다운로드 위치)
   wget http://download.redis.io/redis-stable.tar.gz
   tar xvzf redis-stable.tar.gz
   cd redis-stable
   make
   ~~~

   

2. 디렉토리 생성

   ~~~bash
   mkdir /app/sol/redis-6.2.6
   cd /app/sol/
   ln -s redis-6.2.6 redis
   cd redis
   mkdir bin conf data log
   ~~~

   

3. 필수 파일 복사

   ~~~bash
   # 다운로드 받은 경로로 이동
   cd ~/redis-stable
   
   # config 파일 복사
   cp redis.conf /app/sol/redis/conf/
   
   # 실행 파일 복사
   cd src
   cp redis-benchmark redis-check-aof redis-check-rdb redis-cli redis-server /app/sol/redis/bin/
   
   # redis service 복사 및 등록
   cd ../utils
   cp redis_init_script /etc/init.d/redis
   chkconfig --add redis
   ~~~

   

4. 환경 설정 (redis.conf)

   - 필수 설정 지시자

   ~~~bash
   bind 0.0.0.0
protected-mode yes
port 6379
daemonize yes
supervised auto
pidfile "/var/run/redis_6379.pid"
dir "/app/sol/redis/data"
logfile "/app/sol/redis/log/redis_6379.log"
requirepass "PASSWORD"
appendonly yes
appendfsync everysec
save 300 100
stop-writes-on-bgsave-error no
   ~~~

   > 디스크 백업 방식은 appendonly + RDB 방식 사용

   

5. 구동 스크립트 (/etc/init.d/redis) 

   * USER="nxtwmsadm" 으로만 구동하도록 추가

   ~~~bash
   #!/bin/sh
   #
   # Simple Redis init.d script conceived to work on Linux systems
   # as it does use of the /proc filesystem.
   
   ### BEGIN INIT INFO
   # Provides: redis_6379
   # Default-Start: 2 3 4 5
   # Default-Stop: 0 1 6
   # Short-Description: Redis data structure server
   # Description: Redis data structure server. See https://redis.io
   ### END INIT INFO
   
   REDISPORT=6379
   EXEC=/app/sol/redis/bin/redis-server
   CLIEXEC=/app/sol/redis/bin/redis-cli
   
   PIDFILE=/var/run/redis_${REDISPORT}.pid
   CONF="/app/sol/redis/conf/redis.conf"
   USER="nxtwmsadm"
   
   case "$1" in
   start)
     if [ -f $PIDFILE ]; then
       echo "$PIDFILE exists, process is already running or crashed"
     else
       echo "Starting Redis server..."
       if [ $(id -u) != $(id -u ${USER}) ]; then
         echo "Error, run user : ${USER}"
         exit 0
       else
         $EXEC $CONF
       fi
     fi
     ;;
   stop)
     if [ ! -f $PIDFILE ]; then
       echo "$PIDFILE does not exist, process is not running"
     else
       PID=$(cat $PIDFILE)
       echo "Stopping ..."
       $CLIEXEC -p $REDISPORT shutdown
       while [ -x /proc/${PID} ]; do
         echo "Waiting for Redis to shutdown ..."
         sleep 1
       done
       echo "Redis stopped"
     fi
     ;;
   *)
     echo "Please use start or stop as first argument"
     ;;
   esac
   ~~~

   

6. 시작 방법

   ~~~bash
   # 구동
   [nxtwmsadm@Dnxtwmswas bin]$ service redis start
   Starting Redis server...
   
   # 프로세스 확인
   [nxtwmsadm@Dnxtwmswas bin]$ ps -ef |grep redis | grep -v grep
   nxtwmsa+ 16931 1 0 14:41 ? 00:00:00 /app/sol/redis/bin/redis-server 0.0.0.0:6379
   ~~~

   

7. 종료 방법

   * auth 패스워드 설정을 하였을 경우 , 반드시 인증(auth)을 통해 접속 후, redis server 엔진을 내려줘야 한다.

   ~~~bash
   # redis 접속 및 종료
   [nxtwmsadm@Dnxtwmswas bin]$ ./redis-cli
   127.0.0.1:6379> auth nxtwms123!
   OK
   127.0.0.1:6379> shutdown
   not connected> quit
   ~~~

   ::unlock: 인증 패스워드 : nxtwms123!



### 튜닝

> redis 정식 홈페이지 : https://redis.io/topics/admin
>
> redisgate korea : http://redisgate.kr/redis/configuration/redis_start.php

* 대용량 메모리 페이지 설정  Transparent Huge Pages (THP) 

~~~bash
echo naver > /sys/kernel/mm/transparent_hugepage/enabled

# 확인
cat /sys/kernel/mm/transparent_hugepage/enabled
always madvise [naver]

# 부팅시 적용
/etc/default/grub 설정 파일 수정
- GRUB_CMDLINE_LINUX 값 끝부분에 transparent_hugepage=never 추가

# 적용
grub2-mkconfig -o /boot/grub2/grub.cfg

~~~

>리눅스에서는 대량 메모리를 할당하기 위해서 거대 페이지(huge page)를 사용합니다. Huge pages는 부팅 시 할당해야 합니다. 리눅스에서는 이를 효과적으로 관리하기 위해서 Transparent Huge Pages (THP)를 도입했습니다.  THP는 huge pages의 생성, 관리, 사용의 대부분을 자동화하는 추상화 계층입니다. 그런데 메모리를 많이 사용하는 서버 소프트웨어에서는 성능을 저하시키는 요인이 되기도 합니다.
>
>레디스에서는 필요에 따라 자식 프로세스를 생성해서 데이터를 디스크에 저장하는데 이때 메모리 페이지 복제가 발생하면, Hage pages는 메모리를 많이 사용하는 요인이 되고, 성능을 느리게 만듭니다.  그래서 THP를 사용하지 않게(disable) 설정합니다.

* virtual memory overcommit 커널 설정

~~~bash
sysctl -w vm.overcommit_memory=1
~~~

​	0 - Heuristic overcommit handling.
​	1 - Always overcommit.
​	2 - Don't overcommit.

* TCP Backlog 커널 설정

TCP backlog는 레디스 서버의 초당 클라이언트 연결 개수입니다.   TCP backlog 즉, **somaxconn**은 네크워크 관련 커널 파라미터로서 listen()으로 바인딩 된 서버 소켓에서 accept()를 기다리는 소켓 개수(queue)입니다.

~~~bash
 sysctl -w net.core.somaxconn=4096
 sysctl -w net.ipv4.tcp_max_syn_backlog=4096
~~~

* 재부팅 후에도 커널 설정 적용 

  ~~~bash
  # 파일에 추가
  vi /etc/sysctl.conf
  ---------------------------------------------
  vm.overcommit_memory = 1
  net.core.somaxconn = 4096
  net.core.netdev_max_backlog = 4096
  net.ipv4.tcp_max_syn_backlog = 4096
  ---------------------------------------------
  
  # 바로 적용
  sysctl -p
  ~~~

  

* 최대 접속 클라이언트 (open file ) , 최대 프로세스 수량 조정

~~~bash
$ vi /etc/security/limits.conf
* soft nofile 65536
* hard nofile 65536
* soft noproc 65536
* hard noproc 65536
~~~



### RDB , AOF 차이점

> 참고 : https://hoooon-s.tistory.com/25

RDB (Redis Database)

- 특정시점(snapshot)의 메모리에 있는 데이터 전체를 바이너리 파일로 저장
- AOF 파일보다 사이즈가 작다. 따라서 로딩 속도가 AOF 보다 빠르다. 
- 저장 시점은 redis.conf 에서 save 파라미터로 설정
  - save 900 1 : 900초 동안 1번 이상 key 변경 발생 시 저장
  - save 300 10 : 300초 동안 10번 이상 key 변경 발생시 저장
  - save 조건은 여러 개 지정 가능, 모두 or 조건. 즉, 하나라도 만족하면 수행

AOF (Append Only File)

* appendonly.aof 파일에 기록
* 입력/수정/삭제 명령이 실행될 때 마다 기록된다. 

