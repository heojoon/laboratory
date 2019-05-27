# Laboratory class 01 - Cache

## Description
 I think that I had to demonstrate or verify various features or configurations of the software.
So I need environments that are easy and fast enough to meet those needs.
Because the docker is a skill sufficient to meet these requirements, proceed to the docker.

## Architecture
- ( case 1 ) Web-Cache - WEB - WAS(clustering)  - Data-Cache - DB
- ( case 2 ) Web-cache - WEB - WAS(sessiong db) - Data-Cache - DB
                   
## Requirements
 - docker 18.0.x
 - docker-composer

## Components
 - WEB : nginx x.x
 - WAS : tomcat 8.0.x
 - DB : oracle 11g-xe (2018-02-21 확인 결과 업데이트가 안된다. github 내려가 있음)
 - DB : mysql (mysql로 변경)
 - Web-cache : varnish x.x
 - Data-cache : redis x.x

## Chater 1
- Goal : 기본적으로 4티어 구조에서 data cache 사용시와 미사용시의 퍼포먼스 차이 확인
- Note 
2019-03-12 테스트 시나리오가 필요하다. 그렇기 위해서는 DB에 데이터를 넣어야 하는데 사용 할만한 소스가.. java로 되어있어야 하는데..
오픈소스를 좀 뒤저봐야겠음

