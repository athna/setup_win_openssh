#!/bin/bash

vm_addr=$1
vm_user=$2
vm_passwd=$3


dir_exist=`sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "powershell Test-Path C:\Users\\${vm_user}\.ssh"`
if [ $(echo "$dir_exist" | grep -e 'True') ]; then
    echo "## .ssh directory exist"
    :
else
    echo "## .ssh directory not exist. make .ssh"
    sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "mkdir C:\Users\\${vm_user}\.ssh"
fi


dir_exist=`sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "powershell Test-Path C:\Users\\${vm_user}\.ssh\authorized_keys"`
if [ $(echo "$dir_exist" | grep -e 'True') ]; then
    echo "## authorized_keys file exist"
else
    echo "## authorized_keys file not exist. make authorized_keys"
    sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "type nul > C:\Users\\${vm_user}\.ssh\authorized_keys"
fi


echo "## add sshkey in authorized_keys"
sshkey=`cat ~/.ssh/id_rsa.pub`
sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "echo ${sshkey} >> C:\Users\\${vm_user}\.ssh\authorized_keys"


echo "## create change acl script"
sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "type nul > C:\Users\\${vm_user}\.ssh\create_ch_acl.ps1"
sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "echo \$authorizedKeyPath = \"C:\users\\${vm_user}\.ssh\authorized_keys\" >> C:\Users\\${vm_user}\.ssh\create_ch_acl.ps1"
sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "echo \$acl = Get-Acl \$authorizedKeyPath >> C:\Users\\${vm_user}\.ssh\create_ch_acl.ps1"
sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "echo \$ar = New-Object System.Security.AccessControl.FileSystemAccessRule(\"NT Service\sshd\", \"Read\", \"Allow\") >> C:\Users\\${vm_user}\.ssh\create_ch_acl.ps1"
sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "echo \$acl.SetAccessRule(\$ar) >> C:\Users\\${vm_user}\.ssh\create_ch_acl.ps1"
sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "echo Set-Acl \$authorizedKeyPath \$acl >> C:\Users\\${vm_user}\.ssh\create_ch_acl.ps1"


echo "## exe change acl script"
sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "powershell C:\Users\\${vm_user}\.ssh\create_ch_acl.ps1"

echo "## delete acl script"
sshpass -p ${vm_passwd} ssh ${vm_user}@${vm_addr} "del /Q C:\Users\\${vm_user}\.ssh\create_ch_acl.ps1"
