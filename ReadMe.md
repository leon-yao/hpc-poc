# POC Steps


## 1. 安装ParallelCluster

安装步骤，参考 https://github.com/cyrilclu/pcluster-poc 

### 具体内容如下：
### 安装软件包

    yum install python3-pip
    pip3 install awscli -U --user
    pip3 install aws-parallelcluster -U --user

### 配置AWS Credentials

如果ParallelCluster安装在一台EC2上，只需要给EC2挂载IAM Role即可。 IAM Role需要具备相关的权限，使得ParallelCluster可以调度AWS上的计算资源。 具体权限可以参考下面的链接：

https://docs.aws.amazon.com/zh_cn/parallelcluster/latest/ug/iam.html#parallelclusteruserpolicy

为了测试方便，在下面环境中将使用AdministratorAccess权限（仅限测试环境使用，生产环境需要保持最小权限原则）。

如果不在EC2上安装ParallelCluster，例如在本地笔记本电脑上进行安装，则需要配置AWS AKSK，可以参考下面的链接：

https://docs.aws.amazon.com/zh_cn/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-config

### 准备ParallelCluster配置文件

配置文件示例见config.ini文件。 


## 2. 配置


## 3. 创建ParallelCluster集群



## 4. 运行
