#!/bin/bash

# Run Terraform commands
echo "[INFO] Initializing Terraform..."
terraform init
terraform fmt

echo "[INFO] Planning Terraform changes..."
terraform plan

echo "[INFO] Done."


echo "[INFO] applying Terraform changes..."
terraform apply -auto-approve

echo "[INFO] Done."