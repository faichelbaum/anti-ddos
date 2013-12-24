#!/bin/bash
function start {
 echo "Whitelisting"
 cat /usr/local/etc/whitelist | while read ip; do
  iptables -I INPUT -s $ip -j ACCEPT
  iptables -I INPUT -d $ip -j ACCEPT
  iptables -I OUTPUT -s $ip -j ACCEPT
  iptables -I OUTPUT -d $ip -j ACCEPT
  iptables -I FORWARD -s $ip -j ACCEPT
  iptables -I FORWARD -d $ip -j ACCEPT
 done
 echo "Routing"
 iptables -t nat -A POSTROUTING -o eth2 -j MASQUERADE
 iptables -t nat -A PREROUTING -d VIP1 -m tcp -p tcp --dport 80 -j DNAT --to-destination NET_SERV.201
 iptables -t nat -A PREROUTING -d VIP2 -m tcp -p tcp --dport 80 -j DNAT --to-destination NET_SERV.201
 iptables -t nat -A PREROUTING -d VIP3 -m tcp -p tcp --dport 80 -j DNAT --to-destination NET_SERV.201
 iptables -t nat -A PREROUTING -d VPN -m tcp -p tcp --dport 3006 -j DNAT --to-destination NET_SERV.101
 for chain in INPUT FORWARD; do 
  echo "Block DOS - $chain - Ping of Death"
  iptables -A $chain -p ICMP --icmp-type echo-request -m length --length 60:65535 -j ACCEPT;
  echo "Block DOS - $chain - Teardrop"
  iptables -A $chain -p UDP -f -j DROP;
  echo "Block DDOS - $chain - SYN-flood"
  iptables -A $chain -p TCP ! --syn -m state --state NEW -j TARPIT;
  iptables -A $chain -p TCP ! --syn -m state --state NEW -j DROP;
  echo "Block DDOS - $chain - Smurf"
  iptables -A $chain -m pkttype --pkt-type broadcast -j DROP;
  iptables -A $chain -p ICMP --icmp-type echo-request -m pkttype --pkt-type broadcast -j DROP;
  iptables -A $chain -p ICMP --icmp-type echo-request -m limit --limit 3/s -j ACCEPT;
  echo "Block DDOS - $chain - UDP-flood (Pepsi)"
  iptables -A $chain -p UDP --dport 7 -j DROP;
  iptables -A $chain -p UDP --dport 19 -j DROP;
  echo "Block DDOS - $chain - SMBnuke"
  iptables -A $chain -p UDP --dport 135:139 -j DROP;
  iptables -A $chain -p TCP --dport 135:139 -j TARPIT; 
  iptables -A $chain -p TCP --dport 135:139 -j DROP;
  echo "Block DDOS - $chain - Connection-flood"
  iptables -A $chain -p TCP --syn -m connlimit --connlimit-above 25 -j TARPIT;
  iptables -A $chain -p TCP --syn -m connlimit --connlimit-above 25 -j DROP;
  echo "Block DDOS - $chain - Fraggle"
  iptables -A $chain -p UDP -m pkttype --pkt-type broadcast -j DROP;
  iptables -A $chain -p UDP -m limit --limit 3/s -j ACCEPT;
  echo "Block DDOS - $chain - Jolt"
  iptables -A $chain -p ICMP -f -j DROP;
 done
 /etc/init.d/portsentry start
}
function stop {
 /etc/init.d/portsentry stop
 iptables -F
 iptables -X 
 iptables -F -t nat
 iptables -X -t nat
}
case "$1" in
	start)
		start
		;;
	stop)
		stop
		;;
	restart|reload)
		stop
		start
		;;
	*)
		echo "$0 <start|stop|restart|reload>"
		exit 1
		;;
esac
exit 0
