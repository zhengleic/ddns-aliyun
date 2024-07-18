#!/bin/bash
#
PATH="${PATH}:/opt/local/sbin:/opt/local/bin"

SCRIPT_TOP=${SCRIPT_TOP-"$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"}

KEY="Your Aliyun AccessKeyID"
SECRET="Your Aliyun AccessKeySecret"
DOMAIN="Your Domain"
T4="A"
T6="AAAA"

_V=0

PARAM="$1"

source "${SCRIPT_TOP}/alidns_util.sh"

if [ "A${PARAM}B" == "A-verboseB" ]||[ "A${PARAM}B" == "A-vB" ];then
  _V=1
fi


[ $_V -eq 1 ] && echo
[ $_V -eq 1 ] && echo
[ $_V -eq 1 ] && echo "Start to update aliyun dns record "
[ $_V -eq 1 ] && echo
[ $_V -eq 1 ] && date


#www_ip6=????
#www_ip4=????
#Set_DNS_IP ${KEY} ${SECRET} ${DOMAIN} ${T6} www  ${www_ip6}
#Set_DNS_IP ${KEY} ${SECRET} ${DOMAIN} ${T4} www  ${www_ip4}


# Get IPv6 PD-PREFIX delivered by ISP via pppoe
function get_pd_prefix(){
   local route_ip="$1"
   local isp_prefix="$2"
   local p=`ssh ${route_ip} ifconfig br-lan|grep "inet6 addr: ${isp_prefix}"|sed "s/inet6 addr: //"|sed "s/::.*//"`
   echo "${p}"
}

# ISP_PRE:  CTCC:240e   CMCC:2409   CUCC:2408
ISP_PRE="240e"

# OpenWrt br-lan ip4 value, say 10.0.0.1,172.24.0.1,etc
# portal_ip4="10.0.0.1"
portal_ip4=$(Get_DNS_IP ${KEY} ${SECRET} ${DOMAIN} ${T4} portal)

pd_prefix=$(get_pd_prefix ${portal_ip4} ${ISP_PRE})



[ $_V -eq 1 ] && echo
[ $_V -eq 1 ] && echo "PD_PREFIX=${pd_prefix}"
[ $_V -eq 1 ] && echo


# Assign one fixed suffix for each server to generate the IPv6 value
portal_ip6="${pd_prefix}::1"
mpd_ip6="${pd_prefix}::61"
gallery_ip6="${pd_prefix}::222"


# mpd6/mpdcn/mpdde/mpdhk/gallery2/gallery2cn,  sub-domain of my home server
Set_DNS_IP ${KEY} ${SECRET} ${DOMAIN} ${T6} mpd6  ${mpd_ip6}
Set_DNS_IP ${KEY} ${SECRET} ${DOMAIN} ${T6} mpdcn ${mpd_ip6}
Set_DNS_IP ${KEY} ${SECRET} ${DOMAIN} ${T6} mpdde ${mpd_ip6}
Set_DNS_IP ${KEY} ${SECRET} ${DOMAIN} ${T6} mpdhk ${mpd_ip6}

Set_DNS_IP ${KEY} ${SECRET} ${DOMAIN} ${T6} gallery2   ${gallery_ip6}
Set_DNS_IP ${KEY} ${SECRET} ${DOMAIN} ${T6} gallery2cn ${gallery_ip6}

Set_DNS_IP ${KEY} ${SECRET} ${DOMAIN} ${T6} portal ${portal_ip6}

[ $_V -eq 1 ] && echo
[ $_V -eq 1 ] && echo
[ $_V -eq 1 ] && echo "Aliyun dns record update finished "
[ $_V -eq 1 ] && echo
[ $_V -eq 1 ] && echo

