#! /bin/sh

trap "killall sleep smbd nmbd; exit" TERM INT

mkdir -p /backups

if [ "${MAXSIZE}" != "" ]; then
  echo "max disk size = $(expr ${MAXSIZE} * 1049600)" >> /etc/samba/extra.conf
fi

/usr/sbin/nmbd -D
/usr/sbin/smbd -D

sleep 2147483647d &
wait "$!"
