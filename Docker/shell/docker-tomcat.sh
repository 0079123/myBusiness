#!/bin/bash
#Author:hhyykk
#Version:1.0
#Date:2018-8-17
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
	-v $tomcatPath/webapps:/usr/local/tomcat/webapps \
	-v $tomcatPath/logs:/usr/local/tomcat/logs \
	-v /etc/localtime:/etc/localtime:ro \
	-e TZ="Asia/Shanghai" \
	-p $tomcatPort:8080 \
	tomcat:$tag
echo 
echo
echo "================$cName container has been created================"
echo
echo "容器名称：$cName"
echo
echo "日志路径:$tomcatPath/logs
echo
echo "工程路径:$tomcatPath/webapps"
echo
