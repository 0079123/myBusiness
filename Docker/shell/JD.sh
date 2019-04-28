#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: Red Hat 7 
#	Description: Production Environment
#	Version: 1.0.2
#	Author: hhyykk
#	Date: 2019-4-28
#=================================================
sh_ver="1.0.2"
docker_file="/usr/bin/docker"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

#chek system info
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep  -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
	bit=`uname -m`
}
check_installed_status(){
	[[ ! -e ${docker_file} ]] && echo -e "${Error} Docker 没有安装，请检查 !" && exit 1
}
check_pid(){
	PID=`ps -ef| grep "docker"| grep -v grep| awk '{print $2}'`
}


Install_docker(){
	[[ -e ${docker_file} ]] && echo -e "${Error} 检测到 Docker 已安装 !" && exit 1
	check_sys
	echo -e "${Info} 正在安装..."
	Installation_dependency
	AddGroup_to_docker
	menu_status
}

Uninstall_docker(){
	sudo yum remove docker \
		docker-common \
		docker-selinux \
		docker-engine -y
}

Start_docker(){
	check_installed_status
    check_pid
	[[ ! -z ${PID} ]] && echo -e "${Error} Docker 正在运行，请检查 !" && exit 1
    sudo service docker start
	check_test
	echo -e " "
    menu_status
}

Stop_docker(){
	check_installed_status
	check_pid
	[[ -z ${PID} ]] && echo -e "${Error} Docker 没有运行，请检查 !" && exit 1
    sudo service docker stop
	echo -e " "
	menu_status
}

Restart_docker(){
	check_installed_status
	check_pid
    sudo service docker restart
	echo -e " "
	menu_status
}

Autostart_docker(){
	sudo systemctl enable docker
}

Create_nginx(){
	read -p "请选择版本号(默认 stable):" tag
	read -p "请输入容器名称(默认 nginx):" cName
	read -p "请输入部署nginx的路径(默认 /home/nginx):" nginxPath
	read -p "请输入http的端口号(默认 8843):" httpPort
	if [ -z "${tag}" ];then
		tag="stable"
	fi
	if [ -z "${cName}" ];then
		cName="nginx"
	fi
	if [ -z "${nginxPath}" ];then
		nginxPath="/home/nginx"
	fi
	if [ -z "${httpPort}" ];then
		httpPort="8843"
	fi
	
sudo docker run --name $cName -d \
	--privileged=true \
	-v $nginxPath/log:/var/log/nginx \
	-v $nginxPath/conf:/etc/nginx/conf.d:ro \
	-p $httpPort:80 \
	nginx:$tag	
	
	if docker ps -a | grep $cName |awk {'print $(NF)'} ;then
		Show_result_nginx
	
		else
			echo -e "${Error} nginx容器创建失败 请检查!"
	fi
}

Create_tomcat(){
	read -p "请选择版本号(默认 9):" tag
	read -p "请输入容器名称(默认 tomcat):" cName
	read -p "请输入部署mysql的路径(默认 /home/tomcat):" tomcatPath
	read -p "请输入mysql端口(默认 8080):" tomcatPort
		if [ -z "${tag}" ];then
			tag="9"
		fi	
		if [ -z "${cName}" ];then
			cName="tomcat"
		fi	
		if [ -z "${tomcatPath}" ];then
			tomcatPath="/home/tomcat"
		fi	
		if [ -z "${tomcatPort}" ];then
			tomcatPort="8080"
		fi
		
sudo docker run --name $cName -d \
	--privileged=true \
	-v $tomcatPath/webapps:/usr/local/tomcat/webapps \
	-v $tomcatPath/logs:/usr/local/tomcat/logs \
	-v /etc/localtime:/etc/localtime:ro \
	-e TZ="Asia/Shanghai" \
	-p $tomcatPort:8080 \
	tomcat:$tag
	if docker ps -a | grep $cName |awk {'print $(NF)'} ;then
		Show_result_tomcat
	
		else
			echo -e "${Error} docker容器创建失败 请检查!"
	fi
}

Create_mysql(){
	read -p "请选择版本号(默认 5):" tag
	read -p "请输入容器名称(默认 mysql):" cName
	read -p "请输入部署mysql的路径(默认 /home/mysql):" mysqlPath
	read -p "请设置root密码(默认 vann5668355):" msyqlPsswd
	read -p "请输入mysql端口(默认 3306):" msyqlPort
		if [ -z "${tag}" ];then
		tag="5"
		fi
		if [ -z "${cName}" ];then
			cName="mysql"
		fi
		if [ -z "${mysqlPath}"];then
			mysqlPath="/home/mysql"
		fi
		if [ -z "${msyqlPsswd}"];then
			msyqlPsswd="123456"
		fi
		if [ -z "${msyqlPort}"];then
			msyqlPort="3306"
		fi

sudo docker run  --name $cName -d \
	-v $mysqlPath/conf:/etc/mysql/conf.d \
	-v $mysqlPath/data:/var/lib/mysql \
	-e MYSQL_ROOT_PASSWORD=$msyqlPsswd \
	-p $msyqlPort:3306 \
	--privileged=true \
	mysql:$tag
	if docker ps -a | grep $cName |awk {'print $(NF)'} ;then
		Show_result_mysql
	
		else
			echo -e "${Error} mysql容器创建失败 请检查!"
	fi
}

Create_redis(){
	read -p "请输入容器名称(默认 redis):" cName
	read -p "请输入端口号(默认 6379):" cPort
		if [ -z "${cName}" ];then
			cName="redis"
		fi
		if [ -z "${cPort}"];then
			cPort="6379"
		fi
		
sudo docker run -d --name $cName \
	-p $cPort:6379 \
	0079123/redis --appendonly yes
	if docker ps -a | grep $cName |awk {'print $(NF)'} ;then
		Show_result_redis
	
		else
			echo -e "${Error} mysql容器创建失败 请检查!"
	fi
}

Create_srs(){
	read -p "请输入容器名称(默认 srs):" cName
		if [ -z "${cName}" ];then
			cName="srs"
		fi
docker run -d --name srs \
	--privileged=true \
	-v /home/srs/conf:/srs/conf \
	-p 1935:1935 -p 1985:1985 -p 8848:8080 \
	ossrs/srs:2.0-ffmpeg
	
	if docker ps -a | grep $cName |awk {'print $(NF)'} ;then
		Show_result_srs
	
		else
			echo -e "${Error} mysql容器创建失败 请检查!"
	fi
}

Installation_dependency(){
	if [[ ${release} == "centos" ]]; then
		Yum_install
	else
		Aptget_install
	fi
}


Yum_install(){
	sudo yum update -y
	sudo yum install docker-io -y
}

AddGroup_to_docker(){
	sudo groupadd docker
	sudo usermod -aG docker $USER
}


Show_result_nginx(){
	echo 
	echo
	echo "================$cName container has been created================"
	echo
	echo "容器名称：$cName"
	echo
	echo "日志路径:$nginxPath/log"
	echo
	echo "配置文件路径:$nginxPath/conf"
	echo
	echo "端口号:$httpPort"
	echo
}

Show_result_tomcat(){
	echo 
	echo
	echo "================$cName container has been created================"
	echo
	echo "容器名称：$cName"
	echo
	echo "日志路径:$tomcatPath/logs"
	echo
	echo "工程路径:$tomcatPath/webapps"
	echo
	echo "端口号:$tomcatPort"
	echo
}

Show_result_mysql(){
	echo 
	echo
	echo "================$cName container has been created================"
	echo
	echo "容器名称：$cName"
	echo
	echo "配置文件路径:$mysqlPath/conf"
	echo
	echo "数据库路径:$mysqlPath/data"
	echo
	echo "端口号:$msyqlPort"
	echo
}

Show_result_redis(){
	echo 
	echo
	echo "================$cName container has been created================"
	echo
	echo "容器名称：$cName"
	echo
	echo "端口号:$cPort"
	echo	
}

Show_result_srs(){
	echo 
	echo
	echo "================$cName container has been created================"
	echo
	echo "容器名称：$cName"
	echo
	echo "RTMP端口:1935"
	echo
	echo "API端口:1985"
	echo
	echo "http端口:8848"
	echo		
}

menu_status(){
	if [[ -e ${docker_file} ]]; then
		check_pid
	if [[ ! -z "${PID}" ]]; then
		echo -e " 当前状态: ${Green_font_prefix}已安装${Font_color_suffix} 并 ${Green_font_prefix}已启动${Font_color_suffix}"
	else
		echo -e " 当前状态: ${Green_font_prefix}已安装${Font_color_suffix} 但 ${Red_font_prefix}未启动${Font_color_suffix}"
	fi
	else
		echo -e " 当前状态: ${Red_font_prefix}未安装${Font_color_suffix}"
	fi
}
check_sys
[[ ${release} != "debian" ]] && [[ ${release} != "ubuntu" ]] && [[ ${release} != "centos" ]] && echo -e "${Error} 本脚本不支持当前系统 ${release} !" && exit 1
echo -e "*************************"
echo -e "  京东部署脚本 ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  ---- hhyykk ----"
echo -e "*************************"
while :
do
echo && echo -e "请输入一个数字来选择选项
 ${Green_font_prefix}1.${Font_color_suffix}  安装 Docker
 ${Green_font_prefix}2.${Font_color_suffix}  卸载 Docker
————————————————————
 ${Green_font_prefix}3.${Font_color_suffix}  启动 Docker 
 ${Green_font_prefix}4.${Font_color_suffix}  停止 Docker
 ${Green_font_prefix}5.${Font_color_suffix}  重启 Docker
 ${Green_font_prefix}6.${Font_color_suffix}  设置开机自启
————————————————————
 ${Green_font_prefix}7.${Font_color_suffix}  创建 Nginx
 ${Green_font_prefix}8.${Font_color_suffix}  创建 Tomcat
 ${Green_font_prefix}9.${Font_color_suffix}  创建 Mysql
 ${Green_font_prefix}10.${Font_color_suffix} 创建 redis
 ${Green_font_prefix}11.${Font_color_suffix} 创建 srs
————————————————————
${Green_font_prefix}0.${Font_color_suffix} 退出菜单
————————————————————" && echo
menu_status
stty erase '^H' && read -p " 请输入数字 [0-11]:" num
case "$num" in
	0)
	exit
	;;
	1)
	Install_docker
	;;
	2)
	Uninstall_docker
	;;
	3)
	Start_docker
	;;
	4)
	Stop_docker
	;;
	5)
	Restart_docker
	;;
	6)
	Autostart_docker
	;;
	7)
	Create_nginx
	;;
	8)
	Create_tomcat
	;;
	9)
	Create_mysql
	;;
	10)
	Create_redis
	;;
	11)
	Create_srs
	;;
	*)
	echo "请输入正确数字 [1-11]"
	;;
esac
done
