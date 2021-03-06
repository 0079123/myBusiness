[Nginx](https://en.wikipedia.org/wiki/Nginx) 是开源的高效的 Web 服务器实现，支持 HTTP、HTTPS、SMTP、POP3、IMAP 等协议。 

系统版本 ：`CentOS7 x64`

docker版本：`18.06.0-ce`

# 目录

- [NGINX](#NGINX)
- [拉取镜像](#拉取镜像)
- [内容说明](#内容说明)
  - [日志](#日志)
  - [配置文件](#配置文件)
  - [项目文件](#项目文件)
  - [编译参数](#编译参数)
- [运行容器](#运行容器)
  - [主配置文件](#主配置文件)
  - [外部挂在配置文件](#外部挂在配置文件)
- [容器操作](#容器操作)
  - [进入容器内部](#进入容器内部)
  - [验证配置文件及查找位置](#验证配置文件及查找位置)
  - [重启nginx](#重启nginx)
  - [查看容器信息](#查看容器信息)
  - [查看容器挂载情况](#查看容器挂载情况)
- [添加http2、https支持](#添加http2、https支持)

## NGINX

该镜像所在地址[Docker Hub](https://hub.docker.com/_/nginx/)打开该连接，默认展示 Repo info 标签页（该标签页中包含了一些操作该容器的方法）中的内容，如果想查看该image大小和各标签，可切换到 "Tags"标签页查看。 

## 拉取镜像

实际部署的时候以稳定版为主

```bash
docker pull nginx:stable
```

##  内容说明

通过[Dockerfile](#https://github.com/nginxinc/docker-nginx/blob/d377983a14b214fcae4b8e34357761282aca788f/stable/stretch/Dockerfile)可知文件的存储路径

- 日志位置 ：`/var/log/nginx/ `
- 主配置文件位置 ：`/etc/nginx/ `
- 兼容配置文件位置 : `/etc/nginx/conf.d/ ` 
- 项目位置 ： `/usr/share/nginx/html `

### 日志

nginx的日志比较简单，主要就是access和error日志，只需要挂载宿主目录到容器中nginx日志所在路径即可。 

### 配置文件

配置文件相对来说有点麻烦，一般nginx只需要加载nginx.conf就可以了，在dokcer中，是首先加载nginx.conf，然后在nginx.conf有这么一行`include /etc/nginx/conf.d/*.conf;`，就是加载conf.d目录下的配置文件。所以对于配置只需要挂载到conf.d,覆盖掉即可。

### 项目文件

类似日志的操作，挂载宿主机目录到容器即可。 

### 编译参数

这部分参考Dokcerfile

```bash
configure arguments: --prefix=/etc/nginx 
--sbin-path=/usr/sbin/nginx 
--modules-path=/usr/lib/nginx/modules 
--conf-path=/etc/nginx/nginx.conf 
--error-log-path=/var/log/nginx/error.log 
--http-log-path=/var/log/nginx/access.log 
--pid-path=/var/run/nginx.pid 
--lock-path=/var/run/nginx.lock 
--http-client-body-temp-path=/var/cache/nginx/client_temp 
--http-proxy-temp-path=/var/cache/nginx/proxy_temp 
--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp 
--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp 
--http-scgi-temp-path=/var/cache/nginx/scgi_temp 
--user=nginx 
--group=nginx
 --with-compat 
 --with-file-aio
 --with-threads 
 --with-http_addition_module 
 --with-http_auth_request_module 
 --with-http_dav_module 
 --with-http_flv_module 
 --with-http_gunzip_module 
 --with-http_gzip_static_module 
 --with-http_mp4_module 
 --with-http_random_index_module 
 --with-http_realip_module 
 --with-http_secure_link_module 
 --with-http_slice_module 
 --with-http_ssl_module
 --with-http_stub_status_module 
 --with-http_sub_module 
 --with-http_v2_module 
 --with-mail 
 --with-mail_ssl_module 
 --with-stream 
 --with-stream_realip_module 
 --with-stream_ssl_module 
 --with-stream_ssl_preread_module 
 --with-cc-opt='-g -O2 
 -fdebug-prefix-map=/data/builder/debuild/nginx-1.14.0/debian/debuild-base/nginx-1.14.0=. -specs=/usr/share/dpkg/no-pie-compile.specs 
 -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' --with-ld-opt='-specs=/usr/share/dpkg/no-pie-link.specs 
 -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie'
```



## 运行容器

```bash
docker run --name docker_nginx -d -p 80:80\ 
  -v /home/nginx/log:/var/log/nginx\
  -v /home/nginx/conf:/etc/nginx/conf.d:ro\
  -v /home/mynginx/nginx/nginx.conf:/etc/nginx/nginx/conf:ro\ 
  -v /home/mynginx/nginx/html:/usr/share/nginx/html:ro\
  nginx:stable
######
#默认容器对这个目录有可读写权限，可以通过指定ro，将权限改为只读（readonly）
#第一个-v:挂载日志目录
#第二个-v:挂载配置目录
#第三个-v:干脆把配置文件直接挂出来，不推荐
#第四个-v:挂载项目目录
```

###  配置文件

#### 主配置文件 

`nginx.conf`

```bash
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
```

#### 外部挂载配置文件

`home/nginx/conf/app.conf`

路径关系

`/usr/share/nginx/html`—— > `/home/mynginx/nginx/html`

```
 server {
    listen       80;
    server_name  localhost;

    #charset koi8-r;
    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    location /api{
        proxy_pass http://192.168.1.1:9999/api;
        # access_log "logs/test.log";
    }
}
```

## 容器操作

### 进入容器内部

```bash
# 'docker_nginx' 为容器名称
dokcer exec -it docker_nginx
# 或者
dokcer exec -it docker_nginx bash
```

### 验证配置文件及查找位置 

```bash
#容器内部
nginx -t
#容器外部,其中'docker_nginx'为容器名称
docker exec -it docker_nginx:nginx -t
```

### 重启nginx

修改配置文件后

```bash
#容器内部
nginx -s reload
#容器外部
dokcer exec -it docker_nginx nginx -s reload
```

### 查看容器信息 

```bash
docker inspect 容器名
```

### 查看容器挂载情况 

```bash
docker inspect 容器名 | grep Mounts -A 20
```

## 添加http2、https支持

该特性需要`https`、`openssl` 以及`http_v2` 支持 参考[编译参数](#编译参数)

```bash
#查看nginx 编译参数
nginx -V
```
创建私有证书（单向校验）
```bash
#首先，创建证书和私钥的目录
mkdir -p /etc/nginx/cert
cd /etc/nginx/cert
#创建服务器私钥，命令会让你输入一个口令：
openssl genrsa -des3 -out nginx.key 2048
#创建签名请求的证书（CSR）：
openssl req -new -key nginx.key -out nginx.csr
#在加载SSL支持的Nginx并使用上述私钥时除去必须的口令：
cp nginx.key nginx.key.org
openssl rsa -in nginx.key.org -out nginx.key
#最后标记证书使用上述私钥和CSR：
openssl x509 -req -days 365 -in nginx.csr -signkey nginx.key -out nginx.crt
```

之后在配置的server中添加

```bash
server {
    listen       443 ssl http2;
    server_name  localhost;
	#选择证书所在位置
    ssl_certificate /etc/nginx/cert/nginx.crt;
    ssl_certificate_key /etc/nginx/cert/nginx.key;
 	# 禁止在header中出现服务器版本，防止黑客利用版本漏洞攻击
    server_tokens off;
    # 设置ssl/tls会话缓存的类型和大小。如果设置了这个参数一般是shared，buildin可能会参数内存碎片，默认是none，和off差不多，停用缓存。如shared:SSL:10m表示我所有的nginx工作进程共享ssl会话缓存，官网介绍说1M可以存放约4000个sessions。 
    ssl_session_cache    shared:SSL:1m; 

    # 客户端可以重用会话缓存中ssl参数的过期时间，内网系统默认5分钟太短了，可以设成30m即30分钟甚至4h。
    ssl_session_timeout  5m; 

    # 选择加密套件，不同的浏览器所支持的套件（和顺序）可能会不同。
    # 这里指定的是OpenSSL库能够识别的写法，你可以通过 openssl -v cipher 'RC4:HIGH:!aNULL:!MD5'（后面是你所指定的套件加密算法） 来看所支持算法。
    ssl_ciphers  HIGH:!aNULL:!MD5;

    # 设置协商加密算法时，优先使用我们服务端的加密套件，而不是客户端浏览器的加密套件。
    ssl_prefer_server_ciphers  on;

    location / {
        root   html;
        index  index.html index.htm;
    }
}
```

保存退出,并重启nginx

### 验证效果

在浏览器输入`chrome://net-internals/`打开网络观察组件，然后选择`HTTP/2`

 ![](Docker/example/http2.png)
