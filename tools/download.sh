#!/bin/bash

echo aosp branch: $BRANCH
echo aosp device: $DEVICE
TARGET=${DEVICE}-userdebug

HOST_ARCH=$(uname -m)

if [ "$HOST_ARCH" = "aarch64" ]; then
    HOST_ARCH="arm64"
fi

if [[ "$DEVICE" == *"arm64"* ]]; then
    TARGET_ARCH="arm64"
elif [[ "$DEVICE" == *"x86_64"* ]]; then
    TARGET_ARCH="x86_64"
elif [[ "$DEVICE" == *"riscv64"* ]]; then
    TARGET_ARCH="riscv64"
else
    echo "unknown arch from DEVICE ($DEVICE)"
    exit 1
fi

echo "-> host arch: $HOST_ARCH"
echo "-> target arch: $TARGET_ARCH"

URL_CI_ANDROID=https://ci.android.com/builds/latest/branches/${BRANCH}/targets/${TARGET}/view/BUILD_INFO
RURL_CI_ANDROID=$(curl -Ls -o /dev/null -w %{url_effective} ${URL_CI_ANDROID})

VERSION=${RURL_CI_ANDROID%/$TARGET/latest/view/BUILD_INFO}
VERSION=${VERSION#https://ci.android.com/builds/submitted/}

wget -nv "https://ci.android.com/builds/submitted/15885347/aosp_cf_x86_64_only_phone-userdebug/latest/raw/aosp_cf_x86_64_only_phone-img-15885347.zip" -O ${DEVICE}-img.zip

if [ "$TARGET_ARCH" = "$HOST_ARCH" ]; then
    FILE_NAME="cvd-host_package.tar.gz"
    echo "-> arch matched: (run $TARGET_ARCH on $HOST_ARCH)), downloading $FILE_NAME..."
    wget -nv ${RURL_CI_ANDROID%/view/BUILD_INFO}/raw/cvd-host_package.tar.gz -O cvd-host_package.tar.gz
elif [ "$TARGET_ARCH" != "x86_64" ] && [ "$HOST_ARCH" = "x86_64" ]; then
    FILE_NAME="cvd-host_package-x86_64.tar.gz"
    echo "->  cross arch detected:  (run $TARGET_ARCH on $HOST_ARCH), downloading $FILE_NAME..."
    wget -nv "https://ci.android.com/builds/submitted/15885347/aosp_cf_x86_64_only_phone-userdebug/latest/raw/cvd-host_package.tar.gz" -O cvd-host_package.tar.gz
else
    echo "-> arch not matched: (not support run $TARGET_ARCH on $HOST_ARCH)"
    exit 1
fi

mkdir -p $CF_HOME
tar -xvf cvd-host_package.tar.gz -C $CF_HOME
unzip ${DEVICE}-img.zip -d $CF_HOME

if [ ! -e /dev/kvm ] || [ "$TARGET_ARCH" != "$HOST_ARCH" ]; then
  echo "disable kvm"
  sed -i 's/,accel=kvm/\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00/g' $CF_HOME/bin/run_cvd
  sed -i 's/,accel=kvm/\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00/g' $CF_HOME/bin/assemble_cvd
  sed -i "s/,gic-version=3/,gic-version=2/g" $CF_HOME/bin/run_cvd
  sed -i "s/,gic-version=3/,gic-version=2/g" $CF_HOME/bin/assemble_cvd
  sed -i 's/\x00host\x00/\x00max\x00\x00/g' $CF_HOME/bin/run_cvd
  sed -i 's/\x00host\x00/\x00max\x00\x00/g' $CF_HOME/bin/assemble_cvd
  sed -i 's/\x00-accel\x00/\x00-name\x00\x00/g' $CF_HOME/bin/run_cvd
  sed -i 's/\x00-accel\x00/\x00-name\x00\x00/g' $CF_HOME/bin/assemble_cvd
  touch $CF_HOME/use_qemu
fi
