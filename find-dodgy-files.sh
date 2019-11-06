#!/bin/sh

echo "Starting test 1/5 ..."
/usr/bin/find / -perm -2000 -ls > find_2000-ls.txt
echo "... 1/5 finished"

echo "Starting test 2/5 ..."
/usr/bin/find / -perm -4000 -ls > find_4000-ls.txt
echo "... 2/5 finished"

echo "Starting test 3/5 ..."
/usr/bin/find / -perm -o+w -type f -ls > find_ow_f-ls.txt
echo "... 3/5 finished"

echo "Starting test 4/5 ..."
/usr/bin/find / -perm -o+w -type d -ls > find_ow_d-ls.txt
echo "... 4/5 finished"

echo "Starting test 5/5 ..."
/usr/bin/find / -nouser -o -nogroup -print > find_no.txt
echo "... 5/5 finished"
