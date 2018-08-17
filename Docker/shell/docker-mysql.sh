#!/bin/bash
#Author:hhyykk
#Version:1.0
#Date:2018-8-17

read -p "请选择版本号(默认 5):" tag
read -p "请输入容器名称(默认 mysql):" cName
read -p "请输入部署mysql的路径(默认 /home/mysql):" mysqlPath
read -p "请设置root密码(默认 123456):" msyqlPsswd
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
docker run  --name $cName -d \
	-v $mysqlPath/conf:/etc/mysql/conf.d \
	-v $mysqlPath/data:/var/lib/mysql \
	-e MYSQL_ROOT_PASSWORD=$msyqlPsswd \
	-p $msyqlPort:3306 \
	mysql:$tag
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
