#! /bin/bash
# By jiangran
# Time: 2020-07-06
# 只支持CentOS 7+

usage() {
    echo "请按如下格式执行"
    echo "USAGE: bash $0 服务器IP 环境 服务器名"
    echo "USAGE: bash $0 10.10.10.12 测试环境 ceshi-ceshi"
    exit 1
}

#入口
if [ $# -lt 3 ]
then
    usage
fi

# 安装提示
echo -ne "\\033[0;33m"
cat<<EOT
prometheus监控系统安装说明：
    1. 此脚本只作用与首次安装的时候批量修改一些配置文件
    2. 首次安装成后请修改sd_config下的配置文件进行定制化监控，然后重启prometheus容器
    3. sd_config配置文件说明
        3.1 node.yml 服务器状态监控（linux）
        3.2 windows.yml 服务器状态监控（windows）
        3.3 cadvisor.yml 容器状态监控（linux）
        3.4 icmp.yml ping监控
        3.5 tcp.yml tcp服务监控
        3.6 http_mos.yml http服务监控
        注： http服务监控较多，可以按照不同主机或者业务拆分成多个yml文件，拆分格式http_xxx.yml
    4. 如果需要监控windows机器需要进行额外安装
    5. 欢迎使用prometheus监控系统
EOT
echo -ne "\\033[m"

read -s -n1 -p "按任意键继续 ... "

#定义一些函数
function check_ip() {
    IP=$1
    if [[ $IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        FIELD1=$(echo $IP|cut -d. -f1)
        FIELD2=$(echo $IP|cut -d. -f2)
        FIELD3=$(echo $IP|cut -d. -f3)
        FIELD4=$(echo $IP|cut -d. -f4)
        if [ $FIELD1 -le 255 -a $FIELD2 -le 255 -a $FIELD3 -le 255 -a $FIELD4 -le 255 ]; then
            ok "IP $IP available."
        else
            err "IP $IP 校验失败,请确认拿下你的IP格式是不是合法的!"
        fi
    else
        err "请输入格式正确的内网IP!"
    fi
}

err () {
   # 打印错误消息, 并返回非0
   # 屏幕输出使用红色字体
   echo "$(red_echo $@)"
   return 1
}

ok () {
   # 打印标准输出(绿色消息), 说明某个过程执行成功, 状态码为0
   echo "$(green_echo $@)"
   return 0
}

log () {
   # 打印消息, 并记录到日志, 日志文件由 LOG_FILE 变量定义
   echo "$(blue_echo $@)"
   return 0
}

red_echo ()      { echo -e "\033[031;1m$@\033[0m"; }
green_echo ()    { echo -e "\033[032;1m$@\033[0m"; }
yellow_echo ()   { echo -e "\033[033;1m$@\033[0m"; }
blue_echo ()     { echo -e "\033[034;1m$@\033[0m"; }

# 创建 docker 网络
NET_NAME=monitor
net_flag=`docker network ls | grep -w $NET_NAME | wc -l`
if [ $NET_NAME -eq 0 ]; then
    docker network create $NET_NAME
fi

# 校验IP合法性
MONI_IP=$2
check_ip $MONI_IP

MINENAME=$1
HOSTNAME=$3

# =============== 修改配置文件 ===============
sed -i s/192.168.1.79/$MONI_IP/g $PWD/sd_config/*.yml
sed -i s/高河测试/$MINENAME/g $PWD/sd_config/*.yml
sed -i s/gaohe-test2/$HOSTNAME/g $PWD/sd_config/*.yml
sed -i s/高河测试/$MINENAME/g $PWD/conf/alertmanager.yml

# =============== 启动服务 ===============
docker-compose up -d

# =============== grafana安装饼图插件 ===============
docker exec -it grafana sh -c 'grafana-cli plugins install grafana-piechart-panel'
docker restart grafana

[ $? -eq 0 ] &&  ok "ok: prometheus监控系统安装完成！" || err "error: prometheus监控系统安装失败！"