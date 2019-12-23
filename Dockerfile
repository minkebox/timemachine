FROM alpine:latest

RUN apk add samba-server samba-common-tools samba-client

COPY root/ /

EXPOSE 137/udp 138/udp 139/tcp 445/tcp

HEALTHCHECK --interval=60s --timeout=15s CMD smbclient -L '\\localhost' -U '%' -m SMB3

ENTRYPOINT ["/startup.sh"]
