#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS/Debian/Ubuntu
#	Description: BeautyHome Docker ENV.
#	Version: 1.0.2
#	Author: hhyykk
#	Date: 2019-1-29
#=================================================

sh_ver="1.0.2"
docker_file="/usr/bin/docker"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

#Check_sys
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

#Option1 Install Docker
Install_docker(){
	[[ -e ${docker_file} ]] && echo -e "${Error} 检测到 Docker 已安装 !" && exit 1
	check_sys
	Initialization
	echo -e "${Info} 开始下载..."
	Download_docker
	echo -e "${Info} 开始安装..."
	Install_script
    echo -e "${Info} 所有步骤 安装完毕，开始启动..."
    AddGroup_to_docker
    echo -e "${Info} 当前版本..."
	Show_version
	echo -e " "
	menu_status
}

#Option2 Uninstall Docker
Uninstall_docker(){
	if [[ ${release} == "centos" ]]; then
		Centos_unstall
	else
		Other_unstall
	fi
	echo -e " "
	menu_status
}

#Option3 Start Docker Service
Start_docker(){
	check_installed_status
    check_pid
	[[ ! -z ${PID} ]] && echo -e "${Error} Docker 正在运行，请检查 !" && exit 1
    sudo service docker start
	check_test
	echo -e " "
    menu_status
}

#Option4 Stop Docker Service
Stop_docker(){
	check_installed_status
	check_pid
	[[ -z ${PID} ]] && echo -e "${Error} Docker 没有运行，请检查 !" && exit 1
    sudo service docker stop
	echo -e " "
	menu_status
}

#Option5 Restart Docker Service
Restart_docker(){
	check_installed_status
	check_pid
    sudo service docker restart
	echo -e " "
	menu_status
}

#Option6 Enable Autostart
Autostart_docker(){
	sudo systemctl enable docker
}

#Option7 Create container
Create_tomcat(){
    read -p "请选择版本号(默认最新版):" tag
    read -p "请输入容器名称(默认 tomcat):" cName
    read -p "请输入部署mysql的路径(默认 /home/tomcat):" tomcatPath
    if [ -z "${tag}" ];then
		tag="latest"
	fi        
    if [ -z "${cName}" ];then
		cName="tomcat"
	fi
    if [ -z "${tomcatPath}" ];then
		tomcatPath="/home/tomcat"
	fi

	sudo docker run --name $cName -d \
		--restart=unless-stopped \
		-v $tomcatPath/webapps:/usr/local/tomcat/webapps \
		-v $tomcatPath/webapps/ROOT:/usr/local/tomcat/webapps/ROOT \
		-v $tomcatPath/logs:/usr/local/tomcat/logs \
		-v /etc/localtime:/etc/localtime:ro \
		-e TZ="Asia/Shanghai" \
		--net=host \
		tomcat:$tag
		if docker ps -a | grep $cName |awk {'print $(NF)'} ;then		
			Show_result_tomcat
	
		else
			echo -e "${Error} docker容器创建失败 请检查!"
	fi
}

Initialization(){
	if [[ ${release} == "centos" ]]; then
		Centos_Init
	else
		Other_Init
	fi
}

Download_docker(){
	curl -fsSL get.docker.com -o get-docker.sh
}

Install_script(){
	sudo sh get-docker.sh --mirror Aliyun
}

AddGroup_to_docker(){
	sudo usermod -aG docker $USER
}

Show_version(){
	docker version
}

Centos_Init(){
	sudo yum remove docker \
		docker-common \
		docker-selinux \
		docker-engine -y
#   sudo yum update
#	sudo yum install -y yum-utils \
#	device-mapper-persistent-data \
#	lvm2 
}


Centos_unstall(){
	sudo yum remove -y docker-* 
}

Other_Init(){
    sudo apt-get remove docker\
		docker-engine\
		docker.io -y
#    sudo apt-get update 
#	sudo apt-get -y install \
#	apt-transport-https \
#	ca-certificates \
#	curl \
#	gnupg2 \
#	lsb-release \
#	software-properties-common 
}

Other_unstall(){
	sudo apt-get -y remove docker-*
}

Show_result_tomcat(){
	echo 
	echo
	echo "================$cName container has been created================"
	echo
	echo "容器名称:$cName"
	echo
	echo "日志路径:$tomcatPath/logs"
	echo
	echo "工程路径:$tomcatPath/webapps"
	echo
}
check_test(){
	if [[ -e ${docker_file} ]]; then
		check_pid
	if [[ ! -z "${PID}" ]]; then
		egg_pic
	else
		echo -e " 当前状态: ${Green_font_prefix}已安装${Font_color_suffix} 但 ${Red_font_prefix}未启动${Font_color_suffix}"
	fi
	else
		echo -e " 当前状态: ${Red_font_prefix}未安装${Font_color_suffix}"
	fi
}


egg_pic(){
echo -e "
	,@@@@@@@@@@,,@@@@@@@%  .#&@@@&&.,@@@@@@@@@@,      %@@@@@@%*   ,@@@%     .#&@@@&&.  *&@@@@&(  ,@@@@@@@%  %@@@@@,     ,@@,          
		,@@,    ,@@,      ,@@/   ./.    ,@@,          %@%   ,&@# .&@&@@(   .@@/   ./. #@&.  .,/  ,@@,       %@%  *&@&.  ,@@,          
		,@@,    ,@@&%%%%. .&@@/,        ,@@,          %@%   ,&@# %@& /@@,  .&@@/,     (@@&%(*.   ,@@&%%%%.  %@%    &@#  ,@@,          
		,@@,    ,@@/,,,,    ./#&@@@(    ,@@,          %@@@@@@%* /@@,  #@&.   ./#&@@@(   *(%&@@&. ,@@/,,,,   %@%    &@#  .&&.          
		,@@,    ,@@,      ./,   .&@#    ,@@,          %@%      ,@@@@@@@@@% ./.   .&@# /*.   /@@. ,@@,       %@%  *&@&.   ,,           
		,@@,    ,@@@@@@@% .#&@@@@&/     ,@@,          %@%     .&@#     ,@@/.#&@@@@&/   /%&@@@@.  ,@@@@@@@%  %@@@@@.     ,@@,          
,*************,,*/(((((//,,*(#%%%%%%%%%%%%%%%#(*,,,****************************************************,*/(((((((((/((((////****/((##%%%%%%
,*************,,//((((((//,,*(%%%%%%%%%%%%%%%%%##/*****************************************************,,*/(///(//////****//((##%%%%%%%%%%%
,************,,*/(((((((//***/#%%%%%%%%%%%%%%%%%%%#(/***************************************************,*//////////*//((#%%%%%%%%%%%%%%%%%
,***********,,*////////////***/##%%%%%%%%%%%%%%%%%%%##(*,***********************************************,,*////////(###%%%%%%%%%%%%%%%%%%%%
,**********,,,*/*******//////**/(#%%%%%%%%%%%%%%%%%%%%%#(/**********************************************,,,***/(##%%%%%%%%%%%%%%%%%%%%%%%%%
,*********,,,,*************///***/(#%%%%%%%%%%%%%%%%%%%%%%#(/***********************************,****,****/((#%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
,*********,,,***************//****/(##%%%%%%%%%%%%%%%%%%%%%%##//**************//////////////////////((#####%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#(
,********,,,,***********************/(#%%%%%%%%%%%%%%%%%%%%%%%##################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%##(/
,*******,..,***********************,,*/##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%###((//
,*******,.,,***********************,,,,*(#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%##(//**//
,******,.,,,************************,,,,*/(#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#(//*******
,*****,,,,,********,***,,,,,,,,,,,,*,,,,,,*/(######%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%##(/**********
,*****,..,*******,,,,,,,,,,,,,,,,,,,,,,*,,,,*///((#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%###(/************
,*****,,,*******,,,,,*,,,,,,,,,,,,,,,,,****,,,*/(#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#######(//**************
,****,.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,**,,,/(%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#((//******************
,***,..,,,,,,,,,,,,,,,,,,,,,,,,,,,,,..,,,,,,,*(#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#(/*******************
,**,,.,,,,,,,,,,,,,,,,,,,,,,,,,,.......,,,,,,/#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#####%%%%%%%%%%%%%%%%#(/******************
,**,..,,,,,,,,,,,,,,,,,,,,,,,,,......,,,*,,,*(#%%%%%%%%##(((/(##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%##(((/*/((#%%%%%%%%%%%%%%#(/*****************
,*,..,,,,,,,,,,,,,,,,,,,,,,,,,,,.....,,**,,*/#%%%%%%%##((((*,**/#%%%%%%%%%%%%%%%%%%%%%%%%%%%%##((##/,,,*(#%%%%%%%%%%%%%%#(*****************
.*,.,,,**,,,,,,,,,,,,,,,,,,,,,,,,,,*****,,,/(%%%%%%%%#(//(#/,..*/#%%%%%%%%%%%%%%%%%%%%%%%%%%%#(//(#/,..,/(#%%%%%%%%%%%%%%#/*****///////////
.,..,,,,,,,,,,,,,,,,,,,,,,,,,,*,,*******,,,(#%%%%%%%%#(*,,,....,/#%%%%%%%%%%%%%%%%%%%%%%%%%%%#(*,,,....,/(#%%%%%%%%%%%%%%#(*,**////////////
.,..,,,,,,,,,...........,,,,,,*,********,,*(#%%%%%%%%%#(/*,,...,/#%%%%%%%%%%%%%%%%%%%%%%%%%%%%#(/*,,..,*/##%%%%%%%%%%%%%%%#(***////////////
...,,,,,,,................,,*,**********,,/#%%%%%%%%%%%%#((////((#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%##((///(#%%%%%%%%%%%%%%%%%%(/**////////////
 ..,,,,,,.................,,,**********,,*(#%%%%%%%%%%%%%%%%%%#%%%%%%%%#((///((#%%%%%%%%%%%%%%%%%%%%%#%%%%%%%%%%%%%%%%%%%%%#/**////////////
.,,,,,,,,.................,,***********,,/(####%%%%%%%%%%%%%%%%%%%%%%%%#(/*,,,*(#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#(/*////////////
.,***,,,,,,..............,,,**********,..,***//((##%%%%%%%%%%%%%%%%%%%%%%%##((##%%%%%%%%%%%%%%%%%%%%%%%%%##(((((((((###%%%%%#/**///////////
.*****,,,,,,,,,,,,,,,,,,,*************,..,*******/(#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%##///*//////((#%%%%%#(**///////////
.****************/******/***////*****,.,*///////**/#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#(////////////(#%%%%%#/**//////////
.***********************/////*******,..,*//////////(#%%%%%%%%%%%%%%%%%%%%##########%%%%%%%%%%%%%%%%%%%%#(///////////*/(#%%%%%#(***/////////
.************************///********,..,*//////////#%%%%%%%%%%%%%%%%%%#(//*****///(((##%%%%%%%%%%%%%%%%#(///////////**/##%%%%##/***////////
.***********************************,.,,***///////(#%%%%%%%%%%%%%%%%#(/*,,,*//((((////(#%%%%%%%%%%%%%%%#((////////////(#%%%%%%#(*********//
,***********,,,*,,*,,**************,,,*//******//(#%%%%%%%%%%%%%%%%%#(*,,*/(((#####(((((#%%%%%%%%%%%%%%%##///////////(#%%%%%%%%#(***///////
,*************,,**,,,************,,,,,/(##((((####%%%%%%%%%%%%%%%%%%%(/**/(((#((((#((//(#%%%%%%%%%%%%%%%%%#(((((((((##%%%%%%%%%%#/**///////
,******************************,,,,,,,*(#%#%%%%%%%%%%%%%%%%%%%%%%%%%%#(**/((#(#(((#((//(#%%%%%%%%%%%%%%%%%%%%%%%#%#%%%%%%%%%%%%%#(**///////
,*************,**************,****,,,,,/(#%%%%%%%%%%%%%%%%%%%%%%%%%%%%#(/*/((((#((((///(#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%(/*///////
,*************************************,*/#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%##(////////////(#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#/**/////*
,******////****///////////////////////***/#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%####(((((((###%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#(********
.,*,****///////////////////////////////***/#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#(/*******
.,,,,*****//////////////////////////*******(#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%##(*******
.,,,,,,***********/////////////////********/(#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%(*******
"
}

#Show Menu status
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
echo -e "  美居部署脚本 ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  ---- hhyykk ----"
echo -e "*************************"
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
 ${Green_font_prefix}7.${Font_color_suffix} 创建 Tomcat
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
	Create_tomcat
	;;
	*)
	echo "请输入正确数字 [1-10]"
	;;
esac
done
