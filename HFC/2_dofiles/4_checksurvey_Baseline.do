********************************************************************************
** 	TITLE	: 4_checksurvey_Baseline.do
**
**	PURPOSE	: Run High Frequency Checks on all observations
**				
**	AUTHOR	: Flavia Ungarelli
**
**	DATE LAST MODIFIED	:  21/08/2023
********************************************************************************

/*	============================================================================
	=================== IPA HIGH FREQUENCY CHECK TEMPLATE ====================== 
	============================================================================ */
   
	*========= Remove existing excel files and import prepped Dataset =========* 
	quietly{
	foreach file in hfc corrlog id_dups textaudit surveydb enumdb timeuse tracking bc {
		cap confirm file "${`file'_output}"
		if !_rc {
			rm "${`file'_output}"
		}
	}
   
   use "${preppedsurvey}", clear
   } 
	*======================= Resolve Survey Duplicates ========================*
	quietly{
//Used to check duplicates and to drop/keep/replace them as is necessary. The corrections must be specified in the "corrections" excel sheet in the inputs folder. I suppose we will probably not use this feature and rely on the cleaning document only, but it is available.
  
	if $run_corrections {
		ipacheckcorrections using "${corrfile}",		///
			sheet("${cr_dupsheet}")						///
			id(${key}) 									///
			logfile("${corrlog_output}")				///
			logsheet("${cr_dupslogsheet}")				///
			${cr_nolabel}								///
			${cr_ignore}
	}
}
	*========================= Find Survey Duplicates =========================*
	quietly{
 //Checks for duplicates in the teacher ID and produces the "id duplicates" sheet in the output excel file
  if $run_ids {
	   ipacheckids ${id},								///
				enumerator(${enum}) 					///	
				date(${date})	 						///
				key(${key}) 							///
				outfile("${hfc_output}") 				///
				outsheet("id duplicates")				///
				keep(${id_keepvars})	 				///
				dupfile("${id_dups_output}")			///
				save("${checkedsurvey}")				///
				${id_nolabel}							///
				force									///
				sheetreplace		
		use "${checkedsurvey}", clear
   }
   else {
		isid ${id}
		save "${checkedsurvey}", replace
   }
}  
	*========================== Other HFC Corrections =========================*
	quietly{  
 // Used to implement other corrections to the collected data once their cause is understood and discussed with the field team. The corrections must be specified in the "corrections" excel sheet in the inputs folder.
 
   if $run_corrections {		
		ipacheckcorrections using "${corrfile}", 		///
			sheet("${cr_othersheet}")					///
			id(${id}) 									///
			logfile("${corrlog_output}")				///
			logsheet("${cr_otherlogsheet}")				///
			${cr_nolabel}								///
			${cr_ignore}
			
		save "${checkedsurvey}", replace
	}
 }
	*============================ Other Specify ===============================*
	quietly{
 replace s_status_oth="" if s_status_oth=="."
   if $run_specify {
		ipacheckspecify using "${inputfile}",			///
			id(${id})									///
			enumerator(${enum})							///	
			date(${date})	 							///
			sheet("other specify")						///
        	outfile("${hfc_output}") 					///
			outsheet1("other specify")					///
			outsheet2("other specify (choices)")		///
			${os_nolabel}								///
			sheetreplace
			
			gl childvars "`r(childvarlist)'"
   }
}
	*========================== Recode other specify ==========================* NOT NECESSARY
	quietly{
	if $run_specifyrecode {		
		ipacheckspecifyrecode using "${recodefile}",	///
			sheet("${rc_sheet}")						///
			id($id)										///
			logfile("${recodelog_output}")				///
			logsheet("${rc_logsheet}")					///
			${rc_nolabel}
			
		save "${checkedsurvey}", replace
	}
}  
	*============================ Form versions ===============================*
	quietly{
// Lists the outdated forms that were submitted, if any.

	if $run_version {
		ipacheckversions ${formversion}, 				///
				enumerator(${enum}) 					///	
				date(${date})							///
				outfile("${hfc_output}") 				///
				outsheet1("form versions")				///
				outsheet2("outdated")					///
				keep(${vs_keepvars})					///
				sheetreplace							///
				$vs_nolabel
   }
}
	*========================== Variable Duplicates ===========================*
	quietly{
 preserve
  
// Checks for duplicates in the unique survey key, phone number, name and tsc number.   
  
   egen unique_id_nodups = concat(${id} ${key}) // The ${id} may not uniquely identify the observations when there are duplicates so I create this additional variable.
   
  rename modb_b2 phone_number
  rename concat_names_modb full_name
  
replace tsc_number=. if tsc_number==-555 // -555 is "prefer not to answer" so we need to avoid it showing up as a duplicate.

   if $run_dups {
	   ipacheckdups ${dp_vars},							///
				id(unique_id_nodups)					///
				enumerator(${enum}) 					///	
				date(${date})	 						///
				outfile("${hfc_output}") 				///
				outsheet("duplicates")					///
				keep(${keepvars})	 				///
				${dp_nolabel}							///
				sheetreplace
   }
 restore
}
	*========================= Variable Missingness ===========================*
	quietly{
 // Before running the missing values check I recode all the variables that are not applicable to -666 if numeric or "-666" if string.

 use "${preppedsurvey}", clear
 
**# MODULE A ***

quietly{
 // Questions asked to those who reported internet issues only:
 local varlist_2 "employee_count employee_details_count male_indices female_indices hteacher_index"
  foreach var of local varlist_2 {
	capture confirm numeric variable `var'
		if !_rc {
		replace `var' = -666 if internet_issue == 1	
        }
		else {
		replace `var' = "-666" if internet_issue == 1
        }
	}	

// Some observations have missing consent and no consent_signature photo is uploaded. I do not drop them but I recode all their missing values as "Skips" or -666. 

  foreach var of varlist _all {
	capture confirm numeric variable `var'
		if !_rc {
		replace `var' = -666 if(consented!=1 & missing(`var'))		
        }
		else {
		replace `var' = "-666" if(consented!=1 & missing(`var'))
        }
	}
	
 foreach var of varlist _all {
	capture confirm numeric variable `var'
		if !_rc {
		replace `var' = -666 if(consent_signature=="" & missing(`var'))		
        }
		else {
		replace `var' = "-666" if(consent_signature==""& missing(`var'))
        }
	}

// In some cases the teacher was not available to be interviewed
 foreach var of varlist _all {
	capture confirm numeric variable `var'
		if !_rc {
		replace `var' = -666 if(availability!=1 & missing(`var'))		
        }
		else {
		replace `var' = "-666" if(availability!=1 & missing(`var'))
        }
	}	
}

**# MODULE B ***

quietly{
  // Varibles regarding airtime
 replace airtime_no = "-666" if airtime_confirm==1
 replace airtime_no_reenter = "-666" if airtime_no=="-666"

 // Questions only asked to those with children
 replace modb_b10c= -666 if modb_b10_filtre!=1 // want other kids?
}

 **# MODULE L ***
 quietly{
 // Module L should only be asked to headteachers so we "-666" it for all other teachers, without counting these observations as missing. 
ds modl_*
  foreach var of varlist `r(varlist)' {
	capture confirm numeric variable `var'
		if !_rc {
		replace `var' = -666 if (survey_type!=1& missing(`var'))
        }
		else {
		replace `var' = "-666" if (survey_type!=1& missing(`var'))
        }
	}	
 replace modl_l24b="-666" if modl_l24a!=1 // In what circumstance can teachers leave early?
 }
 
**# MODULE C ***
 quietly{
replace modc_c16a=-666 if survey_type==1 // Part of a teachers union? (Not for HTs)
replace modc_c3f=-666 if survey_type==1 // Changes to timetable (Not for HTs)
}

**# MODULE D ***
 quietly{

/* Reminder of the variables that most commonly determine relevance
HT: survey_type==1
TC: survey_type==2

Female: modb_b9==0
Male: modb_b9==1

Children: modb_b10_filtre==1
No children: modb_b10_filtre==0

>45: modb_b3 < date('1978-06-01') i.e. 6575 for Stata
<45: modb_b3 >= date('1978-06-01') i.e. 6575 for Stata
CHANGED TO age >=/< 45
*/

 // for those with children
replace modd_d1_cal_year=-666 if(modb_b10_filtre!=1|modb_b9!=0)

 // questions only asked to women without children
 replace modd_d27= -666 if(modb_b10_filtre!=0|modb_b9!=0) // want any kids?
 
 // questions only asked to men without children
 replace modd_d27_male= -666 if (modb_b10_filtre!=0|modb_b9!=1) // want any kids?
 
 // for HT and TC female with kids
 replace modd_d3=-666 if(modb_b9!=0|modb_b10_filtre!=1)
 replace modd_d4="-666" if(modb_b9!=0|modb_b10_filtre!=1) // Select multiple
 replace modd_d5_filtre=-666 if(modb_b9!=0|modb_b10_filtre!=1)
 replace modd_d5=-666 if(modd_d5_filtre!=0) //Check
 replace modd_d5=-666 if(modb_b9!=0|modb_b10_filtre!=1)
 replace modd_d6a=-666 if(modb_b9!=0|modb_b10_filtre!=1)
 replace modd_d6b=-666 if(modb_b9!=0|modb_b10_filtre!=1)
 replace modd_d7=-666 if(modb_b9!=0|modb_b10_filtre!=1)
 replace modd_d_filtre=-666 if(modb_b9!=0|modb_b10_filtre!=1)
 replace modd_d8b=-666 if(modb_b9!=0|modb_b10_filtre!=1)
 replace modd_d9a=-666 if(modb_b9!=0|modb_b10_filtre!=1)
 replace modd_d11a=-666 if(modb_b9!=0|modb_b10_filtre!=1)
 replace modd_d12=-666 if(modb_b9!=0|modb_b10_filtre!=1)
 replace modd_d21a_f=-666 if(modb_b9!=0|modb_b10_filtre!=1)
 
 // for TC female with kids
 tostring modd_d15 modd_d19a modd_d20a, replace
 replace modd_d13c=-666 if(modb_b9!=0|modb_b10_filtre!=1|survey_type!=2)
 replace modd_d15="-666" if(modb_b9!=0|modb_b10_filtre!=1|survey_type!=2)
 replace modd_d19a="-666" if(modb_b9!=0|modb_b10_filtre!=1|survey_type!=2) 
 replace modd_d20a ="-666" if(modb_b9!=0|modb_b10_filtre!=1|survey_type!=2)
 
 // Changing the format of the birth date variable from string to date
 
 replace modd_d34= "-666" if(modb_b9!=0|survey_type==2|modb_b10_filtre!=1|age>=45)
 replace modd_d35= -666 if(modb_b9!=0|survey_type==2|modb_b10_filtre!=1|age<45)
 replace modd_d37a= "-666" if(modb_b9!=0|survey_type==2|modb_b10_filtre!=1|age>=45) // Select multiple
 replace modd_d38= -666 if(modb_b9!=0|survey_type==2|modb_b10_filtre!=1|age>=45)
 

 //for males with kids
 foreach var in modd_d1b_male modd_d3_male modd_d11b_male modd_d21a_male modd_d14a_male modd_d19a_male modd_d20a_male  modd_m11_male {
	capture confirm numeric variable `var'
		if !_rc {
		replace `var' = -666 if(modb_b9!=1|modb_b10_filtre!=1)
        }
		else {
		replace `var' = "-666" if(modb_b9!=1|modb_b10_filtre!=1)
        }
	}	
replace modd_d1_cal_year=-666 if(modb_b10_filtre!=1|modb_b9!=0)

 // questions only asked to women without children
 replace modd_d27= -666 if(modb_b10_filtre!=0|modb_b9!=0) // want any kids?
 
 // questions only asked to men without children
 replace modd_d27_male= -666 if (modb_b10_filtre!=0|modb_b9!=1) // want any kids?
 
 // for HT and TC female with kids
 replace modd_d3=-666 if(modb_b9!=0|modb_b10_filtre!=1)
 replace modd_d4="-666" if(modb_b9!=0|modb_b10_filtre!=1) // Select multiple
 replace modd_d5_filtre=-666 if(modb_b9!=0|modb_b10_filtre!=1)
 replace modd_d5=-666 if(modd_d5_filtre!=0) //Check
 replace modd_d5=-666 if(modb_b9!=0|modb_b10_filtre!=1)
 replace modd_d6a=-666 if(modb_b9!=0|modb_b10_filtre!=1)
 replace modd_d6b=-666 if(modb_b9!=0|modb_b10_filtre!=1)
 replace modd_d7=-666 if(modb_b9!=0|modb_b10_filtre!=1)
 replace modd_d_filtre=-666 if(modb_b9!=0|modb_b10_filtre!=1)
 replace modd_d8b=-666 if(modb_b9!=0|modb_b10_filtre!=1)
 replace modd_d9a=-666 if(modb_b9!=0|modb_b10_filtre!=1)
 replace modd_d11a=-666 if(modb_b9!=0|modb_b10_filtre!=1)
 replace modd_d12=-666 if(modb_b9!=0|modb_b10_filtre!=1)
 replace modd_d21a_f=-666 if(modb_b9!=0|modb_b10_filtre!=1)
 
 // for TC female with kids
 tostring modd_d15 modd_d19a modd_d20a, replace
 replace modd_d13c=-666 if(modb_b9!=0|modb_b10_filtre!=1|survey_type!=2)
 replace modd_d15="-666" if(modb_b9!=0|modb_b10_filtre!=1|survey_type!=2)
 replace modd_d19a="-666" if(modb_b9!=0|modb_b10_filtre!=1|survey_type!=2) 
 replace modd_d20a ="-666" if(modb_b9!=0|modb_b10_filtre!=1|survey_type!=2)
 
 // Changing the format of the birth date variable from string to date
 replace modd_d34= "-666" if(modb_b9!=0|survey_type==2|modb_b10_filtre!=1|age>=45)
 replace modd_d35= -666 if(modb_b9!=0|survey_type==2|modb_b10_filtre!=1|age<45)
 replace modd_d37a= "-666" if(modb_b9!=0|survey_type==2|modb_b10_filtre!=1|age>=45) // Select multiple
 replace modd_d38= -666 if(modb_b9!=0|survey_type==2|modb_b10_filtre!=1|age>=45)
 

 //for males with kids
 foreach var in modd_d1b_male modd_d3_male modd_d11b_male modd_d21a_male modd_d14a_male modd_d19a_male modd_d20a_male  modd_m11_male {
	capture confirm numeric variable `var'
		if !_rc {
		replace `var' = -666 if(modb_b9!=1|modb_b10_filtre!=1)
        }
		else {
		replace `var' = "-666" if(modb_b9!=1|modb_b10_filtre!=1)
        }
	}	
 
 // for TC males with kids
 replace modd_d13c_male = -666 if(modb_b9!=1|modb_b10_filtre!=1|survey_type!=2)
 
 // for males without kids
tostring modd_d20a modd_d19a modd_d15, replace

 replace modd_d34_male = "-666" if(modb_b9!=1|modb_b10_filtre!=0)
 replace modd_d3=-666 if(modd_d3!=1&modd_d3!=2&modd_d3!=3) // Did you/wife ever breastfeed/ express milk at the workplace? Only if you did either of the things in general.
 replace modd_d5_filtre=-666 if(modd_d3!=1&modd_d3!=2&modd_d3!=3|modd_d1_cal_year>6) // still breastfeeding?
 replace modd_d6a=-666 if modd_d5_filtre!=0 // Breastfed as long as you/she wanted to? Only if has already stopped.
 replace modd_d6b=-666 if modd_d6a!=0 // Until when would you have wanted to breastfeed?
 replace modd_d7=-666 if modd_d5_filtre!=1 // Until when do you/she want to breastfeed?
 replace modd_d_filtre=-666 if modd_d5_filtre!=1 // exclusive breastfeeding? only if still breastfeeding
 replace modd_d8b=-666 if(modd_d_filtre!=0&modd_d5_filtre!=0) // when did you start introducing formula?
 replace modd_d9a=-666 if(modd_d_filtre!=0&modd_d5_filtre!=0) // exclusive breasfeeding as long as you/she wanted to?
 replace modd_d9b=-666 if modd_d9a!=0 // When would you have wanted to stop?
 replace modd_d12=-666 if(modd_d11a!=1&modd_d11a!=2&modd_d11a!=3&modd_d11a!=4) // How many months of paid maternity? (if working when child was born)
 replace modd_d13c=-666 if survey_type==1 // Discussion with husband about going back to work? (Not for HTs)
 replace modd_d15="-666" if survey_type==1 // able to reach agreement? Wouldn't it make sense to only ask this question if you reply yes to d14?
 replace modd_d19a="-666" if modd_d1_cal_year>=6
 replace modd_d20a="-666" if modd_d1_cal_year<=6 // What if your child is exactly 6? You are not going to be asked either set of questoins?

// only for women planning to have children (<45 and no children yet)
replace modd_d34="-666" if modd_d27!=1
replace modd_d35=-666 if modd_d27!=1
replace modd_d37a="-666" if modd_d27!=1 // Select multiple
replace modd_d38=-666 if modd_d27!=1
replace modd_d13c_male=-666 if(modd_d11b_male!=1&modd_d11b_male!=3&survey_type!=1)
replace modd_d20a_male="-666" if modd_d1b_male<6 //  Select multiple
replace modd_d34_male="-666" if modd_d27_male!=1
}

**# MODULE F and M ***
 quietly{
replace randomdraw1=-666 if survey_type!=2
replace randomdraw2=-666 if(survey_type==1|modb_b9!=0|modd_d1_cal_year>3|modd_d3==4)
replace randomdraw3=-666 if(survey_type!=2|modb_b9!=0)

// For TC only and randomdraw1 <= 0.5
recode modf_f21a_y modf_f21b_y modf_f21c_y modf_f21d_y ("."=-666) if(survey_type!=2|randomdraw1>0.5)

// For TC only and randomdraw1 > 0.5
recode modf_f21a_n modf_f21b_n modf_f21c_n modf_f21d_n ("."=-666) if(survey_type!=2|randomdraw1<=0.5)

tostring modm_m6a_a modm_m6b_a modm_m6c_a modm_m6a_b modm_m6b_b modm_m6c_b, replace

// HTs female only and "modd_d1_cal_year <= 3 and modd_d3!=4 and randomdraw2 > 0.5"
replace modm_m6a_a="-666" if(modd_d1_cal_year>3|modd_d3==4|randomdraw2<=0.5|survey_type!=1|modb_b9!=0|modb_b10_filtre!=1)
replace modm_m6b_a=-666 if(modd_d1_cal_year>3|modd_d3==4|randomdraw2<=0.5|survey_type!=1|modb_b9!=0|modb_b10_filtre!=1)
replace modm_m6c_a="-666" if(modd_d1_cal_year>3|modd_d3==4|randomdraw2<=0.5|survey_type!=1|modb_b9!=0|modb_b10_filtre!=1)

// HTs female only and "modd_d1_cal_year <= 3 and modd_d3 !=4 and randomdraw2 <=0.5"
replace modm_m6a_b="-666" if(modd_d1_cal_year>3|modd_d3==4|randomdraw2>0.5|survey_type!=1|modb_b9!=0|modb_b10_filtre!=1)
replace modm_m6b_b="-666" if(modd_d1_cal_year>3|modd_d3==4|randomdraw2>0.5|survey_type!=1|modb_b9!=0|modb_b10_filtre!=1)
replace modm_m6c_b="-666" if(modd_d1_cal_year>3|modd_d3==4|randomdraw2>0.5|survey_type!=1|modb_b9!=0|modb_b10_filtre!=1)

// randomdraw4 <= 0.5
replace modf_f11=-666 if randomdraw4 > 0.5

// randomdra4 > 0.5
replace modf_f12=-666 if randomdraw4 <= 0.5

// randomdraw5 <= 0.5
replace modf_f13="-666" if randomdraw5 > 0.5

// randomdraw5 > 0.5
replace modf_f14="-666" if randomdraw5 <= 0.5
}

**# MODULE H ***
 quietly{
// if modh_h1 = 1
recode modh_h5 ("."=-666) if modh_h1!=1

// if modh_h1 = 2 or 3
recode modh_h7 ("."=-666) if(modh_h1!=2&modh_h1!=3)
}

**# MODULE I *** // modh_h1 = 1
 quietly{
ds modi_i*
foreach var of varlist `r(varlist)' {
 		capture confirm numeric variable `var'
		if !_rc {
		replace `var' = -666 if modh_h1!=1
        }
		else {
		replace `var' = "-666" if modh_h1!=1
        }
	}
}
	
**# MODULE J *** // modh_h1 = 2 or 3
 quietly{
ds modi_j* modj_*
 foreach var of varlist `r(varlist)' {
 		capture confirm numeric variable `var'
		if !_rc {
		replace `var' = -666 if(modh_h1!=2&modh_h1!=3)
        }
		else {
		replace `var' = "-666" if(modh_h1!=2&modh_h1!=3)
        }
	}
}

**# Running ipacheckmissing ***

 quietly{ // Keeping only the variables that it makes sense to check for missingness (which should always be 0%)

 preserve
 
keep ${keepvars} ${key} ${duration_all} unique_teacher_id  airtime_confirm airtime_no airtime_no_reenter availability calc_enum_name concat_names_modb consent_duration consent_enddur consent_signature consent_startdur consented deviceid duration endtime enum_id employee_count employee_details_count male_indices female_indices hteacher_index f_progresion formdef_version internet_issue mared_living modb_duration modb_enddur modb_startdur modc_duration modc_enddur modc_startdur modd_duration modd_enddur modd_startdur modf_duration modf_enddur modf_startdur modg_duration modg_enddur modg_startdur modh_duration modh_enddur modh_startdur modi_duration modi_enddur modi_startdur modj_duration modj_enddur modj_startdur modk_duration modk_enddur modk_startdur modl_duration modl_enddur modl_startdur modm_duration modm_enddur modm_startdur months_as_teacher nursery position recording s_status school school_gpsaccuracy school_gpsaltitude school_gpslatitude school_gpslongitude school_location_desc school_name service_provider starttime subcounty submissiondate survey_type tsc_number months_as_teacher years_as_teacher modb_b2 modb_b10_filtre modb_b4 modb_b5 modb_b8b modb_b9 modb_b10c modl_l1 modl_l9 modl_l12 modl_l17 modl_l24a modl_l24b modl_l24c modl_l25a modc_c0 modc_c3f modc_c16a modb_b9 modd_d3 modd_d4 modd_d1_cal_year modd_d6a modd_d6b modd_d5 modd_d7  modd_d5_filtre modd_d_filtre modd_d8b modd_d9a modd_d9b modd_d11a modd_d12 modd_d13c modd_d15 modd_d9a modd_d6a  modd_d19a modd_d20a modd_d21a_f modd_d21a_f modd_d27 modd_d34 modd_d35 modd_d37a modd_d38 modd_d3_male modd_d21a_male modd_d11b_male modd_d13c_male modd_d14a_male modd_d19a_male modd_d1b_male modd_d20a_male modd_m11_male modd_d27_male modd_d34_male modf_f11 modf_f12 modf_f13 modf_f14 modf_f21a_y modf_f21b_y modf_f21c_y modf_f21d_y modf_f21a_n modf_f21b_n modf_f21c_n modf_f21d_n modf_f3 modh_h0a modh_h1 modh_h5 modh_h7 modh_h9 modh_h11 modi_i1a modi_i1b modi_i2a modi_i3 modi_i4a modi_i5a modi_i6a modi_i9 modi_j1a modi_j1b modi_j1c modj_j2a modj_j3a modj_j6 modj_j9 modk_k5 modk_k4a modb_b3 modm_m6a_a modm_m6b_a modm_m6c_a modm_m6a_b modm_m6b_b modm_m6c_b modf_f11 modf_f12 modf_f13 modf_f14 

label variable calc_enum_name "Enumerator name (calculate)"
label variable unique_teacher_id "Unique teacher ID (generated for analysis)"
label variable concat_names_modb "Full respondent name (calculate)"
label variable consented "Consent"
label variable f_progresion "Token allocation: fast career progression"
label variable employee_count "Employee count (preloaded)"
label variable employee_details_count "Employee details count (preloaded)"
label variable female_indices "Female indices (preloaded)"
label variable hteacher_index "Ht index (preloaded)"
label variable male_indices "Male indices (preloaded)"
label variable mared_living "Living together/married based on marital status (calculate)"
label variable modd_d13c "Have you had any disagreement or discussion with your husband/partner..."
label variable modd_d13c_male "Have you had any disagreement or discussion with your husband/partner..."
label variable modd_d15 "D15. Were you able reach some formal or informal arrangements?"
label variable modd_d19a "Who takes care of the child when you are at school ?"
label variable modd_d19a_male "Who takes care of the child when you are at school ?"
label variable modd_d1_cal_year "Age of child in years for women (calculate)"
label variable modd_d1b_male "Age of child for men (calculate)"
label variable modd_d3 "D3. Did  ever breastfeed/pump milk"
label variable modd_d34 "D34.Do you think you will be able to reach some formal/informal agreement?"
label variable modd_d34_male "D34. After you come back to work, do you think you will try to reach agreement"
label variable modd_d35 "D35. Will you consider school calendar for future pregnancies?"
label variable modk_k5 "Would you be willing to be a member of the committee?"
label variable years_as_teacher "Years as teacher (calculate)"
}

 quietly{ // Temporarily reverting .d missing values to "-999"
	foreach var of varlist _all {
	capture confirm numeric variable `var'
		if !_rc {
		replace `var'=-999 if `var'==.d
		replace `var'=-888 if `var'==.r
        }
		else {
        }
	}
}

drop availability_str s_status_str

   if $run_missing { 
		ipacheckmissing ${ms_vars}, 					///
			priority(${ms_pr_vars})						///
			outfile("${hfc_output}") 					///
			outsheet("missing")							///
			sheetreplace		
   }
   
 restore
  
 quietly{ // Specifying a missing value code .a for the "not applicable" questions
 	foreach var of varlist _all {
	capture confirm numeric variable `var'
		if !_rc {
		replace `var'=.a if `var'==-666
		replace `var'=.d if `var'==-999
		replace `var'=.r if `var'==-888
        }
		else {
		replace `var'="Not applicable" if `var'=="-666"		
        }
	}
 }
 
save "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/missingness.dta", replace
}
	*==================== Survey and Enumerator Dashboard =====================*
	quietly{	
	/* Not implemented,  the implemented alternative follows below
   if $run_surveydb {
		ipachecksurveydb,			 					///
			by(${sv_by})								///
			enumerator(${enum}) 						///
			date(${date})								///
			period("${sv_period}")						///
			consent(${consent}, ${cons_vals})			///
			dontknow(.d, ${dk_str})						///
			refuse(.r, ${ref_str})						///
			otherspecify("`childvars'")					///
			duration(duration_min)						///
 			formversion(${formversion})					///
        	outfile("${surveydb_output}")				///
			${sv_nolabel}								///
			sheetreplace
   }

 
      *========================= Enumerator Dashboard ============================* It creates the output but gives "ERROR: VARIABLE MEDIA NOT FOUND" due to a typo in IPA's .ado file, so I implement ipachecksurveydb but specifying a disaggregation by enumerator name, I also run a portion of the the "corrected" ipacheckenumdb command keeping only the available surveys.

* do "2_dofiles/ipacheckenumdb.do"

   if $run_enumdb {
		ipacheckenumdb using "${inputfile}",			///
			sheet("enumstats")							///		
			enumerator(${enum})							///
			team(${subcounty})							///
			date(${date})								///
			period("${en_period}")						///
			consent($consent, ${cons_vals})				///
			dontknow(.d, ${dk_str})						///
			refuse(.r, ${ref_str})						///
			otherspecify("`childvars'")					///
			duration(duration)									///
			formversion(${formversion})					///
        	outfile("${enumdb_output}")					///
			${en_nolabel}								///
			sheetreplace
   }
 */
 
	gen duration_min = ${duration}/60
 
    if $run_surveydb {
		ipachecksurveydb,			 					///
			by(${enum})								///
			enumerator(${enum}) 						///
			date(${date})								///
			period("${sv_period}")						///
			consent(${consent}, ${cons_vals})			///
			dontknow(.d, ${dk_str})						///
			refuse(.r, ${ref_str})						///
			otherspecify(${childvars})					///
			duration(duration_min)						///
 			formversion(${formversion})					///
        	outfile("${surveydb_output}")				///
			${sv_nolabel}								///
			sheetreplace
   } 
   
// Moving the relevant output to hfc_output.xlsx and hfc_output_extras.xlsx

preserve

import excel "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/surveydb.xlsx", sheet("weekly productivity") clear
export excel "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/hfc_output.xlsx", sheet("weekly submissions", replace)

import excel "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/surveydb.xlsx", sheet("weekly productivity (grouped)") clear
export excel "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/hfc_output.xlsx", sheet("weekly submissions by enum", replace)

restore
} 

	*==================== Enumerator plots and tables =========================*
	quietly{
**# Making plots and tables of the most relevant variables by enumerator 
 
	label variable ${enum} "Enumerator"
	
	cap confirm file "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/plots"
	if _rc mkdir "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/plots"

   cd "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/plots"
   
   graph bar (count), over(availability) over(${enum}, label(alternate)) title(Availability by enumerator) //Availability
   graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/plots/availability.png", replace
   
   graph bar (count), over(${consent}) over(${enum}, label(alternate)) title(Consent by enumerator) //Consent
   graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/plots/consent.png", replace
   
   label variable ${outcome_str} "Survey status"
   graph bar (count), over(${outcome_str}, label(angle(90))) over(${enum}, label(alternate)) title(Status by enumerator) //Survey status
   graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/plots/survey_status.png", replace
  
   cd "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date"
   
*xtable ${enum} internet_issue, statistic(percent, across(internet_issue)) statistic(frequency) missing
  
  tab2xl ${enum} availability using hfc_output.xlsx, col(1) row(1) sheet("enum_stats", replace) missing percent
  tab2xl ${enum} ${consent} using hfc_output.xlsx, col(7) row(1) sheet("enum_stats") missing percent
  tab2xl ${enum} ${outcome_str} using hfc_output.xlsx, col(14) row(1) sheet("enum_stats") missing percent
   
   asdoc tabulate ${enum} availability, missing replace save(enum_stats.doc) row title(Availability by enumerator) rnames(Enumerator)
   asdoc tabulate ${enum} ${consent}, missing append save(enum_stats.doc) row title(Consent by enumerator) rnames(Enumerator)
   asdoc tabulate ${enum} ${outcome_str}, missing append save(enum_stats.doc) row title(Status by enumerator) rnames(Enumerator)
   
   // Only considering the completed surveys below and for the rest of the checks
  
    cd "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/plots"
	
	keep if ${consent}==1
	
   graph bar (count), over(modb_b9) over(${enum}, label(alternate)) title(Respondent gender by enumerator) // male or female
   graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/plots/gender.png", replace
  
   label variable internet_issue "Was there internet issues that prevented submitting the listing?"
   graph bar (count), over(internet_issue) over(${enum}, label(alternate)) title(Internet issues by enumerator) //ENUMERATOR: Was there internet connectivity issues that prevented you from submitting...
   graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/plots/internet_issues.png" , replace
     
   graph bar (count), over(modb_b10_filtre) over(${enum}, label(alternate)) title(Children by enumerator) // B10a. Do you have biological children?
   graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/plots/children.png", replace
    
   graph bar (count), over(modb_b10c) over(${enum}, label(angle(-60) labsize(*0.5))) missing name(one, replace) title(Planning to have other children by enumerator) // B10c. Do you plan to have others?
*   graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/plots/future_children_parents.png", replace

   graph bar (count), over(modd_d27) over(${enum}, label(angle(-60) labsize(*0.5))) missing name(two, replace) title(Planning to have children-male) //<b>D27.</b>  Do you plan to have biological children?
*   graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/plots/future_children_female.png", replace
   
   graph bar (count), over(modd_d27_male) over(${enum}, label(angle(-60) labsize(*0.5))) missing name(three, replace) title(Planning to have children-male) //<b>D27.</b>  Do you plan to have biological children?
*  graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/plots/future_children_male.png", replace
   
   graph combine one two three, name(future_children, replace)
   graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/plots/future_plans.png", replace
   
   graph bar (count), over(modb_b5, label(angle(90))) over(${enum}, label(alternate)) title(Marriage status by enumerator) // B5. What is your marriage status?
   graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/plots/marriage.png", replace
   
   graph bar (count), over(recording) over(${enum}, label(alternate)) title(Audio recording consent by enumerator) // Thank you. As mentioned above, during this survey you may be audio recorded...
   graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/plots/recording_consent.png", replace
   
   hist age, freq bin(50) title(Distribution of respondent ages) 
   graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/plots/age.png", replace

   cd "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date"

   // Tables for relevant variables
   asdoc tabulate ${enum} modb_b9, missing append save(enum_stats.doc) row title(Respondent gender by enumerator) rnames(Enumerator)
   asdoc tabulate ${enum} internet_issue, missing append save(enum_stats.doc) row title(Internet issues by enumerator) rnames(Enumerator)
   asdoc tabulate ${enum} modb_b10_filtre, missing append save(enum_stats.doc) row title(Children by enumerator) rnames(Enumerator)
   asdoc tabulate ${enum} modb_b10c, append save(enum_stats.doc) row title(Planning to have other children by enumerator)
   asdoc tabulate ${enum} modd_d27, append save(enum_stats.doc) row title(Planning to have children (female) by enumerator)
   asdoc tabulate ${enum} modd_d27_male, append save(enum_stats.doc) row title(Planning to have children (male) by enumerator)
   asdoc tabulate ${enum} modb_b5, missing append save(enum_stats.doc) row title(Marriage status by enumerator) rnames(Enumerator)
   asdoc tabulate ${enum} recording, missing append save(enum_stats.doc) row title(Audio recording consent by enumerator) rnames(Enumerator)
 
  tab2xl ${enum} modb_b9 using hfc_output.xlsx, col(26) row(1) sheet("enum_stats") missing percent
  tab2xl ${enum} internet_issue using hfc_output.xlsx, col(32) row(1) sheet("enum_stats") missing percent
  tab2xl ${enum} modb_b10_filtre using hfc_output.xlsx, col(39) row(1) sheet("enum_stats") missing percent
  tab2xl ${enum} modb_b10c using hfc_output.xlsx, col(45) row(1) sheet("enum_stats") missing percent
  tab2xl ${enum} modd_d27 using hfc_output.xlsx, col(51) row(1) sheet("enum_stats") missing percent
  tab2xl ${enum} modd_d27_male using hfc_output.xlsx, col(57) row(1) sheet("enum_stats") missing percent
  tab2xl ${enum} recording using hfc_output.xlsx, col(63) row(1) sheet("enum_stats") missing percent
  tab2xl ${enum} modb_b5 using hfc_output.xlsx, col(69) row(1) sheet("enum_stats") missing percent

 putexcel set "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/hfc_output_extras.xlsx", sheet("open answers", replace) replace
 putexcel A1="Enumerator", bold border(bottom) txtwrap 
 putexcel B1="Mean of experience question length", bold border(bottom) txtwrap
 putexcel C1="Mean of school improvement suggestions length", bold border(bottom) txtwrap
 putexcel D1="Mean of enumerator explanations", bold border(bottom) txtwrap
 putexcel E1="Mean of open ended questions", bold border(bottom) txtwrap
 putexcel F1="Mean length of the final comment", bold border(bottom) txtwrap
 
 local row=2 
 levelsof ${enum}
 local varlist_enumerators=r(levels)
 foreach z of local varlist_enumerators {
 	preserve
	keep if $enum=="`z'"
	egen mean_length_experience_questions=rmean(length_modm_m6a_a length_modm_m6c_a length_modm_m6a_b length_modm_m6b_b length_modm_m6c_b)
	egen mean_length_suggestion_questions=rmean(length_modl_l23a length_modc_c24)
	egen mean_length_lactrm_good_bad=rmean(length_modi_i1a1 length_modi_i1a2 length_modi_i1b1 length_modi_i1b2 length_modi_j1a1 length_modi_j1a2 length_modi_j1b1 length_modi_j1b2)
	egen mean_length_enum_explain=rmean(length_modd_d6b_explain length_modd_d8b_explain length_modd_d9b_explain)
	egen mean_length_text_answers=rmean(length_reason_refusal length_modl_l18 length_modl_l23a length_modl_l23b length_modm_m1 length_modc_c24 length_modm_m3a  length_modd_d6b_explain length_modd_d8b_explain length_modd_d9b_explain length_modf_f20 length_modi_i1a1 length_modi_i1a2 length_modi_i1b1 length_modi_i1b2 length_modi_j1a1 length_modi_j1a2  length_modi_j1b1 length_modi_j1b2 length_modk_k1a_reson length_modk_k2a_reson length_modk_k1b_reson length_modk_k2b_reson length_modm_m6a_a length_modm_m6c_a length_modm_m6a_b length_modm_m6b_b length_modm_m6c_b)
 
	summarize mean_length_experience_questions
	scalar define mean_exper_`row'= round(r(mean), .01)
	
	summarize mean_length_suggestion_questions
	scalar define mean_sugg_`row'=round(r(mean), .01)
	
	summarize mean_length_lactrm_good_bad
	scalar define mean_gb_`row'=round(r(mean), .01)
	
	summarize mean_length_enum_explain
	scalar define mean_explain_`row'=round(r(mean), .01)
	
	summarize mean_length_text_answers
	scalar define mean_length_`row'=round(r(mean), .01)
	
	summarize length_final_comment
	scalar define mean_comment_`row'=round(r(mean), .01)
	
	putexcel A`row'="`z'"
	putexcel B`row'= mean_exper_`row'
	putexcel C`row'= mean_gb_`row'
	putexcel D`row'= mean_explain_`row'
	putexcel E`row'= mean_length_`row'
	putexcel F`row'= mean_comment_`row'
	
	restore
	local row=`row'+1
	
 }
 
* logout, save(enum_stats.xlsx) excel replace: table ${enum} modb_b9

   cd "${cwd}"
}
	*============================== Outliers ==================================*
	quietly{
 **# Identifying the "not applicable" questions for the numerical variables
 
replace modb_b10b=-666 if modb_b10_filtre!=1 
replace modb_b10d=-666 if(modb_b10c!=1|modb_b10_filtre!=1)
replace modd_d27a=-666 if(modd_d27!=1|modb_b10_filtre!=0|modb_b9!=0)
replace modd_d27a_male=-666 if(modd_d27a_male!=1|modb_b9!=1|modb_b10_filtre!=0)
replace modc_c3f=-666 if survey_type==1
replace modc_c3f3=-666 if modc_c3f!=1
replace modc_c8b=-666 if survey_type!=2
replace modd_d10=-666 if(modb_b9!=0|modb_b10_filtre!=1)
replace modd_d15e=-666 if(modb_b9!=0|modb_b10_filtre!=0)
replace modd_d19c=-666 if(modb_b9!=0|modb_b10_filtre!=0)
replace modd_d20c=-666 if(modb_b9!=0|modb_b10_filtre!=1|survey_type!=2|modd_d1_cal_year<=6|(modd_d20a!="1"&modd_d20a!="2"&modd_d20a!="3"))
replace modd_m11 =-666 if(modb_b9!=0|modb_b10_filtre!=1|survey_type!=2)
replace modd_d23_f=-666 if(modb_b9!=0|modb_b10_filtre!=1|survey_type!=2)
replace modd_d23b_f =-666 if(modb_b9!=0|modb_b10_filtre!=1|survey_type!=2)
replace modd_d30=-666 if(modb_b9!=0|modb_b10_filtre!=0|survey_type!=2|age>=45)
replace modd_d31=-666 if(modb_b9!=0|modb_b10_filtre!=0|survey_type!=2|age>=45)
replace modd_d32=-666 if(modb_b9!=0|modb_b10_filtre!=0|survey_type!=2|age>=45)
replace modd_d33 =-666 if(modb_b9!=0|modb_b10_filtre!=0|survey_type!=2|age>=45)
replace modd_d1b_male_old=-666 if(modb_b9!=1|modb_b10_filtre!=1)
replace modd_d5b_male=-666 if(modb_b9!=1|modb_b10_filtre!=1)
replace modd_d5d_male=-666 if(modb_b9!=1|modb_b10_filtre!=1)
replace modd_d5e_male=-666 if(modb_b9!=1|modb_b10_filtre!=1)
replace modd_d11c_male=-666 if(modb_b9!=1|modb_b10_filtre!=1)
replace modd_d14b_male=-666 if(modb_b9!=1|modb_b10_filtre!=1)
replace modd_d15d_male=-666 if(modb_b9!=1|modb_b10_filtre!=1)
replace modd_m11_male=-666 if(modb_b9!=1|modb_b10_filtre!=1)
replace modd_m11b_male=-666 if(modb_b9!=1|modb_b10_filtre!=1)
replace modd_m11c_male=-666 if(modb_b9!=1|modb_b10_filtre!=1)
replace modd_d23_male=-666 if(modb_b9!=1|modb_b10_filtre!=1)
replace modd_d30_male=-666 if(modb_b9!=1|modb_b10_filtre!=0)
replace modd_d32_male =-666 if(modb_b9!=1|modb_b10_filtre!=0)
replace modi_i6b =-666 if(modh_h1!=1)
replace modi_i6c=-666 if(modh_h1!=1)
replace modi_i7b=-666 if(modh_h1!=1)
replace modi_i8 =-666 if(modh_h1!=1)
replace modj_j4b=-666 if(modh_h1!=2&modh_h1!=3)
replace modj_j6b=-666 if(modh_h1!=2&modh_h1!=3)
replace modj_j7a=-666 if(modh_h1!=2&modh_h1!=3)
replace modj_j7b=-666 if(modh_h1!=2&modh_h1!=3)
replace modk_k5a=-666 if modk_k5!=1
replace modm_m5=-666 if survey_type==1
replace length_reason_refusal =-666 if consented!=0
replace length_modl_l18=-666 if(modl_l17!=1|survey_type!=1)
replace length_modl_l23a=-666 if(survey_type!=1)
replace length_modl_l23b =-666 if(survey_type!=1)
replace length_modc_c24=-666 if(survey_type!=0)
replace length_modd_d6b_explain =-666 if modd_d6b_confirm!=1
replace length_modd_d8b_explain =-666 if modd_d8b_confirm!=1
replace length_modd_d9b_explain =-666 if modd_d9b_confirm!=1
replace length_modi_i1a1=-666 if(modh_h1!=1|(modi_i1a!=1&modi_i1a!=2))
replace length_modi_i1a2 =-666 if(modh_h1!=1|(modi_i1a!=3&modi_i1a!=4))
replace length_modi_i1b1=-666 if(modh_h1!=1|(modi_i1b!=1&modi_i1b!=2))
replace length_modi_i1b2=-666 if(modh_h1!=1|(modi_i1b!=3&modi_i1b!=4))
replace length_modi_j1a1=-666 if((modi_j1a!=1&modi_j1a!=2)|(modh_h1!=2&modh_h1!=3))
replace length_modi_j1a2=-666 if((modi_j1a!=3&modi_j1a!=4)|(modh_h1!=2&modh_h1!=3))
replace length_modi_j1b1=-666 if((modi_j1b!=1&modi_j1b!=2)|(modh_h1!=2&modh_h1!=3))
replace length_modi_j1b2=-666 if((modi_j1b!=3&modi_j1b!=4)|(modh_h1!=2&modh_h1!=3))
replace length_modk_k1a_reson=-666 if(internet_issue!=0)
replace length_modk_k2a_reson=-666 if(internet_issue!=0)
replace length_modk_k1b_reson=-666 if(internet_issue!=1)
replace length_modk_k2b_reson=-666 if(internet_issue!=1)
replace length_modm_m6a_a=-666 if(modb_b9!=0|survey_type!=2|randomdraw2<=0.5)
replace length_modm_m6c_a=-666 if(modb_b9!=0|survey_type!=2|randomdraw2<=0.5)
replace length_modm_m6a_b=-666 if(modb_b9!=0|survey_type!=2|randomdraw2>0.5)
replace length_modm_m6b_b=-666 if(modb_b9!=0|survey_type!=2|randomdraw2>0.5)
replace length_modm_m6c_b=-666 if(modb_b9!=0|survey_type!=2|randomdraw2>0.5)

 // Specifying a missing value code .a for the "not applicable" questions
 	foreach var of varlist _all {
	capture confirm numeric variable `var'
		if !_rc {
		replace `var'=.a if `var'==-666	
        }
		else {
		replace `var'="Not applicable" if `var'=="-666"		
        }
	}

 **# Creating an excel sheet with a list of outliers

 // Creating a .dta file with the matrix of outliers
  preserve
	clear all
	save "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/outliers.dta", emptyok replace
  restore

 local numerical_vars "modb_b7b modb_b10b modb_b10d modd_d27a modd_d27a_male modl_l1 modl_l1b1 modl_l1b2 modl_l1c1 modl_l1c2 modl_l7 modl_l8 modl_l9 modl_l13 modl_l14 modl_l15 modc_c3f3 modc_c8b modd_d5 modd_d6b modd_d7 modd_d8b modd_d9b modd_d10 modd_d12 modd_d15e modd_d19c modd_d20c modd_m11 modd_d23_f modd_d23b_f modd_d30 modd_d31 modd_d32 modd_d33 modd_d1b_male_old modd_d5b_male modd_d5d_male modd_d5e_male modd_d11c_male modd_d14b_male modd_d15d_male modd_m11_male modd_m11b_male modd_m11c_male modd_d23_male modd_d30_male modd_d32_male modf_f2 modf_f3 modf_f5a modh_h12 modh_h13 modi_i6b modi_i6c modi_i7b modi_i8 modj_j4b modj_j6b modj_j7a modj_j7b modk_k5a modm_m5 duration length_reason_refusal length_modl_l18 length_modl_l23a length_modl_l23b length_modm_m1 length_modc_c24 length_modm_m3a length_modd_d6b_explain length_modd_d8b_explain length_modd_d9b_explain length_modf_f20 length_modi_i1a1 length_modi_i1a2 length_modi_i1b1 length_modi_i1b2 length_modi_j1a1 length_modi_j1a2  length_modi_j1b1 length_modi_j1b2 length_modk_k1a_reson length_modk_k2a_reson length_modk_k1b_reson length_modk_k2b_reson length_modm_m6a_a length_modm_m6c_a length_modm_m6a_b length_modm_m6b_b length_modm_m6c_b"	
 local num: list sizeof numerical_vars
 count
 local n_obs=r(N)
 local row=1
 foreach z in `numerical_vars'{
 	summarize `z', detail
	gen label_`z'=`"`:var label `z''"'
	gen name_`z' = "`z'"
	gen iqr_`z' = r(p75) - r(p25) 
 	gen lfence_`z' = r(p25) - 1.5 * iqr_`z'
	gen mean_`z' = round(r(mean), .001)
	gen ufence_`z' = r(p75) + 1.5 * iqr_`z'
	levelsof `z' if(`z'>ufence_`z'|`z'<lfence_`z'), local(val_list)
	local count: word count `val_list'
	forval i = 1/`count'{
		preserve
		keep if `z'==`: word `i' of `val_list' '
		keep ${id} ${enum} ${date} `z' name_`z' lfence_`z' mean_`z' ufence_`z' label_`z'
		rename `z' variable
		rename name_`z' name_variable
		rename lfence_`z' lfence_variable
		label variable lfence_variable "Lower fence value"
		rename ufence_`z' ufence_variable
		label variable ufence_variable "Upper fence value"
		rename label_`z' label
		label variable label "Label"
		rename mean_`z' mean
		label variable mean "Mean"
		label variable ${id} "Teacher id"
		label variable ${enum} "Enumerator name"
		label variable name_variable "Variable name"
		label variable ${date} "Survey submission date"
		save outliers_`row'_`i'.dta
		use "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/outliers.dta", clear
		append using outliers_`row'_`i'.dta
		save "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/outliers.dta", emptyok replace
		erase outliers_`row'_`i'.dta
		restore
	}
	local row=`row'+1
}

 // Making an excel file sheet with the outliers
preserve
use "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/outliers.dta", clear
export excel using "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/hfc_output.xlsx", sheet("outliers", replace) firstrow(varlabels)

putexcel set "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/hfc_output.xlsx", sheet("outliers") modify
putexcel B1="Observed value"
putexcel save
restore

 **# Creating an excel sheet with the summary variables for all the numerical variables in the baseline survey
 
 // I did not include the module duration variables: consent_duration modb_duration modc_duration modd_duration modf_duration modg_duration modh_duration modi_duration modj_duration modk_duration modl_duration modm_duration
   
  preserve

 // Making the matrix
 local numerical_vars "modb_b7b modb_b10b modb_b10d modd_d27a modd_d27a_male modl_l1 modl_l1b1 modl_l1b2 modl_l1c1 modl_l1c2 modl_l7 modl_l8 modl_l9 modl_l13 modl_l14 modl_l15 modc_c3f3 modc_c8b modd_d5 modd_d6b modd_d7 modd_d8b modd_d9b modd_d10 modd_d12 modd_d15e modd_d19c modd_d20c modd_m11 modd_d23_f modd_d23b_f modd_d30 modd_d31 modd_d32 modd_d33 modd_d1b_male_old modd_d5b_male modd_d5d_male modd_d5e_male modd_d11c_male modd_d14b_male modd_d15d_male modd_m11_male modd_m11b_male modd_m11c_male modd_d23_male modd_d30_male modd_d32_male modf_f2 modf_f3 modf_f5a modh_h12 modh_h13 modi_i6b modi_i6c modi_i7b modi_i8 modj_j4b modj_j6b modj_j7a modj_j7b modk_k5a modm_m5 duration length_reason_refusal length_modl_l18 length_modl_l23a length_modl_l23b length_modm_m1 length_modc_c24 length_modm_m3a length_modd_d6b_explain length_modd_d8b_explain length_modd_d9b_explain length_modf_f20 length_modi_i1a1 length_modi_i1a2 length_modi_i1b1 length_modi_i1b2 length_modi_j1a1 length_modi_j1a2 length_modi_j1b1 length_modi_j1b2 length_modk_k1a_reson length_modk_k2a_reson length_modk_k1b_reson length_modk_k2b_reson length_modm_m6a_a length_modm_m6c_a length_modm_m6a_b length_modm_m6b_b length_modm_m6c_b"
 
 local num: list sizeof numerical_vars
 mat outliers=J(`num', 8,.)
 mat list outliers
 local row = 1
 foreach z in `numerical_vars' {
 	replace `z'=. if (`z'==-333|`z'==-100|`z'==-777|`z'==-888|`z'==-999|`z'==-444|`z'==-222)
	summarize `z', detail
	mat outliers [`row', 1]=round(r(mean), .001)
	mat outliers [`row', 2]=round(r(sd), .001)
	mat outliers [`row', 3]=round(r(min))
	mat outliers [`row', 4]=round(r(p25), .001)
	mat outliers [`row', 5]=round(r(p50), .001)
	mat outliers [`row', 6]=round(r(p75), .001)
	mat outliers [`row', 7]=round(r(max))
	mat outliers [`row', 8]=round(r(N))
	local ++row
 }

 mat rownames outliers = "# individuals in hh" "# biological children" "# additional children planned" "# of children planned" "# of children planned" "# students" "# not teaching female staff" "# not teaching male staff" "# teaching female staff" "# teaching male staff" "# pregnant teachers" "# teachers on maternity" "# classrooms" "# toilets for students" "# toilets for staff" "# toilets staff and students" "#Days/week teaching" "Work from home (hrs)" "Months end feeding own milk" "Months wanted end breasfeeding" "Months wants end breastfeed" "Months introduced formula" "Months wanted exclusive brstfeed" "Months want exclusive breastfeed" "Months paid maternity mother" "h/week on childcare (mother)" "Monthly expense childcare" "Monthly expense childcare" "Workdays missed (last 6 months)" "Days missed (3 mon post-birth)" "Days missed brstfd 3mon birth" "Age end breastfeed (planned)" "Age introduce formula (planned)" "# month paid maternity (planned)" "# weeks unpaid maternity" "Child age" "Age wife stop breasfeeding" "months wife wanted to breasfeed" "months husband wanted breastfeed" "Age mother back to work" "Weeks paternity leave" "h/week on childcare (father)" "Days missed (6 mon) father" "Days missed chldcr 6mon father" "Days missed 3mon birth father" "Days missed 3mon birth wife" "Month husband wants breastfeed" "Paid paternity (planned)" "/10 collegues  stop breasfeeding" "/10 collegues stop working" "/10 collegues discuss work-child" "Interval breasfeeding breaks" "Length breasfeeding breaks" "Requested contribution" "Actual contribution" "Willing contribution" "Contribution breastfeeding woman" "Expected cost lactation room" "Willing contribution" "Contribution breastfeeding woman" "Contribution teacher" "Hourly contribution committee" "Donation out of 50 KHS" "Survey duration" "Reason for refusal-length" "Health inspection check-length" "School imprvmnt suggstns-length" "School imprvmnt steps-length" "Important school prblms-length" "School imprvmnt suggstns-length" "Challanges maternity -length" "Justification-length" "Justification-length" "Justification-length" "Cultural beliefs-length" "Good idea lact rm-length" "Bad idea lact rm-length" "Good idea lact rm-length" "Bad idea lact rm-length" "Good idea lact rm-length" "Bad idea lact rm-length" "Good idea lact rm -length" "Bad idea lact rm -length" "Reason champion selection-length" "Reason champion selection-length" "Reason champion selection-length" "Reason champion selection-length" "Need to brstfd in schl-length" "Need to brstfeed feeling-length" "Need to brstfd in schl-length" "Need to brstfd in schl-length" "Need to brstfeed feeling-length"

 mat colnames outliers = "Mean" "Sd" "Min" "q1" "Median" "q3" "Max" "Count"
 mat list outliers
 putexcel set "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/hfc_output_extras.xlsx", sheet("variable distributions", replace) modify
 
 putexcel A1=matrix(outliers), names txtwrap
 putexcel save
 
 restore

**# Ipacheckoutliers - IPA's command does not work but I coded my own alternative

   if $run_outliers {
		ipacheckoutliers using "${inputfile}",			///
			id(${id})									///
			enumerator(${enum}) 						///	
			date(${date})	 							///
			sheet("outliers")							///
        	outfile("${hfc_output}") 					///
			outsheet("outliers")						///						
			${ol_nolabel}								///
			sheetreplace
   }

**# Survey duration by enumerator

preserve
	clear all
	save "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/duration_by_enum.dta", emptyok replace
restore


levelsof ${enum}, local(levels)	
foreach i of local levels {
		preserve
		duplicates drop ${id}, force
		drop if(s_status!=1|1&${consent}!=1)
		keep if $enum=="`i'"
		display "`i'"
		sum duration
		gen obs=r(N)
		label variable obs "Number of consented & completed surveys"
		gen min=r(min)
		label variable min "Min"
		gen mean=r(mean)
		label variable mean "Mean"
		gen max=r(max)
		label variable max "Max"
		gen sd=r(sd)
		label variable sd "Sd"	
		
		keep ${enum} obs min mean max sd
		save duration.dta, replace
		use "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/duration_by_enum.dta", clear
		append using duration.dta
		save "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/duration_by_enum.dta", emptyok 	replace
		erase duration.dta
		restore
		
}

preserve
use "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/duration_by_enum.dta", clear
duplicates drop ${enum}, force
export excel "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/hfc_output.xlsx", sheet("duration by enumerator", replace) firstrow(varlabels) 
restore

/* 
local varlist_enums=r(${enum})
global varlist_enums r(${enum})
 
count
local n_obs=r(N)
levelsof subcounty
local varlist_subcounties=r(levels) 

//Update: later need to change the varlist to the full set of sampled subcounties, now I am only running the check based on those available in the sample dataset

foreach i of local varlist_subcounties {
		preserve
		keep if(subcounty==`i'&s_status==1&${consent}) // Checks only consented, completed surveys
		duplicates drop ${id}, force
		gen obs=r(N)
		gen min=r(min)
		gen mean=r(mean)
		gen max=r(max)
		gen sd=r(sd)
		
		
		count if(survey_type==2&modb_b9==1)
		gen TC_male = r(N)
		label variable TC_male "TC Male"
		gen completion_TC_male = round(TC_male*100/(3*x),.01)
		label variable completion_TC_male "% completion rate (TC male)"
		
		count if(survey_type==2&modb_b9==0)
		gen TC_female =r(N)
		label variable TC_female "TC Female"
		gen completion_TC_female= round(TC_female*100/(6*x),.01)
		label variable completion_TC_female "% completion rate (TC female)"
		
		count if survey_type==1
		gen HT=r(N)
		label variable HT "Head Teacher"
		gen completion_HT=round(HT*100/(1*x),.01)
		label variable completion_HT "% completion rate (HT)"
		
		count
		gen total=r(N)
		label variable total "Total"
		gen completion_rate=round(total*100/(10*x),.01)
		label variable completion_rate "% completion rate (all)"
		
		distinct ${school}
		gen n_schools=r(ndistinct)
		label variable n_schools "# Distinct schools surveyed"
		gen completion_schools=round(n_schools*100/x)
		label variable completion_schools "% of schools visited at least once"
		
		label variable ${subcounty} "Subcounty code"
		
		keep ${subcounty} TC_male TC_female HT completion_HT completion_TC_male completion_TC_female total completion_rate n_schools completion_schools 
		save tracking_`i'.dta, replace
		use "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/tracking_subcounties.dta", clear
		append using tracking_`i'.dta
		save "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/tracking_subcounties.dta", emptyok 	replace
		erase tracking_`i'.dta
		restore
}

preserve
use "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/tracking_subcounties.dta", clear
export excel using "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/hfc_output.xlsx", sheet("respondent tracking subcounty", replace) firstrow(varlabels) 
restore
 */
 
**# Box plot for all population groups combined, for all module duration variables

 graph box consent_duration modb_duration modl_duration modc_duration modd_duration modf_duration modg_duration modh_duration modi_duration modj_duration modk_duration modm_duration, cwhisker mark(1,mlabel(${id})) mark(2,mlabel(${id})) mark(3,mlabel(${id})) mark(4,mlabel(${id})) mark(5,mlabel(${id})) mark(6,mlabel(${id})) mark(7,mlabel(${id})) mark(8,mlabel(${id})) mark(9,mlabel(${id})) mark(10,mlabel(${id})) mark(11,mlabel(${id})) mark(12,mlabel(${id})) legend(rows(2) stack)
 
 graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/plots/module_duration.png", replace
 
**# Box plots for total duration disaggregated by group

 //HT male kids 
preserve

keep if(survey_type==1&modb_b9==1&modb_b10_filtre==1)
	
graph box duration, mark(1,mlabel(${id})) name(HT_male_kids, replace) title(HT_male_kids) nodraw
	
restore

 //HT male no kids 
preserve

keep if(survey_type==1&modb_b9==1&modb_b10_filtre==0)

graph box duration, mark(1,mlabel(${id})) name(HT_male_nokids, replace) title(HT_male_nokids) nodraw
	
restore
		
 //HT female no kids <45 
preserve

keep if(survey_type==1&modb_b9==0&modb_b10_filtre==0&age<45)

graph box duration, mark(1,mlabel(${id})) name(HT_female_nokids_less45, replace) title(HT_female_nokids_less45) nodraw
	
restore
		
//HT female no kids >=45
preserve

keep if(survey_type==1&modb_b9==0&modb_b10_filtre==0&age>=45)

graph box duration, mark(1,mlabel(${id})) name(HT_female_nokids_over45, replace) title(HT_female_nokids_over45) nodraw
	
restore

 //HT female kids
preserve

keep if(survey_type==1&modb_b9==0&modb_b10_filtre==1)

graph box duration, mark(1,mlabel(${id})) name(HT_female_kids, replace) title(HT_female_kids) nodraw
	
restore

		
 //TC male kids
preserve

keep if(survey_type==2&modb_b9==1&modb_b10_filtre==1)

graph box duration, mark(1,mlabel(${id})) name(TC_male_kids, replace) title(TC_male_kids) nodraw
	
restore
		
 //TC male no kids 
preserve

keep if(survey_type==2&modb_b9==1&modb_b10_filtre==0)

graph box duration, mark(1,mlabel(${id})) name(TC_male_nokids, replace) title(TC_male_nokids) nodraw
	
restore
		
//TC female kids
preserve

keep if(survey_type==2&modb_b9==0&modb_b10_filtre==1)

graph box duration, name(TC_female_kids, replace) mark(1,mlabel(${id})) title(TC_female_kids) nodraw
	
restore

 //TC female no kids <45 
preserve

keep if(survey_type==2&modb_b9==0&modb_b10_filtre==0&age<45)

graph box duration, mark(1,mlabel(${id})) name(TC_female_nokids_less45, replace) title(TC_female_nokids_less45) nodraw
	
restore

 //TC female no kids >=45
preserve

keep if(survey_type==2&modb_b9==0&modb_b10_filtre==0&age>=45)

graph box duration, mark(1,mlabel(${id})) name(TC_female_nokids_over45, replace) title(TC_female_nokids_over45) nodraw
	
restore

	
graph combine HT_male_kids HT_male_nokids HT_female_nokids_less45 HT_female_nokids_over45 HT_female_kids TC_male_kids TC_male_nokids TC_female_kids TC_female_nokids_less45 TC_female_nokids_over45, name(all_categories, replace)

graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/plots/Duration_by_group.png", name(all_categories) replace

}
	*============================= Constraints ================================*
	quietly{ 
**# Checks if the constraints are met. I only included the constraints that are already coded in survey CTO so the output is always null.

 preserve
 
  // Labelling the errors that will show in the constraint output
 label variable reason_refusal "Reason for refusal may be too short"
 label variable length_modl_l18 "What did the health inspection check? (short)"
 label variable length_modl_l23a "School improvement suggestions (short)"
 label variable length_modl_l23b "School improvement implementation steps (short)"
 label variable length_modm_m1 "Most important school problems (short)"
 label variable length_modc_c24 "School improvement suggestions (short)"
 label variable length_modm_m3a "Challenges when returning from maternity (short)"
 label variable length_modd_d6b_explain "Justification may be too short"
 label variable length_modd_d8b_explain "Justification may be too short"
 label variable length_modd_d9b_explain "Justification may be too short"
 label variable length_modf_f20 "Cultural beliefs on breastpumpting (short)"
 label variable length_modi_i1a1 "Good idea to have lactation room (short)"
 label variable length_modi_i1a2 "Bad idea to have lactation room (short)"
 label variable length_modi_i1b1 "Good idea lactation room but not breastfeeding (short)"
 label variable length_modi_i1b2 "Bad idea lactation room but not breastfeeding (short)"
 label variable length_modi_i5b "Changes to lactation room (short)"
 label variable length_modi_j1a1 "Good idea to have lactation room (short)"
 label variable length_modi_j1a2 "Bad idea to have lactation room (short)"
 label variable length_modi_j1b1 "Good idea lactation room but not breastfeeding (short)"
 label variable length_modi_j1b2 "Bad idea lactation room but not breastfeeding (short)"
 label variable length_modk_k1a_reson "Reason for selecting champion may be too short"
 label variable length_modk_k2a_reson "Reason for selecting champion may be too short"
 label variable length_modk_k1b_reson "Reason for selecting champion may be too short"
 label variable length_modk_k2b_reson "Reason for selecting champion may be too short"
 label variable length_modm_m6a_a "Needed to express milk at school, action taken? (short)"
 label variable length_modm_m6c_a "Needed to express milk at school, feeling? (short)"
 label variable length_modm_m6a_b "Need to express milk at school, action taken? w lact room (short)"
 label variable length_modm_m6b_b "Need to express milk at school, satisfied? w lact room (short)"
 label variable length_modm_m6c_b "Need to express milk at school, feeling? w lact room (short)"
 label variable length_modm_m3b "What do other teachers do to help them? (short)"
 
 gen text =""
 replace text=reason_refusal if length_reason_refusal
 
   if $run_constraints {
		ipacheckconstraints using "${inputfile}",		///
			id(${id})									///
			enumerator(${enum}) 						///	
			date(${date})	 							///
			sheet("constraints")						///
        	outfile("${hfc_output}") 					///
			outsheet("constraints")						///
			${ct_nolabel}								///
			sheetreplace
   }
 restore
} 
	*================================= Logic ==================================*
	quietly{
 preserve

 use "$preppedsurvey", clear
 
 // Adding the labels that will show as error messages in the output file
label variable teacher_id2_reenter "The teache id was reentered incorrectly"
label variable modb_b2_reenter "The phone number for artime was reentered incorrectly"
label variable modb_b3 "The date of birth is before 01/01/1932 or after 31/12/2004"
label variable modb_b8b "Gross monthly wage is greater then gross household monthly income"
label variable modc_c5 "Time of arrival at school is earlier than time of departure from home"
label variable modc_c6 "Time of departure from school is earlier than the time of arrival"
label variable modc_c7 "Time of arrival at home earlier than time of departure from school"
label variable modd_d5 "When the mother stopped breasfeeding the child was older than current age"
label variable modd_d6b "Mother would have liked to stopped breasfeeding earlier than she actually did"
label variable modd_d7 "Mother wants to stop breastfeeding at age younger than current child age"
label variable modd_d8b "Introduced formula later then when she completely stopped breastfeeding"
label variable modd_m11b "The teacher missed more days of school due to child care than in total"
label variable modd_m11b_male "The teacher missed more days of school due to child care than in total"
label variable modh_h9 "Was oriented on space to use for breastfeeding but saw lactation room by chance."
label variable modm_duration "The duration of module m should be at least 60 seconds to complete the task"
label variable modd_d1b_male_old "The child's date of birth and age do not correspond"
label variable survey_type "Survey type and position at the institution do not correspond"
destring modb_b2_reenter modb_b2 airtime_no_reenter airtime_no, replace

keep if ${consent}==1

   if $run_logic {
		ipachecklogic using "${inputfile}",				///
			id(${id})									///
			enumerator(${enum}) 						///	
			date(${date})	 							///
			sheet("logic")								///
        	outfile("${hfc_output}") 					///
			outsheet("logic")							///
			${cl_nolabel}								///
			sheetreplace
   }

 restore
}
	*=========================== Field comments ===============================* NOT IMPLEMENTED
	quietly{

	if $run_comments {

		ipasctocollate comments ${fieldcomments}, 		///
			folder("${media_folder}")					///
			save("${commentsdata}")						///
			replace
		
		ipacheckcomments ${fieldcomments},				///
			enumerator(${enum}) 						///	
			commentsdata("${commentsdata}")				///
        	outfile("${hfc_output}") 					///
			outsheet("field comments")					///
			keep(${cm_keepvars})						///
			${cm_nolabel}								///
			sheetreplace
   }
 
    *======================= Text audit & time use ============================* NOT IMPLEMENTED
{
   if $run_textaudit | $run_timeuse {
       ipasctocollate textaudit ${textaudit}, 			///
			folder("${media_folder}")					///
			save("${textauditdata}")					///
			replace
   }

   if $run_textaudit {
		ipachecktextaudit ${textaudit},					///
			enumerator(${enum}) 						///	
			textauditdata("${textauditdata}")			///
        	outfile("${textaudit_output}")				///
			stats("${ta_stats}")						///
			${ta_nolabel}								///
			sheetreplace
			
   }
   
   if $run_timeuse {
		ipachecktimeuse ${textaudit}, 					///
			enumerator(${enum})							///	
			starttime(${starttime})						///
			textauditdata("${textauditdata}")			///
        	outfile("${timeuse_output}")				///
			${tu_nolabel} 								///
			sheetreplace
   }
}
}
	*========================= Track Survey Progress ==========================*
	quietly {	
**# Track number of surveyed subcounties, schools, male/female, HT/TC, </> 45, kids/no kids, randomdraws and presence of lactation room

 use "${preppedsurvey}", clear
 
 duplicates drop ${id}, force

 //Keeping only the variables that are necessary to make the dashboard
 keep survey_type modb_b9 age modb_b10_filtre randomdraw1 randomdraw2 randomdraw3 randomdraw4 randomdraw5 school subcounty unique_teacher_id modh_h1 school_name enum_name s_status school ${consent}

**# Respondent tracking by school ***

gen school_fullname=""
label variable school_fullname "School name"
  preserve
	clear all
	save "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/tracking.dta", emptyok replace
  restore

count
local n_obs=r(N)
levelsof ${school}
local varlist_schools=r(levels) //Update: later need to change the varlist to the full set of sampled schools
foreach i of local varlist_schools {
		preserve
		duplicates drop ${id}, force
		keep if(school_name=="`i'"&s_status==1&${consent}==1) // Checks only completed, consented surveys
		
		count if(survey_type==2&modb_b9==1)
		gen TC_male = r(N)
		label variable TC_male "TC Male"
		gen completion_TC_male = round(TC_male*100/3,.01)
		label variable completion_TC_male "% completion rate (TC male)"
		
		count if(survey_type==2&modb_b9==0)
		gen TC_female =r(N)
		label variable TC_female "TC Female"
		gen completion_TC_female= round(TC_female*100/6,.01)
		label variable completion_TC_female "% completion rate (TC female)"
		
		count if survey_type==1
		gen HT=r(N)
		label variable HT "Head Teacher"
		gen completion_HT=round(HT*100/1,.01)
		label variable completion_HT "% completion rate (HT)"
		
		count
		gen total=r(N)
		label variable total "Total"
		gen completion_rate=round(total*100/10,.01)
		label variable completion_rate "% completion rate (all)"
		
		label variable ${subcounty} "Subcounty code"
		label variable ${school} "School id"
		replace school="Primary" if school=="1"
		replace school="Secondary" if school=="2"
		label variable school "School type"
		
		keep school_fullname ${subcounty} ${school} school TC_male TC_female HT completion_HT completion_TC_male completion_TC_female total completion_rate
		save tracking_`i'.dta, replace
		use "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/tracking.dta", clear
		append using tracking_`i'.dta
		save "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/tracking.dta", emptyok 	replace
		erase tracking_`i'.dta
		restore
}

preserve
use "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/tracking.dta", clear
duplicates drop ${school}, force
export excel using "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/hfc_output.xlsx", sheet("respondent tracking by school", replace) firstrow(varlabels)
restore

**# Respondent tracking by subcounty ***
	
 preserve
	clear all
	save "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/tracking_subcounties.dta", emptyok replace
  restore
 
gen subcounty_name=""
label variable subcounty_name "Subcounty"
gen x=30 //Update: change 30 to the actual number of schools sampled per subcounty
  
count
local n_obs=r(N)
levelsof subcounty
local varlist_subcounties=r(levels) //Update: later need to change the varlist to the full set of sampled subcounties, now I am only running the check based on those available in the sample dataset
foreach i of local varlist_subcounties {
		preserve
		keep if(subcounty==`i'&s_status==1&${consent}==1) // Checks only consented, completed surveys
		duplicates drop ${id}, force
		
		count if(survey_type==2&modb_b9==1)
		gen TC_male = r(N)
		label variable TC_male "TC Male"
		gen completion_TC_male = round(TC_male*100/(3*x),.01)
		label variable completion_TC_male "% completion rate (TC male)"
		
		count if(survey_type==2&modb_b9==0)
		gen TC_female =r(N)
		label variable TC_female "TC Female"
		gen completion_TC_female= round(TC_female*100/(6*x),.01)
		label variable completion_TC_female "% completion rate (TC female)"
		
		count if survey_type==1
		gen HT=r(N)
		label variable HT "Head Teacher"
		gen completion_HT=round(HT*100/(1*x),.01)
		label variable completion_HT "% completion rate (HT)"
		
		count
		gen total=r(N)
		label variable total "Total"
		gen completion_rate=round(total*100/(10*x),.01)
		label variable completion_rate "% completion rate (all)"
		
		distinct ${school}
		gen n_schools=r(ndistinct)
		label variable n_schools "# Distinct schools surveyed"
		gen completion_schools=round(n_schools*100/x)
		label variable completion_schools "% of schools visited at least once"
		
		label variable ${subcounty} "Subcounty code"
		
		keep subcounty_name ${subcounty} TC_male TC_female HT completion_HT completion_TC_male completion_TC_female total completion_rate n_schools completion_schools 
		save tracking_`i'.dta, replace
		use "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/tracking_subcounties.dta", clear
		append using tracking_`i'.dta
		save "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/tracking_subcounties.dta", emptyok 	replace
		erase tracking_`i'.dta
		restore
}

preserve
use "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/tracking_subcounties.dta", clear
duplicates drop ${subcounty}, force
export excel using "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/hfc_output.xlsx", sheet("respondent tracking subcounty", replace) firstrow(varlabels) 
restore

**# Survey randomdraws and count of schools with a lactation room ***
 
 preserve
 
 //Defining scalars to report in the dashboard

duplicates drop ${id}, force

count if randomdraw1<0.5
scalar define a=r(N)
count if(randomdraw1>=0.5&randomdraw1!=.)
scalar define b=r(N)
count if randomdraw2<0.5
scalar define c=r(N)
count if(randomdraw2>=0.5&randomdraw2!=.)
scalar define d=r(N)
count if randomdraw3<0.5
scalar define e=r(N)
count if(randomdraw3>=0.5&randomdraw3!=.)
scalar define f=r(N)
count if randomdraw4<0.5
scalar define g=r(N)
count if(randomdraw4>=0.5&randomdraw4!=.)
scalar define h=r(N)
count if randomdraw5<0.5
scalar define i=r(N)
count if(randomdraw5>=0.5&randomdraw5!=.)
scalar define j=r(N)

count if modh_h1==1
scalar define k=r(N)
count if modh_h1!=1
scalar define l=r(N)

count if school=="1"
scalar define m=r(N)
count if school=="2"
scalar define n=r(N)

count if survey_type==1
scalar define o=r(N)
count if survey_type==2
scalar define v=r(N)
count if modb_b9==0
scalar define p=r(N)
count if modb_b9==1
scalar define q=r(N)
count if modb_b10_filtre==1
scalar define r=r(N)
count if modb_b10_filtre==0
scalar define s=r(N)
count if age< 45
scalar define t=r(N)
count if age >= 45
scalar define u=r(N)

 //Putting these scalars into the output excel file
putexcel set "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/hfc_output_extras.xlsx", sheet("random draws and lactation room", replace) modify

putexcel A1=""
putexcel B1= "Count", bold border(bottom) txtwrap 
putexcel C1= "Share (%)", bold border(bottom) txtwrap 

putexcel A2 ="Randomdraw1<0.5", bold border(bottom) txtwrap 
putexcel B2 = a
putexcel C2 = (round((a/(a+b)*100),.01))

putexcel A3 ="Randomdraw1>=0.5", bold border(bottom) txtwrap 
putexcel B3 = b
putexcel C3 = (round((b/(a+b)*100),.01))

putexcel A4 ="Randomdraw2<0.5", bold border(bottom) txtwrap 
putexcel B4 = c
putexcel C4 = (round((c/(c+d)*100),.01))

putexcel A5 ="Randomdraw2>=0.5", bold border(bottom) txtwrap 
putexcel B5 = d
putexcel C5 = (round((d/(c+d)*100),.01))

putexcel A6="Randomdraw3<0.5", bold border(bottom) txtwrap 
putexcel B6 = e
putexcel C6 = (round((e/(e+f)*100),.01))

putexcel A7="Randomdraw3>=0.5", bold border(bottom) txtwrap 
putexcel B7 = f
putexcel C7 = (round((f/(f+e)*100),.01))

putexcel A8="Randomdraw4<0.5", bold border(bottom) txtwrap 
putexcel B8 = g
putexcel C8 = (round((g/(g+h)*100),.01))

putexcel A9="Randomdraw4>=0.5", bold border(bottom) txtwrap 
putexcel B9 = h
putexcel C9 = (round((h/(g+h)*100),.01))

putexcel A10="Randomdraw5<0.5", bold border(bottom) txtwrap 
putexcel B10 = i
putexcel C10 = (round((i/(i+j)*100),.01))

putexcel A11="Randomdraw5>=0.5", bold border(bottom) txtwrap 
putexcel B11 = j
putexcel C11 = (round((j/(i+j)*100),.01))

putexcel B13= "Count", bold border(bottom) txtwrap 
putexcel C13= "Share (%)", bold border(bottom) txtwrap 

putexcel A14="Lactation room present", bold border(bottom) txtwrap 
putexcel B14 = k
putexcel C14 = (round((k/(k+l)*100),.01))

putexcel A15="Lactation room absent", bold border(bottom)
putexcel B15 = l
putexcel C15 = (round((l/(k+l)*100),.01))

putexcel A16="Total", bold border(bottom) txtwrap 
putexcel B16 = k+l
putexcel C16 = 100

putexcel save
 restore

**# Respondent tracking sheet for each school ***

 levelsof ${school}
 local varlist_schools=r(levels) //Update: later need to change the varlist to the full set of sampled schools
 foreach z of local varlist_schools {
	
	putexcel set "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/hfc_output_extras.xlsx", sheet("school `z' tracking", replace) modify

//For PIs: the </>/=35 and 45 splits were not clearly specified. I considered them as follows:

	//Row names
	putexcel A1="Survey status", bold border(bottom) txtwrap 
	putexcel B1= "TC Male<45", bold border(bottom) txtwrap 
	putexcel C1= "Target", border(bottom) txtwrap 
	putexcel D1= "TC Male>=45", bold border(bottom) txtwrap 
	putexcel E1= "Target", border(bottom) txtwrap 
	putexcel F1= "TC Female <35 who went back from maternity from Jul 2022", bold border(bottom) txtwrap 
	putexcel G1= "Target", border(bottom) txtwrap 
	putexcel H1= "TC Female <35 not back from maternity", bold border(bottom) txtwrap 
	putexcel I1= "Target", border(bottom) txtwrap 
	putexcel J1= "TC Female 35-44 who went back from maternity from Jul 2022", bold border(bottom) txtwrap 
	putexcel K1= "Target", border(bottom) txtwrap 
	putexcel L1= "TC Female 35-44 not back from maternity", bold border(bottom) txtwrap 
	putexcel M1= "Target", border(bottom) txtwrap 
	putexcel N1= "TC Female >=45", bold border(bottom) txtwrap 
	putexcel O1= "Target",  border(bottom) txtwrap 
	putexcel P1= "TC male", bold border(bottom) txtwrap 
	putexcel Q1= "Target", border(bottom) txtwrap 
	putexcel R1= "TC femal", bold border(bottom) txtwrap 
	putexcel S1= "Target", border(bottom) txtwrap 
	putexcel T1= "Head teacher (HT)", bold border(bottom) txtwrap 
	putexcel U1= "Target", bold border(bottom) txtwrap 
	putexcel V1= "Total", bold border(bottom) txtwrap 
	putexcel W1= "Target", border(bottom) txtwrap 

	//Column names
	putexcel A2="Inomplete", bold txtwrap 
	putexcel A3= "Complete", bold txtwrap 
	putexcel A4= "Appointment", bold txtwrap 
	putexcel A5= "Refusal", bold txtwrap 
	putexcel A6="Respondent is on leave", bold txtwrap 
	putexcel A7="Respondent is absent from school (with permission)", bold txtwrap 
	putexcel A8="Respondent is absent from school (without permission)", bold txtwrap 
	putexcel A9="Respondent transferred to another school", bold txtwrap 
	putexcel A10= "School closed for half term/holiday break", bold txtwrap 
	putexcel A11= "Other status", bold txtwrap

	//Filling in the dashboard
	
	//Targets
	putexcel C3=2, italic bold
	putexcel E3=1, italic bold
	putexcel G3=2, italic bold
	putexcel I3=2, italic bold
	putexcel K3=1, italic bold
	putexcel M3=0, italic bold
	putexcel O3=1, italic bold
	putexcel Q3=3, italic bold
	putexcel S3=6, italic bold
	putexcel U3=1, italic bold
	putexcel W3=10, italic bold
	
	//TC Male <45
	preserve
		drop if ${school}!="`z'"
		replace s_status=9 if s_status==-777
		local row=2
		forval i=0/9 {
			count if(age<45&modb_b9==1&s_status==`i'&survey_type==2)
			scalar define a=r(N)
			putexcel B`row'= a
			local row=`row'+1
		}
	restore
	
	//TC Male >=45
	preserve
		drop if ${school}!="`z'"
		replace s_status=9 if s_status==-777
		local row=2
		forval i=0/9 {
			count if(age>=45&modb_b9==1&s_status==`i'&survey_type==2)
			scalar define a=r(N)
			putexcel D`row'= a
			local row=`row'+1
		}
	restore
	
	//TC Female <35 who went back from maternity from Jul 2022
	preserve
		drop if ${school}!="`z'"
		replace s_status=9 if s_status==-777
		local row=2
		forval i=0/9 {
			count if(age<35&modb_b9==0&s_status==`i'&survey_type==2)
			scalar define a=r(N)
			putexcel F`row'= a
			local row=`row'+1
		}
	restore
	
//Update: add the maternity condition which will need to be taken from the listing dataset
	
	// TC Female <35 not back from maternity from Jul 2022
	preserve
		drop if ${school}!="`z'"
		replace s_status=9 if s_status==-777
		local row=2
		forval i=0/9 {
			count if(age<35&modb_b9==0&s_status==`i'&survey_type==2)
			scalar define a=r(N)
			putexcel H`row'= a
			local row=`row'+1
		}
	restore
	
	//TC Female 35-44 who went back from maternity from Jul 2022
	preserve
		drop if ${school}!="`z'"
		replace s_status=9 if s_status==-777
		local row=2
		forval i=0/9 {
			count if(age>34&age<45&modb_b9==0&s_status==`i'&survey_type==2)
			scalar define a=r(N)
			putexcel J`row'= a
			local row=`row'+1
		}
	restore
	
	//TC Female 35-44 not back from maternity
	preserve
		drop if ${school}!="`z'"
		replace s_status=9 if s_status==-777
		local row=2
		forval i=0/9 {
			count if(age>34&age<45&modb_b9==0&s_status==`i'&survey_type==2)
			scalar define a=r(N)
			putexcel L`row'= a
			local row=`row'+1
		}
	restore
	
	//TC Female >=45
	preserve
		drop if ${school}!="`z'"
		replace s_status=9 if s_status==-777
		local row=2
		forval i=0/9 {
			count if(age>44&modb_b9==0&s_status==`i'&survey_type==2)
			scalar define a=r(N)
			putexcel N`row'= a
			local row=`row'+1
		}
	restore	
	
	//TC male
	preserve
		drop if ${school}!="`z'"
		replace s_status=9 if s_status==-777
		local row=2
		forval i=0/9 {
			count if(modb_b9==1&s_status==`i'&survey_type==2)
			scalar define a=r(N)
			putexcel P`row'= a
			local row=`row'+1
		}
	restore
	
	//TC female
	preserve
		drop if ${school}!="`z'"
		replace s_status=9 if s_status==-777
		local row=2
		forval i=0/9 {
			count if(modb_b9==0&s_status==`i'&survey_type==2)
			scalar define a=r(N)
			putexcel R`row'= a
			local row=`row'+1
		}
	restore
	
	//Head teacher (HT)
	preserve
		drop if ${school}!="`z'"
		replace s_status=9 if s_status==-777
		local row=2
		forval i=0/9 {
			count if(survey_type==1&s_status==`i')
			scalar define a=r(N)
			putexcel T`row'= a
			local row=`row'+1
		}
	restore
	
	//Total Completed
	preserve
		drop if ${school}!="`z'"
		replace s_status=9 if s_status==-777
		local row=2
		forval i=0/9 {
			count if(s_status==`i')
			scalar define a=r(N)
			putexcel V`row'= a
			local row=`row'+1
		}
	restore
	putexcel save
 }
 
/* Update: for now I cannot run ipatracksurvey because we do not have a tracking survey or respondent list
   
   if $run_tracksurvey {
       ipatracksurvey,									///
			surveydata("$checkedsurvey")				///
			id(${id})									///
			date(${date})								///
			by(${tr_by})								///
			outcome(${tr_outcome})						///
			target(${tr_target})						///
			masterdata("${mastersurvey}")				///
			masterid(${tr_masterid})					///
			trackingdata("${trackingsurvey}")			///
			keepmaster(${tr_keepmaster})				///
			keeptracking(${tr_keeptracking})			///
			keepsurvey(${tr_keepsurvey})				///
			outfile("${tracking_output}")				///
			save("${tr_save}")							///
			${tr_nolabel} 								///
			${tr_summaryonly}							///
			${tr_workbooks} 							///
			${tr_surveyok}								///
			replace
   }
*/
}
