#!/bin/bash

function datarayp() {
    [ $mode == "linear" ] && extra="" || extra="-u"
    sac2gmt -q -e DR.sac -d . -s USER4 -i USER4 -i USER5 $extra 2> /dev/null
}

function databaz() {
    [ $mode == "linear" ] && extra="" || extra="-u"
    sac2gmt -q -e DR.sac -d . -s BAZ -i BAZ -i USER5 $extra 2> /dev/null
}

function getfit() {
    grep '>' | awk '{print $4, $2}'
}

function getvar() {
    grep '>' | awk '{print $3, $2}'
}

gmtset FONT_LABEL 12p,Helvetica,black
gmtset FONT_ANNOT_PRIMARY 10p,Helvetica,black

mode=linear # real or linear

color=orange
W=3.0
YANOT=f1a5
XANOT=f2a10
ps=plot.ps

##
# Rayp Plot
##

[ $mode == "real" ] && YANOT=f0.001a0.01

R=$(datarayp |\
    gmt info -I1.0/0.01 -C |  awk '{scaley=($4-$3)*0.02; printf "-R%f/%f/%f/%f",-5.0,55.,$3-scaley,$4+scaley}')
Rfit=$(datarayp | getfit |\
    gmt info -I1.0/0.01 -C | awk '{scaley=($4-$3)*0.02; printf "-R%f/%f/%f/%f",0.0,110.,$3-scaley,$4+scaley}')
Rvar=$(datarayp | getvar |\
    gmt info -I0.02/0.01 -C | awk '{scaley=($4-$3)*0.02; printf "-R%f/%f/%f/%f",$1,$2+0.01,$3-scaley,$4+scaley}')
echo $R $Rfit / $Rvar
datarayp |\
    gmt pswiggle -Z$W -W0.5p,120 $R -JX6/17 -B${XANOT}:"Time (s)":/${YANOT}WSne -P -X2 -Yc -K -G$color > $ps
datarayp | getfit | gmt psxy $Rfit -JX1.5/17 -Bg20f20a40:"% Fit":/0N -X6.5 -W1p,gray,-- -O -K --MAP_GRID_PEN_PRIMARY=default,gray >> $ps
datarayp | getvar | gmt psxy $Rvar -JX1.5/17 -Bf0.01a0.03:"p (s/km)":/0Swe -W1p,red -O -K >> $ps

##
# BAZ plot
##

[ $mode == "real" ] && YANOT=f5a45

R=$(databaz |\
    gmt info -I1.0/1. -C | awk '{scaley=($4-$3)*0.02;printf "-R%f/%f/%f/%f",-5.0,55.,$3-scaley,$4+scaley}')
Rfit=$(databaz | getfit |\
    gmt info -I1.0/1. -C | awk '{scaley=($4-$3)*0.02;printf "-R%f/%f/%f/%f",0.0,110.,$3-scaley,$4+scaley}')
Rvar=$(databaz | getvar |\
    gmt info -I1/1. -C | awk '{scaley=($4-$3)*0.02;printf "-R%f/%f/%f/%f",-5.0,365,$3-scaley,$4+scaley}')
echo $R $Rfit / $Rvar
databaz |\
    gmt pswiggle -Z$W -W0.5p,120 $R -JX6/17 -B${XANOT}:"Time (s)":/${YANOT}WSne -P -X3 -Yc -G$color -K -O >> $ps
databaz | getfit | gmt psxy $Rfit -JX1.5/17 -Bg20f20a40:"% Fit":/0N -X6.5 -W1p,gray,-- -O -K --MAP_GRID_PEN_PRIMARY=default,gray >> $ps
databaz | getvar | gmt psxy $Rvar -JX1.5/17 -Bf30a180:"BAZ (\260)":/0Swe -W1p,red -O -K >> $ps

gmt psxy -R -J -O -T >> $ps
psconvert -Z -A -P -Tf $ps
evince $(basename $ps .ps).pdf
