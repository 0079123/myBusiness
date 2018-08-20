 

# 目录

[Docker CE 安装](#Docker CE 安装)

- [Ubuntu](#Ubuntu 安装 Docker CE)
- [CentOS](#CentOS 安装Docker CE)
- [Debian](#Debian 安装Docker CE)
- [Windows](#Windows 安装Docker CE)
- [macOS](#macOS 安装Docker CE)
- [树莓派](#树莓派安装 Docker CE)



# Docker CE 安装

## Ubuntu 安装 Docker CE 

### 准备工作 

#### 系统要求 

Docker CE 支持以下版本的 Ubuntu 操作系统： 

- Artful 17.10 (Docker CE 17.11 Edge)

-  Zesty 17.04 

- Xenial 16.04 (LTS)

-  Trusty 14.04 (LTS)

Docker CE 可以安装在 64 位的 x86 平台或 ARM 平台上。[Ubuntu](https://www.ubuntu.com/server) 发行版中，LTS（LongTerm-Support）长期支持版本，会获得 5 年的升级维护支持，这样的版本会更稳定，因此在 生产环境中推荐使用 LTS 版本,当前最新的 LTS 版本为 Ubuntu 16.04 。

#### 卸载旧版本 

旧版本的 Docker 称为 `docker` 或者 `docker-engine `，使用以下命令卸载旧版本： 

```bash
$ sudo apt-get remove docker \
	 docker-engine \
	 docker.io

```

#### Ubuntu 14.04 可选内核模块 

从 Ubuntu 14.04 开始，一部分内核模块移到了可选内核模块包 ( linux-image-extra-* ) ，以 减少内核软件包的体积。正常安装的系统应该会包含可选内核模块包，而一些裁剪后的系统 可能会将其精简掉。 AUFS 内核驱动属于可选内核模块的一部分，作为推荐的 Docker 存储层 驱动，一般建议安装可选内核模块包以使用 AUFS 。 

```bash
# 更新源
$ sudo apt-get update
#执行安装
$ sudo apt-get install \
	 linux-image-extra-$(uname -r) \
	 linux-image-extra-virtual

```

#### 使用 APT 安装 

由于 apt 源使用 HTTPS 以确保软件下载过程中不被篡改。因此，我们首先需要添加使用 HTTPS 传输的软件包以及 CA 证书。 

```bash
$ sudo apt-get update
$ sudo apt-get install \
	 apt-transport-https \
	 ca-certificates \
	 curl \
	 software-properties-common
```

鉴于国内网络问题，强烈建议使用国内源，官方源请在注释中查看。 为了确认所下载软件包的合法性，需要添加软件源的 GPG 密钥。 

```bash
$ curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
# 官方源
# $ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

### 安装 Docker CE 

更新 apt 软件包缓存，并安装 `docker-ce` ： 

```bash
$ sudo apt-get update

$ sudo apt-get install docker-ce
```

#### 使用脚本自动安装 

在测试或开发环境中 Docker 官方为了简化安装流程，提供了一套便捷的安装脚本，Ubuntu 系统上可以使用这套脚本安装： 

```bash
$ curl -fsSL get.docker.com -o get-docker.sh
 
$ sudo sh get-docker.sh --mirror Aliyun
```

执行这个命令后，脚本就会自动的将一切准备工作做好，并且把 Docker CE 的 Edge 版本安 装在系统中。 

#### 启动 Docker CE 

```bash
$ sudo systemctl enable docker

$ sudo systemctl start docker
```

Ubuntu 14.04 请使用以下命令启动： 

```bash
$ sudo service docker start
```

#### 建立 docker 用户组 

默认情况下， `docker `命令会使用 [Unix socket](https://en.wikipedia.org/wiki/Unix_domain_socket) 与 Docker 引擎通讯。而只有` root`用户和` docker` 组的用户才可以访问 Docker 引擎的 Unix socket。出于安全考虑，一般 Linux 系统 上不会直接使用` root `用户。因此，更好地做法是将需要使用` docker` 的用户加入 `docker` 用户组。 

建立 `docker` 组：

```bash
$ sudo groupadd docker
```

 将当前用户加入 ` docker` 组： 

```bash
$ sudo usermod -aG docker $USER
```

退出当前终端并重新登录，进行如下测试。 

### 测试 Docker 是否安装正确 

```bash
$ docker run hello-world

Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
ca4f61b1923c: Pull complete
Digest: sha256:be0cd392e45be79ffeffa6b05338b98ebb16c87b255f48e297ec7f98e123905c
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.
To generate this message, Docker took the following steps:

	1. The Docker client contacted the Docker daemon.
	2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
	   (amd64)
	3. The Docker daemon created a new container from that image which runs the
	   executable that produces the output you are currently reading.
	4. The Docker daemon streamed that output to the Docker client, which sent it
	   to your terminal.
	   
To try something more ambitious, you can run an Ubuntu container with:
  $ docker run -it ubuntu bash
 
Share images, automate workflows, and more with a free Docker ID:
  https://cloud.docker.com/

For more examples and ideas, visit:
  https://docs.docker.com/engine/userguide/
```

若能正常输出以上信息，则说明安装成功。 

### 镜像加速 

鉴于国内网络被墙，拉取Docker镜像十分缓慢，建议安装Docker后配置[国内镜像加速](#镜像加速器)



## CentOS 安装Docker CE

### 准备工作
#### 系统要求

Docker CE 支持 64 位版本 CentOS 7，并且要求内核版本不低于 3.10。 CentOS 7 满足最低 内核的要求，但由于内核版本比较低，部分功能（如 overlay2 存储层驱动）无法使用，并 且部分功能可能不太稳定。 

#### 卸载旧版本 

旧版本的 Docker 称为 `docker` 或者 `docker-engine` ，使用以下命令卸载旧版本： 

```bash
$ sudo yum remove docker \
	   docker-common \
	   docker-selinux \
	   docker-engine
```

####  使用 yum 安装 

执行以下命令安装依赖

```bash
$ sudo yum install -y yum-utils \
	  device-mapper-persistent-data \
	  lvm2
```

鉴于国内网络问题，强烈建议使用国内源，官方源请在注释中查看。 

执行下面的命令添加 `yum` 软件源： 

```bash
$ sudo yum-config-manager \
	  --add-repo \
	  https://mirrors.ustc.edu.cn/docker-ce/linux/centos/docker-ce.repo

# 官方源
# $ sudo yum-config-manager \
# --add-repo \
# https://download.docker.com/linux/centos/docker-ce.repo
```

如果需要最新版本的 Docker CE 请使用以下命令： 

```bash
$ sudo yum-config-manager --enable docker-ce-edge
```

如果需要测试版本的 Docker CE 请使用以下命令： 

```bash
$ sudo yum-config-manager --enable docker-ce-test
```

### 安装Docker CE

更新 `yum `软件源缓存，并安装` docker-ce` 

```bash
$ sudo yum makecache fast
$ sudo yum install docker-ce
```

#### 使用脚本自动安装 

在测试或开发环境中 Docker 官方为了简化安装流程，提供了一套便捷的安装脚本，CentOS 系统上可以使用这套脚本安装： 

```bash
$ curl -fsSL get.docker.com -o get-docker.sh
$ sudo sh get-docker.sh --mirror Aliyun
```

执行这个命令后，脚本就会自动的将一切准备工作做好，并且把 Docker CE 的 Edge 版本安 装在系统中。 

#### 启动 Docker CE 

```bash
$ sudo systemctl enable docker
$ sudo systemctl start docker
```

#### 建立 docker 用户组 

默认情况下， `docker `命令会使用 [Unix socket](https://en.wikipedia.org/wiki/Unix_domain_socket) 与 Docker 引擎通讯。而只有` root`用户和` docker` 组的用户才可以访问 Docker 引擎的 Unix socket。出于安全考虑，一般 Linux 系统 上不会直接使用` root `用户。因此，更好地做法是将需要使用` docker` 的用户加入 `docker` 用户组。 

建立 `docker` 组 :

```bash
$ sudo groupadd docker
```

将当前用户加入 `docker` 组： 

```bash
$ sudo usermod -aG docker $USER
```

退出当前终端并重新登录，进行如下测试。 

#### 测试 Docker 是否安装正确  

输入以下命令

```bash
$  docker run hello-world
```

若能正常输出信息，则说明安装成功。 

#### 镜像加速 

鉴于国内网络被墙，拉取Docker镜像十分缓慢，建议安装Docker后配置[国内镜像加速](#镜像加速器)



## Debian 安装Docker CE

### 准备工作

#### 系统要求

Docker CE 支持以下版本的 [Debian](https://www.debian.org/intro/about) 操作系统：

- Stretch 9 
- Jessie 8 (LTS)
-  Wheezy 7.7 (LTS) 

#### 卸载旧版本

旧版本的 Docker 称为` docker` 或者 `docker-engine` ，使用以下命令卸载旧版本：

```bash
$ sudo apt-get remove docker \
	  docker-engine \
	  docker.io
```

 #### Debian 7 Wheezy 

Debian 7 的内核默认为 3.2，为了满足 Docker CE 的需求，应该安装  [backports](https://backports.debian.org/Instructions/) 的内核。 

#### 使用 APT 安装

由于 apt 源使用 HTTPS 以确保软件下载过程中不被篡改。因此，我们首先需要添加使用 HTTPS 传输的软件包以及 CA 证书。



 Debian 8 Jessie 或者 Debian 9 Stretch 使用以下命令: 

```bash
$ sudo apt-get update
$ sudo apt-get install \
	  apt-transport-https \
	  ca-certificates \
	  curl \
	  gnupg2 \
	  lsb-release \
	  software-properties-common
```



 Debian 7 Wheezy 使用以下命令： 

```bash
$ sudo apt-get update
$ sudo apt-get install \
	  apt-transport-https \
	  ca-certificates \
	  curl \
	  lsb-release \
	  python-software-properties
```

鉴于国内网络问题，强烈建议使用国内源，官方源请在注释中查看 。

为了确认所下载软件包的合法性，需要添加软件源的 GPG 密钥。 

```bash
$ curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/debian/gpg | sudo apt-key add -

# 官方源
# $ curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
```

然后，我们需要向 `source.list `中添加 Docker CE 软件源： 

```bash
$ sudo add-apt-repository \
	"deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/$(. /etc/os-release;
echo "$ID") \
	$(lsb_release -cs) \
	stable"


# 官方源
# $ sudo add-apt-repository \
# "deb [arch=amd64] https://download.docker.com/linux/debian \
# $(lsb_release -cs) \
# stable"
```

以上命令会添加稳定版本的 Docker CE APT 镜像源，如果需要最新或者测试版本的 Docker CE 请将 stable 改为 edge 或者 test。从 Docker 17.06 开始，edge test 版本的 APT 镜像源也会包含稳定版本的 Docker CE。 

#### Debian 7 需要进行额外的操作： 

编辑` /etc/apt/sources.list `将 deb-src 一行删除或者使用 # 注释。 

```bash
deb-src [arch=amd64] https://download.docker.com/linux/debian wheezy stable
```



### 安装Docker CE

更新 apt 软件包缓存，并安装 `docker-ce `。

```bash
$ sudo apt-get update
$ sudo apt-get install docker-ce
```

 使用脚本自动安装 

在测试或开发环境中 Docker 官方为了简化安装流程，提供了一套便捷的安装脚本，Debian 系统上可以使用这套脚本安装： 

```bash
$ curl -fsSL get.docker.com -o get-docker.sh
$ sudo sh get-docker.sh --mirror Aliyun
```

执行这个命令后，脚本就会自动的将一切准备工作做好，并且把 Docker CE 的 Edge 版本安 装在系统中。 

#### 启动 Docker CE 

```bash
$ sudo systemctl enable docker
$ sudo systemctl start docker
```

#### Debian 7 Wheezy 请使用以下命令启动 

```bash
$ sudo service docker start
```
#### 建立 docker 用户组

默认情况下， `docker `命令会使用 [Unix socket](https://en.wikipedia.org/wiki/Unix_domain_socket) 与 Docker 引擎通讯。而只有` root`用户和` docker` 组的用户才可以访问 Docker 引擎的 Unix socket。出于安全考虑，一般 Linux 系统 上不会直接使用` root `用户。因此，更好地做法是将需要使用` docker` 的用户加入 `docker` 用户组。 

建立 `docker` 组：

```bash
$ sudo groupadd docker
```

 将当前用户加入 `docker` 组 

```bash
$ sudo usermod -aG docker $US
```

退出当前终端并重新登录，进行如下测试。 

#### 测试 Docker 是否安装正确 

输入以下命令

```bash
$ docker run hello-world
```

若能正常输出信息，则说明安装成功。 

#### 镜像加速 

鉴于国内网络被墙，拉取Docker镜像十分缓慢，建议安装Docker后配置[国内镜像加速](#镜像加速器)



## Windows 安装Docker CE

待续费



## macOS 安装Docker CE

待续费



 ## 树莓派安装 Docker CE

待续费







### 镜像加速器 

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



#### Windows 10 

对于使用 Windows 10 的系统，在系统右下角托盘 Docker 图标内右键菜单选择 `Settings` ， 打开配置窗口后左侧导航菜单选择 Docker Daemon 。编辑窗口内的 JSON 串，填写加速器地 址，如： 

```json
{
	"registry-mirrors": [
		"https://registry.docker-cn.com"
	]
}
```

编辑完成，点击 Apply 保存后 Docker 服务会重新启动。 



#### macOS 

对于使用 macOS 的用户，在任务栏点击 Docker for mac 应用图标 -> Perferences... -> Daemon -> Registry mirrors。在列表中填写加速器地址即可。修改完成之后，点击` Apply & Restart `按钮，Docker 就会重启并应用配置的镜像地址了。 

![mac-mirror](C:\Users\user\Desktop\Docker\mac-mirror.png)

检查加速器是否生效

配置加速器之后，如果拉取镜像仍然十分缓慢，请手动检查加速器配置是否生效，在命令行 执行` docker info `，如果从结果中看到了如下内容，说明配置成功。 

```bash
Registry Mirrors:
https://registry.docker-cn.com/
```

