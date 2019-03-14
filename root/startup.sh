#! /bin/sh

trap "killall sleep smbd nmbd; exit" TERM INT

mkdir -p /backups

if [ "${MAXSIZE}" != "" ]; then
  echo "fruit:time machine max size = ${MAXSIZE}" > /etc/samba/fruit.conf
fi

/usr/sbin/nmbd -D
/usr/sbin/smbd -D

sleep 2147483647d &
wait "$!"
