#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS/Debian/Ubuntu
#	Description: Docker
#	Version: 1.1.1
#	Author: hhyykk
#	Date: 2018-9-7
#=================================================

sh_ver="1.1.1"
docker_file="/usr/bin/docker"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"
#检查系统
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
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
Yum_install(){
	#卸载系统自带版本
	sudo yum remove docker \
		docker-common \
		docker-selinux \
		docker-engine -y
	#下载依赖
	sudo yum update
	sudo yum install -y yum-utils \
	device-mapper-persistent-data \
	lvm2 
}
Aptget_install(){
	#卸载系统自带版本
	sudo apt-get remove docker\
		docker-engine\
		docker.io -y
	#下载依赖
	sudo apt-get update 
	sudo apt-get -y install \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg2 \
	lsb-release \
	software-properties-common 
}

Installation_dependency(){
	if [[ ${release} == "centos" ]]; then
		Yum_install
	else
		Aptget_install
	fi
}

Download_docker(){
	curl -fsSL get.docker.com -o /tmp/get-docker.sh
}

Install_script(){
	sudo sh /tmp/get-docker.sh --mirror Aliyun
}
AddGroup_to_docker(){
	sudo groupadd docker
	sudo usermod -aG docker $USER
}
Show_version(){
	docker version
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
	echo "html路径:$nginxPath/html"
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
}
Show_result_mysql(){
	echo 
	echo
	echo "================$cName container has been created================"
	echo
	echo "容器名称：$cName"
	echo
	echo "配置文件路径: $mysqlPath/conf"
	echo
	echo "数据库路径: $mysqlPath/data"
	echo
}
Init_docker(){
	if [[ ${release} == "centos" ]]; then
		Start_docker
		AddGroup_to_docker
	else
		AddGroup_to_docker
	fi
}

#安装
Install_docker(){
	[[ -e ${docker_file} ]] && echo -e "${Error} 检测到 Docker 已安装 !" && exit 1
	check_sys
	echo -e "${Info} 开始安装/配置 依赖..."
	Installation_dependency
	echo -e "${Info} 开始下载..."
	Download_docker
	echo -e "${Info} 开始安装..."
	Install_script
	echo -e "${Info} 所有步骤 安装完毕，开始启动..."
	Init_docker
	echo -e "${Info} 当前版本..."
	Show_version
	menu_status
}

Yum_unstall(){
	sudo yum remove -y docker-ce 
}
Aptget_unstall(){
	sudo apt-get -y remove docker-ce
}

#卸载
Uninstall_docker(){
	check_sys
	if [[ ${release} == "centos" ]]; then
		Yum_unstall
	else
		Aptget_unstall
	fi
	menu_status
}


#启动docker服务
Start_docker(){
	check_installed_status
	check_pid
	[[ ! -z ${PID} ]] && echo -e "${Error} Docker 正在运行，请检查 !" && exit 1
#	sudo systemctl start docker
	sudo service docker start
	menu_status
}

#停止docker服务
Stop_docker(){
	check_installed_status
	check_pid
	[[ -z ${PID} ]] && echo -e "${Error} Docker 没有运行，请检查 !" && exit 1
#	sudo systemctl stop docker
	sudo service docker stop
	menu_status
}

#重启docker服务
Restart_docker(){
	check_installed_status
	check_pid
#	sudo systemctl restart docker
	sudo service docker restart
	menu_status
}
#设置服务自启
Autostart_docker(){
	sudo systemctl enable docker
}

#创建nginx容器
Create_nginx(){
	read -p "请选择版本号(默认 stable):" tag
	read -p "请输入容器名称(默认 nginx):" cName
	read -p "请输入部署nginx的路径(默认 /home/nginx):" nginxPath
	read -p "请输入http的端口号(默认 80):" httpPort
	read -p "请输入https的端口号(默认 443):" httpsPort
	if [[ -z "${tag}" ]];then
		tag="stable"
	fi
	if [[ -z "${cName}" ]];then
		cName="nginx"
	fi
	if [[ -z "${nginxPath}" ]];then
		nginxPath="/home/nginx"
	fi
	if [[ -z "${httpPort}" ]];then
		httpPort="80"
	fi
	if [[ -z "${httpsPort}" ]];then
		httpsPort="443"
	fi
sudo docker run --name $cName -d\
	-v $nginxPath/log:/var/log/nginx\
	-v $nginxPath/conf:/etc/nginx/conf.d:ro\
	-v $nginxPath/html:/usr/share/nginx/html:ro\
	-p $httpPort:80  -p $httpsPort:443\
	nginx:$tag	
	#检查是否创建
	if docker ps -a | grep $cName |awk {'print $(NF)'} ;then
		Show_result_nginx
	
		else
			echo -e "${Error} nginx容器创建失败 请检查!"
	fi
}

#创建tomcat容器
Create_tomcat(){
read -p "请选择版本号(默认 9):" tag
read -p "请输入容器名称(默认 tomcat):" cName
read -p "请输入部署mysql的路径(默认 /home/tomcat):" tomcatPath
read -p "请输入mysql端口(默认 8080):" tomcatPort
	if [[ -z "${tag}" ]];then
		tag="9"
	fi	
	if [[ -z "${cName}" ]];then
		cName="tomcat"
	fi	
	if [[ -z "${tomcatPath}" ]];then
		tomcatPath="/home/tomcat"
	fi	
	if [[ -z "${tomcatPort}" ]];then
		tomcatPort="8080"
	fi

sudo docker run --name $cName -d \
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
	

#创建mysql容器
Create_mysql(){
read -p "请选择版本号(默认 5):" tag
read -p "请输入容器名称(默认 mysql):" cName
read -p "请输入部署mysql的路径(默认 /home/mysql):" mysqlPath
read -p "请设置root密码(默认 123456):" msyqlPsswd
read -p "请输入mysql端口(默认 3306):" msyqlPort
	if [[ -z "${tag}" ]];then
		tag="5"
	fi
	if [[ -z "${cName}" ]];then
		cName="mysql"
	fi
	if [[ -z "${mysqlPath}" ]];then
		mysqlPath="/home/mysql"
	fi
	if [[ -z "${msyqlPsswd}" ]];then
		msyqlPsswd="123456"
	fi
	if [[ -z "${msyqlPort}" ]];then
		msyqlPort="3306"
	fi
sudo docker run  --name $cName -d \
	-v $mysqlPath/conf:/etc/mysql/conf.d \
	-v $mysqlPath/data:/var/lib/mysql \
	-e MYSQL_ROOT_PASSWORD=$msyqlPsswd \
	-p $msyqlPort:3306 \
	mysql:$tag
	if docker ps -a | grep $cName |awk {'print $(NF)'} ;then
		Show_result_mysql
	
		else
			echo -e "${Error} mysql容器创建失败 请检查!"
	fi
}

Update_Shell(){
	echo -e "当前版本为 [ ${sh_ver} ]，开始检测最新版本..."
	
	sh_new_ver=$(wget --no-check-certificate -qO- "https://raw.githubusercontent.com/0079123/myBusiness/master/Docker/shell/Docker.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1) && sh_new_type="github"
	[[ -z ${sh_new_ver} ]] && echo -e "${Error} 检测最新版本失败 !" && exit 0
	if [[ ${sh_new_ver} != ${sh_ver} ]]; then
		echo -e "发现新版本[ ${sh_new_ver} ]，是否更新？[Y/n]"
		stty erase '^H' && read -p "(默认: y):" yn
		[[ -z "${yn}" ]] && yn="y"
		if [[ ${yn} == [Yy] ]]; then
		
			if [[ ${sh_new_type} == "github" ]]; then
				wget -N --no-check-certificate "https://raw.githubusercontent.com/0079123/myBusiness/master/Docker/shell/Docker.sh" && chmod +x Docker.sh
			#else
				###预留
			fi
			echo -e "脚本已更新为最新版本[ ${sh_new_ver} ] !"
		else
			echo && echo "	已取消..." && echo
		fi
	else
		echo -e "当前已是最新版本[ ${sh_new_ver} ] !"
	fi
}

#显示菜单状态
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
echo -e "  Docker一键管理脚本 ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  ---- hhyykk | github.com/0079123 ---"
while :
do
echo && echo -e "请输入一个数字来选择选项
 ${Green_font_prefix}1.${Font_color_suffix} 安装 Docker
 ${Green_font_prefix}2.${Font_color_suffix} 卸载 Docker
————————————————————
 ${Green_font_prefix}3.${Font_color_suffix} 启动 Docker 
 ${Green_font_prefix}4.${Font_color_suffix} 停止 Docker
 ${Green_font_prefix}5.${Font_color_suffix} 重启 Docker
 ${Green_font_prefix}6.${Font_color_suffix} 设置开机自启
————————————————————
 ${Green_font_prefix}7.${Font_color_suffix} 创建 Nginx
 ${Green_font_prefix}8.${Font_color_suffix} 创建 Tomcat
 ${Green_font_prefix}9.${Font_color_suffix} 创建 Mysql
————————————————————
 ${Green_font_prefix}10.${Font_color_suffix}更新脚本
 ${Green_font_prefix}0.${Font_color_suffix} 退出菜单
————————————————————" && echo
menu_status
stty erase '^H' && read -p " 请输入数字 [0-10]:" num
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
	Update_Shell
	;;
	*)
	echo "请输入正确数字 [1-10]"
	;;
esac
done
