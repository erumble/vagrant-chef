#!/bin/bash

# add puppet binaries to the secure path
cat > /etc/sudoers.d/securepath << EOF
Defaults    secure_path = /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin
EOF

chmod 440 /etc/sudoers.d/securepath

# keep the ssh auth socket, useful becasue we forward the ssh agent from the host to the guest
cat > /etc/sudoers.d/envkeep << EOF
Defaults env_keep += SSH_AUTH_SOCK
EOF

chmod 440 /etc/sudoers.d/envkeep

