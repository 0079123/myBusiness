#!/bin/bash
#Author:hhyykk
#Version:1.0
#Date:2018-8-17

read -p "请选择版本号(默认 stable):" tag
read -p "请输入容器名称(默认 nginx):" cName
read -p "请输入部署nginx的路径(默认 /home/nginx):" nginxPath
read -p "请输入http的端口号(默认 80):" httpPort
read -p "请输入https的端口号(默认 443):" httpsPort
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
		httpPort="80"
	fi
	if [ -z "${httpsPort}" ];then
		httpsPort="443"
	fi
sudo docker run --name $cName -d\
	-v $nginxPath/log:/var/log/nginx\
	-v $nginxPath/conf:/etc/nginx/conf.d:ro\
	-v $nginxPath/html:/usr/share/nginx/html:ro\
	-p $httpPort:80  -p $httpsPort:443\
	nginx:$tag
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
