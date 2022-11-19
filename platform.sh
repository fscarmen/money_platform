#!/bin/bash

# 更新日期 2022-10-31

PLATFORM=("watchtower" "traffmonetizer" "bitping" "repocket" "peer2profit" "psclient")
REPOSITORY=("containrrr/watchtower" "traffmonetizer/cli" "bitping/bitping-node" "repocket/repocket" "peer2profit/peer2profit_linux" "packetstream/psclient")
PLATFORM_NUM="${#PLATFORM[*]}"

# 自定义字体彩色，read 函数，安装依赖函数
red() { echo -e "\033[31m\033[01m$1$2\033[0m"; }
green() { echo -e "\033[32m\033[01m$1$2\033[0m"; }
yellow() { echo -e "\033[33m\033[01m$1$2\033[0m"; }
reading() { read -rp "$(green "$1")" "$2"; }

# 必须以root运行脚本
check_root() {
  [ $(id -u) != 0 ] && red " The script must be run as root, you can enter sudo -i and then download and run again. \n" && exit 1
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
    [[ $(tr '[:upper:]' '[:lower:]' <<< "$SYS") =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && break
  done

  [ -z "$SYSTEM" ] && red " ERROR: The script supports Debian, Ubuntu, CentOS or Alpine systems only. \n" && exit 1
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
  [[ ! "$ARCHITECTURE" =~ aarch64|x64|x86_64|amd64 ]] && red " ERROR: Unsupported architecture: $ARCHITECTURE \n" && exit 1
}

error_input() {
  [ "$ERROR" = 1 ] && red "\n ERROR: Wrong choice. " && sleep 1 || ERROR=1
}

# 选择平台，并输入账户信息
choose_platform() {
  until [[ "$CHOOSE" = [1-$((PLATFORM_NUM - 1 ))] ]]; do
    error_input
    yellow "\n Install or change account information:\n 1. Traffmonetizer\n 2. Bitping\n 3. Repocket\n 4. Peer2profit\n 5. PacketStream\n " && reading " Choose [1-$((PLATFORM_NUM - 1 ))]: " CHOOSE
  done

  [[ "$CHOOSE" = [23] && ! "$ARCHITECTURE" =~ x64|x86_64|amd64 ]] && red " ERROR: ${PLATFORM[$CHOOSE]} support amd64 only. \n" && exit 1
  case "$CHOOSE" in
    1 ) case "$ARCHITECTURE" in
          aarch64 ) ARCH=arm64v8 ;;
          x64|x86_64|amd64 ) ARCH=latest ;;
        esac
        [ -z "$TMTOKEN" ] && reading " Enter your Traffmonetizer token: " TMTOKEN
        [ -z "$TMTOKEN" ] && red " ERROR: Wrong account message. \n" && exit 1 ;;
    2 ) ;;
    3 ) [ -z "$EMAIL" ] && reading " Enter your Email: " EMAIL
        [ -z "$PASSWORD" ] && reading " Enter your password: " PASSWORD
        [[ -z "$EMAIL" || -z "$PASSWORD" ]] && red " ERROR: Wrong account message. \n" && exit 1 ;;
    4 ) [ -z "$EMAIL" ] && reading " Enter your Email: " EMAIL
        [ -z "$EMAIL" ] && red " ERROR: Wrong account message. \n" && exit 1 ;;
    5 ) [ -z "$CID" ] && reading " Enter your CID: " CID
        [ -z "$CID" ] && red " ERROR: Wrong account message. \n" && exit 1 ;;
    * ) red " ERROR: Wrong choose. \n" && unset CHOOSE && choose_platform ;;
  esac
}

container_build() {
  build_1() { 
    docker rm -f ${PLATFORM[$CHOOSE]} 2>/dev/null || true && docker run -d --name ${PLATFORM[$CHOOSE]} --restart=always ${REPOSITORY[$CHOOSE]}:$ARCH start accept --token "$TMTOKEN"
  }

  build_2() {
    RUN_MODE=d && [ ! -e $HOME/.bitping/credentials.json ] && RUN_MODE=it && mkdir -p $HOME/.bitping/
    docker rm -f ${PLATFORM[$CHOOSE]} 2>/dev/null || true && docker run -$RUN_MODE --name ${PLATFORM[$CHOOSE]} --mount type=bind,source="$HOME/.bitping/",target=/root/.bitping ${REPOSITORY[$CHOOSE]}
  }

  build_3() {
    docker rm -f ${PLATFORM[$CHOOSE]} 2>/dev/null || true && docker run -d --name ${PLATFORM[$CHOOSE]} --restart=always -e RP_EMAIL=$EMAIL -e RP_PASSWORD=$PASSWORD ${REPOSITORY[$CHOOSE]}
  }

  build_4() {
    export P2P_EMAIL=$EMAIL
    docker rm -f ${PLATFORM[$CHOOSE]} 2>/dev/null || true && docker run -d --name ${PLATFORM[$CHOOSE]} --restart always -e P2P_EMAIL=$P2P_EMAIL ${REPOSITORY[$CHOOSE]}
  }

  build_5() {
    docker rm -f ${PLATFORM[$CHOOSE]} 2>/dev/null || true && docker run -d --name ${PLATFORM[$CHOOSE]} --restart always -e CID=$CID ${REPOSITORY[$CHOOSE]}
  }

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
  # 限定输入范围
  until [[ "$REMOVE" = [0-$PLATFORM_NUM] ]]; do
    error_input
    yellow "\n 0. Watchtower\n 1. Traffmonetizer\n 2. Bitping\n 3. Repocket\n 4. Peer2profit\n 5. PacketStream\n 6. Above all\n " && reading " Remove choose [0-${#PLATFORM[*]}]: " REMOVE
  done

  if [ "$REMOVE" = "${#PLATFORM[*]}" ]; then
    docker rm -f ${PLATFORM[*]} 2>/dev/null
    docker rmi -f ${REPOSITORY[*]} 2>/dev/null
    [ -d $HOME/.bitping ] && rm -rd $HOME/.bitping
  else
    docker rm -f ${PLATFORM[$REMOVE]} 2>/dev/null
    docker rmi -f ${REPOSITORY[$REMOVE]} 2>/dev/null
    case "$REMOVE" in
      2 ) [ -d $HOME/.bitping ] && rm -rd $HOME/.bitping ;;
      4 ) unset P2P_EMAIL ;;
    esac
  fi
  green "\n Uninstall containers and images complete. \n"
  exit 0
}


# 主程序1
check_root
check_operating_system
check_ipv4
check_arch

# 传参
while getopts "Uu" OPTNAME; do
  case "$OPTNAME" in
    'U'|'u' ) uninstall ;;
  esac
done

# 主程序2
choose_platform
container_build
towerwatch_build
result
