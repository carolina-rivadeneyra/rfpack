from __future__ import print_function, division
from obspy import read
from obspy.signal import cross_correlation
import numpy as np
import glob
import os, sys

w      = 12
mincor = 0.65

if len(sys.argv) == 1:
	print("Usage: python correlation.py <BASEFILE> [mincor_value] [pos_zero_window_length]")
	sys.exit(1)

basename=sys.argv[1]
if not os.path.exists(basename):
	print("Error, base trace dos not exists.")
	sys.exit(1)

if len(sys.argv) > 2:
	mincor = float(sys.argv[2])
	print("Using mincor=%f" % mincor)

if len(sys.argv) > 3:
	w = float(sys.argv[3])
	print("Using w=%f" % w)

a=read(basename)
at=a[0]
ats=at.slice(at.stats.starttime+7,at.stats.starttime+10+w)
atsn=ats.data/np.nanmax(ats)

for f in glob.glob("*.DR.sac"):
	if f == basename: continue
	b=read(f)
	bt=b[0]
	bts=bt.slice(bt.stats.starttime+7,bt.stats.starttime+10+w)
	btsn=bts.data/np.nanmax(bts)
	x,y = cross_correlation.xcorr(atsn,btsn,0)
	print(f,y,"removed" if y < mincor else "accepted")
	if y < mincor:
		os.rename(f, "%s.bad" % f)

for f in glob.glob("*.DR.sac.bad"):
	if f == basename: continue
	b=read(f)
	bt=b[0]
	bts=bt.slice(bt.stats.starttime+7,bt.stats.starttime+10+w)
	btsn=bts.data/np.nanmax(bts)
	x,y = cross_correlation.xcorr(atsn,btsn,0)
	print(f,y,"removed" if y < mincor else "accepted")
	if y >= mincor:
		os.rename(f, "%s" % f[:-4])
