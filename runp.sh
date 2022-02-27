#!/bin/bash

tmp=$(mktemp -d)


NCORE=$(grep -c "processor" /proc/cpuinfo)
NCORE=12
[ $NCORE -eq 1 ] && echo "Nothing to do here, sorry just one CPU" && exit

cat > $tmp/ALL

#
## Split into chunks the list of files
#
#split -n l/$NCORE $tmp/ALL $tmp/CHUNKS.
tot=$(cat $tmp/ALL | wc -l | awk -v chunks=$NCORE '{print int($1/chunks)}')
/usr/bin/split -l $tot $tmp/ALL $tmp/CHUNKS.
wc -l $tmp/*
read -p "go?" ans

#
## Run in paralel
#
pidlist=""
for f in $tmp/CHUNKS.*
do
	n=$(basename $f)
	bash $f > $tmp/$n.LOG 2>&1 &
	pidlist="$pidlist $!"
done

#
## Wait
#
echo "Waiting for ... $pidlist"
wait $pidlist

echo "Output is @ $tmp"
(cd $tmp && xterm)

