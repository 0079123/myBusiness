#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS/Debian/Ubuntu
#	Description: openssl
#	Version: 1.0.7
#	Author: hhyykk
#	Date: 2018-9-5
#=================================================
sh_ver="1.0.7"
ssl_file="/home/ssl"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

#检查系统
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

Use_IP(){
check_sys
[[ ${release} != "debian" ]] && [[ ${release} != "ubuntu" ]] && [[ ${release} != "centos" ]] && echo -e "${Error} 本脚本不支持当前系统 ${release} !" && exit 1
	Create_By_Ip
}

Use_Domain(){
check_sys
[[ ${release} != "debian" ]] && [[ ${release} != "ubuntu" ]] && [[ ${release} != "centos" ]] && echo -e "${Error} 本脚本不支持当前系统 ${release} !" && exit 1
	Create_By_Domain
}
Create_By_Ip(){
	echo -e "${Info} 开始编辑配置信息..."
	Create_IP_config
	echo -e "${Info} 开始创建证书..."
	Creat_IP_Cert
	echo -e "${Info} 证书创建完成..."
	echo -e "${Info} 证书路径${ssl_file}"
}
Create_IP_config(){
	read -p "请输入使用的IP:" Cip
	if [ -z "${Cip}" ];then
		 echo -e "${Error} IP不能为空!" && exit 1
	fi
	mkdir -p ${ssl_file}
	cd  ${ssl_file}
	cat > cert_ip.conf << END_TEXT
[ req ]
default_bits        = 2048
default_keyfile     = server-key.pem
distinguished_name  = subject
req_extensions      = req_ext
x509_extensions     = x509_ext
string_mask         = utf8only
# The Subject DN can be formed using X501 or RFC 4514 (see RFC 4519 for a description).
#   Its sort of a mashup. For example, RFC 4514 does not provide emailAddress.
[ subject ]
countryName         = Country Name (2 letter code)
countryName_default     = CN

stateOrProvinceName     = State or Province Name (full name)
stateOrProvinceName_default = FJ

localityName            = Locality Name (eg, city)
localityName_default        = Xiamen

organizationName         = Organization Name (eg, company)
organizationName_default    = example  Inc.

# Use a friendly name here because its presented to the user. The server's DNS
#   names are placed in Subject Alternate Names. Plus, DNS names here is deprecated
#   by both IETF and CA/Browser Forums. If you place a DNS name here, then you
#   must include the DNS name in the SAN too (otherwise, Chrome and others that
#   strictly follow the CA/Browser Baseline Requirements will fail).
commonName          = Common Name (e.g. server FQDN or YOUR name)
commonName_default      = Example Company

emailAddress            = Email Address
emailAddress_default        = test@example.com

# Section x509_ext is used when generating a self-signed certificate. I.e., openssl req -x509 ...
[ x509_ext ]

subjectKeyIdentifier        = hash
authorityKeyIdentifier  = keyid,issuer

# You only need digitalSignature below. *If* you don't allow
#   RSA Key transport (i.e., you use ephemeral cipher suites), then
#   omit keyEncipherment because that's key transport.
basicConstraints        = CA:TRUE
keyUsage            = digitalSignature, keyEncipherment
subjectAltName          = @alternate_names
nsComment           = "comment"

# RFC 5280, Section 4.2.1.12 makes EKU optional
#   CA/Browser Baseline Requirements, Appendix (B)(3)(G) makes me confused
#   In either case, you probably only need serverAuth.
extendedKeyUsage  = serverAuth, clientAuth

# Section req_ext is used when generating a certificate signing request. I.e., openssl req ...
[ req_ext ]

subjectKeyIdentifier        = hash

basicConstraints        = CA:FALSE
keyUsage            = digitalSignature, keyEncipherment
subjectAltName          = @alternate_names
nsComment           = "comment"

# RFC 5280, Section 4.2.1.12 makes EKU optional
#   CA/Browser Baseline Requirements, Appendix (B)(3)(G) makes me confused
#   In either case, you probably only need serverAuth.
extendedKeyUsage  = serverAuth, clientAuth

[ alternate_names ]
IP.1         = ${Cip}
# IPv6 localhost
# DNS.8     = ::1

END_TEXT
}
Creat_IP_Cert(){
	cd ${ssl_file}
	read -p "请输入证书有效时间 单位年(默认10年):" CY
	if [ -z "${CY}" ];then
		CY="10"
	fi
		CY=$((${CY}*365))
	openssl req -config cert_ip.conf \
	-new -x509 -sha256 -newkey rsa:2048 -nodes \
	-keyout ${ssl_file}/cert.key -days ${CY} \
	-out ${ssl_file}/cert.crt
}

Create_By_Domain(){
	echo -e "${Info} 开始编辑配置信息..."
	Create_Domain_config
	echo -e "${Info} 开始创建证书..."
	Creat_Domain_Cert
	echo -e "${Info} 证书创建完成..."
	echo -e "${Info} 证书路径${ssl_file}"
}
Create_Domain_config(){
	read -p "请输入使用的域名:" Cdomain
	if [ -z "${Cdomain}" ];then
		 echo -e "${Error} 域名不能为空!" && exit 1
	fi
	mkdir -p ${ssl_file}
	cd  ${ssl_file}
	cat > cert_domain.conf << END_TEXT
[ req ]
default_bits        = 2048
default_keyfile     = server-key.pem
distinguished_name  = subject
req_extensions      = req_ext
x509_extensions     = x509_ext
string_mask         = utf8only
# The Subject DN can be formed using X501 or RFC 4514 (see RFC 4519 for a description).
#   Its sort of a mashup. For example, RFC 4514 does not provide emailAddress.
[ subject ]
countryName         = Country Name (2 letter code)
countryName_default     = CN

stateOrProvinceName     = State or Province Name (full name)
stateOrProvinceName_default = FJ

localityName            = Locality Name (eg, city)
localityName_default        = Xiamen

organizationName         = Organization Name (eg, company)
organizationName_default    = example  Inc.

# Use a friendly name here because its presented to the user. The server's DNS
#   names are placed in Subject Alternate Names. Plus, DNS names here is deprecated
#   by both IETF and CA/Browser Forums. If you place a DNS name here, then you
#   must include the DNS name in the SAN too (otherwise, Chrome and others that
#   strictly follow the CA/Browser Baseline Requirements will fail).
commonName          = Common Name (e.g. server FQDN or YOUR name)
commonName_default      = Example Company

emailAddress            = Email Address
emailAddress_default        = test@example.com

# Section x509_ext is used when generating a self-signed certificate. I.e., openssl req -x509 ...
[ x509_ext ]

subjectKeyIdentifier        = hash
authorityKeyIdentifier  = keyid,issuer

# You only need digitalSignature below. *If* you don't allow
#   RSA Key transport (i.e., you use ephemeral cipher suites), then
#   omit keyEncipherment because that's key transport.
basicConstraints        = CA:TRUE
keyUsage            = digitalSignature, keyEncipherment
subjectAltName          = @alternate_names
nsComment           = "comment"

# RFC 5280, Section 4.2.1.12 makes EKU optional
#   CA/Browser Baseline Requirements, Appendix (B)(3)(G) makes me confused
#   In either case, you probably only need serverAuth.
extendedKeyUsage  = serverAuth, clientAuth

# Section req_ext is used when generating a certificate signing request. I.e., openssl req ...
[ req_ext ]

subjectKeyIdentifier        = hash

basicConstraints        = CA:FALSE
keyUsage            = digitalSignature, keyEncipherment
subjectAltName          = @alternate_names
nsComment           = "comment"

# RFC 5280, Section 4.2.1.12 makes EKU optional
#   CA/Browser Baseline Requirements, Appendix (B)(3)(G) makes me confused
#   In either case, you probably only need serverAuth.
extendedKeyUsage  = serverAuth, clientAuth

[ alternate_names ]
DNS.1 = ${Cdomain}
DNS.2 = localhost
DNS.3 = 127.0.0.1
# IPv4 localhost
IP.1 = 127.0.0.1
# IPv6 localhost
IP.2 = ::1
END_TEXT
}
Creat_Domain_Cert(){
	cd ${ssl_file}
	read -p "请输入证书有效时间 单位年(默认10年):" CY
	if [ -z "${CY}" ];then
		CY="10"
	fi
		CY=$((${CY}*365))
	openssl req -config cert_domain.conf \
	-new -x509 -sha256 -newkey rsa:2048 -nodes \
	-keyout ${ssl_file}/cert.key -days ${CY} \
	-out ${ssl_file}/cert.crt

}
Update_Shell(){
echo -e "当前版本为 [ ${sh_ver} ]，开始检测最新版本..."
	
	sh_new_ver=$(wget --no-check-certificate -qO- "https://raw.githubusercontent.com/0079123/myBusiness/master/Docker/shell/CA.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1) && sh_new_type="github"
	[[ -z ${sh_new_ver} ]] && echo -e "${Error} 检测最新版本失败 !" && exit 0
	if [[ ${sh_new_ver} != ${sh_ver} ]]; then
		echo -e "发现新版本[ ${sh_new_ver} ]，是否更新？[Y/n]"
		stty erase '^H' && read -p "(默认: y):" yn
		[[ -z "${yn}" ]] && yn="y"
		if [[ ${yn} == [Yy] ]]; then
		
			if [[ ${sh_new_type} == "github" ]]; then
				wget -N --no-check-certificate "https://raw.githubusercontent.com/0079123/myBusiness/master/Docker/shell/CA.sh" && chmod +x CA.sh
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


check_sys
[[ ${release} != "debian" ]] && [[ ${release} != "ubuntu" ]] && [[ ${release} != "centos" ]] && echo -e "${Error} 本脚本不支持当前系统 ${release} !" && exit 1
echo -e "  SSL私有证书 一键管理脚本 ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  ---- hhyykk | github.com/0079123 --"
echo && echo -e "请输入一个数字来选择选项
 ${Green_font_prefix}1.${Font_color_suffix} 仅使用IP
 ${Green_font_prefix}2.${Font_color_suffix} 使用域名
 ${Green_font_prefix}3.${Font_color_suffix} 升级脚本
——————————————
 ${Green_font_prefix}0.${Font_color_suffix} 退出菜单
——————————————" && echo

stty erase '^H' && read -p " 请输入数字 [0-2]:" num
case "$num" in
	0)
	exit
	;;
	1)
	Use_IP
	;;
	2)
	Use_Domain
	;;
	3)
	Update_Shell	
	;;
	*)
	echo "请输入正确数字 [0-2]"
	;;
esac
