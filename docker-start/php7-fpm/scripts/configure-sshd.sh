#!/bin/bash
set +e

WORKDIR="$(readlink -f "$(dirname $0)")"
SSH_PASSWORD="${SSH_PASSWORD:-1234}"

cp "$WORKDIR/ssh/ssh_host_key" "$WORKDIR/ssh/ssh_host_key.pub"  /etc/ssh
cp "$WORKDIR/ssh/ssh_host_rsa_key" "$WORKDIR/ssh/ssh_host_rsa_key.pub" /etc/ssh
cp "$WORKDIR/ssh/ssh_host_dsa_key" "$WORKDIR/ssh/ssh_host_dsa_key.pub" /etc/ssh
chmod 600 "/etc/ssh/ssh_host_key" "/etc/ssh/ssh_host_rsa_key" "/etc/ssh/ssh_host_dsa_key"
chmod 644 "/etc/ssh/ssh_host_key.pub" "/etc/ssh/ssh_host_rsa_key.pub" "/etc/ssh/ssh_host_dsa_key.pub"

echo "root:${SSH_PASSWORD}" | chpasswd
# ssh public key authentication
mkdir -m 0700 /root/.ssh
cat "$WORKDIR/ssh_key.pub" >> "/root/.ssh/authorized_keys2"
chmod 0600 "/root/.ssh/authorized_keys2"
echo "== Create ssh access: ssh://root:${SSH_PASSWORD}@${HOSTNAME}:2022"

# new user
if [[ -n "$SSH_USERNAME" ]] ; then
    if grep -q "^${SSH_USERNAME}:" /etc/passwd ; then
        usermod -s /bin/bash "${SSH_USERNAME}"
        SSH_HOME="$(grep "^${SSH_USERNAME}:" /etc/passwd | awk -F: '{print $6}')"
        if [[ -z "$SSH_HOME" ]] ; then
            SSH_HOME="/home/${SSH_USERNAME}"
            mkdir "$SSH_HOME"
            usermod -d "${SSH_HOME}" "${SSH_USERNAME}"
        fi
    else
	    useradd --create-home -s /bin/bash -g ftp "${SSH_USERNAME}"
	fi
	echo "${SSH_USERNAME}:${SSH_PASSWORD}" | chpasswd
	
	# ssh public key authentication
	mkdir -m 0700 "/home/${SSH_USERNAME}/.ssh"
	cat "$WORKDIR/ssh_key.pub" >> "/home/${SSH_USERNAME}/.ssh/authorized_keys2"
	chmod 0600 "/home/${SSH_USERNAME}/.ssh/authorized_keys2"
	chown "${SSH_USERNAME}:$(id -gn ${SSH_USERNAME})" -R "/home/${SSH_USERNAME}/.ssh"
	echo "== Create ssh access: ssh://${SSH_USERNAME}:${SSH_PASSWORD}@${HOSTNAME}:2022"
fi

# additional configuration
if [[ -n "$SSH_CONFIGURE_SCRIPT2" && -f "$SSH_CONFIGURE_SCRIPT2" ]] ; then
	/bin/sh "$SSH_CONFIGURE_SCRIPT2"
fi
