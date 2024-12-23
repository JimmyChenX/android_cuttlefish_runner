#ifconfig

#sudo modprobe vhost_vsock vhost_net

ls -l /dev/ | grep lvm

cd $CF_HOME

HOME=$PWD ./bin/launch_cvd -cpus=4 --memory_mb=8192 -enable_sandbox=false --report_anonymous_usage_stats=n --daemon
