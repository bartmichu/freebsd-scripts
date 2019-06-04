#! /bin/sh

maxCapacity=80
scrubExpire=691200
problems=0

condition=$(/sbin/zpool status | egrep -i '(DEGRADED|FAULTED|OFFLINE|UNAVAIL|REMOVED|FAIL|DESTROYED|corrupt|cannot|unrecover)')
if [ "${condition}" ]; then
        emailSubject="`hostname` - ZFS pool - HEALTH fault"
        problems=1
fi

if [ ${problems} -eq 0 ]; then
   capacity=$(/sbin/zpool list -H -o capacity | cut -d'%' -f1)
   for line in ${capacity}
     do
       if [ $line -ge $maxCapacity ]; then
         emailSubject="`hostname` - ZFS pool - Capacity Exceeded"
         problems=1
       fi
     done
fi

if [ ${problems} -eq 0 ]; then
   errors=$(/sbin/zpool status | grep ONLINE | grep -v state | awk '{print $3 $4 $5}' | grep -v 000)
   if [ "${errors}" ]; then
        emailSubject="`hostname` - ZFS pool - Drive Errors"
        problems=1
   fi
fi

if [ ${problems} -eq 0 ]; then
   currentDate=$(date +%s)
   zfsVolumes=$(/sbin/zpool list -H -o name)

  for volume in ${zfsVolumes}
   do
    if [ $(/sbin/zpool status $volume | egrep -c "none requested") -ge 1 ]; then
        printf "ERROR: You need to run \"zpool scrub $volume\" before this script can monitor the scrub expiration time."
        break
    fi
    if [ $(/sbin/zpool status $volume | egrep -c "scrub in progress|resilver") -ge 1 ]; then
        break
    fi

    ### FreeBSD 11.2
    #scrubRawDate=$(/sbin/zpool status $volume | grep scrub | awk '{print $15 $12 $13}')
    
    ### FreeBSD 12.0
    scrubRawDate=$(/sbin/zpool status $volume | grep scrub | awk '{print $17 $14 $15}')
    
    scrubDate=$(date -j -f '%Y%b%e-%H%M%S' $scrubRawDate'-000000' +%s)

     if [ $(($currentDate - $scrubDate)) -ge $scrubExpire ]; then
        emailSubject="`hostname` - ZFS pool - Scrub Time Expired. Scrub Needed on Volume(s)"
        problems=1
     fi
   done
fi

if [ "$problems" -ne 0 ]; then
  printf '%s\n' "$emailSubject" "" "`/sbin/zpool list`" "" "`/sbin/zpool status`" | /usr/bin/mail -s "$emailSubject" root@localhost
  logger $emailSubject
fi