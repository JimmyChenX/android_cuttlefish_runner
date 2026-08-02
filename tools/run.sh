#!/bin/bash

CVD_HOME=$1

if [ ! -d $CVD_HOME ] && [ ! -f $CVD_HOME/bin/launch_cvd ] ;then
    echo launch_cvd not found 
    exit 1
fi
cd $CVD_HOME

if [ -e use_qemu ];then
  HOME=$PWD ./bin/launch_cvd --vm_manager=qemu_cli -cpus=4 --memory_mb=8192 -enable_sandbox=false --report_anonymous_usage_stats=n --daemon
else
  HOME=$PWD ./bin/launch_cvd -cpus=4 --memory_mb=8192 -enable_sandbox=false --report_anonymous_usage_stats=n --daemon
fi

