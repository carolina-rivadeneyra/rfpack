#!/usr/bin/python
## ## ## ## ## ##

import sys, os

from Builders import FDSNBuilder, ArcLinkFDSNBuilder
from BaseBuilder import Range, BaseBuilder
from Downloader import Sc3ArclinkFetcher, Downloader
from Savers import QSaver, SacSaver

acl="seisrequest.iag.usp.br:18001/m.bianchi@iag.usp.br"

MINMAG = 5.0
MAXMAG = 10.0
MIND   = 30.
MAXD   = 95.

ns=sys.argv[1]

# Builder
rb = ArcLinkFDSNBuilder("IRIS",acl)

if not os.path.isfile("%s.req" % ns):
    t0 = sys.argv[2]
    t1 = sys.argv[3]



    print "Building a new request for ... %s" % ns
    rq = rb.stationBased(t0, t1,
        targetSamplingRate = 20.0,
        allowedGainList = ["H", "L"],
        dataWindowRange = Range(-120, 300),
        phasesOrPhaseGroupList = "pgroup",
        networkStationList = "%s" % ns,
        stationRestrictionArea = None,
        eventRestrictionArea = None,
        magnitudeRange = Range(MINMAG, MAXMAG),
        depthRange = None,
        distanceRange = Range(MIND, MAXD))

    rb.save_request("%s.req" % ns, rq)
else:
    print "Loading request from file %s!" % ns
    rq = rb.load_request("%s.req"  % ns)

# Fetcher
ft = Sc3ArclinkFetcher(acl, allinone=True, merge=False)

# Saver
s = SacSaver(debug = False)
s.enableTimeWindowCheck(-50, 120)

# Downloader
dl = Downloader("./", True, False, ft, [s])
dl.work(rq)
