********************************************************************************
** 	TITLE	: 3_prepsurvey_Baseline.do
**
**	PURPOSE	: Prepare Survey Data for HFCs
**				
**	AUTHOR	: Flavia Ungarelli
**
**	DATE LAST MODIFIED : 23/08/2023
********************************************************************************

**# Import data
*------------------------------------------------------------------------------*
use "$rawsurvey", clear

**# Recode extended missing values
*------------------------------------------------------------------------------*
	quietly{
foreach var of varlist _all{
	format `var'
}

/*
** I don't know **
foreach var in modf_f4 modg_g11 modh_h3 modh_h9 modh_h10 modi_i3 modi_i4a modi_i5a modi_i6a modi_i7a modj_j3a modj_j6 modb_b2_whatsapp {
	tostring `var', replace
	replace `var'=-999 if `var'==3
	}
	
foreach var of varlist modd_d17* {
	replace `var'=-999 if `var'==3
} 
	
foreach var of varlist modd_d22*_male {
	replace `var'=-999 if `var'==3
	}
//yesnodk questions
	
replace modh_h6=-999 if modh_h6==3 //spc_decision
replace modh_h7=-999 if modh_h7==5 //brfeed_expmilk

foreach var in modf_f17_male modf_f18_male modf_f19_male{
	replace `var'=-999 if `var'==5
	} 
//support_male

replace modf_f7_male=-999 if modf_f7_male==5 //a_likert_male

** Other specify **
replace modl_l24b="-777" if modl_l24b=="5" // latereasons 
// FU: For now I am leaving it like this but it is a select multiple, so it is necessary to change the options in survey cto

foreach var in modd_d14c_male modd_d34 modd_d34_male modd_d15_male {
	destring `var', replace
	replace `var'=-777 if `var'==4
	}
	//contrcttype_male and futurearrang
	
foreach var of varlist _all {
	capture confirm numeric variable `var'
		if !_rc {
		replace `var' = -999 if(`var'==-222&"`var'"!="modd_d4"&"`var'"!="modd_d4_male")		
        }
		else {
		replace `var' = "-999" if(`var'=="-222"&"`var'"!="modd_d4"&"`var'"!="modd_d4_male")
        }
	}	

replace modd_d15="-777" if modd_d15=="4" //contrcttype - select multiple so str
replace modk_k4a="-777" if modd_d15=="6" //incentives - select multiple so str
*/

	if "$dk_num" ~= "" {
		loc dk_num = trim(itrim(subinstr("$dk_num", ",", " ", .)))
		ds, has(type numeric)
		recode `r(varlist)' (`dk_num' = .d)
	}
	
	if "$ref_num" ~= "" {
		loc ref_num = trim(itrim(subinstr("$ref_num", ",", " ", .)))
		ds, has(type numeric)
		recode `r(varlist)' (`ref_num' = .r)
	}

}	

**# Teacher ID variable must be made a single, unique, non-missing variable
*------------------------------------------------------------------------------*
	quietly{
//We have just two separate variables for teacher id depending on whether the school was able to submit a listing with internet. This new variable that contains the unique id of each teacher.
gen unique_teacher_id = teacher_id
replace unique_teacher_id = teacher_id2 if missing(teacher_id)
}

**# Destring numeric variables
*------------------------------------------------------------------------------*
	quietly{
	#d;
	destring ${duration}
			 ${enum}	
			 ${subcounty}
			 ${id}
			 ${formversion}
			 ${starttime}
			 ${endtime}
			 ${duration_all}
modb_b7b modb_b10b modb_b10d modd_d27a modd_d27a_male modl_l1 modl_l1b1 modl_l1b2 modl_l1c1 modl_l1c2 modl_l7 modl_l8 modl_l9 modl_l13 modl_l14 modl_l15 modc_c3f3 modc_c8b modd_d5 modd_d6b modd_d7 modd_d8b modd_d9b modd_d10 modd_d12 modd_d15e modd_d19c modd_d20c modd_m11 modd_d23_f modd_d23b_f modd_d30 modd_d31 modd_d32 modd_d33 modd_d1b_male_old modd_d5b_male modd_d5d_male modd_d5e_male modd_d11c_male modd_d14b_male modd_d15d_male modd_m11_male modd_m11b_male modd_m11c_male modd_d23_male modd_d30_male modd_d32_male modf_f2 modf_f3 modf_f5a modh_h12 modh_h13 modi_i6b modi_i6c modi_i7b modi_i8 modj_j4b modj_j6b modj_j7a modj_j7b modk_k5a modm_m5 modd_d1_cal_year modd_d1b_male randomdraw1 randomdraw2 randomdraw3 randomdraw4 randomdraw5 modc_c4 modc_c5 modc_c6 modc_c7 modd_d1_cal_month attempt_counter_pl
			 , 
			 replace
		 ;
	#d cr
}
	
**# Check key variable
	* check that key variable contains no missing values
	* check that key variable has no duplicates
*------------------------------------------------------------------------------*
	quietly{
		count if missing($key)
		if `r(N)' > 0 {
			disp as err "key variable should never be missing. Variable $key has `r(N)' missing values"
			exit 459
		}
		else {

			cap isid $key
			if _rc == 459 {
				preserve
				keep $key
				duplicates tag $key, gen (_dup)
				gen row = _n
				sort $key row
				disp as err "variable $key does not uniquely identify the observations"
				noi list row $key if _dup, abbreviate(32) noobs sepby($key)
				exit 459
			}
		}
}	

**# Generate Short-Key variable
	* Generate short key variable. ie. last 12 chars of the SurveyCTO key
	* check that short key variable has no duplicates
*------------------------------------------------------------------------------*
	quietly {
		gen skey = substr(${key}, -12, .)
		count if missing(skey)
		if `r(N)' > 0 {
			disp as err "skey variable should never be missing. Variable skey has `r(N)' missing values"
			exit 459
		}
		else {

			cap isid skey
			if _rc == 459 {
				preserve
				keep skey
				duplicates tag skey, gen (_dup)
				gen row = _n
				sort skey row
				disp as err "variable skey does not uniquely identify the observations"
				noi list row skey if _dup, abbreviate(32) noobs sepby(skey)
				exit 459
			}
		}
	}
		
**# Check date variables													
	* check that surveycto auto generated date variables have no missing values
	* check that surveycto auto generated date variables show values before 
	* Jan 1, 2023		
	quietly {
			count if missing(submissiondate)
			if `r(N)' > 0 {
				disp as err "Variable submissiondate has `r(N)' missing values"
				exit 459
			}
			else {
				cap assert year(dofc(submissiondate)) >= 2023
				if _rc == 9 {
					preserve
					keep $key submissiondate
					gen row = _n
					disp as err "variable submissiondate has dates before 2022. Check that date variable are properly imported"
					noi list row $key `submissiondate if year(dofc(submissiondate)) < 2023, abbreviate(32) noobs sepby($key)
					exit 459
				}
			}
		}

**# Generate datevars from surveycto default datetime vars
*------------------------------------------------------------------------------*	
	quietly {
		foreach var of varlist starttime endtime submissiondate {
			count if missing(`var')
			if `r(N)' > 0 {
				disp as err "Variable `var' has `r(N)' missing values"
				exit 459
			}
			else {
				cap assert year(dofc(`var')) >= 2023
				if _rc == 9 {
					preserve
					keep $key `var'
					gen row = _n
					disp as err "variable `var' has dates before 2023. Check that date variable are properly imported"
					noi list row $key `var' if year(dofc(`var')) < 2023, abbreviate(32) noobs sepby($key)
					exit 459
				}
			}
		}
	}

**# Labelling numerical variables
*------------------------------------------------------------------------------*	
	quietly{ 
label variable modb_b6 "Date of marriage"
label variable modb_b7b "Number of individuals in the household"
label variable modb_b10b "Number of biological children"
label variable modl_l1 "Number of students in the school"
label variable modc_c3f3 "Numbers of days a week in which the respondent teaches"
label variable modc_c8b "Hours that the respondent works at home per week"
label variable modc_c9b "Number of people supervised by the respondent"
label variable modc_c20 "Satisfaction with work (1-10)"
label variable modc_c21 "Would you recommend to family and friends the school as a place to work (1-10)"
label variable modc_c22 "Satisfaction with the relationship with collegues"
label variable modc_c23 "Satisfaction with facilities in the school (1-10)"
label variable modd_d1 "Child's date of birth"
label variable modd_d5 "Child age (in months) when the mother stopped feeding them with her milk"
label variable modd_d7 "Child age (in months) at which the respondent wants to stop breastfeeding the child"
label variable modd_d8b "Child age (in months) at which the mother started introducing formula"
label variable modd_d10 "Child age (in months) until which the mother wants to keep exclusive breastfeeding"
label variable modd_d12 "Months of paid maternity leave taken by the mother"
label variable modd_d20c "Monthly spending for childcare services"
label variable modd_d23_f "Days of work missed by the mother to take care of children in the first three months after childbirth"
label variable modd_d23b_f "Days of work missed to take care of children in the first three months after childbirth"
label variable modf_f2 "Female collegues (out of 10) forced to stop breastfeeding due to work"
label variable modf_f3 "Female collegues (out of 10) forced to stop working due to childcare"
label variable modf_f5a "Female collegues (out of 10) who talked to the respondent about balancing work and breastfeeding"
label variable modh_h12 "Interval of the breasfeeding breaks agreed with the school"
label variable modh_h13 "Length of the breasfeeding breaks agreed with the school"
label variable consent_duration "Consent duration"
label variable duration "Total interview duration"
label variable modb_duration "Module b duration"
label variable modl_duration "Module l duration"
label variable modc_duration "Module c duration"
label variable modd_duration "Module d duration"
label variable modf_duration "Module f duration"
label variable modg_duration "Module g duration"
label variable modh_duration "Module h duration"
label variable modi_duration "Module i duration"
label variable modj_duration "Module j duration"
label variable modk_duration "Module k duration"
label variable modm_duration "Module m duration"
label variable modb_b10d "# of additional children planned (for parents)"
label variable modd_d27a "# of children planned (not parent yet, female)"
label variable modd_d27a_male "# of children planned (not parent yet, male)"
label variable modl_l1b1 "# not teaching female staff"
label variable modl_l1b2 "# not teaching male staff"
label variable modl_l1c1 "# teaching female staff"
label variable modl_l1c2 "# teaching male staff"
label variable modl_l7 "# pregnant teachers"
label variable modl_l8 "# teachers on maternity leave that week"
label variable modl_l9 "# classrooms"
label variable modl_l13 "# toilets for students"
label variable modl_l14 "# toilets for staff"
label variable modl_l15 "# toilets for staff and students"
label variable modd_d6b "Child age (in months) when the mother wanted to stop breasfeeding"
label variable modd_d9b "Child age (in months) when the mother wanted to stop exclusive breasfeeding"
label variable modd_d15e "Hours spent caring for child per week (female respondent)"
label variable modd_d19c "Monthly spending for childcare services"
label variable modd_m11 "Days of work missed in past 6 months (female respondent)"
label variable modd_d30 "Child age (in months) when respondent plans to stop breasfeeding completely"
label variable modd_d31 "Child age (in months) when respondent plans to introduce formula"
label variable modd_d32 "# month of paid maternity leave the respondent plans to take"
label variable modd_d33 "# extra weeks of unpaid maternity leave the respondent plans to take"
label variable modd_d1b_male_old "Child age (male respondent)"
label variable modd_d5b_male "Child age (in months) when wife stopped breasfeeding completely"
label variable modd_d5d_male "# months that the wife wanted to breasfeed the child for"
label variable modd_d5e_male "# months that the husband wanted his wife to breasfeed the child for"
label variable modd_d11c_male "Age of child when the respondent's wife went back to work"
label variable modd_d14b_male "Weeks of paternity leave taken"
label variable modd_d15d_male "Hours spent caring for child per week (male respondent)"
label variable modd_m11_male "Days of work missed in past 6 months (male respondent)"
label variable modd_m11b_male "Days of work missed due to childcare in past 6 months (male respondent)"
label variable modd_m11c_male "Days of work missed in first 3 months after childbirth (male respondent)"
label variable modd_d23_male "Days of work missed in by wife first 3 months after childbirth (male respondent)"
label variable modd_d30_male "Month the respondent wants his partner to breastfeed for"
label variable modd_d32_male "Weeks of paid paternity leave the respondent plans to take"
label variable modi_i6b "Requested contribution for the lactation room"
label variable modi_i6c "Respondent's actual contribution for the lactation room"
label variable modi_i7b "Contribution the respondent would have paid for a lactation room"
label variable modi_i8 "Contribution a breastfeeding women would have paid according to respondent"
label variable modj_j4b "Expected costs of setting up a lactation room"
label variable modj_j6b "Contribution the responent would willingly make for lactation room"
label variable modj_j7a "Contribution a breastfeeding women would pay according to respondent"
label variable modj_j7b  "Contribution a teacher would pay according to respondent"
label variable modk_k5a "Hours the respondent would contribute to committee"
label variable modm_m5 "Donation out of 50 KHS for lactation room"
label variable duration "Survey duration"

label variable consented "Consent"
label variable modb_b9 "Gender"
label variable internet_issue "Internet issues i.e. no listing available"
label variable modb_b10_filtre "Children"
label variable availability "Availability"
label variable modb_b10c "Plan to have other children"
label variable modd_d27 "Plan to have children (female)"
label variable modd_d27_male "Plan to have children (male)"
label variable recording "Consent audio recording"
label variable modb_b5 "Marriage status"
 }
 
**# Generate datevars from surveycto default datetime vars
*------------------------------------------------------------------------------*
	quietly{
/*	gen startdate 	= dofc(starttime)
	gen enddate		= dofc(endtime)
	
	format %td startdate enddate subdate
*/
}
	
**# Drop observations with date before jan 2023
*------------------------------------------------------------------------------*
	quietly{
	drop if submissiondate <= date("01jan2022", "DMY")
}	

**# Age of respondent
*------------------------------------------------------------------------------*
	quietly{
gen age =datediff(modb_b3,dofc(submissiondate),"year")
gen age_child_male =datediff(modd_d1_male,dofc(submissiondate),"year")
}

**# String variables for consent, status and availability
*------------------------------------------------------------------------------*
	quietly{
gen availability_str="."
 replace availability_str="Available" if ${availability}==1
 replace availability_str="Not available" if ${availability}==0
 
 gen consented_str="."
 replace consented_str="Consented" if ${consent}==1
 replace consented_str="Did not consent" if ${consent}==0
 
 gen s_status_str="."
 replace s_status_str= "Incomplete" if ${outcome}==0
 replace s_status_str= "Complete" if ${outcome}==1
 replace s_status_str= "Appointment" if ${outcome}==2
 replace s_status_str= "Refusal" if ${outcome}==3
 replace s_status_str= "Respondent was on leave" if ${outcome}==4
 replace s_status_str= "Respondent was absent from school (with permission)" if ${outcome}==5
 replace s_status_str= "Respondent was absent from school (without permission)" if ${outcome}==6
 replace s_status_str= "Respondent transferred to another school" if ${outcome}==7
 replace s_status_str= "School closed for half term/holiday break" if ${outcome}==8
 tostring s_status_oth,  replace
 replace s_status_str= s_status_oth if ${outcome}==-777
}

**# String length
*------------------------------------------------------------------------------*
	quietly {
// Generating variables measuring the length of the open answer questions
 gen length_reason_refusal = ustrlen(reason_refusal) if reason_refusal!=""
 gen length_modl_l18 = ustrlen(modl_l18) if modl_l18!=""
 gen length_modl_l23a = ustrlen(modl_l23a) if modl_l23a!=""
 gen length_modl_l23b = ustrlen(modl_l23b) if modl_l23b!=""
 gen length_modm_m1 = ustrlen(modm_m1) if modm_m1!=""
 gen length_modc_c24 = ustrlen(modc_c24) if modc_c24!=""
 gen length_modm_m3a = ustrlen(modm_m3a) if modm_m3a!=""
 gen length_modm_m3b = ustrlen(modm_m3b) if modm_m3b!=""
 gen length_modd_d6b_explain = ustrlen(modd_d6b_explain) if modd_d6b_explain!=""
 gen length_modd_d8b_explain = ustrlen(modd_d8b_explain) if modd_d8b_explain!=""
 gen length_modd_d9b_explain = ustrlen(modd_d9b_explain) if modd_d9b_explain!=""
 gen length_modf_f20 = ustrlen(modf_f20) if modf_f20!=""
 gen length_modi_i1a1 = ustrlen(modi_i1a1) if modi_i1a1!=""
 gen length_modi_i1a2 = ustrlen(modi_i1a2) if modi_i1a2!=""
 gen length_modi_i1b1 = ustrlen(modi_i1b1) if modi_i1b1!=""
 gen length_modi_i1b2 = ustrlen(modi_i1b2) if modi_i1b2!=""
 gen length_modi_i5b = ustrlen(modi_i5b) if modi_i5b!=""
 gen length_modi_j1a1 = ustrlen(modi_j1a1) if modi_j1a1!=""
 gen length_modi_j1a2 = ustrlen(modi_j1a2) if modi_j1a2!=""
 gen length_modi_j1b1 = ustrlen(modi_j1b1) if modi_j1b1!=""
 gen length_modi_j1b2 = ustrlen(modi_j1b2) if modi_j1b2!=""
 gen length_modk_k1a_reson = ustrlen(modk_k1a_reson) if modk_k1a_reson!=""
 gen length_modk_k2a_reson = ustrlen(modk_k2a_reson) if modk_k2a_reson!=""
 gen length_modk_k1b_reson = ustrlen(modk_k1b_reson) if modk_k1b_reson!=""
 gen length_modk_k2b_reson = ustrlen(modk_k2b_reson) if modk_k2b_reson!=""
 gen length_modm_m6a_a = ustrlen(modm_m6a_a) if modm_m6a_a!=""
 gen length_modm_m6c_a = ustrlen(modm_m6c_a) if modm_m6c_a!=""
 gen length_modm_m6a_b = ustrlen(modm_m6a_b) if modm_m6a_b!=""
 gen length_modm_m6b_b = ustrlen(modm_m6b_b) if modm_m6b_b!="" 
 gen length_modm_m6c_b = ustrlen(modm_m6c_b) if modm_m6c_b!=""
 gen length_final_comment=ustrlen(final_comment) 
}

**# Other specify variables
*------------------------------------------------------------------------------*
	quietly{
replace educ_level_oth="" if modb_b4!=-777
replace modl_l24b_oth="" if modl_l24b!="-777"
replace modl_l25b_oth="" if modl_l25b!="-777"
replace modc_c2_oth="" if modc_c2!=-777
replace modc_c3c_oth="" if modc_c3c!=-777
replace modc_c12_oth="" if modc_c12!="-777"
replace modc_c15_oth="" if modc_c15!=-777
replace modc_c16b_oth="" if modc_c16b!="-777"
replace modd_d11a_oth="" if modd_d11a!=-777
replace modd_d15_other="" if modd_d15!="-777"
replace modd_d19a_oth="" if modd_d19a!="-777"
replace modd_d20a_oth="" if modd_d20a!="-777"
replace modd_d21b_male_other="" if modd_d21a_male!=-777
replace modd_d11a_male_other="" if modd_d11a_male!=-777
replace modd_d21b_f_oth="" if modd_d21b_f!=-777
replace modd_d37a_oth="" if modd_d37a!="-777"
replace modd_d38_oth="" if modd_d38!=-777
replace modh_h2_oth="" if modh_h2!="-777"
replace modh_h5_oth="" if modh_h5!=-777
replace modh_h14_oth="" if modh_h14!=-777
replace modh_h15_oth="" if modh_h15!=-777
replace modi_i4b_oth="" if modi_i4b!="-777"
replace modi_j1c_oth="" if modi_j1c!=-777
replace modj_j3b_oth="" if modj_j3b!="-777"
replace modj_j4_oth="" if modj_j4!="-777"
replace modj_j11_oth="" if modj_j11!=-777
replace modk_k4a_oth="" if modk_k4a!="-777"
replace s_status_oth="" if s_status!=-777
replace modd_d15e_male="" if modd_d15_male!=-777
replace modd_d34d="" if modd_d34!="-777"
replace modd_d34d_male="" if modd_d34_male!="-777"
	}

**# Save data
*------------------------------------------------------------------------------*
	save "$preppedsurvey", replace
	