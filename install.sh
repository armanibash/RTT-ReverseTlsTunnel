#!/bin/bash -e

echo
echo "
 █████╗ ██████╗ ███╗   ███╗ █████╗ ███╗   ██╗██╗    ██████╗  █████╗ ███████╗██╗  ██╗
██╔══██╗██╔══██╗████╗ ████║██╔══██╗████╗  ██║██║    ██╔══██╗██╔══██╗██╔════╝██║  ██║
███████║██████╔╝██╔████╔██║███████║██╔██╗ ██║██║    ██████╔╝███████║███████╗███████║
██╔══██║██╔══██╗██║╚██╔╝██║██╔══██║██║╚██╗██║██║    ██╔══██╗██╔══██║╚════██║██╔══██║
██║  ██║██║  ██║██║ ╚═╝ ██║██║  ██║██║ ╚████║██║    ██████╔╝██║  ██║███████║██║  ██║
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
"
echo "***** https://github.com/armanibash *****"
echo "***** RTT-ReverseTlsTunnel *****"
echo
sleep 1

function exit_badly {
echo "$1"
exit 1
}

error() {
    echo -e " \n $red Something Bad Happen $none \n "
}

if [ "$EUID" -ne 0 ]
then echo "Please run as root."
exit
fi

if pgrep -x "RTT" > /dev/null; then
	echo "Tunnel is running!. you must stop the tunnel before update. (pkill RTT)"
    echo "Kiling RTT..."
    sleep 5
    pkill RTT
	echo "Done"
fi

DISTRO="$(awk -F= '/^NAME/{print tolower($2)}' /etc/os-release|awk 'gsub(/[" ]/,x) + 1')"
DISTROVER="$(awk -F= '/^VERSION_ID/{print tolower($2)}' /etc/os-release|awk 'gsub(/[" ]/,x) + 1')"

valid_os()
{
    case "$DISTRO" in
    "debiangnu/linux"|"ubuntu")
        return 0;;
    *)
        echo "OS $DISTRO is not supported"
        return 1;;
    esac
}
if ! valid_os "$DISTRO"; then
    echo "Bye."
    exit 1
else
[[ $(id -u) -eq 0 ]] || exit_badly "Please re-run as root (e.g. sudo ./path/to/this/script)"
fi

update_os() {
apt-get -o Acquire::ForceIPv4=true update
apt-get -o Acquire::ForceIPv4=true install -y software-properties-common
add-apt-repository --yes universe
add-apt-repository --yes restricted
add-apt-repository --yes multiverse
apt-get -o Acquire::ForceIPv4=true install -y moreutils dnsutils tmux screen nano wget curl socat jq qrencode unzip lsof
}

rtt_instller() {

wget  "https://raw.githubusercontent.com/radkesvat/ReverseTlsTunnel/master/scripts/install.sh" -O install.sh && chmod +x install.sh && bash install.sh 
}

CHS=3
IRIP=$(dig -4 +short myip.opendns.com @resolver1.opendns.com)
EXIP=0.0.0.0
IRPORT=23-65535
IRPORTTT=443
TOIP=127.0.0.1
TOPORT=multiport


iranserver() {
cat >/etc/systemd/system/tunnel.service <<-EOF
[Unit]
Description=Reverse TLS Tunnel

[Service]
Type=idle
User=root
WorkingDirectory=/root
ExecStart=/root/RTT --iran  --lport:$IRPORT  --sni:$SNI --password:$TOPASS
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl --now enable tunnel.service
systemctl start tunnel.service
}

externalserver() {
cat >/etc/systemd/system/tunnel.service <<-EOF
[Unit]
Description=Reverse TLS Tunnel

[Service]
Type=idle
User=root
WorkingDirectory=/root
ExecStart=/root/RTT --kharej --iran-ip:$EXIP --iran-port:$IRPORTTT --toip:$TOIP --toport:$TOPORT --password:$TOPASS --sni:$SNI --terminate:$TERM
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl --now enable tunnel.service
systemctl start tunnel.service
}

echo "Select Server Location:"
echo "1.Iran(Internal)"
echo "2.kharej(External)"
echo "3.Exit"
read -r -p "Select Number(Default is: 3):" CHS

case $CHS in
    1)  echo "Be carefull SSH port must under 23"
    echo "Multiport is activated all ports above 22 were forwarded"
    read -r -p "RTT PASS(Default is: Armani@bash): " TOPASS
    TOPASS=${TOPASS:-"Armani@bash"}
    read -r -p "RTT SNI(Default is: cloudflare.com): " SNI
    SNI=${SNI:-"cloudflare.com"}
    read -r -p "RTT Restart Time(Default is: 24): " TERM
    TERM=${TERM:-"24"}
    sleep 3
    update_os
    rtt_instller
    iranserver
    echo
    echo "=== Finished ==="
    echo
    sleep 3
    exit ;;
    2)     echo "Be carefull SSH port must under 23"
    echo "Multiport is activated all ports above 22 were forwarded"
    read -r -p "RTT IP(Enter Iran IP): " EXIP
    read -r -p "RTT PASS(Default is: Armani@bash): " TOPASS
    TOPASS=${TOPASS:-"Armani@bash"}
    read -r -p "RTT SNI(Default is: cloudflare.com): " SNI
    SNI=${SNI:-"cloudflare.com"}
    read -r -p "RTT Restart Time(Default is: 24): " TERM
    TERM=${TERM:-"24"}
    sleep 3
    update_os
    rtt_instller
    externalserver
    echo
    echo "=== Finished ==="
    echo
    sleep 3
    exit ;;
    3)      exit_badly ;;
    
    *)   echo "Done."; exit 1 ;;

esac
