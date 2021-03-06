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
config.ini文件中配置了创建4个queue，分别使用不同的实例类型来运行Job。分别是：compute-m5-16xlarge,compute-m5-4xlarge,compute-p3-16xlarge,compute-m5-8xlarge

Master节点使用c5.xlarge机型的EC2实例。

### 创建集群

使用以下命令创建ParallelCluster集群

    ~/.local/bin/pcluster create -c config.ini p-cluster
    
### 执行完成后，会返回Master节点的IP地址，可以通过config.ini中指定的Key Pair进行SSH连接。


## 2. 部署容器运行环境

参考ngs_pipeline_containerized_README.md进行环境部署工作。


## 3. 通过sbatch运行job

例如：

    cd /path/to
    sbatch m5-4xlarge-t32-uhrr.sbatch

## 4. 检查运行结果

运行结果输出到：/path/to/c5-24xlarge-t192-uhrr_9.out





## 附录：参考命令

### 运行在Controller Node

    ~/.local/bin/pcluster list -- 列出所有创建好的ParallelCluster实例 
    ~/.local/bin/pcluster status pcluster  -- 获得指定cluster的状态信息 
    ~/.local/bin/pcluster stop pcluster -- stop指定cluster
    ~/.local/bin/pcluster start roche-cluster -- start指定cluster
    ~/.local/bin/pcluster update roche-cluster -c config-gred.ini -- 创建cluster

### 运行在Master Node
    squeue --列出所有sbatch jobs
    scancel <jobid>  --取消指定job
    sinfo --显示当前cluster的配置信息
    sbatch <batch file> --运行sbatch job

