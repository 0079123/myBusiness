系统版本 ：`CentOS7 x64`

docker版本：`18.06.0-ce`

# 目录

- [拉取镜像](#拉取镜像)
- [创建容器](#创建容器)
  - [目录准备](#目录准备)
  - [初始化容器](#初始化容器)
- [查看容器](#查看容器)
- [部署本地项目](#部署本地项目)
- [Tomcat 容器删除](#Tomcat 容器删除)
- [配合 jenkins 部署](#配合 jenkins 部署)

## 拉取镜像

该镜像所在地址[Docker Hub](#https://hub.docker.com/_/tomcat/)打开该连接，默认展示 Repo info 标签页（该标签页中包含了一些操作该容器的方法）中的内容，如果想查看该image大小和各标签，可切换到 "Tags"标签页查看。

```bash
# 以tomcat 9为例
docker pull tomcat:9
```

## 创建容器

根据[Dockerfile](https://github.com/docker-library/tomcat/blob/1383c5549ee60522e76b37667c38b4cddc8bbc6d/9.0/jre10-slim/Dockerfile) 路径位于 `/usr/local/tomcat`

### 目录准备

```bash
mkdir -p /root/tomcat9/webapps
mkdir -p /root/tomcat9/logs
```

### 初始化容器

```bash
docker run --name tomcat9 -d \
	-v /root/tomcat9/webapps:/usr/local/tomcat/webapps \
	-v /root/tomcat9/logs:/usr/local/tomcat/logs \
	-v /etc/localtime:/etc/localtime:ro \
	-e TZ="Asia/Shanghai" \
	-p 8081:8080 tomcat:9
	
```

`--name` 容器命名为 tomcat9, 以后容器操作时用到; `-d` 以后台模式运行 

`webapps` 目录映射到本地, 方便后面的项目部署

`logs` 日志映射到本地, 方便查日志

时区调整, 不然时间可能会有点问题(还有catalina.out日志里的时间戳) 

`-p 8081:8080` 端口映射, 开放本地端口 `8081`, 以:`http://ip:8081` 访问 

`tomcat:9` 指定镜像以及标签版本

因为映射本地的`/root/tomcat9/webapps` 为空目录，所以访问`http://ip:8081`什么也没有

把这个去掉就可以访问tomcat的控制台页面了

## 查看容器

```bash
#查看正在运行的容器
docker ps
#查看已终止运行的容器
docker ps -a
#列出不运行的容器ID
docker ps -aq
```

## 部署本地项目

由于前面把部署的目录映射到本地了, 所以项目直接解压到本地的指定目录即可完成部署 

```bash
#先停掉tomcat
docker container start tomcat9

#删除原来的 项目
rm -rf /root/tomcat9/webapps/$PROJECT

# 手动解压war包 (也可以直接把 war 包丢到 webapps 下由tomcat解压)
unzip /tmp/$PROJECT-0.0.1-SNAPSHOT.war -d /root/tomcat9/webapps/$PROJECT

# 最后在启动tomcat
docker container start tomcat9
```

然后访问: `http://ip:8081/$PROJECT` 即可 

## Tomcat 容器删除

```bash
# 删除前需要先停下来
docker container start tomcat9

# 然后按容器名称删除
docker container rm tomcat9

#日志查看(已经映射到本地)
docker logs tomcat9
```

## 配合 jenkins 部署

直接做成脚本: `dev-deploy-docker.sh` 

```bash
#!/bin/sh
# author: hhyykk@outlook.com
# description: 自动部署war包到指定的内网docker服务器
# 1. mvn编译打包(jenkins完成)
# 2. scp到目标内网服务器, 并解压到指定目录
# 3. 重启docker tomcat容器


# 1
PROJECT=$1
HOST=192.168.7.251
WAR=$WORKSPACE/target/$PROJECT-0.0.1-SNAPSHOT.war

if [ ! -f "$WAR" ]; then
    echo "待发布的 war 包不存在：filepath=$WAR"
    exit 1
fi


# 3 scp war files
scp $WAR root@$HOST:/tmp
echo ".................... scp war files: $WORKSPACE/target/$PROJECT-0.0.1-SNAPSHOT.war "

# 4.docker container restart
ssh -tt root@$HOST <<EOF
    docker container stop tomcat8

    rm -rf /data/tomcat8/webapps/$PROJECT

    unzip /tmp/$PROJECT-0.0.1-SNAPSHOT.war -d /data/tomcat8/webapps/$PROJECT

    docker container start tomcat8

    exit
EOF
echo ".................... docker container restart tomcat8 "

```

![jenkins部署](C:\Users\user\Desktop\Docker\jenkins.png)