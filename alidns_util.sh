#!/bin/bash
#
#####################################################################
#
#Author:                Tingjusting
#Email:                 tingjusting@gmail.com
#Date:                  2023-02-17
#FileName：             alidns.sh
#URL:                   https://github.com/ledrsnet
#Description：          阿里云DDNS
#Copyright (C):         2023 All rights reserved
#Signature Api:         https://help.aliyun.com/document_detail/315526.html
#Alidns Api：           https://next.api.aliyun.com/document/Alidns/2015-01-09
#
#########################################################################
#
#  Updated by Leic for multiple AAAA records,
#  In case of IPv6-PD supported by ISP
#  2024/07/18
#
##########################################################################

urlEncode() {
  # 将输入的字符串转换为16进制编码的值
  local length="${#1}"
  length=$((length-1))
  for i in $(seq 0 $length)
  do
    local c="${1:i:1}"
    case $c in
      [a-zA-Z0-9.~_-])
        printf "$c"
        ;;
      *)
        printf '%%%02X' "'$c"
        ;;
    esac
  done
}


function DescribeDomainRecords(){
    local keyid=$1
    local keyval=$2
    local domain=$3
    local type=$4
    local rr=$5
    local URL_PARAMS
    URL_PARAMS="AccessKeyId=${keyid}"
    URL_PARAMS="${URL_PARAMS}&Action=DescribeDomainRecords"
    URL_PARAMS="${URL_PARAMS}&DomainName=${domain}"
    URL_PARAMS="${URL_PARAMS}&Format=JSON"
    URL_PARAMS="${URL_PARAMS}&RRKeyWord=${rr}"
    URL_PARAMS="${URL_PARAMS}&SignatureMethod=HMAC-SHA1"
    URL_PARAMS="${URL_PARAMS}&SignatureNonce="`date +%s%3N`
    URL_PARAMS="${URL_PARAMS}&SignatureVersion=1.0"
    URL_PARAMS="${URL_PARAMS}&Timestamp="`urlEncode $(date -u +"%Y-%m-%dT%H:%M:%SZ")`
    URL_PARAMS="${URL_PARAMS}&Type=${type}"
    URL_PARAMS="${URL_PARAMS}&Version=2015-01-09"

    local STRING_To_SIGN="GET&%2F&`urlEncode ${URL_PARAMS}`"

    local SIGNATURE=`echo -n ${STRING_To_SIGN} | openssl dgst -hmac "${keyval}&" -sha1 -binary | openssl enc -base64`
    SIGNATURE=`urlEncode $SIGNATURE`

    URL_PARAMS="${URL_PARAMS}&Signature=${SIGNATURE}"
    curl -ss "http://alidns.aliyuncs.com?${URL_PARAMS}"
}

function UpdateDomainRecord(){
    local keyid=$1
    local keyval=$2
    local recid=$3
    local type=$4
    local rr=$5
    local ip=$6
    local URL_PARAMS
    URL_PARAMS="AccessKeyId=${keyid}"
    URL_PARAMS="${URL_PARAMS}&Action=UpdateDomainRecord"
    URL_PARAMS="${URL_PARAMS}&Format=JSON"
    URL_PARAMS="${URL_PARAMS}&RR=${rr}"
    URL_PARAMS="${URL_PARAMS}&RecordId=${recid}"
    URL_PARAMS="${URL_PARAMS}&SignatureMethod=HMAC-SHA1"
    URL_PARAMS="${URL_PARAMS}&SignatureNonce="`date +%s%3N`
    URL_PARAMS="${URL_PARAMS}&SignatureVersion=1.0"
    URL_PARAMS="${URL_PARAMS}&Timestamp="`urlEncode $(date -u +"%Y-%m-%dT%H:%M:%SZ")`
    URL_PARAMS="${URL_PARAMS}&Type=${type}"
    URL_PARAMS="${URL_PARAMS}&Value=`urlEncode ${ip}`"
    URL_PARAMS="${URL_PARAMS}&Version=2015-01-09"

    local STRING_To_SIGN="GET&%2F&`urlEncode ${URL_PARAMS}`"

    local SIGNATURE=`echo -n ${STRING_To_SIGN} | openssl dgst -hmac "${keyval}&" -sha1 -binary | openssl enc -base64`
    SIGNATURE=`urlEncode $SIGNATURE`

    URL_PARAMS="${URL_PARAMS}&Signature=${SIGNATURE}"
    curl -ss "http://alidns.aliyuncs.com?${URL_PARAMS}"
}

function AddDomainRecord(){
    local keyid=$1
    local keyval=$2
    local domain=$3
    local type=$4
    local rr=$5
    local ip=$6
    local URL_PARAMS
    URL_PARAMS="AccessKeyId=${keyid}"
    URL_PARAMS="${URL_PARAMS}&Action=AddDomainRecord"
    URL_PARAMS="${URL_PARAMS}&DomainName=${domain}"
    URL_PARAMS="${URL_PARAMS}&Format=JSON"
    URL_PARAMS="${URL_PARAMS}&RR=${rr}"
    URL_PARAMS="${URL_PARAMS}&SignatureMethod=HMAC-SHA1"
    URL_PARAMS="${URL_PARAMS}&SignatureNonce="`date +%s%3N`
    URL_PARAMS="${URL_PARAMS}&SignatureVersion=1.0"
    URL_PARAMS="${URL_PARAMS}&Timestamp="`urlEncode $(date -u +"%Y-%m-%dT%H:%M:%SZ")`
    URL_PARAMS="${URL_PARAMS}&Type=${type}"
    URL_PARAMS="${URL_PARAMS}&Value=`urlEncode ${ip}`"
    URL_PARAMS="${URL_PARAMS}&Version=2015-01-09"

    local STRING_To_SIGN="GET&%2F&`urlEncode ${URL_PARAMS}`"

    local SIGNATURE=`echo -n ${STRING_To_SIGN} | openssl dgst -hmac "${keyval}&" -sha1 -binary | openssl enc -base64`
    SIGNATURE=`urlEncode $SIGNATURE`

    URL_PARAMS="${URL_PARAMS}&Signature=${SIGNATURE}"
    curl -ss "http://alidns.aliyuncs.com?${URL_PARAMS}"
}

function get_RecordIP() {
  local records=$1
  local ip="`echo ${records}|tr -d '{}'|cut -f 10 -d','|tr -d '[:alpha:]'|tr -d '"'|sed "s/://"`"
  echo "$ip"
}

function get_RecordId() {
  local records=$1
  local id="`echo ${records}|tr -d '{}'|cut -f 11 -d','|tr -cd '[:digit:]'`"
  echo "$id"
}


function Set_DNS_IP() {
    local keyid=$1
    local keyval=$2
    local domain=$3
    local type=$4
    local rr=$5
    local ip=$6

  local records=$(DescribeDomainRecords ${keyid} ${keyval} ${domain} ${type} ${rr})

  if echo ${records}|grep -q '"'${rr}'"'; then
    if echo ${records}|grep -q '"'${ip}'"'; then
        [ $_V -eq 1 ] && echo ""
        [ $_V -eq 1 ] && echo "${rr}.${domain}    ${ip}"
        [ $_V -eq 1 ] && echo "Already set,  Skip"
    else
      local rec_id=$(get_RecordId ${records})

      local result=`UpdateDomainRecord ${keyid} ${keyval} ${rec_id} ${type} ${rr} ${ip}`
      if echo ${result}|grep -q 'RecordId'; then
          [ $_V -eq 1 ] && echo ""
          [ $_V -eq 1 ] && echo "${rr}.${domain}    $ip"
          [ $_V -eq 1 ] && echo "Set the DNS IP,  OK."
      else
          [ $_V -eq 1 ] && echo ""
          [ $_V -eq 1 ] && echo "${rr}.${domain}    $ip"
          [ $_V -eq 1 ] && echo "Set the DNS IP,  Failed."
      fi
    fi
  fi
}


function Get_DNS_IP() {
    local keyid=$1
    local keyval=$2
    local domain=$3
    local type=$4
    local rr=$5

  local records=$(DescribeDomainRecords ${keyid} ${keyval} ${domain} ${type} ${rr})
  local ip=$(get_RecordIP ${records})

  echo ${ip}
}
