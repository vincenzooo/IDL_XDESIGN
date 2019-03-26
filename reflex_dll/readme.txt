2019/03/25 Vincenzo
This folder contains reflectivity programs based on the use of Fortran DLL.

loadRI: used to load refraction indices before calling reflexDLL 
reflexDLL,reflexDLLexample: calculate reflectivity as a function of energy for a single angle.
reflexmatrix: calculate 2d reflectivity, assuming refraction indices were previously loaded.
reflex2d(v1,2,3),spie2010: wrapper around loadRI and reflexmatrix.
 calculate 2d reflectivity and load indices, generate a set of outputs.

=DEVELOPER NOTES=
Programs are sorted today and collected here, but sorting was not completed because 
dll is still not running under UNIX and it was not possible to test the code.
See notes on programming spiral notebook about how to integrate fortran and IDL.

TODO: There are three different versions of reflex2d. Most updated version (3)
can be modified to remove shell angle alpha from input.
theta resolution was removed from version 2.
alpha and thResArcsec can be moved out and used to calculate theta.
Examples after routine can be removed (they were moved to a separate file SPIE2010
to whom an interface subroutine procedure converting alpha and thresarcsec to vector theta). 

