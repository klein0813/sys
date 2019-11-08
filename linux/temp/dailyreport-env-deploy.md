## linux: vue + springboot jdk8 jpa mysql redis rabbitmq

### 工具准备
```
`node.js`环境（npm包管理器）
`vue-cli` 脚手架构建工具
`cnpm`  npm的淘宝镜像
```

### npm run dev执行顺序
-> `npm run` 其实执行了`package.json`中的`script`脚本<br>
-> 底层相当执行`webpack-dev-server --inline --progress --config build/webpack.dev.conf.js`命令<br>
-> `build/webpack.dev.conf.js`文件中`require ./webpack.base.conf`文件，并且合并入新的对象配置（可以参考webpack-marge）<br>
-> `./webpack.base.conf`文件中设置项目入口`main.js`


### 多环境配置
webpack根据不同的环境打包（`npm run build -- xx`）
路径：`/build/build.js`
```
process.env.NODE_ENV = process.argv.splice(2)[0]
````
例：`npm run build -- testing`

### eslint配置：
位置：`/build/webpack.base.conf.js`
```
const createLintingRule = () => ({
  test: /\.(js|vue)$/,
  loader: 'eslint-loader',
  enforce: 'pre',
  include: [resolve('src'), resolve('test')],
  options: {
    formatter: require('eslint-friendly-formatter'),
    emitWarning: !config.dev.showEslintErrorsInOverlay
  }
})

module: {
    rules: [
       ...(config.dev.useEslint ? [createLintingRule()] : [])
    ]
}
```

### 离线安装 mysql
> 下载
```
https://dev.mysql.com/downloads/file/?id=490089
```

> 安装
<pre>
sudo dpkg -i mysql-common_8.0.18-1ubuntu16.04_amd64.deb
sudo dpkg -i mysql-community-client-core_8.0.18-1ubuntu16.04_amd64.deb
sudo dpkg -i mysql-community-client_8.0.18-1ubuntu16.04_amd64.deb
sudo dpkg -i mysql-client_8.0.18-1ubuntu16.04_amd64.deb
sudo dpkg -i mysql-community-server-core_8.0.18-1ubuntu16.04_amd64.deb
</pre>
https://pkgs.org/download/libaio1

* Update the package index
```
sudo apt-get update
```
* Install libaio1 deb package
```
sudo apt-get install libaio1
sudo apt-get -f install
```
<pre>
sudo dpkg -i mysql-community-server_8.0.18-1ubuntu16.04_amd64.deb
sudo dpkg -i libmysqlclient21_8.0.18-1ubuntu16.04_amd64.deb
sudo dpkg -i libmysqlclient-dev_8.0.18-1ubuntu16.04_amd64.deb
</pre>

> 数据库初始化
<p>数据库名不要引号</p>


### 离线安装 maven
> 下载
```
http://mirror.bit.edu.cn/apache/maven/maven-3/3.6.2/binaries/
```

> 安装
<p>减压压缩到安装目录</p>

> 配置
* 路径：`/etc/profile`
```
export M2_HOME=/opt/apache-maven-3.6.2
export PATH=${JAVA_HOME}/bin:${M2_HOME}/bin:$PATH
```
* 重启或执行 `source /etc/profile` 使配置生效

### 安装 ssh (For auto deploy)
> 安装
```
sudo apt-get install openssh-server
```

> 配置 ssh 免密登录<br>
* 将生成的公钥传至目的主机: `ssh-copy-id -i ~/.ssh/id_rsa.pub username@hosts`
```
:ssh-copy-id -i ~/.ssh/id_rsa.pub t04839@192.168.22.35

/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/t04839/.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
t04839@192.168.22.35's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 't04839@192.168.22.35'"
and check to make sure that only the key(s) you wanted were added.
```

### 离线安装 ngnix
> 安装
```
wget http://nginx.org/download/nginx-1.13.7.tar.gz
tar zxvf nginx-1.13.7.tar.gz
# nginx 文件目录下执行
./configure
make
make install
```

> 配置
* 使用给予的配置文件 nginx.conf
```
user user; #文件第一行 => useradd user #需要增加user用户

注释掉虚拟主机配置(依实际情况而定)
	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;

注意：
mime.types 与 mime.types 文件实际路径保持一致
？？？server.listen 与 application.properties里的 h5 port 保持一致
server.root 与 dailyreport-frontend 的实际部署路径保持一致
access_log 和 error_log 路径与实际路径保持一致，且可读可写
```

> 启动
* `/usr/local/nginx/sbin ./nginx`

> 重启
* `/usr/local/nginx/sbin ./nginx -s reload`

> 常见命令
```
罗列出与nginx相关的软件: dpkg --get-selections|grep nginx
查看nginx正在运行的进程: ps -ef |grep nginx
```

### 安装 redis
> 安装 
```
sudo apt-get install redis-server
```
检查Redis服务器系统进程: `pa -aux|grep redis`

### 安装 rabbitmq
> 安装
```
apt-get install erlang
apt-get install rabbitmq-server
```

> 添加管理用户
```
sudo rabbitmqctl add_user admin yourpassword
```

> 分配管理员角色 
```
sudo rabbitmqctl set_user_tags admin administrator
```

> 授权
```
rabbitmqctl set_permissions -p "/" admin ".*" ".*" ".*"
```

> 打开web管理
```
sudo rabbitmq-plugins enable rabbitmq_management
```

### 安装 dtach (For auto deploy)
```
sudo apt-get install dtach
```

### 报错：
> maven
* The JAVA_HOME environment variable is not defined correctly.
This environment variable is needed to run this program.
NB: JAVA_HOME should point to a JDK not a JRE
```
执行：:~$ mvn -v
原因：JAVA_HOME路径配置错误
sudo vim /etc/profile => 修改JAVA_HOME路径
source /etc/profile
```

> nginx
* nginx: [error] invalid PID number "" in "/usr/local/nginx/logs/nginx.pid"
```
./nginx -c /usr/local/nginx/conf/nginx.conf
```

* nginx: [emerg] unknown directive "ssl_protocols" in /usr/local/nginx/conf/nginx.conf
```
配置ssl_protocols
去nginx解压目录下执行
./configure --with-http_ssl_module
make
将原来 nginx 备份
cp /usr/local/nginx/sbin/nginx /usr/local/nginx/sbin/nginx.bak
将新的 nginx 覆盖旧安装目录
cp -rfp objs/nginx /usr/local/nginx/sbin/nginx
```

### basis
> rabbitmq

默认端口 15672
http://127.0.0.1:15672

Listening ports
<table class="list">
  <tbody><tr>
    <th>Protocol</th>
    <th>Bound to</th>
    <th>Port</th>
  </tr>
  <tr class="alt1">
    <td>amqp</td>
    <td>::</td>
    <td>5672</td>
  </tr>
  <tr class="alt2">
    <td>clustering</td>
    <td>::</td>
    <td>25672</td>
  </tr>
</tbody></table>

> linux command
* 查看端口情况： `lsof -i:9999`
* 杀死进程(pid): `sudo kill -9 9999`

### 留存
* 自动化部署执行：`fab -f dailyreport.py deploy:staging`
```
python
python组件：fabric
maven(135没有安装, 远程自动化部署时，远程服务器可不安装)
dtash(135没有安装)
```

* 全自动化部署<br>
需设置ssh免密登录

* nginx 服务器的 启动不在自动化部署中
```
启动 nginx: /usr/local/nginx/sbin ./nginx
```

* npm run build -- staging
```
process.env.NODE_ENV = process.argv.splice(2)[0] === 'staging' ? 'testing' : process.argv.splice(2)[0]
```
