# Purpose
  Shell script to modfify IP value of Aliyun DNS Record,  A or AAAA type


# Usage:  
  aliyun.sh
  aliyun.sh -v  or aliyun.sh -verbose


# Code Example:
  # Set_DNS_IP ${KEY} ${SECRET} ${DOMAIN} ${T4} ${RR}  ${IP4}
  # Set_DNS_IP ${KEY} ${SECRET} ${DOMAIN} ${T6} ${RR}  ${IP6}

  # Get_DNS_IP ${KEY} ${SECRET} ${DOMAIN} ${T4} ${RR}
  # Get_DNS_IP ${KEY} ${SECRET} ${DOMAIN} ${T6} ${RR}
  
# Here:
  # KEY       = AccessKeyId of Aliyun
  # SECRET    = AccessKeySecret of Aliyun
  # DOMAIN    = Your domain,  say: aliyun.net
  # RR        = 3rd level domain name,  say:  www
  # IP4       = IPv4 value
  # IP6       = IPv6 value

  
# Install
  # Download alidns.sh, alidns_util.sh
  # And copy to anywhere of your server
  # say:  /opt/local/etc/aliyun

# Note 
  # curl must be installed


# Cron:
  # Add one of following line in cron file:
   #  */10 * * * *  /opt/local/etc/aliyun/alidns.sh -v >> /tmp/alidns.log
   #  */10 * * * *  /opt/local/etc/aliyun/alidns.sh -v >> /dev/null
   #  */10 * * * *  /opt/local/etc/aliyun/alidns.sh


### Back Info
In case of CTCC ISP, config the home modem running in the bridge mode, and Wan interface of OpenWrt/23.05 route in PPPoE mode,
A PD_PREFIX/56 IPv6 set will be available in the home route.

Assign one IPv6 of the IPv6-PD set to each of home server,
The home server can be accessed anywhere publicly via IPv6 network, 
say from handset of mobile network in China.

By config the router DHCPv6 server,  with the interface MAC and a specified suffix value,
the home server IPv6 value can be staticlly configed from IPv6-PD set.

But the PD_PREFIX will be changed each time,
when reboot the modem. or reboot the router.

So need to find a way, 
to update IPv6 value dynamiclly,
with the changes of the IPv6-PD set.

