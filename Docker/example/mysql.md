- 系统版本 ：CentOS7 x64
- docker版本：18.06.0-ce

目录

- 安装 mysql 5
  - 拉取镜像
  - 运行容器
  - 查看容器
  - 进入mysql容器
  - 停止容器
  - 备注
- 安装mysql 8
  - 拉去镜像
  - 运行容器
  - 常见问题1
  - 常见问题2
    

安装 mysql 5

该镜像所在地址Docker Hub打开该连接，默认展示 Repo info 标签页（该标签页中包含了一些操作该容器的方法）中的内容，如果想查看该image大小和各标签，可切换到 "Tags"标签页查看。 

拉取镜像

    docker pull mysql:5.7.23

运行容器

    docker run  --name mysql1 -v /root/mysql/conf:/etc/mysql/conf.d  -v /root/mysql/data:/var/lib/mysql -p 3306:3306  -e MYSQL_ROOT_PASSWORD=123456 -d mysql:5.7.23

--name ：容器别名

-v  : 创建一个挂载地址（可选）

-p 3306:3306 ：将容器的 3306 端口映射到主机的 3306 端口

-e MYSQL_ROOT_PASSWORD=123456 ：设置环境变量 ，这里是初始化 root 用户的密码 

-d ：后台运行容器，并返回容器ID

mysql:5.7.23 ：表示使用的镜像和版本

查看容器

    #查看正在运行的容器
    docker ps
    #查看已终止运行的容器
    docker ps -a
    #列出不运行的容器ID
    docker ps -aq

CONTAINER ID ：容器ID

进入msql容器

例如容器ID为	 a936fdfe89b5 

    # 可以看到mysql容器的短id值，这里我们取前4位即可辨识
    
    # 使用docker exec进入容器， -it 表示交互式终端  bash 表示使用熟悉的Linux命令提示符形式
    
    docker exec -it a936 bash

执行mysql命令,输入账号以及密码登陆mysql

    mysql -u root -p

查看mysql用户的权限

    select host,user,plugin,authentication_string from mysql.user;

停止容器

    # 之前已经知道了 mysql 容器的 id值，使用 a936即可标识该容器
    
    # 那么可以使用下面的命令关闭容器
    docker container stop a936
    
    # 当然使用 mysql来标识该容器也是可以的
    docker container stop mysql
    
    # 使用ps检查该容器
    docker ps -a
    # 或 
    docker container ls -a
    
    # 处于终止的容器还可使用下面的命令重新启动
    docker container start mysql

备注

默认配置文件目录位于 /etc/mysql/my.cnf  对于该配置文件我们可以直接覆盖，如果在Dockerfile中还看到 !includedir /etc/mysql/conf.d/,那么说明mysql会先加载 my.cnf 中的配置，再加载  conf.d 文件夹中配置文件的的配置，利用这一点我们可以保留 my.cnf 中的配置，而将自定义的配置文件放在 conf.d 目录下。

安装mysql 8

拉取镜像

    #默认拉取最新版本
    docker pull mysql

运行容器

具体参数信息使用 docker run --help 查看

    docker run  --name mysql1 -v /root/mysql/conf:/etc/mysql/conf.d  -v /root/mysql/data:/var/lib/mysql -p 3306:3306  -e MYSQL_ROOT_PASSWORD=123456 -d mysql

Q1:无法远程登陆

如果 mysql 服务器版本大于 8.0.4，那么默认使用 caching_sha2_password 授权插件，而不是 5.6 / 5.7 使用的 mysql_native_password 进行身份验证。 

使用下面的方法更改root账户的远程登录验证插件为 mysql_native_password： 

    alter user 'root'@'%' identified with mysql_native_password by 'youPassword';
    
    flush privileges;

下面三篇文章中都牵涉到验证插件相关命令 

- Docker安装MySQL8 
- Docker安装mysql8 
- docker mysql 8.0 
  

---



Q2: No data dictionary version number found

错误原因见： MySQL 8.0.11 报错 Different lower_case_table_names settings for server ('1') - CSDN博客 

 背景知识：

MySQL8.0  新增了data dictionary的概念，数据初始化的时候在linux下默认使用lower-case-table-names=0的参数，数据库启动的时候读取的 my.cnf 文件中的值。若二者值不一致则在mysql的错误日志中记录报错信息。

在MySQL 5.7之前则允许数据库初始化和启动的值不一致且以启动值为准。

 在MySQL 官方提供的RPM包中默认是使用 lower-case-table-names=0，不太适合生产环境部署。在生产环境建议使用官方的二进制包。

官方解释：

After initialization, is is not allowed to change this setting.So "lower_case_table_names" needs to be set together with --initialize .

解决办法：

在mysql数据库初始化的时候指定不区分大小写，在数据库实例启动的时候也要指定不区分大小写。即数据库初始化时lower_case_table_names的值和数据库启动时的值需要一样。

在实际开发生产的应用中多是不区分大小写的即lower-case-table-names=1。

 操作步骤： 

    /usr/local/mysql/bin/mysqld --user=mysql --lower-case-table-names=1 --initialize-insecure --basedir=/usr/local/mysql --datadir=/data/mysql/node1

my.cnf

    [mysqld]
    lower_case_table_names = 1

若初始化和启动值不一样则会在错误日志中有如下提示： 

    [ERROR] [MY-011087] [Server] Different lower_case_table_names settings for server ('1') and data dictionary ('0').
     [ERROR] [MY-011087] [Server] Different lower_case_table_names settings for server ('0') and data dictionary ('1').

参考资料 https://bugs.mysql.com/bug.php?id=90695 

 

 

 

 

 

 










