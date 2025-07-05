#!/bin/bash
# Example user data that fetches parameters from SSM Parameter Store and exports as env variables
PARAMS=$(aws ssm get-parameters-by-path --path "${env_params_ssm_path}" --region ${var.aws_region} --with-decryption --query 'Parameters[].{Name:Name,Value:Value}' --output json)
for row in $(echo "${PARAMS}" | jq -r '.[] | @base64'); do
  _jq() {
    echo "${row}" | base64 --decode | jq -r "${1}"
  }
  name=$(_jq '.Name' | sed "s|${env_params_ssm_path}/||")
  value=$(_jq '.Value')
  echo "export ${name}='${value}'" >> /etc/profile.d/env_vars.sh
done
