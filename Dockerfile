FROM alpine:latest

RUN apk --no-cache add samba-server

COPY root/ /

EXPOSE 137/udp 138/udp 139/tcp 445/tcp

ENTRYPOINT ["/startup.sh"]
