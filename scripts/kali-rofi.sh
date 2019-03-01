#!/usr/bin/env bash
# ~/.config/kali/rofi

if [ ! "$@" = "" ]; then
    if echo "$@" | grep -v "";then
        target=$(echo "${@// }")
        killall -9 rofi &

        urxvt -hold -e sh -c "~/.config/kali/launch.sh $target"
    fi
fi

if [ "$@" ]; then
    # Override the previously set prompt.
    echo -en "\x00prompt\x1f$@\n"

    if [ "$@" == " Information Gathering" ]; then
        echo " DNS Analysis"
        echo " IDS/IPS Identitication"
        echo " Live Host Identification"
        echo " Network & Port Scanners"
        echo " OSINT Analysis"
        echo " Route Analysis"
        echo " SMB Analysis"
        echo " SMTP Analysis"
        echo " SNMP Analysis"
        echo " SSL Analysis"
        echo " dmitry"
        echo " dnmap_client"
        echo " dnmap_server"
        echo " ike-scan"
        echo " maltego"
        echo " netdiscover"
        echo " nmap"
        echo " p0f"
        echo " recon-ng"
        echo " sparta"
        echo " zenmap"
    fi

    if [ "$@" == " DNS Analysis" ]; then
        echo " dnsenum"
        echo " dnsmap"
        echo " dnsrecon"
        echo " dnstracer"
        echo " dnswalk"
        echo " fierce"
        echo " urlcrazy"
    fi

    if [ "$@" == " IDS/IPS Identitication" ]; then
        echo " fragroute"
        echo " fragrouter"
        echo " ftest"
        echo " lbd"
        echo " wafw00f"
    fi

    if [ "$@" == " Live Host Identification" ]; then
        echo " arping"
        echo " cdpsnarf"
        echo " fping"
        echo " hping3"
        echo " masscan"
        echo " miranda"
        echo " ncat"
        echo " atk6-thcping6"
        echo " unicornscan"
        echo " wol-e"
        echo " xprobe2"
    fi

    if [ "$@" == " Network & Port Scanners" ]; then
        echo " masscan"
        echo " nmap"
        echo " unicornscan"
        echo " zenmap"
    fi

    if [ "$@" == " OSINT Analysis" ]; then
        echo " automater"
        echo " maltego"
        echo " theharvester"
        echo " twofi"
        echo " urlcrazy"
    fi

    if [ "$@" == " Route Analysis" ]; then
        echo " 0trace.sh"
        echo " intrace"
        echo " ass"
        echo " cdp"
        echo " netdiscover"
        echo " netmask"
    fi
else
    echo " Information Gathering"
    echo " Vulnerability Analysis"
    echo " Web Application Analysis"
    echo " Database Assessment"
    echo " Password Attacks"
    echo " Wireless Attacks"
    echo " Reverse Engineering"
    echo " Exploitation Tools"
    echo " Sniffing & Spoofing"
    echo " Post Exploitation"
    echo " Forensics"
    echo " Reporting Tools"
    echo " Social Engineering Tools"
    echo " System Services"
fi

