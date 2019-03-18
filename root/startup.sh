#! /bin/sh

trap "killall sleep smbd nmbd; exit" TERM INT

mkdir -p /backups

cp /dev/null /etc/samba/fruit.conf
if [ "${MAXSIZE}" != "" ]; then
  echo "fruit:time machine max size = ${MAXSIZE}" >> /etc/samba/fruit.conf
fi

GUEST=yes
if [ "${SAMBA_USERNAME}" != "" ]; then
  GUEST=no
  adduser -D -s /sbin/nologin ${SAMBA_USERNAME}
  if [ "${SAMBA_PASSWORD}" = "" ]; then
    passwd -u ${SAMBA_USERNAME}
    (echo ; echo) | smbpasswd -s -a ${SAMBA_USERNAME}
    smbpasswd -n ${SAMBA_USERNAME}
  else
    echo ${SAMBA_USERNAME}:${SAMBA_PASSWORD} | chpasswd > /dev/null
    (echo ${SAMBA_PASSWORD} ; echo ${SAMBA_PASSWORD}) | smbpasswd -s -a ${SAMBA_USERNAME}
  fi
  smbpasswd -e ${SAMBA_USERNAME}
fi
echo "guest ok = ${GUEST}" >> /etc/samba/fruit.conf

/usr/sbin/nmbd -D
/usr/sbin/smbd -D

sleep 2147483647d &
wait "$!"
