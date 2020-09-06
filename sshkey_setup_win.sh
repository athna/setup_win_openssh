#!/bin/bash

vm_addr=$1
vm_user=$2
vm_passwd=$3

ssh_dir="C:\Users\\${vm_user}\.ssh"
dir_exist=`sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "powershell Test-Path ${ssh_dir}"`
if [ $(echo "$dir_exist" | grep -e 'True') ]; then
    echo "## .ssh directory exist"
else
    echo "## .ssh directory not exist. make .ssh"
    sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "mkdir ${ssh_dir}"
fi


dir_exist=`sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "powershell Test-Path ${ssh_dir}\authorized_keys"`
if [ $(echo "$dir_exist" | grep -e 'True') ]; then
    echo "## authorized_keys file exist"
else
    echo "## authorized_keys file not exist. make authorized_keys"
    sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "type nul > ${ssh_dir}\authorized_keys"
fi


echo "## add sshkey in authorized_keys"
sshkey=`cat ~/.ssh/id_rsa.pub`
sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "echo ${sshkey} >> ${ssh_dir}\authorized_keys"


echo "## create change acl script"
sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "type nul > ${ssh_dir}\create_ch_acl.ps1"
sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "echo \$authorizedKeyPath = ${ssh_dir}\\authorized_keys >> ${ssh_dir}\create_ch_acl.ps1"
sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "echo \$acl = Get-Acl \$authorizedKeyPath >> ${ssh_dir}\create_ch_acl.ps1"
sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "echo \$ar = New-Object System.Security.AccessControl.FileSystemAccessRule(\"NT Service\\sshd\", \"Read\", \"Allow\") >> ${ssh_dir}\\create_ch_acl.ps1"
sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "echo \$acl.SetAccessRule(\$ar) >> ${ssh_dir}\\create_ch_acl.ps1"
sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "echo Set-Acl \$authorizedKeyPath \$acl >> ${ssh_dir}\\create_ch_acl.ps1"


echo "## exe change acl script"
sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "powershell ${ssh_dir}\create_ch_acl.ps1"

echo "## delete acl script"
sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "del /Q ${ssh_dir}\create_ch_acl.ps1"
