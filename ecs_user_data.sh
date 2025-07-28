#!/bin/bash
echo ECS_CLUSTER=${ecs_cluster_name} >> /etc/ecs/ecs.config
sudo yum update -y
sudo yum install -y amazon-ecs-init
sudo systemctl enable --now ecs
