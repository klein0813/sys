#!/bin/bash -e

# 自动监控Apache服务，服务不存在自动执行重启操作 并添加8013到80端口的映射
# date: 2019-11-07

#   测试项：
#      访问：http://its.resource.augmentum.com.cn:8013/its/

#日志输出
MonitorLog=/tmp/MonitorLog.log

# ps -ef |grep apache2 |grep -w 'apache2'|grep -v 'grep'|awk '{print $2}'
# sudo /usr/share/apache2/bin/apachectl restart
MonitorApache() {
	echo "-------------------------[`date "+%Y-%m-%d %H:%M:%S"`]------------------------"

	echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] 开始监控apache..."	
	ApacheID=$(ps -ef |grep apache2 |grep -w 'apache2'|grep -v 'grep'|awk '{print $2}')
	echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] 当前apache进程ID：$ApacheID"

	if [ -n "$ApacheID" ];then
		echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] 当前apache已经启动，继续监测是否运行正常..."
	else
		echo "[error][`date "+%Y-%m-%d %H:%M:%S"`] 当前apache没有启动，开始重启apache..."
		sudo /usr/share/apache2/bin/apachectl restart
	fi
	
}

# sudo iptables -t nat -L | grep -w '8013' | grep -w '80'
# sudo iptables -t nat -A PREROUTING -p tcp --dport 8013 -j REDIRECT --to-port 80
MonitorMapping() {
	echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] 开始监控8013到80端口的映射..."
	MappingInfo=$(sudo iptables -t nat -L | grep -w '8013' | grep -w '80')
        echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] 映射信息: $MappingInfo"

  	if [[ $MappingInfo != '' ]]; then
        	echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] 8013到80端口的映射已完成."
   	else
        	echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] 8013到80端口的映射未完成."
		echo "[error][`date "+%Y-%m-%d %H:%M:%S"`] 开始做8013端口映射到80端口..."
		sudo iptables -t nat -A PREROUTING -p tcp --dport 8013 -j REDIRECT --to-port 80
    	fi
}

MonitorApache>>$MonitorLog
MonitorMapping>>$MonitorLog
