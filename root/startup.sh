#! /bin/sh

trap "killall sleep smbd nmbd; exit" TERM INT

mkdir -p /backups

/usr/sbin/nmbd -D
/usr/sbin/smbd -D

sleep 2147483647d &
wait "$!"
