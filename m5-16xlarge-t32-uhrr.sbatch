#!/bin/bash
#SBATCH --job-name=uhrr
#SBATCH --ntasks=1
#SBATCH --partition=compute-m5-16xlarge
#SBATCH --output=%x_%j.out

sudo yum install docker -y
sudo service docker start
cd /path/to/resources
export RESOURCES=$PWD/resources
cd /path/to/working_dir/
sudo docker load < ngs_pipeline_docker_4.2.2.tar.gz
sudo docker run -v $PWD:/working_dir -v $RESOURCES:/resources gne/ngs_pipeline:4.2.2 -t 32 --run /working_dir/UHRR/uhrr.config.txt
