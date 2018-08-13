

Linux系统 ： `CentOS7 x64`

Nginx版本： `1.14.0`

# **目录**

- [安装](#安装)
  - [编译所需依赖](#编译所需依赖)
  - [下载](#下载)
- [编译安装](#编译安装)
  - [nginx测试](#nginx测试)
  - [设置全局命令](#设置全局nginx命令)
  - [开机启动](#开机启动)
- [运维](#运维)
  - [服务管理](#服务管理)
  - [开放防火墙端口](#开放防火墙端口)
- [卸载nginx](#卸载nginx)
- [参数说明](#参数说明)

## 安装

### 编译所需依赖

> prce(重定向支持)和openssl(https支持)二者根据实际需求安装

```bash
yum -y install gcc gcc-c++ autoconf automake wget
yum -y install zlib zlib-devel openssl openssl-devel pcre pcre-devel
```

### 下载

[nginx下载地址](http://nginx.org/download/)

```bash
wget http://nginx.org/download/nginx-1.14.0.tar.gz

#如果没有安装wget

#下载已编译版本
yum install -y wget

#解压压缩包
tar zxf nginx-1.14.0.tar.gz
```

## 编译安装

进入目录执行编译 ，[参数说明](#参数说明)

```bash
cd nginx-1.14.0
./configure 
....
后接configure参数
```

如果没有错误信息，则执行

```bash
make 
make install
```

### nginx测试

通常情况下修改配置文件后要先执行测试，测试通过后再执行重启ngixn服务

```bash
cd /usr/local/nginx/sbin/
./nginx -t

# nginx: the configuration file /usr/local/nginx/conf/nginx.conf syntax is ok
# nginx: configuration file /usr/local/nginx/conf/nginx.conf test is successful
```

### 设置全局nginx命令

```bash
vim ~/.bash_profile
```

将下面内容添加到 `~/.bash_profile` 文件中

```bash
PATH=$PATH:$HOME/bin:/usr/local/nginx/sbin/
export PATH
```

运行命令 **`source ~/.bash_profile`** 让配置立即生效。你就可以全局运行 `nginx` 命令了。

### 开机启动

**方法一：**

```bash
#编辑nginx.service文件
vim /lib/systemd/system/nginx.service
```

然后编辑以下内容

```bash
[Unit]
Description=nginx
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/local/nginx/sbin/nginx -t -c /usr/local/nginx/conf/nginx.conf
ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

- `[Unit]`:服务的说明
- `Description`:描述服务
- `After`:描述服务类别  
- `[Service]`服务运行参数的设置  
- `Type=forking`是后台运行的形式  
- `ExecStart`为服务的具体运行命令  
- `ExecReload`为重启命令  
- `ExecStop`为停止命令  
- `PrivateTmp=True`表示给服务分配独立的临时空间  

注意：`[Service]`的启动、重启、停止命令全部要求使用绝对路径。

`[Install]`运行级别下服务安装的相关设置，可设置为多用户，即系统运行级别为`3`。

保存退出。

```bash
# 启动nginx服务
systemctl start nginx.service
# 停止开机自启动
systemctl disable nginx.service
# 查看服务当前状态
systemctl status nginx.service
# 查看所有已启动的服务
systemctl list-units --type=service
# 重新启动服务
systemctl restart nginx.service
# 设置开机自启动
systemctl enable nginx.service
# 输出下面内容表示成功了
Created symlink from /etc/systemd/system/multi-user.target.wants/nginx.service to /usr/lib/systemd/system/nginx.service.
```

从Centos7 开始，命令行较Centos6 已经有了很大的不同，服务类的命令以`systemctl`开始

```bash
systemctl is-enabled servicename.service # 查询服务是否开机启动
systemctl enable *.service # 开机运行服务
systemctl disable *.service # 取消开机运行
systemctl start *.service # 启动服务
systemctl stop *.service # 停止服务
systemctl restart *.service # 重启服务
systemctl reload *.service # 重新加载服务配置文件
systemctl status *.service # 查询服务运行状态
systemctl --failed # 显示启动失败的服务
#注：*代表某个服务的名字，如http的服务名为httpd
```

**方法二:**

```bash
vi /etc/rc.local

# 在 rc.local 文件中，添加下面这条命令
/usr/local/nginx/sbin/nginx start
```

注：rc.local默认是不可执行的，需要对权限进行修改

```bash
# /etc/rc.local是/etc/rc.d/rc.local的软连接，
chmod +x /etc/rc.d/rc.local
```

**方法三:**

```bash
vim /etc/init.d/nginx
```

编辑内容

```bash
# description: nginx-server

#填写nginx安装位置
nginx=/usr/local/nginx-1.14.0/sbin/nginx    
case "$1" in
        start)
                netstat -anlpt | grep nginx
            if
                [ $? -eq 0 ]
             then
                echo " the nginx-server is already running"
            else
                echo " ther nginx-server is starting to run"
                $nginx
            fi
         ;;

       stop)
              netstat -anlpt | grep nginx
                if 
                [ $? -eq 0 ]
              then
                   $nginx -s stop
                   if [ $? -eq 0 ]
                      then
                          echo " the nginx-server is stopped " 
                   else
                          echo " failed to stop the nginx-server" 
                  fi
            else
               echo " the nginx-server has stopped you needn't to stop it " 
            fi
         ;;
      restart)
                 $nginx -s reload
             if 
                 [ $? -eq 0 ]
               then
                  echo "the nginx-server is restarting "
              else
                  echo " the nginx-server failed to restart"
             fi
         ;;

        status)
                   netstat -anlpt | grep nginx
             if 
                 [ $? -eq 0 ]
               then
                   echo " the nginx-server is running "
            else
                   echo " the nginx-server is not running ,please try again" 
             fi
       ;;

        status)
                   netstat -anlpt | grep nginx
             if 
                 [ $? -eq 0 ]
               then
                   echo " the nginx-server is running "
            else
                   echo " the nginx-server is not running ,please try again" 
             fi
         ;;
        *)
               echo "please enter { start|stop|status|restart}"
        ;;
esac
```

保存退出

```bash
chkconfig nginx on 
```

**方法四:** [官方脚本](https://www.nginx.com/resources/wiki/start/topics/examples/redhatnginxinit/)。



## 运维

### 服务管理

```bash
# 启动
/usr/local/nginx/sbin/nginx

# 重启
/usr/local/nginx/sbin/nginx -s reload

# 关闭进程
/usr/local/nginx/sbin/nginx -s stop

# 平滑关闭nginx
/usr/local/nginx/sbin/nginx -s quit

# 查看nginx的安装状态，
/usr/local/nginx/sbin/nginx -V 
```

### 开放防火墙端口

```bash
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --reload
```

## 卸载nginx

如果通过yum安装，使用下面命令安装。

```bash
yum remove nginx
```

编译安装，删除/usr/local/nginx目录即可
如果配置了自启动脚本，也需要删除。

## 参数说明

| 参数                                         | 说明                                                         |
| -------------------------------------------- | ------------------------------------------------------------ |
| --prefix=`<path>`                            | Nginx安装路径。如果没有指定，默认为 /usr/local/nginx。       |
| --sbin-path=`<path>`                         | Nginx可执行文件安装路径。只能安装时指定，如果没有指定，默认为`<prefix>`/sbin/nginx。 |
| --conf-path=`<path>`                         | 在没有给定-c选项下默认的nginx.conf的路径。如果没有指定，默认为`<prefix>`/conf/nginx.conf。 |
| --pid-path=`<path>`                          | 在nginx.conf中没有指定pid指令的情况下，默认的nginx.pid的路径。如果没有指定，默认为 `<prefix>`/logs/nginx.pid。 |
| --lock-path=`<path>`                         | nginx.lock文件的路径。                                       |
| --error-log-path=`<path>`                    | 在nginx.conf中没有指定error_log指令的情况下，默认的错误日志的路径。如果没有指定，默认为 `<prefix>`/- logs/error.log。 |
| --http-log-path=`<path>`                     | 在nginx.conf中没有指定access_log指令的情况下，默认的访问日志的路径。如果没有指定，默认为 `<prefix>`/- logs/access.log。 |
| --user=`<user>`                              | 在nginx.conf中没有指定user指令的情况下，默认的nginx使用的用户。如果没有指定，默认为 nobody。 |
| --group=`<group>`                            | 在nginx.conf中没有指定user指令的情况下，默认的nginx使用的组。如果没有指定，默认为 nobody。 |
| --builddir=DIR                               | 指定编译的目录                                               |
| --with-rtsig_module                          | 启用 rtsig 模块                                              |
| --with-select_module --without-select_module | 允许或不允许开启SELECT模式，如果 configure 没有找到更合适的模式，比如：kqueue(sun os),epoll (linux kenel 2.6+), rtsig(- 实时信号)或者/dev/poll(一种类似select的模式，底层实现与SELECT基本相 同，都是采用轮训方法) SELECT模式将是默认安装模式 |
| --with-poll_module --without-poll_module     | Whether or not to enable the poll module. This module is enabled by, default if a more suitable method such as kqueue, epoll, rtsig or /dev/poll is not discovered by configure. |
| --with-http_ssl_module                       | Enable ngx_http_ssl_module. Enables SSL support and the ability to handle HTTPS requests. Requires OpenSSL. On Debian, this is libssl-dev. 开启HTTP SSL模块，使NGINX可以支持HTTPS请求。这个模块需要已经安装了OPENSSL，在DEBIAN上是libssl |
| --with-http_realip_module                    | 启用 ngx_http_realip_module                                  |
| --with-http_addition_module                  | 启用 ngx_http_addition_module                                |
| --with-http_sub_module                       | 启用 ngx_http_sub_module                                     |
| --with-http_dav_module                       | 启用 ngx_http_dav_module                                     |
| --with-http_flv_module                       | 启用 ngx_http_flv_module                                     |
| --with-http_stub_status_module               | 启用 "server status" 页                                      |
| --without-http_charset_module                | 禁用 ngx_http_charset_module                                 |
| --without-http_gzip_module                   | 禁用 ngx_http_gzip_module. 如果启用，需要 zlib 。            |
| --without-http_ssi_module                    | 禁用 ngx_http_ssi_module                                     |
| --without-http_userid_module                 | 禁用 ngx_http_userid_module                                  |
| --without-http_access_module                 | 禁用 ngx_http_access_module                                  |
| --without-http_auth_basic_module             | 禁用 ngx_http_auth_basic_module                              |
| --without-http_autoindex_module              | 禁用 ngx_http_autoindex_module                               |
| --without-http_geo_module                    | 禁用 ngx_http_geo_module                                     |
| --without-http_map_module                    | 禁用 ngx_http_map_module                                     |
| --without-http_referer_module                | 禁用 ngx_http_referer_module                                 |
| --without-http_rewrite_module                | 禁用 ngx_http_rewrite_module. 如果启用需要 PCRE 。           |
| --without-http_proxy_module                  | 禁用 ngx_http_proxy_module                                   |
| --without-http_fastcgi_module                | 禁用 ngx_http_fastcgi_module                                 |
| --without-http_memcached_module              | 禁用 ngx_http_memcached_module                               |
| --without-http_limit_zone_module             | 禁用 ngx_http_limit_zone_module                              |
| --without-http_empty_gif_module              | 禁用 ngx_http_empty_gif_module                               |
| --without-http_browser_module                | 禁用 ngx_http_browser_module                                 |
| --without-http_upstream_ip_hash_module       | 禁用 ngx_http_upstream_ip_hash_module                        |
| --with-http_perl_module                      | 启用 ngx_http_perl_module                                    |
| --with-perl_modules_path=PATH                | 指定 perl 模块的路径                                         |
| --with-perl=PATH                             | 指定 perl 执行文件的路径                                     |
| --http-log-path=PATH                         | Set path to the http access log                              |
| --http-client-body-temp-path=PATH            | Set path to the http client request body temporary files     |
| --http-proxy-temp-path=PATH                  | Set path to the http proxy temporary files                   |
| --http-fastcgi-temp-path=PATH                | Set path to the http fastcgi temporary files                 |
| --without-http                               | 禁用 HTTP server                                             |
| --with-mail                                  | 启用 IMAP4/POP3/SMTP 代理模块                                |
| --with-mail_ssl_module                       | 启用 ngx_mail_ssl_module                                     |
| --with-cc=PATH                               | 指定 C 编译器的路径                                          |
| --with-cpp=PATH                              | 指定 C 预处理器的路径                                        |
| --with-cc-opt=OPTIONS                        | Additional parameters which will be added to the variable CFLAGS. With the use of the system library PCRE in FreeBSD, it is necessary to indicate --with-cc-opt="-I /usr/local/include". If we are using select() and it is necessary to increase the number of file descriptors, then this also can be assigned here: --with-cc-opt="-D FD_SETSIZE=2048". |
| --with-ld-opt=OPTIONS                        | Additional parameters passed to the linker. With the use of the system library PCRE in - FreeBSD, it is necessary to indicate --with-ld-opt="-L /usr/local/lib". |
| --with-cpu-opt=CPU                           | 为特定的 CPU 编译，有效的值包括：pentium, pentiumpro, pentium3, pentium4, athlon, opteron, amd64, sparc32, sparc64, ppc64 |
| --without-pcre                               | 禁止 PCRE 库的使用。同时也会禁止 HTTP rewrite 模块。在 "location" 配置指令中的正则表达式也需要 PCRE 。 |
| --with-pcre=DIR                              | 指定 PCRE 库的源代码的路径。                                 |
| --with-pcre-opt=OPTIONS                      | Set additional options for PCRE building.                    |
| --with-md5=DIR                               | Set path to md5 library sources.                             |
| --with-md5-opt=OPTIONS                       | Set additional options for md5 building.                     |
| --with-md5-asm                               | Use md5 assembler sources.                                   |
| --with-sha1=DIR                              | Set path to sha1 library sources.                            |
| --with-sha1-opt=OPTIONS                      | Set additional options for sha1 building.                    |
| --with-sha1-asm                              | Use sha1 assembler sources.                                  |
| --with-zlib=DIR                              | Set path to zlib library sources.                            |
| --with-zlib-opt=OPTIONS                      | Set additional options for zlib building.                    |
| --with-zlib-asm=CPU                          | Use zlib assembler sources optimized for specified CPU, valid values are: pentium, pentiumpro |
| --with-openssl=DIR                           | Set path to OpenSSL library sources                          |
| --with-openssl-opt=OPTIONS                   | Set additional options for OpenSSL building                  |
| --with-debug                                 | 启用调试日志                                                 |
| --add-module=PATH                            | Add in a third-party module found in directory PATH          |

