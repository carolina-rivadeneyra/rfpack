export PYTHONPATH=$(pwd)/fetchtool/
export PATH=$(pwd):$PATH
#source /opt/miniconda2/bin/activate

function events() {
	[ -z "$1" ] && d="./" || d="$1"
	sachinfo -d $d kevnm | awk '{print $2}' | sort -u
}

function spacer() {
	awk '{print " "$0}'
}

function cleandec() {
	rm -v *.DR.sac *.DT.sac *.LOG
}

function cleancorr() {
	for f in *.bad
	do
		mv -i $f $(basename $f .bad)
	done
}
