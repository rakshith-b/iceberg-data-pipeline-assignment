#!/bin/bash
set -e

echo "=== Deploying EKS Cluster ==="
cd terraform/eks
terraform init
terraform apply -var-file="terraform.tfvars" -auto-approve

# Export EKS kubeconfig using AWS CLI
aws eks update-kubeconfig --region us-west-2 --name icebergs-spark-cluster

echo "=== Deploying IAM Roles ==="
cd ../iam
terraform init
terraform apply -var-file="terraform.tfvars" -auto-approve

echo "=== Deploying RDS for Hive Metastore ==="
# RDS PostgreSQL provisioning (MySQL provisioning also avialble here ../rds/mysql)
cd ../rds/postgresql
terraform init
terraform apply -var-file="terraform.tfvars" -auto-approve

echo "=== Deploying Hive Metastore with MySQL on EKS ==="
# Hive Metastore on Kubernetes via Helm with MySQL
cd ../hive-metastore
terraform init
terraform apply -var-file="terraform.tfvars" -auto-approve

echo "=== Deploying Hive Metastore with PostgreSQL on EKS ==="
# Hive Metastore on Kubernetes via Helm with PostgreSQL
cd ../hive-metastore/hive-metastore-main/docker
# Build your own image for Hive Metastore
docker build -t hive-metastore:7.0.0 .
docker tag hive-metastore:7.0.0 rakshith16/hive-metastore:7.0.0
docker push rakshith16/hive-metastore:7.0.0
# Deploy the above image using helm in EKS
cd ../hive-metastore/
helm install hms getindata-hms/hive-metastore -f values.yaml
# To check Hive Metastore is running in EKS
kubectl get pods -n default
kubectl logs -f <pod-name> -n default

echo "=== Deploying Spark on EKS ==="
# Creating Sprak Cluster on EKS
cd ../../../spark
terraform init
terraform apply -var-file="terraform.tfvars" -auto-approve

echo "Infrastructure deployment completed."