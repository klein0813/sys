# encoding=utf8
from fabric.api import *
from fabric.colors import green, blue, red
from fabric.contrib.files import exists
import time

environ_staging = {
    'name': 'staging',
    # 'hosts': ['user@192.168.22.113'],
    'hosts': ['user@192.168.22.135'],
    # 'proj_dir' : '~/develop/RoomBooking/',
    'proj_dir' : '~/project/DailyReport/',
    'deploy_dir' : '~/deploy/DailyReport/',
    'java_port' : 9999
}
environ_pro = {
    'name': 'pro',
    'hosts': ['user@172.26.20.233'],
    'proj_dir' : '~/project/DailyReport/',
    'deploy_dir' : '~/deploy/DailyReport/',
    'java_port' : 9999
}
environ_all = {
    'staging': environ_staging,
    'pro': environ_pro
}

environ = None

def deploy(environ_param):
    environs = ['staging', 'pro']
    if (environ_param not in environs):
        print red('environments parameters must be in ' + str(environs))
        abort('')

    # 根据命令行部署环境的参数来设定相关参数
    global environ
    environ = environ_all[environ_param]
    hosts = environ['hosts']
    execute(task_deploy, hosts=hosts)

def task_deploy():
    build();
    backup_last_deploy();
    copy_package_to_server();
    run_backend();

# 本地编译前后端代码
def build():
    with lcd(environ['proj_dir']):
        local('git reset --hard')
        local('git pull origin develop')
    # build frontend of web
    print green("begin to build frontend of web")
    with lcd(environ['proj_dir'] + 'dailyreport-frontend/'):
        local("cnpm install")
        local('npm run build -- %s' % (environ['name']))

    # 将文件夹notice和文件WW_verify_6axgCbLwLvYIp03X复制到dailyreport-frontend/dist/
    local('cp -r %sdeploy-config/notice %sdailyreport-frontend/dist/' % (environ['proj_dir'], environ['proj_dir']))
    local('cp %sdeploy-config/WW_verify_6axgCbLwLvYIp03X %sdailyreport-frontend/dist/' % (environ['proj_dir'], environ['proj_dir']))

    print green("build frontend of web success")

    # build frontend of wechat
    # print green("begin to build frontend of wechat")
    # with lcd(environ['proj_dir'] + 'roombooking-wechat/'):
    #     local("cnpm install")
    #     local('npm run build:%s' % (environ['name']))
    # print green("build frontend of wechat success")

    # build backend
    print green("begin to build backend")
    with lcd(environ['proj_dir'] + 'dailyReport-backend/'):
        local('mvn clean package -Dmaven.test.skip=true -P%s' % (environ['name']))
    print green("build backend success")

#备份上次的前后台打包文件到history文件夹
def backup_last_deploy():
    print green("begin to backup last deploy")
    with cd(environ['deploy_dir']):
        if(not exists('history')):
            run('mkdir history')
        #获取当前时间戳
        ts = str(time.time())
        #拷贝后端jar包
        if(exists('dailyreport-0.0.1-SNAPSHOT.jar')):
            run('cp dailyreport-0.0.1-SNAPSHOT.jar history/dailyreport-0.0.1-SNAPSHOT_%s.jar' % (ts))
        #拷贝前端文件
        run('pwd')
        if(exists('dailyreport-frontend')):
            run('cp -r dailyreport-frontend history/dailyreport-frontend_%s' % (ts))
        else:
            run('mkdir dailyreport-frontend')
    print green("backup last deploy success")

# 拷贝打包文件到服务器
def copy_package_to_server():
    print green("begin to copy package to server")
    with cd(environ['deploy_dir']):
        run('rm -rf dailyreport-frontend/*')
        # run('rm -rf nginx/www/wechat/*')
    with lcd(environ['proj_dir']):
        put(environ['proj_dir'] + 'dailyReport-backend/target/dailyreport-0.0.1-SNAPSHOT.jar', environ['deploy_dir'])
        put(environ['proj_dir'] + 'dailyreport-frontend/dist', environ['deploy_dir'] + 'dailyreport-frontend')
        # put(environ['proj_dir'] + 'roombooking-wechat/dist/*', environ['deploy_dir'] + 'nginx/www/wechat/')
    print green("copy package to server success")

#java命令运行jar包
def run_backend():
    print green("begin to run backend")
    with cd(environ['deploy_dir']):
        #根据后台服务端口号来获得进程id
        java_pid = run("lsof -i:%s | awk '{print $2}'| awk -F: 'NR==2{print}'" % (environ['java_port']))
        if (java_pid != ''):
            run('kill -9 %s' % java_pid)
        else:
            print red("SpringBoot-DailyReport is not running on: %s" % (environ['java_port']))
        #后台启动springboot项目
        _runbg('java -Dfile.encoding=UTF-8 -jar dailyreport-0.0.1-SNAPSHOT.jar --spring.profiles.active=%s' % (environ['name']))
    print green("run backend success")

#使用dtach运行后台命令，直接使用&模式不可行
def _runbg(cmd, sockname="dtach"):
    return run('dtach -n `mktemp -u /tmp/%s.XXXX` %s'  % (sockname,cmd))
