#!/bin/bash
## ## ## ##

########################################################################################
# Configuration
########################################################################################
iteration=450
alpha=5.0
shift=10.
########################################################################################

source $(dirname $0)/help.sh

ev="$1" && shift
folder="$1"

[ ! -z "$folder" ] && pushd "$folder"
[ -z "$ev" ] && echo "No event given." && exit
[ $(ls -1 *.$ev.?.sac | wc -l) -ne 5 ] && echo "Missing files for event $ev" && exit

# prepare to run
HERE=$(pwd)

# Prepare and run a deconvolution
Z=$(basename $(ls -1 *.$ev.Z.sac))
R=$(basename $(ls -1 *.$ev.R.sac))
T=$(basename $(ls -1 *.$ev.T.sac))
DR=$(basename $Z .Z.sac).DR.sac
DT=$(basename $Z .Z.sac).DT.sac
LOG=$(basename $Z .Z.sac).LOG

tmp=$(mktemp -d)
pushd $tmp > /dev/null 2>&1  # Enter temp folder

ln -s $HERE/$Z
ln -s $HERE/$R
ln -s $HERE/$T

[ ! -f $Z ] && echo "No Z -- $Z --" && exit 1
[ ! -f $R ] && echo "No R -- $R --" && exit 1
[ ! -f $T ] && echo "No T -- $T --" && exit 1

arc=$(sachinfo $Z gcarc)
dep=$(sachinfo $Z evdp)
echo "Event $Z Gcarc=$arc Dep=$dep"
rayp=$(udtdd -GCARC $arc -EVDP $dep)

rm -f decon.out
echo "Running decon on: $(date)" > $LOG

## Do Radial
saciterd -FN $R -FD $Z -N $iteration -D $shift -ALP $alpha -RAYP $rayp >> $LOG 2>&1
mv decon.out $DR
rm -f denominator numerator observed predicted

## Do Tangential
saciterd -FN $T -FD $Z -N $iteration -D $shift -ALP $alpha -RAYP $rayp  >> $LOG 2>&1
mv decon.out $DT
rm -f denominator numerator observed predicted

sac << EOF >> $LOG 2>&1
rh $DR $DT
ch kevnm $ev
ch nzyear 1970
ch nzjday 001
ch nzhour 00
ch nzmin 00 
ch nzsec 00
ch nzmsec 0
ch o 0.0
ch a undef
ch ka undef
wh
rh $DR; ch kcmpnm DHR; wh
rh $DT; ch kcmpnm DHT; wh
quit
EOF

grep 'The final' $LOG | spacer

mv $DR $DT $LOG $HERE/ | spacer
popd > /dev/null 2>&1 # Leave the temp folder
rm -rf $tmp

[ ! -z "$folder" ] && popd

exit

160623_030539
