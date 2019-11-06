#!/bin/sh

email_address="root"
email_subject="`/bin/hostname` - Lynis Audit Warnings"

/usr/bin/printf '%s\n' "$email_subject" "" "`/usr/local/bin/lynis audit system --cronjob --warnings-only`" | /usr/bin/mail -s "$email_subject" "$email_address"
