#!/usr/bin/python

from __future__ import print_function, division

import sys, glob, os
from matplotlib import pyplot as plt
from obspy import read as oRead
import warnings

plt.rcParams['keymap.save'] = ''

class Picker(object):
	def __init__(self):
		self.key = None
		self.count = 0

	def onkey(self,event): 
		self.key = event.key

	def onmouse(self, event):
		self.key = None

# Setup

picker = Picker()
good   = []
bad    = []

# File loop

plt.close()
fig = plt.figure()
fig.canvas.mpl_connect('key_press_event', picker.onkey)

if os.path.isfile("goodlist.txt"):
	fh = open("goodlist.txt")
	good = fh.readlines()
	good = map(lambda x: x.strip(), good)
	fh.close()

if os.path.isfile("badlist.txt"):
	fh = open("badlist.txt")
	bad = fh.readlines()
	bad = map(lambda x: x.strip(), bad)
	fh.close()


print(good)
print(bad)

lista=glob.glob("*.sac")

i=0
while i < len(lista): 
	f = lista[i]
	status="-"
	if f in good: status="good"
	if f in bad: status="bad"
	st = oRead(f)
	tr=st[0]
#	filt=tr.filter('highpass', freq=0.05, corners=2, zerophase=True)
	tr.plot(fig=fig)
	plt.title('[%d/%d] %s [%s]' % (i+1,len(lista),f,status))
	fig.show()
	while 1:
		fig.waitforbuttonpress(timeout=-1)
		if picker.key == 'q':
			break
		elif picker.key == '1':
			i=0
			break
		elif picker.key == '9':
			i=len(lista)-1
			break
		elif picker.key == 'N':
			for i in range(0,len(lista)):
				if lista[i] in good or lista[i] in bad: continue
				break
			break

		elif picker.key == 'n':
			i = min(len(lista)-1,i+1)
			break
		elif picker.key == 'p':
			i = max(0,i-1)
			break
		elif picker.key == 'g':
			if f in bad: bad.remove(f)
			good.append(f)
			i += 1
			break
		elif picker.key == 'b':
			if f in good: good.remove(f)
			bad.append(f)
			i += 1
			break
		else:
			print("Unknow key, %s" % picker.key)
	fig.clear()
	if picker.key == 'q': break

listfile = open("list","w")
for f in good:
	print("%s" % f,file=listfile)
listfile.close()
print("Saved to file 'list'")

badfile = open("badlist.txt","w")
for f in bad:
	print("%s" % f,file=badfile)
badfile.close()
print("Saved to file 'badlist.txt'")

