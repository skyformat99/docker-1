#!/bin/sh
set -x
MODE=$(echo $MODE | tr '[a-z]' '[A-Z]')
if [[ "${MODE}" == "SUPERNODE" ]]; then
    echo  ${MODE} -- 超级节点模式
    nohup \
      supernode \
      -l $SUPERNODE_PORT \
      -f \
      >> /var/log/run.log 2>&1 &
elif [[ "${MODE}" == "DHCPD" ]]; then
    echo ${MODE} -- DHCPD 服务器模式
    STATIC_IP=`echo $STATIC_IP | grep -Eo "([0-9]{1,3}[\.]){3}"`1
    nohup \
      edge \
      -d $N2N_INTERFACE \
      -a $STATIC_IP \
      -c $N2N_GROUP \
      -k $N2N_PASS \
      -l $N2N_SERVER \
      -Arf \
      >> /var/log/run.log 2>&1 &
      nohup dhcpd -f -d  $N2N_INTERFACE >> /var/log/run.log 2>&1 &
elif [[ "${MODE}" == "DHCP" ]]; then
    echo ${MODE} -- DHCP客户端模式
    nohup \
      edge \
      -d $N2N_INTERFACE \
      -a dhcp:0.0.0.0 \
      -c $N2N_GROUP \
      -k $N2N_PASS \
      -l $N2N_SERVER \
      -Arf \
      >> /var/log/run.log 2>&1 &
    while [ -z `ifconfig $N2N_INTERFACE| grep "inet addr:" | awk '{print $2}' | cut -c 6-` ]
    do
      dhclient $N2N_INTERFACE
    done
elif [[ "${MODE}" == "STATIC" ]]; then
    echo ${MODE} -- 静态地址模式
    nohup \
      edge \
      -d $N2N_INTERFACE \
      -a $STATIC_IP \
      -c $N2N_GROUP \
      -k $N2N_PASS \
      -l $N2N_SERVER \
      -Arf \
      >> /var/log/run.log 2>&1 &
    while [ -z `ifconfig $N2N_INTERFACE| grep "inet addr:" | awk '{print $2}' | cut -c 6-` ]
    do
      sleep 1
    done
else
    echo ${MODE} -- 判断失败
fi
ifconfig
tail -f -n 20  /var/log/run.log