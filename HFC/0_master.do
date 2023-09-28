********************************************************************************
** 	TITLE	: 00_master.do
**	PURPOSE	: Master do file
**  PROJECT	: Kenya Lactation Rooms		
**	AUTHOR	: Flavia Ungarelli
**	DATE LAST MODIFIED: 29/06/2023
********************************************************************************

**# packages to install

/* net install grc1leg.pkg, all replace from("http://www.stata.com/users/vwiggins/") //For combined boxplots

 net install ipacheck, all replace from("https://raw.githubusercontent.com/PovertyAction/high-frequency-checks/master")
ipacheck update

 ssc install asdoc, update
 
 net install http://www.stata.com/users/kcrow/tab2xl, replace
 
 net install logout.pkg, all replace from(" http://fmwww.bc.edu/RePEc/bocode/l/")
*/

**# setup Stata
*------------------------------------------------------------------------------*
	cls
	clear 			all
	macro drop 		_all
	version 		17
	set min_memory 	1g
	set maxvar 		32767
	set more 		off
	
	set seed 		87235
	set sortseed 	98237

**# setup working directory
*------------------------------------------------------------------------------*

global user = "/Users/flavia_ungarelli"
global cwd "${user}/Dropbox/Kenya Lactation Rooms/9.SCALEUP/HFC"

cd "${cwd}"
	
**# Baseline Survey
*------------------------------------------------------------------------------*
	do "2_dofiles/1_globals_Baseline.do"										// globals do-file
	
	do "2_dofiles/import_Baseline.do"											// import do-file 	
	
	do "2_dofiles/3_prepsurvey_Baseline.do"										// prep survey do-file
	
	do "2_dofiles/4_checksurvey_Baseline.do"									// check survey do-file

	do "2_dofiles/7_checksurvey_Baseline_newsubmissions.do", nostop

** END **
