#!/bin/sh
#

# This script works with unmodified GENERIC kernels distributed as a part
# of an official FreeBSD release.

email_to="root"
email_subject="`/bin/hostname` - Reboot Required"

if [ `/bin/freebsd-version` != `/usr/bin/uname -r` ]; then
  echo "A reboot is required following updates to this server: `/bin/hostname`" | /usr/bin/mail -s "$email_subject" $email_to
fi
