#!/bin/bash

component=$1
environment=$2
echo "Component: $component and Environment: $environment"
dnf install ansible -y
ansible-pull -i localhost, -U https://github.com/mlnawsdevops/expense-ansible-roles-tf.git main.yml -e component=$component -e environment=$environment