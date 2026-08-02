#!/bin/bash

BRANCH=aosp-android-latest-release
DEVICE=aosp_cf_x86_64_only_phone
TARGET=${DEVICE}-userdebug


URL_CI_ANDROID=https://ci.android.com/builds/latest/branches/${BRANCH}/targets/${TARGET}/view/BUILD_INFO
RURL_CI_ANDROID=$(curl -Ls -o /dev/null -w %{url_effective} ${URL_CI_ANDROID})

VERSION=${RURL_CI_ANDROID%/$TARGET/latest/view/BUILD_INFO}
VERSION=${VERSION#https://ci.android.com/builds/submitted/}

wget -nv ${RURL_CI_ANDROID%/view/BUILD_INFO}/raw/${DEVICE}-img-$VERSION.zip -O ${DEVICE}-img.zip

wget -nv ${RURL_CI_ANDROID%/view/BUILD_INFO}/raw/cvd-host_package.tar.gz -O cvd-host_package.tar.gz
#wget -nv ${RURL_CI_ANDROID%/view/BUILD_INFO}/raw/cvd-host_package-x86_64.tar.gz -O cvd-host_package.tar.gz

mkdir -p $CF_HOME
tar -xvf cvd-host_package.tar.gz -C $CF_HOME
unzip ${DEVICE}-img.zip -d $CF_HOME
