; docformat = 'rst'
;
; VC: converted from IDL template
; 
;+
; NAME:
;	ROUTINE_NAME
;
; PURPOSE:
;	Tell what your routine does here.  I like to start with the words:
;	"This function (or procedure) ..."
;	Try to use the active, present tense.
;
; :Categories:
;	Put a category (or categories) here.  For example:
;	Widgets.
;
; CALLING SEQUENCE:
;	Write the calling sequence here. Include only positional parameters
;	(i.e., NO KEYWORDS). For procedures, use the form:
;
;	ROUTINE_NAME, Parameter1, Parameter2, Foobar
;
;	Note that the routine name is ALL CAPS and arguments have Initial
;	Caps.  For functions, use the form:
; 
;	Result = FUNCTION_NAME(Parameter1, Parameter2, Foobar)
;
;	Always use the "Result = " part to begin. This makes it super-obvious
;	to the user that this routine is a function!
;
; :Params:
;	  Parm1:	
;	    Describe the positional input parameters here. Note again
;		     that positional parameters are shown with Initial Caps.
;
; :Keywords:
;	  KEY1:	
;	    Document keyword parameters like this. Note that the keyword
;		is shown in ALL CAPS!
;
; OUTPUTS:
;	Describe any outputs here.  For example, "This function returns the
;	foobar superflimpt version of the input array."  This is where you
;	should also document the return value for functions.
;
; OPTIONAL OUTPUTS:
;	Describe optional outputs here.  If the routine doesn't have any, 
;	just delete this section.
;
; COMMON BLOCKS:
;	BLOCK1:	Describe any common blocks here. If there are no COMMON
;		blocks, just delete this entry.
;
; SIDE EFFECTS:
;	Describe "side effects" here.  There aren't any?  Well, just delete
;	this entry.
;
; :Uses:
;	  Specify any other routines, classes, etc. needed by the routine
;
; PROCEDURE:
;	You can describe the foobar superfloatation method being used here.
;	You might not need this section for your routine.
;
; :Examples:
;	Please provide a simple example here. An example from the
;	DIALOG_PICKFILE documentation is shown below. Please try to
;	include examples that do not rely on variables or data files
;	that are not defined in the example code. Your example should
;	execute properly if typed in at the IDL command line with no
;	other preparation. 
;
;       Create a DIALOG_PICKFILE dialog that lets users select only
;       files with the extension `pro'. Use the `Select File to Read'
;       title and store the name of the selected file in the variable
;       file. Enter:
;
;       file = DIALOG_PICKFILE(/READ, FILTER = '*.pro') 
;
; :Author:
; 	Written by:	Your name here, Date.
;	
;	:History:
;	  July, 1994	Any additional mods get described here.  Remember to
;			change the stuff above if you add a new keyword or
;			something!
;-

PRO TEMPLATE

  PRINT, "This is an example header file for documenting IDL routines"

END
