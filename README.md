# 撸钱平台一键式命令安装

* * *

# 目录

- [脚本特点](README.md#脚本特点)
- [安装和卸载](README.md#安装和卸载)
- [traffmonetizer 介绍（转述自 Google Play)](README.md#traffmonetizer-介绍转述自-google-play)
- [bitping 介绍 (转述自 极客元素)](README.md#bitping-介绍-转述自-极客元素)
- [repocket 介绍（转述自 官网)](README.md#repocket-介绍-转述自-官网)
- [peer2profit 介绍 (转述自 知乎)](README.md#peer2profit-介绍--转述自-知乎-)
- [PacketStream 介绍 (转述自 网络探索者)](README.md#packetstream-介绍--转述自-网络探索者-)
- [免责声明](README.md#免责声明)

* * *

## 脚本特点

* 多个集成多个撸钱平台，全部镜像均自来官方，统一安装管理

* 根据架构 AMD64 和 ARM64 自动选择和构建拉取的docker镜像，无需您手动修改官方案例安装。

* 使用 Watchtower 自动同步官方最新镜像，无需手动更新和重新输入参数。(Watchtower 是一款实现自动化更新 Docker 镜像与容器的实用工具.它监控着所有正在运行的容器以及相关镜像,当检测本地镜像与镜像仓库中的镜像有差异时,会自动拉取最新镜像并使用最初部署时的参数重新启动相应的容器.)

## 安装和卸载

### 交互式使用方法---注册链接注册后，复制左上角的token，运行脚本，粘贴token，回车，即可开始安装。

```shell
bash <(wget -qO- https://raw.githubusercontent.com/fscarmen/money_platform/main/platform.sh)
```

### 全部卸载

```shell
bash <(wget -qO- https://raw.githubusercontent.com/fscarmen/money_platform/main/platform.sh) -U
```

## traffmonetizer 介绍[（转述自 Google Play)](https://play.google.com/store/apps/details?id=com.traffmonetizer.client)

注册: https://traffmonetizer.com/?aff=196148

traffmonetizer 是一种允许用户通过分享您的流量来赚钱的选项。注册链接: https://traffmonetizer.com/?aff=196148

您共享的 1G 流量将获得 0.10 美元，并且此脚本支持数据中心网络或家庭带宽。

轻松在线赚钱！每个月，您都会以固定的月费获得无限的互联网流量包。大多数时候，有大量流量未被使用，您的连接处于空闲状态。出售一部分未使用的流量并开始赚取被动收入。

我们为什么要为此付费？数百家营销和广告代理商需要访问来自不同地区的客户网站，以确保他们的广告正常显示并检查其努力成果。这些公司向我们支付在不同地区收集数据的费用，而我们向您支付使用您的互联网流量收集这些数据的费用。

## bitping 介绍 [（转述自 极客元素）](https://www.geekmeta.com/article/1384361.html)

注册: https://app.bitping.com?r=n0zqXxLr

bitping: 真实的分布式用户数据智能平台

bitping 是一个强调真实数据的分布式、众包的智能网络。也是第一个收集真实的、可验证的用户数据的网络智能服务，并为此向节点支付实时费用。

（对于普通用户讲，就是挂机赚比特币）

## repocket 介绍 [（转述自 官网）](https://repocket.co/about-us/)

注册: https://link.repocket.co/ArVa

Repocket的创建是为了让任何能上网的人都能快速入门，赚取被动的副业收入。

## peer2profit 介绍 [ (转述自 知乎) ](https://zhuanlan.zhihu.com/p/439237654)

注册: https://p2pr.me/16526078526280cb6c30a08

全自动化挂机多平台赚钱，零成本可放大。

最先是平台的详细介绍。这一Peer2Profit平台是海外有悠久的历史的挂机平台。其工作原理与千寻以前讲解的平台类似。挂机市场销售设备的空余网络带宽可以得到盈利。

Peer2Profit较大的特征便是有Windows，Android，Mac，Linux等版本号的手机软件，可以根据电脑上和手机上挂机。并且可以在同一帐户下登陆的设备沒有限制，同一IP现阶段都没有挂机限定(这可能是bug，之后应当限制)。可是，从千寻的评测看来，一个IP挂两部设备是较好的，不然网络速度变卡到你开始怀疑人生。

## PacketStream 介绍 [ (转述自 网络探索者) ](https://www.nettsz.com/2641.html)

注册: https://packetstream.io/?psr=4Qpr

PacketStream是一个成立于2018年的P2P点对点代理网络平台。允许用户将自己的闲置带宽进行共享以获得相应的报酬。共享带宽的用户在平台上被称为“打包者”。

此外可以让客户从打包者共享的IP地址进行网络访问。总的来说PacketStream就是一个流量买卖平台。

## 免责声明

本程序仅供学习了解, 非盈利目的，请于下载后 24 小时内删除, 不得用作任何商业用途, 文字、数据及图片均有所属版权, 如转载须注明来源。

使用本程序必循遵守部署免责声明。使用本程序必循遵守部署服务器所在地、所在国家和用户所在国家的法律法规, 程序作者不对使用者任何不当行为负责.
