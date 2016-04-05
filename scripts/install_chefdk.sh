#!/bin/bash

# declare a hash of os major release version and the sha1sum of the chefdk rpm
declare -A chefdk_sha1sums=(
  ['6']='619dfe23e23b0af622052827f564a59beded7973'
  ['7']='8692e7e29f051298c413578bc3b1121d59e60979'
)

os_family=$(lsb_release -is)
os_release=$(lsb_release -rs | awk -F '.' '{ print $1 }')

if [[ $os_family != "CentOS" ]] || ! [[ $os_release =~ [6-7] ]]; then
  echo 'This script only works on CentOS 6 or 7'
  exit 1
fi

chefdk_rpm_url=https://packages.chef.io/stable/el/$os_release/
chefdk_rpm=chefdk-0.12.0-1.el$os_release.x86_64.rpm
chefdk_sha1=${chefdk_sha1sums[$os_release]}

mkdir -p /tmp/chef-dk
pushd /tmp/chef-dk
  wget -nv $chefdk_rpm_url$chefdk_rpm
  if [[ $(sha1sum $chefdk_rpm) != $chefdk_sha1* ]]; then
    echo "$chefdk_rpm has an invalid checksum; aborting installation"
    exit 1
  fi

  yum localinstall -y $chefdk_rpm
popd
rm -rf /tmp/chef-dk

