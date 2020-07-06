### 1. 依赖环境

- Cent OS 7 +
- docker 18.03 +
- docker-compose 1.21 +

### 2. 安装步骤

```shell
# 获取软件安装包
git clone git@git.leaniot.cn:product/monitor.git

# 切换分支
git checkout alone-monitor

#创建docker网络
docker network create monitor

# 进入部署目录
cd monitor

# 启动部署脚本
bash deploy.sh [ 环境 主机IP 主机名 ]
```

### 3. 说明

#### 3.1. 产品包含组件

- grafana：图形展示

- prometheus：监控

- alertmanager：报警

- alone-alert：钉钉报警

- node-exporter：主机监控

- cadvisor：容器监控

- blackbox-exporter：网络监控

- portainer：容器管理

#### 3.2. 挂载信息（docker volume）

- grafana：grafana_data
- prometheus：prometheus_data
- portainer：portainer_data

#### 3.3. 网络信息（docker network）

- monitor：external: true

#### 3.4. 目录介绍

```
monitor/
├── alone-alert                         // 钉钉报警webhook服务目录
├── conf
│   ├── alertmanager.yml				// alertmanager报警配置
│   ├── grafana.ini						// grafana配置
│   └── prometheus.yml					// prometheus配置
├── deploy.sh							// 部署脚本
├── docker-compose.yml					// 主程序文件
├── moni_temp							// grafana模板
│   ├── HTTP_TCP_ICMP监控.json
│   ├── Windows监控.json
│   ├── 主机监控.json
│   └── 容器监控.json
├── readme.md
├── rules
│   ├── hoststats-alert.rules			// 主机报警规则配置	
│   └── networkstats-alet.rules			// 网络报警规则配置
├── sd_config
│   ├── cadvisor.yml					// 容器监控配置
│   ├── http_mos.yml					// http监控配置
│   ├── icmp.yml						// icmp监控配置
│   ├── node.yml						// Linux主机监控配置
│   ├── tcp.yml							// tcp监控配置
│   └── windows.yml						// Windows主机监控配置
└── secret
    ├── grafana_password				// grafana登陆密码
    └── portainer_password				// portainer登陆密码
```

### 4. 配置

#### 4.1 监控配置

- 监控信息配置

> 在sd_config目录下添加相应监控内容（如需要监控主机信息，则在node.yml添加上主机即可）

#### 4.2 报警配置

- 报警规则配置

>在rules目录下添加相应报警规则

- 报警信息配置

>在conf/alertmanger.yml中添加相应报警信息

#### 4.3 被监控服务器配置

- 监控组件配置

>添加node_exporter和cadvisor等监控组件

##### 相关链接

[prometheus教程](https://github.com/yunlzheng/prometheus-book)

[grafana模板大全](https://grafana.com/grafana/dashboards?orderBy=name&direction=asc)

