# IDL_XDESIGN
Collection of IDL routines for X-Ray telescopes design and simulation and for surface data analysis.

This collection was put together during many years of work on different topics, and it is under constant reorganization
It started from messy state because of the bad habit of mixing in same folder libraries and code at any level of development and the entire source base (from times before version control) was uploaded. 
However (at least part of) procedures are quite documented, and recently had the chance to use and clean up some of them. 
I don't exclude to do more clean up and generate some documentation if I will have the chance (I don't even have a version of IDL installed at the moment).

The code is mostly about three areas:
## Coatings
NEW 2019: This is old code on which I recently started working again for a project about ray-tracing and design of optics. 
`Reflex`contains several examples of reflectivity calculation (using IMD library, using external dll and a simpler pure IDL implementation)
Each one of these was working at some point in history, but doesn't have a common interface or usage. At the moment the library is quite messy, as I am still figuring out what part of it is doing, but things are getting sorted out.
`Multilayer` and `Overcoating` contain dependent functions for optimization of multilayer and bilayer coatings and for comparison and visualization of performances for different coatings. 

## Telescopes
This is a collection of utilities for the calculation of effective area of a telescope, on axis and off-axis. As for coating, I recently restarted working on this and I am working on recovering and cleaning the relevant part (a large part of the code deals with reading the output of previous fortran code). 
`Effective_area` contains code for the calculation of on-axis effective area. 
`Offaxis` in progress now, will extend the calculation to off-axis area.

## Metrology
This is no long actively maintained, and in current status it is difficult to find anything.
A possible starting point can be `cmmdatafile__define`, `cmmsurface__definedev`, `cmmprofile__define` in
`pool/surfaces`.
Most of the work was ported to or continued (and improved) in python:
https://github.com/vincenzooo/pyXSurf

