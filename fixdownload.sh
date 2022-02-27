#!/bin/bash
## ## ## ##

source help.sh

HERE=$(pwd)

folder="$1"

HP=0.5
LP=4.0

[ -z "$folder" ] && echo "Bad folder." && exit
[ ! -d "$folder" ] && echo "No folder." && exit

(
	cd $folder || exit
	nbad=$(sachinfo -d . b a e | awk '$3 <= $2 || $3 >= $4' | wc -l)
	[ "$nbad" -ge 1 ] && echo "Bad traces !" && exit
)

(
	cd $folder || exit
	sachinfo -d . knetwk kstnm kcmpnm kevnm | sort -k 5 | awk '{printf "mv -iv %s %s.%s.%s.%s.sac\n",$1,$2,$3,$5,substr($4,3,1)}' | bash
)

(
	cd $folder || exit
	for ev in $(events)
	do
		echo "Fixing .. $ev"
		
		rfile=$(ls -1 *.$ev.Z.sac | sed -e 's/[.]Z[.]/.R./g')
		tfile=$(ls -1 *.$ev.Z.sac | sed -e 's/[.]Z[.]/.T./g')
		
		sac << EOF > $HERE/LOG.fix 2>&1
cut a -10. 60.
r *.$ev.*Z.sac
cut a -10 120.
r more *.$ev.*[NE].sac
rmean; rtr; rmean; rtr; taper w 0.01;
sync
lp cor $LP p 2 n 3
hp cor $HP p 2 n 3
interp delta 0.1
rtr; taper w 0.01
w over
cut off
r *.$ev.[NE12].sac
rotate to gcp
ch file 1 kcmpnm HHR
ch file 2 kcmpnm HHT
w $rfile $tfile
quit y

EOF
	done
)

exit

170224_055907
