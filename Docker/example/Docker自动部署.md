## 目录

- [安装依赖](#安装依赖)
  - [CentOS](#CentOS)
  - [Ubuntu/Debian](#Ubuntu/Debian)
- [安装脚本](#下载脚本并执行)
- [使用说明](#使用说明)
  - [运行脚本](#运行脚本)
  - [文件位置](#文件位置)
  - [镜像加速](#镜像加速)
    - [Ubuntu 14.04、Debian 7 Wheezy](#Ubuntu 14.04、Debian 7 Wheezy)
    - [Ubuntu 16.04+、Debian 8+、CentOS 7](#Ubuntu 16.04+、Debian 8+、CentOS 7)
- [问题与处理](#问题与处理)
  - [提示1](#提示1`xxx is not in the sudoers file.  This incident will be reported. `)
  - [提示2](#提示2  `wget: command not found`错误)

## 安装依赖

### CentOS

```bash
$ sudo yum install -y wget vim 
```

### Ubuntu/Debian

```bash
# 更新源
$ sudo apt-get update
# 执行安装
$ sudo apt-get install -y wget vim
```

## 下载脚本并执行

```bash
$ sudo wget -N --no-check-certificate https://raw.githubusercontent.com/0079123/myBusiness/master/Docker/shell/Docker.sh && chmod +x Docker.sh && bash Docker.sh
```

默认情况下， `docker`命令会使用 [Unix socket](https://en.wikipedia.org/wiki/Unix_domain_socket) 与 Docker 引擎通讯。而只有`root`用户和`docker` 组的用户才可以访问 Docker 引擎的 Unix socket。出于安全考虑，一般 Linux 系统 上不会直接使用`root`用户。因此，更好地做法是将需要使用`docker` 的用户加入 `docker` 用户组。 

注`ubuntu`  `Debian` 系列需要手动添加

```bash
$ sudo groupadd docker
# username 填写本机用户名
$ sudo usermod -aG docker username
```

## 使用说明

### 运行脚本

```bash
sudo bash Docker.sh
```

```bash
请输入一个数字来选择选项
1. 安装 Docker
2. 卸载 Docker
————————————————————
3. 启动 Docker 
4. 停止 Docker
5. 重启 Docker
6. 设置开机自启
————————————————————
7. 创建 Nginx
8. 创建 Tomcat
9. 创建 Mysql
————————————————————
0.退出菜单
————————————————————
当前状态: 已安装 并 已启动
请输入数字 [0-9]:
```

### 文件位置

安装目录：`/usr/bin/docker`

文件目录：`/var/lib/docker`

配置文件：`/etc/sysconfig/docker  `

### 镜像加速

鉴于国内网络被墙，拉取Docker镜像十分缓慢，建议安装Docker后配置 

国内从 Docker Hub 拉取镜像有时会遇到困难，此时可以配置镜像加速器。Docker 官方和国 内很多云服务商都提供了国内加速器服务，例如： 

- [Docker 官方提供的中国 registry mirror](https://docs.docker.com/registry/recipes/mirror/#use-case-the-china-registry-mirror)
- [DaoCloud 加速器 ](https://www.daocloud.io/mirror#accelerator-doc)
- [阿里云加速器](https://account.aliyun.com/login/login.htm?oauth_callback=https%3A%2F%2Fcr.console.aliyun.com%2F#/accelerator)

以 Docker 官方加速器为例

#### Ubuntu 14.04、Debian 7 Wheezy

对于使用 [upstart](http://upstart.ubuntu.com/) 的系统而言，编辑` /etc/default/docker `文件，在其中的 DOCKER_OPTS 中 添加获得的加速器配置： 

```bash
DOCKER_OPTS="--registry-mirror=https://registry.docker-cn.com"
```

重新启动服务。 

```bash
sudo service docker restart
```



#### Ubuntu 16.04+、Debian 8+、CentOS 7

对于使用 [systemd](https://www.freedesktop.org/wiki/Software/systemd/) 的系统，请在` /etc/docker/daemon.json `中写入如下内容（如果文件不存 在请新建该文件） 

```json
{
	"registry-mirrors": [
		"https://registry.docker-cn.com"
	]
}
```

- 注：一定要保证该文件符合 json 规范，否则 Docker 将不能启动。 

之后重新启动服务。 

```bash
$ sudo systemctl daemon-reload
$ sudo systemctl restart docker
```

## 问题与处理

### 提示1`xxx is not in the sudoers file.  This incident will be reported. ` 

这是由于Linux默认没有为当前

用户开启sudo权限！

执行命令

```bash
$ su
$ visudo
```

或者编辑 `/etc/sudoers `文件

```bash
# 找到下面的一行： 
root  ALL=(ALL) ALL
# 在该行下添加 ，xxx 为本机用户名
xxx   ALL=(ALL) ALL
```

### 提示2  `wget: command not found`错误

是你的系统精简的太干净了，wget都没有安装，所以需要安装wget。 查看[依赖](#安装依赖)