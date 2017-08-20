#!/bin/sh
set -e

# Checks for USER variable
if [ -z "$USER" ]; then
  echo >&2 'Please set an USER variable (ie.: -e USER=john).'
  exit 1
fi

# Checks for PASSWORD variable
if [ -z "$PASSWORD" ]; then
  echo >&2 'Please set a PASSWORD variable (ie.: -e PASSWORD=hackme).'
  exit 1
fi

if /usr/bin/id -u ${USER}; then
  echo "User ${USER} already exists"
else
  echo "Creating user ${USER} with home /data"
  adduser -D -h /data ${USER}
  echo "${USER}:${PASSWORD}" | chpasswd
fi

if [ ! -d /data/webroot ]; then
  echo "Creating /data/webroot"
  mkdir -p /data/webroot
fi

# The folder itself must be owned by root, the contents
# by the user
echo "Fixing permissions for user ${USER} in /data/webroot"
chown -Rv ${USER}:${USER} /data/webroot
chmod -Rv 644 /data/webroot
chown root.root /data/webroot
chmod 777 /data/webroot

echo "Fixing permission to root in /data"
chown root.root /data
chmod 755 /data

# Generate unique ssh keys for this container, if needed
if [ ! -f /etc/ssh/keys/ssh_host_ed25519_key ]; then
    ssh-keygen -t ed25519 -f /etc/ssh/keys/ssh_host_ed25519_key -N ''
fi
if [ ! -f /etc/ssh/keys/ssh_host_rsa_key ]; then
    ssh-keygen -t rsa -b 4096 -f /etc/ssh/keys/ssh_host_rsa_key -N ''
fi

exec /usr/bin/supervisord -n -c /etc/supervisord.conf
