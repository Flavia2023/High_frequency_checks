
********************************************************************************
** 	TITLE	: 4_checksurvey_Baseline_newsubmissions.do
**
**	PURPOSE	: Run High Frequency Checks on recent observations only
**				
**	AUTHOR	: Flavia Ungarelli
**
**	DATE LAST MODIFIED	:  26/08/2023
********************************************************************************

   use "${preppedsurvey}", clear
   
**# Creating a folder with the observations of the previous day only
quietly{
	cap confirm file "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations"
	if _rc mkdir "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations"
	
	gl hfc_output_new	"${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations/hfc_output.xlsx"
}



**# Dropping submissions more than z days old ***
quietly{
// Change z to the number of days to be assessed
	global z = today()-20
	generate numdate = dofc(submissiondate)
	drop if numdate <=${z}
}

	*========================= Find Survey Duplicates =========================*
	quietly{
 //Checks for duplicates in the teacher ID and produces the "id duplicates" sheet in the output excel file
  if $run_ids {
	   ipacheckids ${id},								///
				enumerator(${enum}) 					///	
				date(${date})	 						///
				key(${key}) 							///
				outfile("${hfc_output_new}") 				///
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

	*============================ Other Specify ===============================*
	quietly{
 replace s_status_oth="" if s_status_oth=="."
   if $run_specify {
		ipacheckspecify using "${inputfile}",			///
			id(${id})									///
			enumerator(${enum})							///	
			date(${date})	 							///
			sheet("other specify")						///
        	outfile("${hfc_output_new}") 					///
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
				outfile("${hfc_output_new}") 				///
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
  
replace tsc_number=. if(tsc_number==-555|tsc_number==-888) // -555 is "prefer not to answer" but we need to avoid it showing up as a duplicate.

   if $run_dups {
	   ipacheckdups ${dp_vars},							///
				id(unique_id_nodups)					///
				enumerator(${enum}) 					///	
				date(${date})	 						///
				outfile("${hfc_output_new}") 				///
				outsheet("duplicates")					///
				keep(${keepvars})	 				///
				${dp_nolabel}							///
				sheetreplace
   }
 restore 
}
	*========================= Variable Missingness ===========================*
	quietly{
		
	use "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/missingness.dta", clear
	generate numdate = dofc(submissiondate)
	drop if numdate <=${z}	
	
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

// Temporarily reverting missing values codes to numbers
	foreach var of varlist _all {
	capture confirm numeric variable `var'
		if !_rc {
		replace `var'=-999 if `var'==.d
		replace `var'=-888 if `var'==.r
		replace `var'=-666 if `var'==.a	
        }
		else {
        }
	}

drop availability_str s_status_str
	
   if $run_missing { 
		ipacheckmissing ${ms_vars}, 					///
			priority(${ms_pr_vars})						///
			outfile("${hfc_output_new}") 					///
			outsheet("missing")							///
			sheetreplace		
   }
	}

	*==================== Enumerator plots and tables =========================*
	quietly{
		
	use "${preppedsurvey}", clear
	generate numdate = dofc(submissiondate)
	drop if numdate <=${z}
	
**# Making plots and tables of the most relevant variables by enumerator 
 
	label variable ${enum} "Enumerator"
	
	cap confirm file "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations/plots"
	if _rc mkdir "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations/plots"

   cd "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations/plots"
   
   graph bar (count), over(availability) over(${enum}, label(alternate)) title(Availability by enumerator) //Availability
   graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations/plots/availability.png", replace
   
   graph bar (count), over(${consent}) over(${enum}, label(alternate)) title(Consent by enumerator) //Consent
   graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations/plots/consent.png", replace
   
   label variable ${outcome_str} "Survey status"
   graph bar (count), over(${outcome_str}, label(angle(90))) over(${enum}, label(alternate)) title(Status by enumerator) //Survey status
   graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations/plots/survey_status.png", replace
  
   cd "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations"
   
*xtable ${enum} internet_issue, statistic(percent, across(internet_issue)) statistic(frequency) missing
  
  tab2xl ${enum} availability using hfc_output.xlsx, col(1) row(1) sheet("enum_stats", replace) missing percent
  tab2xl ${enum} ${consent} using hfc_output.xlsx, col(7) row(1) sheet("enum_stats") missing percent
  tab2xl ${enum} ${outcome_str} using hfc_output.xlsx, col(14) row(1) sheet("enum_stats") missing percent
   
   asdoc tabulate ${enum} availability, missing replace save(enum_stats.doc) row title(Availability by enumerator) rnames(Enumerator)
   asdoc tabulate ${enum} ${consent}, missing append save(enum_stats.doc) row title(Consent by enumerator) rnames(Enumerator)
   asdoc tabulate ${enum} ${outcome_str}, missing append save(enum_stats.doc) row title(Status by enumerator) rnames(Enumerator)
   
   // Only considering the completed surveys below and for the rest of the checks
  
    cd "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations/plots"
	
	keep if ${consent}==1
	
   graph bar (count), over(modb_b9) over(${enum}, label(alternate)) title(Respondent gender by enumerator) // male or female
   graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations/plots/gender.png", replace
  
   label variable internet_issue "Was there internet issues that prevented submitting the listing?"
   graph bar (count), over(internet_issue) over(${enum}, label(alternate)) title(Internet issues by enumerator) //ENUMERATOR: Was there internet connectivity issues that prevented you from submitting...
   graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations/plots/internet_issues.png" , replace
     
   graph bar (count), over(modb_b10_filtre) over(${enum}, label(alternate)) title(Children by enumerator) // B10a. Do you have biological children?
   graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations/plots/children.png", replace
    
   graph bar (count), over(modb_b10c) over(${enum}, label(angle(-60) labsize(*0.5))) missing name(one, replace) title(Planning to have other children by enumerator) // B10c. Do you plan to have others?
*   graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations/plots/future_children_parents.png", replace

   graph bar (count), over(modd_d27) over(${enum}, label(angle(-60) labsize(*0.5))) missing name(two, replace) title(Planning to have children-male) //<b>D27.</b>  Do you plan to have biological children?
*   graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations/plots/future_children_female.png", replace
   
   graph bar (count), over(modd_d27_male) over(${enum}, label(angle(-60) labsize(*0.5))) missing name(three, replace) title(Planning to have children-male) //<b>D27.</b>  Do you plan to have biological children?
*  graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations/plots/future_children_male.png", replace
   
   graph combine one two three, name(future_children, replace)
   graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations/plots/future_plans.png", replace
   
   graph bar (count), over(modb_b5, label(angle(90))) over(${enum}, label(alternate)) title(Marriage status by enumerator) // B5. What is your marriage status?
   graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations/plots/marriage.png", replace
   
   graph bar (count), over(recording) over(${enum}, label(alternate)) title(Audio recording consent by enumerator) // Thank you. As mentioned above, during this survey you may be audio recorded...
   graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations/plots/recording_consent.png", replace
   
   hist age, freq bin(50) title(Distribution of respondent ages) 
   graph export "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations/plots/age.png", replace

   cd "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations"

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

 putexcel set "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations/hfc_output_extras.xlsx", sheet("open answers", replace) replace
 putexcel A1="Enumerator", bold border(bottom) txtwrap 
 putexcel B1="Mean of experience question length", bold border(bottom) txtwrap
 putexcel C1="Mean of school improvement suggestions length", bold border(bottom) txtwrap
 putexcel D1="Mean of enumerator explanations", bold border(bottom) txtwrap
 putexcel E1="Mean of a select subset of open ended questions", bold border(bottom) txtwrap
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
	scalar define mean_exper_`row'=r(mean)
	
	summarize mean_length_suggestion_questions
	scalar define mean_sugg_`row'=r(mean)
	
	summarize mean_length_lactrm_good_bad
	scalar define mean_gb_`row'=r(mean)
	
	summarize mean_length_enum_explain
	scalar define mean_explain_`row'=r(mean)
	
	summarize mean_length_text_answers
	scalar define mean_length_`row'=r(mean)
	
	summarize length_final_comment
	scalar define mean_comment_`row'=r(mean)
	
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
preserve
use "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/outliers.dta", clear

generate numdate = dofc(submissiondate)
drop if numdate <=${z}

export excel using "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations/hfc_output.xlsx", sheet("outliers", replace) firstrow(varlabels)

putexcel set "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations/hfc_output.xlsx", sheet("outliers") modify
putexcel B1="Observed value"
putexcel save
restore
}
	*============================= Constraints ================================*
	quietly{ 
**# Checks if the constraints are met. I only included the constraints that are already coded in survey CTO so the output is always null.

 preserve
 
 replace modc_c22=12 if duration==1482 // FU: just to show how it works
 
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
        	outfile("${hfc_output_new}") 					///
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
 
 generate numdate = dofc(submissiondate)
 drop if numdate <=${z}
 
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
        	outfile("${hfc_output_new}") 					///
			outsheet("logic")							///
			${cl_nolabel}								///
			sheetreplace
   }

 restore
}

**# Moving the final versions of the documents for the field to a new folder

cd  "${cwd}/HFC_lactationrooms_field"

gl folder_date_field = string(year(today())) + "-`:disp %tdNN today()'-`:disp %tdDD today()'"

cap confirm file "${folder_date_field}"
if _rc mkdir "${folder_date_field}"
	
cd "${cwd}"

shell mv "${hfc_output}" "${cwd}/HFC_lactationrooms_field/$folder_date_field"

shell mv "${cwd}/3_checks/2_outputs/1_Baseline/$folder_date/new_observations/hfc_output.xlsx" "${cwd}/HFC_lactationrooms_field/$folder_date_field/hfc_output_recent.xlsx"
