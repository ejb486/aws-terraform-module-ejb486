#!/bin/bash
echo "ECS_CLUSTER=tdcs-dev-ecs-cluster" >> /etc/ecs/ecs.config
sudo systemctl stop ecs
sudo systemctl start ecs