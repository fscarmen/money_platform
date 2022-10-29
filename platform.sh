#!/bin/bash

# 更新日期 2022-10-29

PLATFORM=("watchtower" "traffmonetizer" "bitping" "repocket")

# 自定义字体彩色，read 函数，安装依赖函数
red() { echo -e "\033[31m\033[01m$1$2\033[0m"; }
green() { echo -e "\033[32m\033[01m$1$2\033[0m"; }
yellow() { echo -e "\033[33m\033[01m$1$2\033[0m"; }
reading() { read -rp "$(green "$1")" "$2"; }

# 必须以root运行脚本
check_root() {
  [[ $(id -u) != 0 ]] && red " The script must be run as root, you can enter sudo -i and then download and run again. \n" && exit 1
}

# 判断系统，并选择相应的指令集
check_operating_system() {
  CMD=("$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2)"
       "$(hostnamectl 2>/dev/null | grep -i system | cut -d : -f2)"
       "$(lsb_release -sd 2>/dev/null)" "$(grep -i description /etc/lsb-release 2>/dev/null | cut -d \" -f2)"
       "$(grep . /etc/redhat-release 2>/dev/null)"
       "$(grep . /etc/issue 2>/dev/null | cut -d \\ -f1 | sed '/^[ ]*$/d')"
      )

  for i in "${CMD[@]}"; do SYS="$i" && [[ -n $SYS ]] && break; done

  REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|amazon linux|alma|rocky")
  RELEASE=("Debian" "Ubuntu" "CentOS")
  PACKAGE_UPDATE=("apt -y update" "apt -y update" "yum -y update")
  PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install")
  PACKAGE_UNINSTALL=("apt -y autoremove" "apt -y autoremove" "yum -y autoremove")

  for ((int = 0; int < ${#REGEX[@]}; int++)); do
    [[ $(echo "$SYS" | tr '[:upper:]' '[:lower:]') =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && break
  done

  [[ -z $SYSTEM ]] && red " ERROR: The script supports Debian, Ubuntu, CentOS or Alpine systems only. \n" && exit 1
}

# 判断宿主机的 IPv4 或双栈情况,没有拉取不了 docker
check_ipv4() {
  [[ ! $(curl -s4m8 ip.sb) =~ ^([0-9]{1,3}\.){3} ]] && red " ERROR：The host must have IPv4. \n" && exit 1
}

# 查是否已经安装容器
check_install() {
  [ $(type -p docker) ] && [[ $(docker ps -a) =~ $CONTAIN_NAME ]] && red " Repocket has been installed. The script exits. \n" && exit 1
}

# 判断 CPU 架构
check_arch() {
  ARCHITECTURE=$(uname -m)
  case "$ARCHITECTURE" in
    aarch64 ) ARCH=arm64v8 ;;
    x64|x86_64|amd64 ) ARCH=latest ;;
    * ) red " ERROR: Unsupported architecture: $ARCHITECTURE \n" && exit 1 ;;
  esac
}

# 选择平台，并输入账户信息
choose_platform() {
  [ -z "$CHOOSE" ] && yellow " 1. Traffmonetizer\n 2. Bitping\n 3. Repocket\n " && reading " Choose: " CHOOSE
  [[ "$CHOOSE" = [23] && ! "$ARCHITECTURE" =~ x64|x86_64|amd64 ]] && red " ERROR: ${PLATFORM[$CHOOSE]} support amd64 only. \n" && exit 1 
  [ $(type -p docker) ] && [[ $(docker ps -a) =~ ${PLATFORM[$CHOOSE]} ]] && red " ${PLATFORM[$CHOOSE]} has been installed. The script exits. \n" && exit 1
  case "$CHOOSE" in
    1 ) [ -z "$TMTOKEN" ] && reading " Enter your Traffmonetizer token: " TMTOKEN
        [ -z "$TMTOKEN" ] && red " ERROR: Wrong account message. \n" && exit 1 ;;
    2 )  ;;
    3 ) [ -z "$EMAIL" ] && reading " Enter your Email: " EMAIL
        [ -z "$PASSWORD" ] && reading " Enter your password: " PASSWORD
        [[ -z "$EMAIL" || -z "$PASSWORD" ]] && red " ERROR: Wrong account message. \n" && exit 1 ;;
    * ) red " ERROR: Wrong choose. \n" && unset CHOOSE && choose_platform ;;
  esac
}

container_build() {
  build_1() { docker run -d --name ${PLATFORM[$CHOOSE]} --restart=always traffmonetizer/cli:$ARCH start accept --token "$TMTOKEN"; }
  build_2() {
    mkdir -p $HOME/.bitping/
    docker run -it --name ${PLATFORM[$CHOOSE]} --mount type=bind,source="$HOME/.bitping/",target=/root/.bitping bitping/bitping-node:latest
  }
  build_3() { docker run -d --name ${PLATFORM[$CHOOSE]} --restart=always -e RP_EMAIL=$EMAIL -e RP_PASSWORD=$PASSWORD repocket/repocket; }

  # 宿主机安装 docker
  if ! systemctl is-active docker >/dev/null 2>&1; then
  yellow "\n Install docker"
    if [ $SYSTEM = "CentOS" ]; then
      ${PACKAGE_INSTALL[int]} yum-utils
      yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
      ${PACKAGE_INSTALL[int]} docker-ce docker-ce-cli containerd.io
      systemctl enable --now docker
    else
      ${PACKAGE_INSTALL[int]} docker.io
    fi
  fi
  # 创建容器
  yellow "\n Create the ${PLATFORM[$CHOOSE]} container. \n"
  build_$CHOOSE
  
}

# 安装 watchtower ，以实时同步官方最新镜像
towerwatch_build() {
  [[ ! $(docker ps -a) =~ 'watchtower' ]] && yellow " Install Watchtower. \n" && docker run -d --name watchtower --restart always  -p 2095:8080 -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --cleanup
}

# 显示结果
result() {
  docker ps -a | grep -q "${PLATFORM[$CHOOSE]}" && docker ps -a | grep -q "watchtower" && green " Install success. \n" || red " install fail. \n"
}

# 卸载
uninstall() {
  docker rm -f ${PLATFORM[*]} 2>/dev/null
  docker rmi -f $(docker images | grep ${PLATFORM[0]} | awk '{print $3}') $(docker images | grep ${PLATFORM[1]} | awk '{print $3}') $(docker images | grep ${PLATFORM[2]} | awk '{print $3}') $(docker images | grep ${PLATFORM[3]} | awk '{print $3}')2>/dev/null
  green "\n Uninstall containers and images complete. \n"
  exit 0
}


# 主程序1
check_root
check_operating_system
check_ipv4
check_arch

# 传参
while getopts "UuT:t:E:e:P:p:" OPTNAME; do
  case "$OPTNAME" in
    'U'|'u' ) uninstall ;;
    'T'|'t' ) TM_TOKEN ;;
    'E'|'e' ) EMAIL=$OPTARG ;;
    'P'|'p' ) PASSWORD=$OPTARG ;;
  esac
done

# 主程序2
choose_platform
container_build
towerwatch_build
result
