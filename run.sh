#!/usr/bin/env bash 

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Makes the vpn work with wireguard connections
ip route add 10.0.0.0/24 via 192.168.4.1 dev enp10s0

docker run -it --rm \
  --net=host \
  --device=/dev/net/tun --cap-add=NET_ADMIN \
  -e JAVA_TOOL_OPTIONS="-Djava.awt.headless=true" \
  sonicwall-connect-tunnel \
  /usr/local/Aventail/startct.sh --mode console --name unipi --server access.unipi.it --username $(cat .username.secret)  --password $(cat .password.secret)
