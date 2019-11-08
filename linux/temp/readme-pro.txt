生产环境自动化部署步骤
1.进入部署脚本所在目录
  例：cd ~/project/DailyReport/deploy-config/
2.执行脚本文件
  fab -f dailyreport-pro.py deploy:pro

部署前的准备工作
I.关闭监控脚本，杀死项目Java进程
  关闭监控脚本：
    sudo crontab -e   (例如，显示如下)
      #
      # For more information see the manual pages of crontab(5) and cron(8)
      #
      # m h  dom mon dow   command
      */15 * * * * bash /home/user/launch-script/monitor.sh
    将monitor.sh所在行注释掉，如下
      #
      # For more information see the manual pages of crontab(5) and cron(8)
      #
      # m h  dom mon dow   command
      # */15 * * * * bash /home/user/launch-script/monitor.sh
    部署完成后，需依上述步骤，恢复上述修改，打开监控脚本

  杀死项目Java进程：
    sudo lsof -i:9999 (例如，显示如下)
      COMMAND  PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
      java    1590 root   29u  IPv6  18303      0t0  TCP *:9999 (LISTEN)
    得到PID为1590，杀死此进程
      sudo kill -9 1590

II.软件需求
  1.服务器软件需求 (172.26.20.233)
    ssh (生产环境已安装)
      安装命令：sudo apt-get install openssh-server
      ssh免密登录：
        获取密钥：ssh-keygen -t rsa (若`~.ssh`目录下没有`id_rsa.pub`文件)
        传送公钥：ssh-copy-id -i ~/.ssh/id_rsa.pub user@172.26.20.233
    dtach (生产环境已安装)
        安装：sudo apt-get install dtach

  2.执行脚本文件的服务器软件需求
    maven (生产环境未安装)
      安装：sudo apt-get install maven
    python (系统默认安装)
    python组件fabric (生产环境未安装)
      安装pip: sudo apt-get install python-pip
      安装fabric: sudo pip install fabric

说明：
  脚本执行完成，不意味着部署成功，jar包的部署是后台执行，需等会儿
