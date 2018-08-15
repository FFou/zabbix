https://blog.csdn.net/foxbillcsdn/article/details/80680786

docker搭建zabbix


本次使用docker搭建zabbix的组合是mysql+docker+zabix-server
1 先安装数据库mysql


sudo docker run --name zabbix-mysql-server --hostname zabbix-mysql-server \
-e MYSQL_ROOT_PASSWORD="123456" \
-e MYSQL_USER="zabbix" \
-e MYSQL_PASSWORD="123456" \
-e MYSQL_DATABASE="zabbix" \
-p 3306:3306  \
-d mysql:5.7 \
--character-set-server=utf8 --collation-server=utf8_bin


2 创建zabbix-server


sudo docker run  --name zabbix-server-mysql --hostname zabbix-server-mysql \
--link zabbix-mysql-server:mysql \
-e DB_SERVER_HOST="mysql" \
-e MYSQL_USER="zabbix" \
-e MYSQL_DATABASE="zabbix" \
-e MYSQL_PASSWORD="123456" \
-v /etc/localtime:/etc/localtime:ro \
-v /data/docker/zabbix/alertscripts:/usr/lib/zabbix/alertscripts \
-v /data/docker/zabbix/externalscripts:/usr/lib/zabbix/externalscripts \
-p 10051:10051 \
-d \
zabbix/zabbix-server-mysql


3 最后web-nginx


最后安装zabbix-web-nginx
sudo docker run --name zabbix-web-nginx-mysql --hostname zabbix-web-nginx-mysql \
--link zabbix-mysql-server:mysql \
--link zabbix-server-mysql:zabbix-server \
-e DB_SERVER_HOST="mysql" \
-e MYSQL_USER="zabbix" \
-e MYSQL_PASSWORD="123456" \
-e MYSQL_DATABASE="zabbix" \
-e ZBX_SERVER_HOST="zabbix-server" \
-e PHP_TZ="Asia/Shanghai" \
-p 8000:80 \
-p 8443:443 \
-d \
zabbix/zabbix-web-nginx-mysql


4.登录访问测试


浏览器访问ip:8000查看
默认登录
username:Admin
password:zabbix
这里说明下，mysql没做数据卷的映射，nginx也没做数据卷的映射，在实际生产环境下，最好做数据映射。防止数据丢失。


docker-zabbbix-agent的安装以及链接zabbix-server
docker run --name zabbix-agent --link zabbix-server-mysql:zabbix-server -d zabbix/zabbix-agent:latest
最后需要在web端将，zabbix-agent添加到zabbix-server的host列表里面。
