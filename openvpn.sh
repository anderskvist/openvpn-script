#!/bin/bash

# Created by Anders Kvist <anderskvist@gmail.com> - 2013-08-21

# OpenVPN environemtn variables
DEV=${dev}

case ${1} in
    start)
	I=1
	while true; do 
	    VARIABLE=foreign_option_${I}
	    if [ -z "${!VARIABLE}" ]; then
		break;
	    fi
	    echo "${!VARIABLE}"|sed 's/dhcp-option DOMAIN/search/'|sed 's/dhcp-option DNS/nameserver/'|sed 's/dhcp-option NTP.*//'
	    I=$((${I}+1))
	done | resolvconf -a ${DEV}
	;;
    stop)
	resolvconf -d ${DEV}
	;;
    install)
	NAME=${2}
	cat <<EOF > ${HOME}/.local/share/applications/${NAME}.desktop
[Desktop Entry]
Encoding=UTF-8
Name=${NAME}
Comment=VPN Connection for ${NAME}
Exec=${HOME}/bin/openvpn.sh ${NAME}
Icon=${HOME}/.local/share/applications/openvpn.png
Terminal=true
Type=Application
StartupNotify=true
Categories=Network
EOF
	wget -o /dev/null http://swupdate.openvpn.net/community/icons/ovpntech_key.png -O ${HOME}/.local/share/applications/openvpn.png
	TARGET=${HOME}/.openvpn-${NAME}
	mkdir -p ${TARGET}
	echo "You need to copy your openvpn config to ${TARGET}/openvpn.ovpn and dependencies"
	SUDOERS=/etc/sudoers.d/${USER}-openvpn
	if [ ! -f ${SUDOERS} ]; then
	    echo
	    echo "You should consider allowing ${USER} to run /usr/sbin/openvpn without password by running the following:"
	    echo "sudo sh -c 'echo \"${USER} ALL=(root) NOPASSWD: /usr/sbin/openvpn *\" > ${SUDOERS}'"
	fi

	;;
    "")
	echo "Usage: ${0} [install] CONFIGNAME"
	echo
	;;
    *)
	NAME=${1}
	WORKDIR="${HOME}/.openvpn-${NAME}"
	cd ${WORKDIR}
	sudo /usr/sbin/openvpn --script-security 2 --up "${0} start" --down "${0} stop" --config openvpn.ovpn
	echo
	echo "Press ENTER to close window..."
	read
	;;
esac


