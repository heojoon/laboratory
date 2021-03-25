# MySQL MHA 



## 1. 구성 스펙

- MACBOOK 위에 VM1 (svr1), VM2 (svr2)
- 10.211.55.5 manager
  - CentOS7 minimal

* 10.211.55.6 svr1
  * Centos7 minimal

- 10.211.55.7 svr2
  - Centos7 minimal



## 2. 테스트 환경 구성

* **HOST에 아이피 등록 **
  테스트 아이피 변경이나 테스트의 직관성을 위하여 내 PC (MacBook) 과 각 VM (svr1,2)의 hosts 파일에  아이피를 이름으로 등록

~~~bash
sudo su 
echo "10.211.55.5 mha" >> /etc/hosts
echo "10.211.55.6 svr1" >> /etc/hosts
echo "10.211.55.7 svr2" >> /etc/hosts
~~~



* **SSH 패스워드 없이 로그인하기** (*MACBOOK 유저와 서버 유저가 동일해야함*)

~~~bash
# SVR 1번 서버 접속
ssh hjoon@svr1

cd ~					
mkdir .ssh 			# 만약 없으면 디렉토리 생성, 있으면 건너뛰기
chmod 700 .ssh


# 암호키 생성 (공개키/개인키)
ssh-keygen -t rsa			# 엔터 3번 눌러서 계속 default로 진행

# 공개키를 서버에 등록
cat id_rsa.pub >> authorized_keys
chmod 600 authorized_keys

# 개인키를 내 PC에 복사 
cat id_rsa # 클립보드에 복사
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABlwAAAAdzc2gtcn
NhAAAAAwEAAQAAAYEAocice0gNir8rRGWuAFXad4DYKajv085iPOGt7ZLFIM8dzjOsraVS
Em9zX3t0s1N8LLMMpxY8iFibKoXjniAAQlzLRVGBUUV5e5ZYHI30tpKb9eQqcSWx
  ......
YTEyznKZPpvilcoIz0l29W1eNlgb8VcxjS4WJN15QVkAb7BQT42pmEPKhdzWUFHXXeK+Lv
9FuDM59X7h+eDWospk3t14X2uXJUlvsXGRG9/DGGdfYDBphjGQJp17qDmYYW84x5jp7ocb
tx9adiEvTYkiclAAAACmhqb29uQHN2cjE=
-----END OPENSSH PRIVATE KEY-----
~~~




* **내 PC에서 각 서버 접속 테스트**

~~~bash
# 내 맥북에서 개인키를 붙여넣기 (터미널을 하나 더 열고 작업)
cd ~/.ssh
vi id_rsa #<- 개인키 붙여넣기
chmod 600 id_rsa

# 접속 확인 
ssh. svr1
~~~



* **2번 서버 작업**

~~~bash
ssh hjoon@svr2
cd ~					
mkdir .ssh 			# 만약 없으면 디렉토리 생성, 있으면 건너뛰기
chmod 700 .ssh

# svr1 의 공개키를 authorized_keys 로 추가/생성

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQChyJx7SA2KvytEZa4AVdp3gNgpqO/TzmI84a3tksUgzx3OM6ytpVIp7uonPJ7HekVSxLtQ9p648DnK896HOkr/Wzy5rjOzd3yXAIrwuzdmRAPUw2UQDgJHI30irwYk3KFLoAauune1qS9a1p0qQfE5uJ3UWYIE= hjoon@svr2" >> authorized_keys

chmod 600 authorized_keys

# 1번, 2번 접속 SSH 패스워드 없이 로그인 설정 완료!!
~~~




## 3. MySQL 설치
* MySQL 8 버전을 다운로드

~~~bash
https://dev.mysql.com/downloads/file/?id=489467 접속 후 다운로드


~~~



* MySQL8 설치하기 (1번, 2번 서버 동일)

~~~bash
# Repository 등록
sudo yum install  mysql80-community-release-el7-3.noarch.rpm

# repolist 확인
yum repolist enabled | grep "mysql.*-community.*"
yum repolist all | grep mysql

# EL8 Only (EL8-based systems such as RHEL8 and Oracle Linux 8 include a MySQL module that is enabled by default)
sudo yum -y module disable mysql

# Install
sudo yum -y install mysql-community-server

sudo systemctl start mysqld
sudo systemctl enable mysqld
systemctl status mysqld
~~~



* **MySQL root 패스워드 확인 및 변경**

  MySQL 초기 패스워드를 확인해서 root로 로그인 한 후 , 패스워드를 변경

~~~bash
sudo grep 'temporary password' /var/log/mysqld.log

2021-03-12T15:25:20.361076Z 6 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: Oh2+s2nGlusX

mysql -uroot -p"Oh2+s2nGlusX"

# mysql>
ALTER USER 'root'@'localhost' IDENTIFIED BY 'Password_1234';
~~~





## 4. MySQL Replication

* svr1 서버

  * 디렉토리 생성 

  ~~~bash
  mkdir /var/log/mysql
  chown mysql:mysql /var/log/mysql
  ~~~

  * /etc/my.cnf 편집



~~~bash
[mysqld]

datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock

log-error=/var/log/mysql/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid

## Replication Settings
server-id=1
log-bin=/var/lib/mysql/binlog
sync_binlog=1
binlog_cache_size=2M
binlog_format=ROW
max_binlog_size=512M
expire_logs_days=7
log-bin-trust-function-creators=1

# Current hostname 
report-host=svr1 

relay-log=/var/log/mysql/mysqld_relay.log
relay-log-index=/var/log/mysql/mysqld_relay_log.index
relay_log_purge=off
expire_logs_days=7
log_slave_updates=ON
~~~

* systemctl restart mysqld

  

* svr2 서버
  
  - 디렉토리 생성

~~~bash
mkdir /var/log/mysql
chown mysql:mysql /var/log/mysql
~~~



- /etc/my.cnf 편집

~~~bash
[mysqld]

datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock

log-error=/var/log/mysql/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid

## Replication Settings
server-id=2
log-bin=/var/lib/mysql/binlog
sync_binlog=1
binlog_cache_size=2M
binlog_format=ROW
max_binlog_size=512M
expire_logs_days=7
log-bin-trust-function-creators=1

# Current hostname 
report-host=svr2

relay-log=/var/log/mysql/mysqld_relay.log
relay-log-index=/var/log/mysql/mysqld_relay_log.index
relay_log_purge=off
expire_logs_days=7
log_slave_updates=ON
~~~

* systemctl restart mysqld



* Replication 전용 유저 생성 (svr1,2)

~~~sql
mysql> 
use mysql
create user 'repl_user'@'%' identified by 'Repl_user1234';
grant replication slave on *.* to 'repl_user'@'%';
flush privileges;
~~~



* Replication 설정 확인 (마스터)

~~~sql
mysql>
show master status\G

*************************** 1. row ***************************
             File: binlog.000005
         Position: 156
     Binlog_Do_DB:
 Binlog_Ignore_DB:
Executed_Gtid_Set:
1 row in set (0.00 sec)
~~~



* 슬레이브 (File 값과 Position 값 입력 )

~~~sql
mysql>
CHANGE MASTER TO MASTER_HOST='svr1', MASTER_USER='repl_user', 
MASTER_PASSWORD='Repl_user1234',
MASTER_LOG_FILE='binlog.000001',
MASTER_LOG_POS=156;

start slave;

show slave status\G

~~~



* Root 패스워드 변경

~~~sql
mysql>
alter user 'root'@'localhost' identified with mysql_native_password by 'Password_1234';
create user 'root'@'%' identified by 'Password_1234';
grant all on *.* to 'root'@'%';
flush privileges;
~~~



* 접속 테스트

~~~bash
mysql -urepl_user -p"Repl_user1234" -h svr1
mysql -urepl_user -p"Repl_user1234" -h svr2
~~~



* Slave 정상 동작 확인

~~~
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: svr1
                  Master_User: repl_user
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: binlog.000006
          Read_Master_Log_Pos: 156
               Relay_Log_File: mysqld_relay.000002
                Relay_Log_Pos: 321
        Relay_Master_Log_File: binlog.000006
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB:
          Replicate_Ignore_DB:
           Replicate_Do_Table:
       Replicate_Ignore_Table:
      Replicate_Wild_Do_Table:
  Replicate_Wild_Ignore_Table:
                   Last_Errno: 0
                   Last_Error:
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 156
              Relay_Log_Space: 527
              Until_Condition: None
               Until_Log_File:
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File:
           Master_SSL_CA_Path:
              Master_SSL_Cert:
            Master_SSL_Cipher:
               Master_SSL_Key:
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error:
               Last_SQL_Errno: 0
               Last_SQL_Error:
  Replicate_Ignore_Server_Ids:
             Master_Server_Id: 1
                  Master_UUID: 27cc7000-8347-11eb-8c13-001c42f0922e
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp:
               Master_SSL_Crl:
           Master_SSL_Crlpath:
           Retrieved_Gtid_Set:
            Executed_Gtid_Set:
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name:
           Master_TLS_Version:
       Master_public_key_path:
        Get_master_public_key: 0
            Network_Namespace:
1 row in set, 1 warning (0.01 sec)
~~~





* 복제 정상 동작 확인
  - svr1 

~~~sql
mysql>
create database testdb;
use testdb;

create table `test_tb`(
	`no` int(11) NOT NULL,
    `name` char(255),
    `tel` char(255),
    primary key (`no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8

use testdb;
show tables;
+------------------+
| Tables_in_testdb |
+------------------+
| test_tb          |
+------------------+
desc test_tb;
+-------+-----------+------+-----+---------+-------+
| Field | Type      | Null | Key | Default | Extra |
+-------+-----------+------+-----+---------+-------+
| no    | int       | NO   | PRI | NULL    |       |
| name  | char(255) | YES  |     | NULL    |       |
| tel   | char(255) | YES  |     | NULL    |       |
+-------+-----------+------+-----+---------+-------+

insert into test_tb values(1,"hjoon","010-1234-1234");
insert into test_tb values(2,"kim","011-1234-1234");
insert into test_tb values(3,"park","012-1234-1234");

select * from test_tb;
~~~



* 복제 여부 확인 (svr2)

~~~sql
use testdb;
desc test_tb;
select * from test_tb;
~~~



* 터미널에서 쿼리 날리기

~~~bash
echo "select * from testdb.test_tb" | mysql -uroot -p"Password_1234" -h svr1
echo "select * from testdb.test_tb" | mysql -uroot -p"Password_1234" -h svr2
~~~



>! 잊지마세요 !
>
>MySQL Slave DB 를 재시작 할 경우 정상적으로 복제가 되는지 확인하고 안되고 있다면 "start slave" 명령을 수행해야한다  



## 5. MHA 구성

* MHA 는 CentOS7 에 설치했다.
* mysql el7버전을 다운로드해서 설치했다. Client 사용을 위해서...



### 5.1. 매니저 설치

* 매니저 설치 (<u>노드 선행 설치 필수</u>)

~~~bash
## Install dependent Perl modules
sudo yum install -y perl-DBD-MySQL 
sudo yum install -y perl-Config-Tiny 
sudo yum install -y perl-Log-Dispatch 
sudo yum install -y perl-Parallel-ForkManager
sudo yum -y install perl-devel perl-CPAN

yum install perl-DBD-MySQL \
perl-Config-Tiny perl-Log-Dispatch \
perl-Parallel-ForkManager \
perl-Log-Dispatch perl-Time-HiRes \
perl-CPAN perl-Module-Install

wget https://github.com/yoshinorim/mha4mysql-manager/releases/download/v0.58/mha4mysql-manager-0.58.tar.gz

cd mha4mysql-manager-0.58
perl Makefile.PL
make
sudo make install

~~~

  

* **EPEL 설치**
  - CentOS8

~~~bash
sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
~~~

  CentOS7

~~~bash
rpm -ivh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
~~~



### 5.2. 노드 설치

~~~bash
sudo yum -y install wget


 wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/mysql-master-ha/mha4mysql-node-0.54.tar.gz

wget https://github.com/yoshinorim/mha4mysql-node/releases/download/v0.58/mha4mysql-node-0.58.tar.gz


tar -zxf mha4mysql-node-0.54.tar.gz

cd mha4mysql-node-0.54




sudo yum -y install perl-devel perl-CPAN
perl Makefile.PL
make
sudo make install


~~~



* 심볼릭 링크 생성
  * 대상 : 마스터 서버, 슬레이스 서버 (매니저 서버 제외)
    mysql 와 mysqlbinlog 파일이 아래 경로에 없다면 root 유저로 심볼릭 링크를 설정 해줍니다.

~~~bash
ls -al /usr/bin/mysqlbinlog
ls -al /usr/local/bin/mysql

ln -s /bin/mysql /usr/local/bin/mysql
~~~



* 필요 디렉토리 생성 및 파일 복사 ( 매니저 서버)

~~~bash
mkdir -p /app/mha
mkdir -p /mha/scripts

cd /home/hjoon/mha4mysql-manager-0.58/samples
cp conf/* /app/mha/
cp scripts/* /mha/scripts/
~~~



* 모든 서버에서 작업 실행

~~~bash
mkdir -p /mha/app1
chown -R mha:mysql /mha
~~~



### 5.3 OS 환경 설치

* mha 유저 생성 (매니저,서버1,서버2)

  ~~~bash
  # OS 유저생성
  useradd mha
  echo "Password_1234" | passwd --stdin mha
echo "mha     ALL=NOPASSWD:   ALL" >> /etc/sudoers
  
  # mysql group에 mha 유저 추가
  usermod -G mysql mha
  ~~~
  
  -> **mha** 계정으로 매니저 , 서버1 , 서버2  SSH 패스워드 없이 접속해야한다. (필수)
  
  * 매니저 서버
  
    ~~~bash
    [mha@mha .ssh]$ pwd
    /home/mha/.ssh
    [mha@mha .ssh]$ ls
    authorized_keys  id_rsa  known_hosts
    ~~~
  
  * 서버1
  
    ~~~bash
    [mha@svr1 .ssh]$ pwd
    /home/mha/.ssh
    [mha@svr1 .ssh]$ ls
    authorized_keys  id_rsa  known_hosts
    ~~~
  
  * 서버2
  
    ~~~bash
    [mha@svr2 .ssh]$ pwd
    /home/mha/.ssh
    [mha@svr2 .ssh]$ ls
    authorized_keys  id_rsa  known_hosts
    ~~~
  
    
  
  
  
* mha DB 계정 생성

  ~~~sql
  create user 'mha'@'%' identified by 'Password_1234';
  alter user 'mha'@'%' identified with mysql_native_password by 'Password_1234';
  grant all on *.* to 'mha'@'%';
  flush privileges;
  ~~~
~~~
  
  

### 5.4 MHA 구조 설치

---

* 디렉토리 생성
  환경 설정 파일과 스크립트 파일, 로그 위치를 지정합니다

* 환경설정 디렉토리 위치

  - 매니저 서버

    ~~~bash
    mkdir /app/mha
    mkdir -p /mha/app1 /mha/scripts
    chown mha /app/mha
    chown mha:mysql /mha/app1 /mha/scripts
~~~
  - 서버1
  
    ~~~bash
    mkdir -p /mha/app1
    chown mha:mysql /mha/app1
    ~~~
  
  - 서버2
  
      ~~~bash
      mkdir -p /mha/app1
      chown mha:mysql /mha/app1
      ~~~



### 5.5. 매니저 서버 환경설정 

---

* **/etc/mha/app1.cnf** 

~~~bash
## mysql user and password
user=mha
password=Password_1234
ssh_user=mha

repl_user=repl_user
repl_password=Repl_user1234

## MHA manager info
manager_workdir=/mha/app1
manager_log=/mha/app1/app1.log

## Remote server info
remote_workdir=/mha/app1
master_binlog_dir=/var/lib/mysql

## master
#master_ip_online_change_script=/masterha/scripts/master_ip_online_change

## Secondary Host Connect Check
secondary_check_script=/usr/local/bin/masterha_secondary_check -s svr1 -s svr2 --user=mha --master_host=svr1 --master_ip=svr1 --master_port=3306

#master_ip_failover_script=/masterha/scripts/master_ip_failover

## Health Check interval
ping_interval=3

## Log level
log_level=debug


[server1]
hostname=svr1
candidate_master=1

[server2]
hostname=svr2
candidate_master=1
~~~



## 6. MHA 구성 정상 확인

### 6.1 SSH 접속 테스트

- mha 계정으로 매니저서버 -> 서버1,서버2 , 서버1 -> 서버2 , 서버2 ->서버1 를 테스트 한다

~~~bash
[mha@mha mha]$ masterha_check_ssh --conf=/app/mha/app1.cnf
~~~

~~~bash
Tue Mar 16 22:30:09 2021 - [warning] Global configuration file /etc/masterha_default.cnf not found. Skipping.
Tue Mar 16 22:30:09 2021 - [info] Reading application default configuration from /app/mha/app1.cnf..
Tue Mar 16 22:30:09 2021 - [info] Reading server configuration from /app/mha/app1.cnf..
Tue Mar 16 22:30:09 2021 - [info] Starting SSH connection tests..
Tue Mar 16 22:30:09 2021 - [debug]
Tue Mar 16 22:30:09 2021 - [debug]  Connecting via SSH from mha@svr1(10.211.55.6:22) to mha@svr2(10.211.55.7:22)..
Tue Mar 16 22:30:09 2021 - [debug]   ok.
Tue Mar 16 22:30:10 2021 - [debug]
Tue Mar 16 22:30:09 2021 - [debug]  Connecting via SSH from mha@svr2(10.211.55.7:22) to mha@svr1(10.211.55.6:22)..
Tue Mar 16 22:30:09 2021 - [debug]   ok.
Tue Mar 16 22:30:10 2021 - [info] All SSH connection tests passed successfully.
~~~



### 6.2  DB 구성 완료 테스트

- 지금까지 환경 설정을 매니저 서버에서 각 서버에 SSH 접속, MySQL DB 접속이 가능하도록 한 구성이기 때문에 아래 체크를 매니저 서버에서 원격으로 수행 가능하다

~~~bash
# replication 확인
echo "show master status" | mysql -uroot -p"Password_1234" -h svr1
echo "show slave status\G" | mysql -uroot -p"Password_1234" -h svr2

# mha(mysqldb user) 확인
echo "show databases" | mysql -umha -p"Password_1234" -h svr1
echo "show databases" | mysql -umha -p"Password_1234" -h svr2

# repl_user 확인
echo "show databases" | mysql -urepl_user -p"Repl_user1234" -h svr1
echo "show databases" | mysql -urepl_user -p"Repl_user1234" -h svr2

# 데이터 확인
echo "select * from testdb.test_tb" | mysql -uroot -p"Password_1234" -h svr1
echo "select * from testdb.test_tb" | mysql -uroot -p"Password_1234" -h svr2

# 정상 복제 확인
echo "insert into testdb.test_tb values(4,\"Lee\",\"013-1234-1234\")" | mysql -uroot -p"Password_1234" -h svr1
echo "select * from testdb.test_tb" | mysql -uroot -p"Password_1234" -h svr1
echo "select * from testdb.test_tb" | mysql -uroot -p"Password_1234" -h svr2

echo "insert into testdb.test_tb values(5,\"mee\",\"013-1234-1234\")" | mysql -uroot -p"Password_1234" -h svr1
echo "select * from testdb.test_tb" | mysql -uroot -p"Password_1234" -h svr1
echo "select * from testdb.test_tb" | mysql -uroot -p"Password_1234" -h svr2



mysql: [Warning] Using a password on the command line interface can be insecure.
no	name	tel
1	hjoon	010-1234-1234
2	kim	011-1234-1234
3	park	012-1234-1234
4	Lee	013-1234-1234
~~~

위와 같이 나오면 접속 및 복제에 관련 된 모든 사항은 준비 완료이다.



> [ 트러블 슈팅 ] 
>
> MySQL 8.0 부터는 인증 방식이 변경 되었다 아래와 같은 에러메시지가 뜨면 my.cnf 파일에 한줄 추가한다 
>
> 이미 만든 유저는 패스워드를 변경해야한다 (참고2)
>
> flush privileges 명령 잊지 마세요

```bash
# 인증 방식 선택
default-authentication-plugin=mysql_native_password
```

~~~bash
Tue Mar 16 23:09:40 2021 - [debug] Got MySQL error when connecting svr2(10.211.55.7:3306) :2059:Authentication plugin 'caching_sha2_password' cannot be loaded: /usr/lib64/mysql/plugin/caching_sha2_password.so: cannot open shared object file: No such file or directory
~~~

~~~bash
# 참고2
alter user 'mha'@'%' identified with mysql_native_password by 'Password_1234';
flush privileges;
~~~



### 6.3 MHA Replication 모니터링 테스트

---

* **MHA 구동**

  ~~~bash
  nohup masterha_manager --conf=/app/mha/app1.cnf &
  ~~~


* Replication 상태 확인

  ~~~bash
  masterha_check_repl --conf=/app/mha/app1.cnf
  ~~~

  ~~~bash
  (중략)
  Wed Mar 17 00:37:00 2021 - [info]
  svr1(10.211.55.6:3306) (current master)
   +--svr2(10.211.55.7:3306)
  
  Wed Mar 17 00:37:00 2021 - [info] Checking replication health on svr2..
  Wed Mar 17 00:37:00 2021 - [info]  ok.
  Wed Mar 17 00:37:00 2021 - [warning] master_ip_failover_script is not defined.
  Wed Mar 17 00:37:00 2021 - [warning] shutdown_script is not defined.
  Wed Mar 17 00:37:00 2021 - [debug]  Disconnected from svr1(10.211.55.6:3306)
  Wed Mar 17 00:37:00 2021 - [debug]  Disconnected from svr2(10.211.55.7:3306)
  Wed Mar 17 00:37:00 2021 - [info] Got exit code 0 (Not master dead).
  
  MySQL Replication Health is OK.
  ~~~

  

* 모니터링 상태 확인

  ~~~bash
  masterha_check_status --conf=/app/mha/app1.cnf
  ~~~
  
  ~~~bash
  app1 (pid:4016) is running(0:PING_OK), master:svr1
  ~~~
  
  


* 모니터링 정지

  ~~~bash
  masterha_stop --conf=/app/mha/app1.cnf
  ~~~

  ~~~bash
  Stopped app1 successfully.
  [1]+  Exit 1                  nohup masterha_manager --conf=/app/mha/app1.cnf
  ~~~

  

* 마스터 DB 강제 변경

  ~~~bash
  masterha_master_switch -
  ~~~




### 6.4 FailOver 테스트

~~~bash
# replication 확인
echo "show master status\G" | mysql -uroot -p"Password_1234" -h svr1
echo "show slave status\G" | mysql -uroot -p"Password_1234" -h svr2 | egrep -i "(Master_Log_File|Read_Master_Log_Pos|Relay_Master_Log_File|Slave_IO_Running|Slave_SQL_Running)"
~~~







## 참고

- MHA 스크립트 정리 까지 있음 :  https://m.blog.naver.com/kkhkykkk2/220659814573

* [MHA 구동, 그림 및 Fail-Over 정리](https://khj93.tistory.com/entry/MHA-MHA-%EA%B5%AC%EC%84%B1-%EB%B0%8F-%EC%84%A4%EC%B9%98-DB%EC%9D%B4%EC%A4%91%ED%99%94-Fail-Over-%ED%85%8C%EC%8A%A4%ED%8A%B8)

