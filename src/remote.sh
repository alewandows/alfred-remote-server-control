#!/bin/bash

# Est-ce qu'on a du reseau ?
ping -c 1 -W 100 www.google.com &> /dev/null
PING_STATUS=$?

if [[ PING_STATUS -ne 0 ]]; then
  cat << EOB
  {"items": [
	{
	  "title": "Remote PC",
	  "subtitle": "No Internet connection",
	  "valid": "false",
	}
  ]}  
EOB
exit 0
fi

# Est-ce que le routeur repond ?
if [[ ${router_used} -eq 1 ]]; then

    ping -c 1 -W 100 ${remote_ip} &> /dev/null 
    PING_STATUS=$?

    if [[ PING_STATUS -ne 0 ]]; then

    cat << EOB
    {"items": [
        {
        "title": "Remote PC",
        "subtitle": "Host not reachable",
        "valid": "false",
        }
    ]}
EOB

    exit 0
    fi
fi

# Est-ce que le serveur tourne ?
nc -G 1 ${remote_ip} ${remote_ssh_port} &> /dev/null
PING_STATUS=$?

if [[ PING_STATUS -ne 0 ]]; then

 cat << EOB
  {"items": [
	{
	  "title": "Start Remote PC",
	  "subtitle": "wakeonlan -i ${remote_ip} -p ${remote_wol_port} ${remote_mac}",
	  "arg": "wakeonlan",
	}
  ]}
  
EOB

else

  if [[ `ls ${local_folder} | wc -m` -eq 0 ]]; then 

  cat << EOB
  {"items": [
	{
	  "title": "SSH Remote PC",
	  "subtitle": "ssh -i ${identity_file} -p ${remote_ssh_port} ${username}@${remote_ip}",
	  "arg": "ssh",
      "icon": { "path": "icons/ssh.png"}
	},
	{
	  "title": "Mount Remote PC Folder",
	  "subtitle": "sshfs -p ${remote_ssh_port} ${username}@${remote_ip}:${remote_folder} \"${local_folder}\" -o volname=\"${local_folder##*/}\"",
	  "arg": "sshfs",
      "icon": { "path": "icons/network.png"}
	},
	{
	  "title": "Shutdown Remote PC",
	  "subtitle": "ssh -p ${remote_ssh_port} ${username}@${remote_ip} & sudo shutdown",
	  "arg": "shutdown",
      "icon": { "path": "icons/switch-off.png"}
	}
  ]}

EOB
  else 

  cat << EOB
  {"items": [
	{
	  "title": "SSH Remote PC",
	  "subtitle": "ssh -i ${identity_file} -p ${remote_ssh_port} ${username}@${remote_ip}",
	  "arg": "ssh",
      "icon": { "path": "icons/ssh.png"}
	},
	{
	  "title": "Unmount Remote PC Folder",
	  "subtitle": "umount \"${local_folder}\" ",
	  "arg": "umount",
      "icon": { "path": "icons/network.png"}
	},
	{
	  "title": "Shutdown Remote PC",
	  "subtitle": "ssh -p ${remote_ssh_port} ${username}@${remote_ip} & sudo shutdown",
	  "arg": "shutdown",
      "icon": { "path": "icons/switch-off.png"}
	}
  ]}

EOB
  fi

fi


