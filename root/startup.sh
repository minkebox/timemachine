#! /bin/sh -x

trap "killall sleep smbd nmbd dbus-daemon avahi-daemon; exit" TERM INT

mkdir -p /backups

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

i=0
cp /dev/null /etc/samba/fruit.conf
cp /dev/null /tmp/txt
echo "${BACKUPLIST}" | while read line; do
  name=$(echo $line | cut -d',' -f1)
  size=$(echo $line | cut -d',' -f2)
  mkdir -p "/backups/${name}"
  cat >> /etc/samba/fruit.conf << __EOF__
[${name}]
  comment = Time Machine (${name})
  path = /backups/${name}
  browseable = yes
  writeable = yes
  printable = no
  spotlight = yes
  vfs objects = catia fruit streams_xattr
  fruit:aapl = yes
  fruit:time machine = yes
  guest ok = ${GUEST}
__EOF__
  if [ "${size}" != "0" -a "${size}" != "" ]; then
    echo "  fruit:time machine max size = ${size}" >> /etc/samba/fruit.conf
  fi
  echo "<txt-record>dk${i}=adVF=0x82,adVN=${name}</txt-record>" >> /tmp/txt
  i=$(($i + 1))
done

cp /dev/null /etc/avahi/services/timemachine.service
cat >> /etc/avahi/services/timemachine.service << __EOF__
<service-group>
  <name replace-wildcards="yes">%h</name>
  <service>
    <type>_adisk._tcp</type>
    <port>9</port>
    <txt-record>waMa=0</txt-record>
    <txt-record>sys=adVF=0x100</txt-record>
    $(cat /tmp/txt)
  </service>
</service-group>
__EOF__

/usr/bin/dbus-daemon --system
/usr/sbin/avahi-daemon -D
/usr/sbin/nmbd -D
/usr/sbin/smbd -D

sleep 2147483647d &
wait "$!"
