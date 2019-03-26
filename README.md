# IDL_XDESIGN
Collection of IDL routines for X-Ray telescopes design and simulation and for surface data analysis.

This collection was put together during many years of work on different topics, and it is under constant reorganization
It started from messy state because of the bad habit of mixing in same folder libraries and code at any level of development and the entire source base (from times before version control) was uploaded. 
However (at least part of) procedures are quite documented, and recently had the chance to use and clean up some of them. 
I don't exclude to do more clean up and generate some documentation if I will have the chance (I don't even have a version of IDL installed at the moment).

The code is mostly about three areas:
## Coatings
## Telescopes
## Metrology
This is no long actively maintained, and in current status it is difficult to find anything.
A possible starting point can be `cmmdatafile__define`, `cmmsurface__definedev`, `cmmprofile__define` in
`pool/surfaces`.
Most of the work was ported to or continued in python:
https://github.com/vincenzooo/pyXTel

