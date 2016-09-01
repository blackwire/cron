#!/bin/bash

# base schedule around start time of the script
start=$(date +%s);

# schedule (interval in seconds:command to run)
schedule=(
    [0]='10:stress --cpu 2 --timeout 5' 
    [1]='1:ls | grep "blackwire"'
);

while :
do
    for item in "${schedule[@]}"
    do
        now=$(date +%s);
        elapsed=$((now - start));

        # wait to run until first interval is hit from the script start time
        if [[ $elapsed == 0 ]]
        then
            sleep 1;
            continue;
        fi;

        # split the string to pull out the interval and the command as seperate values
        IFS=':' read -r -a attributes <<< "${item}";
        interval=${attributes[0]};
        cmd="${attributes[1]}";
        
        # run command based on the interval specified in the schedule
        if [[ $((elapsed % interval)) == 0 ]]
        then
            (>&1 echo "[cron-start] $(date +%s)  ::  ${cmd}");
            # run command using the && at the end to tell it to run the complete/failed after completion of the script
            # and use the & after the if block to tell it to run all of this in a separate process and keep running the cron independently
            eval $cmd && 
            if [ $? -eq 0 ] 
            then 
                (>&1 echo "[cron-complete] $(date +%s)  ::  ${cmd}")
            else
                (>&2 echo "[cron-failed] $(date +%s)  ::  ${cmd}")
            fi &
        fi
    done;
    sleep 1;
done;

exit 0;