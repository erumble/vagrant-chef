#!/bin/bash

# declare a hash of os major release version and the sha1sum of the chefdk rpm
declare -A chefserver_sha1sums=(
  ['6']='377b6bb59d445aa7f86bc972af853ef07e673bd3'
  ['7']='b963a115f492f71dddded6c4957d5be24d488a09'
)

os_family=$(lsb_release -is)
os_release=$(lsb_release -rs | awk -F '.' '{ print $1 }')

if [[ $os_family != "CentOS" ]] || ! [[ $os_release =~ [6-7] ]]; then
  echo 'This script only works on CentOS 6 or 7'
  exit 1
fi

chefserver_rpm_url=https://packages.chef.io/stable/el/$os_release/
chefserver_rpm=chef-server-core-12.4.1-1.el$os_release.x86_64.rpm
chefserver_sha1=${chefserver_sha1sums[$os_release]}

mkdir -p /tmp/chef-server
pushd /tmp/chef-server
  wget -nv $chefserver_rpm_url$chefserver_rpm
  if [[ $(sha1sum $chefserver_rpm) != $chefserver_sha1* ]]; then
    echo "$chefserver_rpm has an invalid checksum; aborting installation"
    exit 1
  fi

  yum localinstall -y $chefserver_rpm
popd
rm -rf /tmp/chef-server

# setup some stuff for the chef server
cat > /etc/opscode/chef-server.rb <<EOF
server_name = "$(hostname -f)"
api_fqdn server_name
bookshelf['vip'] = server_name
nginx['url'] = "https://#{server_name}"
nginx['server_name'] = server_name
nginx['ssl_certificate'] = "/var/opt/opscode/nginx/ca/#{server_name}.crt"
nginx['ssl_certificate_key'] = "/var/opt/opscode/nginx/ca/#{server_name}.key"
lb['fqdn'] = server_name
EOF

# install management console
chef-server-ctl install chef-manage

# install reporting feature
chef-server-ctl install opscode-reporting

# reconfigure all the things!
chef-server-ctl reconfigure
opscode-manage-ctl reconfigure

# setup the admin user
admin_username=erumble
admin_firstname=eric
admin_lastname=rumble
admin_email=eric.rumble@example.com
admin_password=ChefInABox!
chef-server-ctl user-create $admin_username $admin_firstname $admin_lastname $admin_email $admin_password --filename $admin_username.pem

# setup the organization
org_shortname=poc
org_longname='Proof of Concept'
chef-server-ctl org-create $org_shortname $org_longname --association_user $admin_username --filename $org_shortname.pem

