#!/bin/bash -e

# 自动监控mysql服务，服务不存在自动执行重启操作
# date: 2019-11-04

# 步骤：
#  1. 启动数据库 `sudo service mysql start`
#  2. 切换目录 `cd /home/user/deploy/DailyReport`
#  3. 启动服务 `nohup java -jar jar包名称 &`

#     例如：`nohup java -jar dailyreport-0.0.1-SNAPSHOT.jar &`

#   测试项：
#      打开微信 - 发现 - 群硕软件 - 日报 - 填写日报

. /etc/profile

#日志输出
MysqlMonitorLog=/tmp/MysqlMonitor.log
RabbitMqMonitorLog=/tmp/RabbitMqMonitorLog.log
NginxMonitorLog=/tmp/NginxMonitorLog.log
RedisMonitorLog=/tmp/RedisMonitorLog.log
DailyReportMonitorLog=/tmp/DailyReportMonitorLog.log

MonitorMysql() {
	echo "-------------------------[`date "+%Y-%m-%d %H:%M:%S"`]------------------------"
	echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] 开始监控Mysql..."
	pgrep -x mysqld &> /dev/null
	if [ $? -ne 0 ]
	then
		echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] Mysql没有启动. "
		echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] 正在自动启动Mysql，请稍等..."
		sudo service mysql start
	else
		echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] Mysql已经正常运行中."
	fi
}

# sudo service rabbitmq-server status
MonitorRabbitMq() {
	echo "-------------------------[`date "+%Y-%m-%d %H:%M:%S"`]------------------------"
	echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] 开始监控RabbitMq..."
	rabbitmqStatus=$(sudo service rabbitmq-server status)
	echo $rabbitmqStatus

	if [[ $rabbitmqStatus == *'Error: unable to connect to node'* ]]; then
		echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] RabbitMq 没有启动. "
		echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] 正在重启RabbitMq，请稍等..."
		sudo service rabbitmq-server start
	else
		echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] RabbitMq 已经正常运行中."
	fi
}

# sudo service nginx status
MonitorNginx() {
	echo "-------------------------[`date "+%Y-%m-%d %H:%M:%S"`]------------------------"
	echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] 开始监控Nginx..."
	nginxStatus=$(sudo service nginx status)
	echo $nginxStatus

	if [[ $nginxStatus == *'Active: active (running)'* ]]; then
		echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] Nginx 已经正常运行中."
	else
		echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] Nginx 没有启动. "
		echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] 正在重启Nginx，请稍等..."
		sudo service nginx start
	fi
}

# sudo service redis-server status
MonitorRedis() {
	echo "-------------------------[`date "+%Y-%m-%d %H:%M:%S"`]------------------------"
	echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] 开始监控Redis..."
	nginxStatus=$(sudo service redis-server status)
	echo $nginxStatus

	if [[ $nginxStatus == *'Active: active (running)'* ]]; then
		echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] Redis 已经正常运行中."
	else
		echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] Redis 没有启动. "
		echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] 正在重启Redis，请稍等..."
		sudo service redis-server start
	fi
}

# sudo service dailyReport status
MonitorDailyReport() {
	echo "-------------------------[`date "+%Y-%m-%d %H:%M:%S"`]------------------------"
	echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] 开始监控DailyReport..."

    java_pid = $("lsof -i:9999 | awk '{print $2}'| awk -F: 'NR==2{print}'")
    if [[java_pid != '']]; then
        echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] DailyReport 已经正常运行中."
	else
		echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] DailyReport 没有启动. "
		echo "[info][`date "+%Y-%m-%d %H:%M:%S"`] 正在重启DailyReport，请稍等..."
		nohup java -jar /home/user/deploy/DailyReport/dailyreport-0.0.1-SNAPSHOT.jar > /dev/null 2>&1 &
	fi
}

MonitorMysql>>$MysqlMonitorLog
MonitorRabbitMq>>$RabbitMqMonitorLog
MonitorNginx>>$NginxMonitorLog
MonitorRedis>>$RedisMonitorLog
MonitorDailyReport>>$DailyReportMonitorLog