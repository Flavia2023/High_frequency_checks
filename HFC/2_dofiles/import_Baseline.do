* 	import_baseline_survey_lactation_rooms_scaleup.do
*
* 	Imports and aggregates "Baseline_Survey_Lactation_Rooms_Scaleup" (ID: baseline_survey_lactation_rooms_scaleup) data.
*
*	Inputs:  "Baseline_Survey_Lactation_Rooms_Scaleup_WIDE.csv"
*	Outputs: "Baseline_Survey_Lactation_Rooms_Scaleup.dta"
*
*	Output by SurveyCTO July 31, 2023 4:10 PM.

* initialize Stata
clear all
set more off
set mem 100m

* initialize workflow-specific parameters
*	Set overwrite_old_data to 1 if you use the review and correction
*	workflow and allow un-approving of submissions. If you do this,
*	incoming data will overwrite old data, so you won't want to make
*	changes to data in your local .dta file (such changes can be
*	overwritten with each new import).
local overwrite_old_data 0

* initialize form-specific parameters
local csvfile "/Users/flavia_ungarelli/Dropbox/Kenya Lactation Rooms/9.SCALEUP/HFC/4_data/2_survey/0_Mock_dataset_baseline/Baseline_Survey_Lactation_Rooms_Scaleup_WIDE.csv"
local dtafile "/Users/flavia_ungarelli/Dropbox/Kenya Lactation Rooms/9.SCALEUP/HFC/4_data/2_survey/0_Mock_dataset_baseline/Baseline_Survey_Lactation_Rooms_Scaleup.dta"
local corrfile "/Users/flavia_ungarelli/Dropbox/Kenya Lactation Rooms/9.SCALEUP/HFC/4_data/2_survey/0_Mock_dataset_baseline/Baseline_Survey_Lactation_Rooms_Scaleup_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid subscriberid simid devicephonenum comments duration consent_audit moduleb moduledc moduledd moduledf moduledg moduledi moduledj moduledk question_m6 question_m3a question_m3b"
local text_fields2 "speed_violations_audit school subcounty school_name calc_enum_name employee_count employee_details_count employee_index_* employee_name_* employee_pid_* teachername_1 teachername_2 teachername_3"
local text_fields3 "teachername_4 teachername_5 teachername_6 teachername_7 teachername_8 teachername_9 teachername_10 teachername_11 teachername_12 teachername_13 teachername_14 teachername_15 teachername_16"
local text_fields4 "teachername_17 teachername_18 teachername_19 teachername_20 teachername_21 teachername_22 teachername_23 teachername_24 teachername_25 teachername_26 teachername_27 teachername_28 teachername_29"
local text_fields5 "teachername_30 teachername_31 teachername_32 teachername_33 teachername_34 teachername_35 teachername_36 teachername_37 teachername_38 teachername_39 teachername_40 teachername_41 teachername_42"
local text_fields6 "teachername_43 teachername_44 teachername_45 teachername_46 teachername_47 teachername_48 teachername_49 teachername_50 teachername_51 teachername_52 teachername_53 teachername_54 teachername_55"
local text_fields7 "teachername_56 teachername_57 teachername_58 teachername_59 teachername_60 teachername_61 teachername_62 teachername_63 teachername_64 teachername_65 teachername_66 teachername_67 teachername_68"
local text_fields8 "teachername_69 teachername_70 teachername_71 teachername_72 teachername_73 teachername_74 teachername_75 teachername_76 teachername_77 teachername_78 teachername_79 teachername_80 teachername_81"
local text_fields9 "teachername_82 teachername_83 teachername_84 teachername_85 teachername_86 teachername_87 teachername_88 teachername_89 teachername_90 teachername_91 teachername_92 teachername_93 teachername_94"
local text_fields10 "teachername_95 teachername_96 teachername_97 teachername_98 teachername_99 teachername_100 teacher_pid1 teacher_pid2 teacher_pid3 teacher_pid4 teacher_pid5 teacher_pid6 teacher_pid7 teacher_pid8"
local text_fields11 "teacher_pid9 teacher_pid10 teacher_pid11 teacher_pid12 teacher_pid13 teacher_pid14 teacher_pid15 teacher_pid16 teacher_pid17 teacher_pid18 teacher_pid19 teacher_pid20 teacher_pid21 teacher_pid22"
local text_fields12 "teacher_pid23 teacher_pid24 teacher_pid25 teacher_pid26 teacher_pid27 teacher_pid28 teacher_pid29 teacher_pid30 teacher_pid31 teacher_pid32 teacher_pid33 teacher_pid34 teacher_pid35 teacher_pid36"
local text_fields13 "teacher_pid37 teacher_pid38 teacher_pid39 teacher_pid40 teacher_pid41 teacher_pid42 teacher_pid43 teacher_pid44 teacher_pid45 teacher_pid46 teacher_pid47 teacher_pid48 teacher_pid49 teacher_pid50"
local text_fields14 "teacher_pid51 teacher_pid52 teacher_pid53 teacher_pid54 teacher_pid55 teacher_pid56 teacher_pid57 teacher_pid58 teacher_pid59 teacher_pid60 teacher_pid61 teacher_pid62 teacher_pid63 teacher_pid64"
local text_fields15 "teacher_pid65 teacher_pid66 teacher_pid67 teacher_pid68 teacher_pid69 teacher_pid70 teacher_pid71 teacher_pid72 teacher_pid73 teacher_pid74 teacher_pid75 teacher_pid76 teacher_pid77 teacher_pid78"
local text_fields16 "teacher_pid79 teacher_pid80 teacher_pid81 teacher_pid82 teacher_pid83 teacher_pid84 teacher_pid85 teacher_pid86 teacher_pid87 teacher_pid88 teacher_pid89 teacher_pid90 teacher_pid91 teacher_pid92"
local text_fields17 "teacher_pid93 teacher_pid94 teacher_pid95 teacher_pid96 teacher_pid97 teacher_pid98 teacher_pid99 teacher_pid100 male_indices female_indices hteacher_index f_name_list0 m_name_list0 s_name_list0"
local text_fields18 "concat_names_list0 f_name_list1 m_name_list1 s_name_list1 concat_names_list1 school_location_desc consent_startdur position_cal consent_signature reason_refusal consent_enddur consent_duration"
local text_fields19 "modb_startdur f_name_moduleb m_name_moduleb s_name_moduleb concat_names_modb modb_b2 modb_b2_reenter airtime_no airtime_no_reenter year_16years_old educ_level_oth mared_living modb_b7a modb_enddur"
local text_fields20 "modb_duration modl_startdur modl_l18 modl_l23a modl_l23b modl_l24b modl_l24b_oth do_would modl_l24c_oth modl_l25b modl_l25b_oth modl_enddur modl_duration modc_startdur years_as_teacher"
local text_fields21 "months_as_teacher weeks_as_teacher modc_c2_cal modc_c2_oth modc_c3c_oth modc_c3f4 modc_c4 modc_c5 modc_c6 modc_c7 modc_c12 modc_c12_oth total_token modc_c15_oth modc_c15_ht modc_c16b modc_c16b_oth"
local text_fields22 "modm_m1 modc_c24 modm_m3a modm_m3b modc_enddur modc_duration gender gender2 are_is_cal have_has_cal do_does_cal was_were_cal she_you_cal workplace_cal you_they_cal your_their school_work_cal your_her"
local text_fields23 "you_she_cal you_her husband_wife mywife_i mywife_my formywife_blank mywife_blank youwife_she you_father inlaw_grandmother mother_inlaw wifegrandmother herself_myself my_her she_i modd_startdur"
local text_fields24 "child_name modd_d1_cal_month modd_d1_cal_year modd_d4 modd_d6b_explain modd_d8b_explain modd_d9b_explain modd_d11a_oth modd_d13d modd_d15 modd_d15_other modd_d15a modd_d15b modd_d15c modd_d15d"
local text_fields25 "modd_d16_f modd_d18b modd_d19a modd_d19a_oth modd_d20a modd_d20a_oth modd_d21b_f_oth modd_d29 modd_d34 modd_d34a modd_d34b modd_d34c modd_d34d modd_d36 modd_d37a modd_d37a_oth modd_d38_oth"
local text_fields26 "modd_d0_male modd_d1b_male modd_d4_male modd_d21b_male_other modd_d11a_male_other modd_d11b1_male modd_d13d_male modd_d14c_male modd_d15a_male modd_d15b_male modd_d15c_male modd_d15e_male"
local text_fields27 "modd_d19a_male modd_d19b_male modd_d20a_male modd_d20b_male modd_d34_male modd_d34a_male modd_d34b_male modd_d34c_male modd_d34d_male modd_enddur modd_duration modf_startdur modf_f20 randomdraw1"
local text_fields28 "randomdraw4 randomdraw5 modf_f13 modf_f14 modf_enddur modf_duration modg_startdur modg_g6 modg_enddur modg_duration modh_startdur modh_h0b modh_h2 modh_h2_oth modh_h5_oth modh_h8a modh_h8a1 modh_h8a2"
local text_fields29 "modh_h8b modh_h14_oth modh_h15_oth modh_enddur modh_duration modi_startdur modi_i1a1 modi_i1a2 modi_i1b1 modi_i1b2 modi_i3a modi_i4b modi_i4b_oth modi_i5b modi_enddur modi_duration modj_startdur"
local text_fields30 "modi_j1a1 modi_j1a2 modi_j1b1 modi_j1b2 modi_j1c_oth modi_j1d modj_j2c modj_j3b modj_j3b_oth modj_j4 modj_j4_oth modj_j9b modj_j11_oth modj_enddur modj_duration modk_startdur modk_k1a modk_k1_name"
local text_fields31 "modk_k2_name modk_k1a_reson modk_k2a_reson modk_k1b modk_k2b modk_k1b_reson modk_k2b_reson modk_k4a modk_k4a_oth modk_enddur modk_duration modm_startdur randomdraw2 modm_m6a_a modm_m6c_a modm_m6a_b"
local text_fields32 "modm_m6b_b modm_m6c_b randomdraw3 upload_picture modm_enddur modm_duration s_status_oth attempt_counter_pl attempt_counter completion_status survey_result final_comment instanceid"
local date_fields1 "modb_b3 modb_b6 modc_c0 modd_d1 modd_d1_male modh_h5a"
local datetime_fields1 "submissiondate starttime endtime"

disp
disp "Starting import of: `csvfile'"
disp

* import data from primary .csv file
insheet using "`csvfile'", names clear

* drop extra table-list columns
cap drop reserved_name_for_field_*
cap drop generated_table_list_lab*

* continue only if there's at least one row of data to import
if _N>0 {
	* drop note fields (since they don't contain any real data)
	forvalues i = 1/100 {
		if "`note_fields`i''" ~= "" {
			drop `note_fields`i''
		}
	}
	
	* format date and date/time fields
	forvalues i = 1/100 {
		if "`datetime_fields`i''" ~= "" {
			foreach dtvarlist in `datetime_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=clock(`tempdtvar',"DMYhms",2025)
						* automatically try without seconds, just in case
						cap replace `dtvar'=clock(`tempdtvar',"DMYhm",2025) if `dtvar'==. & `tempdtvar'~=""
						format %tc `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
		if "`date_fields`i''" ~= "" {
			foreach dtvarlist in `date_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=date(`tempdtvar',"DMY",2025)
						format %td `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
	}

	* ensure that text fields are always imported as strings (with "" for missing values)
	* (note that we treat "calculate" fields as text; you can destring later if you wish)
	tempvar ismissingvar
	quietly: gen `ismissingvar'=.
	forvalues i = 1/100 {
		if "`text_fields`i''" ~= "" {
			foreach svarlist in `text_fields`i'' {
				cap unab svarlist : `svarlist'
				if _rc==0 {
					foreach stringvar in `svarlist' {
						quietly: replace `ismissingvar'=.
						quietly: cap replace `ismissingvar'=1 if `stringvar'==.
						cap tostring `stringvar', format(%100.0g) replace
						cap replace `stringvar'="" if `ismissingvar'==1
					}
				}
			}
		}
	}
	quietly: drop `ismissingvar'


	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid


	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"
	cap label variable formdef_version "Form version used on device"
	cap label variable review_status "Review status"
	cap label variable review_comments "Comments made during review"
	cap label variable review_corrections "Corrections made during review"


	label variable school "ENUMERATOR: A1. Please select the type of school"
	note school: "ENUMERATOR: A1. Please select the type of school"

	label variable subcounty "A2. Select the Subcounty in Nairobi where the school is located"
	note subcounty: "A2. Select the Subcounty in Nairobi where the school is located"

	label variable school_name "ENUMERATOR: A3. Select the name of the school"
	note school_name: "ENUMERATOR: A3. Select the name of the school"

	label variable id "ENUMERATOR: A4. Enter the school id"
	note id: "ENUMERATOR: A4. Enter the school id"

	label variable enum_name "A5. Enumerator's Name"
	note enum_name: "A5. Enumerator's Name"
	label define enum_name 91793 "Jael Awuor Mumbo" 91929 "Rhoda Syonthi Munyau" 90964 "Teresa Mahungu Orachi" 92189 "Faithjully Akinyi Jagero" 92068 "Margaret Nambiro Nyende" 90697 "Quinter Anyango Owaga" 91955 "Scovia Adhiambo Owini" 90957 "Cynthia Akinyi Juma" 92092 "Turphena Akinyi Mola" 90775 "Winnie Teresa Anyango" 91753 "Jessica Ondeche" 92152 "Timinah Mwawuda" 91366 "Phoebe Tata" 1234 "Aisha Sophia"
	label values enum_name enum_name

	label variable enum_id "A6. Enumerator's ID"
	note enum_id: "A6. Enumerator's ID"

	label variable internet_issue "ENUMERATOR: Was there internet connectivity issues that prevented you from submi"
	note internet_issue: "ENUMERATOR: Was there internet connectivity issues that prevented you from submitting the school's listing survey?"
	label define internet_issue 1 "Yes" 0 "No"
	label values internet_issue internet_issue

	label variable teacher_list "ENUMERATOR: Please select the name of the teacher whom you are speaking to"
	note teacher_list: "ENUMERATOR: Please select the name of the teacher whom you are speaking to"
	label define teacher_list 1 "\${teacher_pid1},\${teachername_1}" 2 "\${teacher_pid2},\${teachername_2}" 3 "\${teacher_pid3},\${teachername_3}" 4 "\${teacher_pid4},\${teachername_4}" 5 "\${teacher_pid5},\${teachername_5}" 6 "\${teacher_pid6},\${teachername_6}" 7 "\${teacher_pid7},\${teachername_7}" 8 "\${teacher_pid8},\${teachername_8}" 9 "\${teacher_pid9},\${teachername_9}" 10 "\${teacher_pid10},\${teachername_10}" 11 "\${teacher_pid11},\${teachername_11}" 12 "\${teacher_pid12},\${teachername_12}" 13 "\${teacher_pid13},\${teachername_13}" 14 "\${teacher_pid14},\${teachername_14}" 15 "\${teacher_pid15},\${teachername_15}" 16 "\${teacher_pid16},\${teachername_16}" 17 "\${teacher_pid17},\${teachername_17}" 18 "\${teacher_pid18},\${teachername_18}" 19 "\${teacher_pid19},\${teachername_19}" 20 "\${teacher_pid20},\${teachername_20}" 21 "\${teacher_pid21},\${teachername_21}" 22 "\${teacher_pid22},\${teachername_22}" 23 "\${teacher_pid23},\${teachername_23}" 24 "\${teacher_pid24},\${teachername_24}" 25 "\${teacher_pid25},\${teachername_25}" 26 "\${teacher_pid26},\${teachername_26}" 27 "\${teacher_pid27},\${teachername_27}" 28 "\${teacher_pid28},\${teachername_28}" 29 "\${teacher_pid29},\${teachername_29}" 30 "\${teacher_pid30},\${teachername_30}" 31 "\${teacher_pid31},\${teachername_31}" 32 "\${teacher_pid32},\${teachername_32}" 33 "\${teacher_pid33},\${teachername_33}" 34 "\${teacher_pid34},\${teachername_34}" 35 "\${teacher_pid35},\${teachername_35}" 36 "\${teacher_pid36},\${teachername_36}" 37 "\${teacher_pid37},\${teachername_37}" 38 "\${teacher_pid38},\${teachername_38}" 39 "\${teacher_pid39},\${teachername_39}" 40 "\${teacher_pid40},\${teachername_40}" 41 "\${teacher_pid41},\${teachername_41}" 42 "\${teacher_pid42},\${teachername_42}" 43 "\${teacher_pid43},\${teachername_43}" 44 "\${teacher_pid44},\${teachername_44}" 45 "\${teacher_pid45},\${teachername_45}" 46 "\${teacher_pid46},\${teachername_46}" 47 "\${teacher_pid47},\${teachername_47}" 48 "\${teacher_pid48},\${teachername_48}" 49 "\${teacher_pid49},\${teachername_49}" 50 "\${teacher_pid50},\${teachername_50}" 51 "\${teacher_pid51},\${teachername_51}" 52 "\${teacher_pid52},\${teachername_52}" 53 "\${teacher_pid53},\${teachername_53}" 54 "\${teacher_pid54},\${teachername_54}" 55 "\${teacher_pid55},\${teachername_55}" 56 "\${teacher_pid56},\${teachername_56}" 57 "\${teacher_pid57},\${teachername_57}" 58 "\${teacher_pid58},\${teachername_58}" 59 "\${teacher_pid59},\${teachername_59}" 60 "\${teacher_pid60},\${teachername_60}" 61 "\${teacher_pid61},\${teachername_61}" 62 "\${teacher_pid62},\${teachername_62}" 63 "\${teacher_pid63},\${teachername_63}" 64 "\${teacher_pid64},\${teachername_64}" 65 "\${teacher_pid65},\${teachername_65}" 66 "\${teacher_pid66},\${teachername_66}" 67 "\${teacher_pid67},\${teachername_67}" 68 "\${teacher_pid68},\${teachername_68}" 69 "\${teacher_pid69},\${teachername_69}" 70 "\${teacher_pid70},\${teachername_70}" 71 "\${teacher_pid71},\${teachername_71}" 72 "\${teacher_pid72},\${teachername_72}" 73 "\${teacher_pid73},\${teachername_73}" 74 "\${teacher_pid74},\${teachername_74}" 75 "\${teacher_pid75},\${teachername_75}" 76 "\${teacher_pid76},\${teachername_76}" 77 "\${teacher_pid77},\${teachername_77}" 78 "\${teacher_pid78},\${teachername_78}" 79 "\${teacher_pid79},\${teachername_79}" 80 "\${teacher_pid80},\${teachername_80}" 81 "\${teacher_pid81},\${teachername_81}" 82 "\${teacher_pid82},\${teachername_82}" 83 "\${teacher_pid83},\${teachername_83}" 84 "\${teacher_pid84},\${teachername_84}" 85 "\${teacher_pid85},\${teachername_85}" 86 "\${teacher_pid86},\${teachername_86}" 87 "\${teacher_pid87},\${teachername_87}" 88 "\${teacher_pid88},\${teachername_88}" 89 "\${teacher_pid89},\${teachername_89}" 90 "\${teacher_pid90},\${teachername_90}" 91 "\${teacher_pid91},\${teachername_91}" 92 "\${teacher_pid92},\${teachername_92}" 93 "\${teacher_pid93},\${teachername_93}" 94 "\${teacher_pid94},\${teachername_94}" 95 "\${teacher_pid95},\${teachername_95}" 96 "\${teacher_pid96},\${teachername_96}" 97 "\${teacher_pid97},\${teachername_97}" 98 "\${teacher_pid98},\${teachername_98}" 99 "\${teacher_pid99},\${teachername_99}" 100 "\${teacher_pid100},\${teachername_100}"
	label values teacher_list teacher_list

	label variable teacher_id "Enter the id of the teacher"
	note teacher_id: "Enter the id of the teacher"

	label variable f_name_list0 "a. First name"
	note f_name_list0: "a. First name"

	label variable m_name_list0 "b. Middle name"
	note m_name_list0: "b. Middle name"

	label variable s_name_list0 "c. Surname"
	note s_name_list0: "c. Surname"

	label variable f_name_list1 "a. First name"
	note f_name_list1: "a. First name"

	label variable m_name_list1 "b. Middle name"
	note m_name_list1: "b. Middle name"

	label variable s_name_list1 "c. Surname"
	note s_name_list1: "c. Surname"

	label variable teacher_id2 "Enter the id of the teacher"
	note teacher_id2: "Enter the id of the teacher"

	label variable teacher_id2_reenter "Re-enter the the id of the teacher"
	note teacher_id2_reenter: "Re-enter the the id of the teacher"

	label variable school_location_desc "A10. Please record the description of the location of the school"
	note school_location_desc: "A10. Please record the description of the location of the school"

	label variable school_gpslatitude "A11. Record the GPS coordinates of the school (latitude)"
	note school_gpslatitude: "A11. Record the GPS coordinates of the school (latitude)"

	label variable school_gpslongitude "A11. Record the GPS coordinates of the school (longitude)"
	note school_gpslongitude: "A11. Record the GPS coordinates of the school (longitude)"

	label variable school_gpsaltitude "A11. Record the GPS coordinates of the school (altitude)"
	note school_gpsaltitude: "A11. Record the GPS coordinates of the school (altitude)"

	label variable school_gpsaccuracy "A11. Record the GPS coordinates of the school (accuracy)"
	note school_gpsaccuracy: "A11. Record the GPS coordinates of the school (accuracy)"

	label variable availability "Is the teacher available to be interviewed now?"
	note availability: "Is the teacher available to be interviewed now?"
	label define availability 1 "Yes" 0 "No"
	label values availability availability

	label variable position "B1a. What is your position in the institution?"
	note position: "B1a. What is your position in the institution?"
	label define position 1 "Headteacher" 2 "Deputy head teacher" 3 "Senior teacher" 4 "Teacher"
	label values position position

	label variable survey_type "ENUMERATOR: Which survey are you conducting: teacher survey or headteacher surve"
	note survey_type: "ENUMERATOR: Which survey are you conducting: teacher survey or headteacher survey?"
	label define survey_type 1 "Headteacher survey" 2 "Teacher survey"
	label values survey_type survey_type

	label variable consented "If I have answered all your questions, do you agree to participate in this study"
	note consented: "If I have answered all your questions, do you agree to participate in this study?"
	label define consented 1 "Yes" 0 "No"
	label values consented consented

	label variable recording "Thank you. As mentioned above, during this survey you may be audio recorded for "
	note recording: "Thank you. As mentioned above, during this survey you may be audio recorded for quality assurance purposes. You and the person interviewing you will both not know when this recording may happen. The audio recording may only happen if you consent to it and you will not be recorded against your will. This recording will only be used for data quality assurance purposes. Do you consent to a possible audio recording?"
	label define recording 1 "Yes" 0 "No"
	label values recording recording

	label variable consent_signature "Please sign your name/mark as your permission to participate."
	note consent_signature: "Please sign your name/mark as your permission to participate."

	label variable reason_refusal "May I ask why you do not wish to participate?"
	note reason_refusal: "May I ask why you do not wish to participate?"

	label variable f_name_moduleb "a. First name"
	note f_name_moduleb: "a. First name"

	label variable m_name_moduleb "b. Middle name"
	note m_name_moduleb: "b. Middle name"

	label variable s_name_moduleb "a. Surname"
	note s_name_moduleb: "a. Surname"

	label variable tsc_number "What is your TSC number?"
	note tsc_number: "What is your TSC number?"

	label variable modb_b2 "B2. What is you phone number?"
	note modb_b2: "B2. What is you phone number?"

	label variable modb_b2_reenter "B2b. Re-enter phone number"
	note modb_b2_reenter: "B2b. Re-enter phone number"

	label variable modb_b2_whatsapp "B2c. Do you have whatsapp on this phone number?"
	note modb_b2_whatsapp: "B2c. Do you have whatsapp on this phone number?"
	label define modb_b2_whatsapp 1 "Yes" 2 "No" -999 "I don't know"
	label values modb_b2_whatsapp modb_b2_whatsapp

	label variable airtime_confirm "Is this the number we should use to send you airtime?"
	note airtime_confirm: "Is this the number we should use to send you airtime?"
	label define airtime_confirm 1 "Yes" 0 "No"
	label values airtime_confirm airtime_confirm

	label variable airtime_no "Which number should we use to send you airtime?"
	note airtime_no: "Which number should we use to send you airtime?"

	label variable airtime_no_reenter "Re-enter the number we should use to send you airtime"
	note airtime_no_reenter: "Re-enter the number we should use to send you airtime"

	label variable service_provider "ENUMERATOR: Select the service provider of the number we should use to send airt"
	note service_provider: "ENUMERATOR: Select the service provider of the number we should use to send airtime"
	label define service_provider 1 "Safaricom" 2 "Airtel" 3 "Telkom"
	label values service_provider service_provider

	label variable modb_b3 "B3. What's your date of birth?"
	note modb_b3: "B3. What's your date of birth?"

	label variable modb_b4 "B4.What's the highest educational level you achieved?"
	note modb_b4: "B4.What's the highest educational level you achieved?"
	label define modb_b4 1 "Primary" 2 "Secondary" 3 "Post-secondary, vocational" 4 "College (certificate-level)" 5 "College (diploma-level)" 6 "University undergraduate" 7 "University postgraduate" -777 "Other Specify"
	label values modb_b4 modb_b4

	label variable educ_level_oth "Specify the highest level of education achieved"
	note educ_level_oth: "Specify the highest level of education achieved"

	label variable modb_b5 "B5. What is your marriage status?"
	note modb_b5: "B5. What is your marriage status?"
	label define modb_b5 1 "Married monogamous" 2 "Married polygamous" 3 "Living together" 4 "Separated" 5 "Divorced" 6 "Widow or widower" 7 "Never married"
	label values modb_b5 modb_b5

	label variable modb_b6 "B6. When did \${mared_living}"
	note modb_b6: "B6. When did \${mared_living}"

	label variable modb_b7a "B7a. What does your partner do for a living?"
	note modb_b7a: "B7a. What does your partner do for a living?"

	label variable modb_b7b "B7b. How many individuals live in your household? ( do not include the househelp"
	note modb_b7b: "B7b. How many individuals live in your household? ( do not include the househelp/nanny)"

	label variable modb_b8a "B8a. What is your household's total gross monthly income?"
	note modb_b8a: "B8a. What is your household's total gross monthly income?"
	label define modb_b8a 1 "LESS THAN KSh 20.000" 2 "KSh 20.000 - 40.000" 3 "KSh 40.001 - 60.000" 4 "KSh 60.001 - 80.000" 5 "KSh 80.001 - 100.000" 6 "KSh 100.001 - 120.000" 7 "KSh 120.001 - 140.000" 8 "KSh 140.001 - 160.000" 9 "KSh 160.001 - 180.000" 10 "KSh 180.001 - 200.000" 11 "ABOVE KSh 200.001"
	label values modb_b8a modb_b8a

	label variable modb_b8b "B8b. What is your gross monthly wage on average?"
	note modb_b8b: "B8b. What is your gross monthly wage on average?"
	label define modb_b8b 1 "LESS THAN KSh 10.000" 2 "KSh 10.000 - 20.000" 3 "KSh 20.001 - 30.000" 4 "KSh 30.001 - 40.000" 5 "KSh 40.001 - 50.000" 6 "KSh 50.001 - 60.000" 7 "KSh 60.001 - 70.000" 8 "KSh 70.001 - 80.000" 9 "KSh 80.001 - 90.000" 10 "KSh 90.001 - 100.000" 11 "ABOVE KSh 100.000"
	label values modb_b8b modb_b8b

	label variable modb_b9 "B9. ENUMERATOR: What's the respondent's gender?"
	note modb_b9: "B9. ENUMERATOR: What's the respondent's gender?"
	label define modb_b9 1 "Male" 0 "Female"
	label values modb_b9 modb_b9

	label variable modb_b10_filtre "B10a. Do you have biological children?"
	note modb_b10_filtre: "B10a. Do you have biological children?"
	label define modb_b10_filtre 1 "Yes" 0 "No"
	label values modb_b10_filtre modb_b10_filtre

	label variable modb_b10b "B10b. How many biological children do you have?"
	note modb_b10b: "B10b. How many biological children do you have?"

	label variable modb_b10c "B10c. Do you plan to have others?"
	note modb_b10c: "B10c. Do you plan to have others?"
	label define modb_b10c 1 "Yes" 0 "No"
	label values modb_b10c modb_b10c

	label variable modb_b10d "B10d. How many other children do you plan to have?"
	note modb_b10d: "B10d. How many other children do you plan to have?"

	label variable modb_b10b_check "ENUMERATOR: On the last screen you entered that the respondent has \${modb_b10b}"
	note modb_b10b_check: "ENUMERATOR: On the last screen you entered that the respondent has \${modb_b10b} number of children. This number seems very high. Please confirm that it is correct"
	label define modb_b10b_check 1 "Yes" 0 "No"
	label values modb_b10b_check modb_b10b_check

	label variable modd_d27 "D27. Do you plan to have biological children?"
	note modd_d27: "D27. Do you plan to have biological children?"
	label define modd_d27 1 "Yes" 0 "No"
	label values modd_d27 modd_d27

	label variable modd_d27a "D27a. How many do you plan to have?"
	note modd_d27a: "D27a. How many do you plan to have?"

	label variable modd_d27_male "D27. Do you plan to have biological children?"
	note modd_d27_male: "D27. Do you plan to have biological children?"
	label define modd_d27_male 1 "Yes" 0 "No"
	label values modd_d27_male modd_d27_male

	label variable modd_d27a_male "D27. How many do you plan to have?"
	note modd_d27a_male: "D27. How many do you plan to have?"

	label variable modb_b11 "B11. Do you have running water at home?"
	note modb_b11: "B11. Do you have running water at home?"
	label define modb_b11 1 "Yes" 0 "No"
	label values modb_b11 modb_b11

	label variable modb_b11b "B11b. Is the water in your home safe to drink without being boiled first?"
	note modb_b11b: "B11b. Is the water in your home safe to drink without being boiled first?"
	label define modb_b11b 1 "Yes" 0 "No"
	label values modb_b11b modb_b11b

	label variable modb_b12 "B12. Do you have electricity at home?"
	note modb_b12: "B12. Do you have electricity at home?"
	label define modb_b12 1 "Yes" 0 "No"
	label values modb_b12 modb_b12

	label variable modb_b13 "B13. Do you have a fridge at home?"
	note modb_b13: "B13. Do you have a fridge at home?"
	label define modb_b13 1 "Yes" 0 "No"
	label values modb_b13 modb_b13

	label variable modb_b14 "B14. Do you own a car in your household?"
	note modb_b14: "B14. Do you own a car in your household?"
	label define modb_b14 1 "Yes" 0 "No"
	label values modb_b14 modb_b14

	label variable modl_l1 "L1. How many students are there in this school?"
	note modl_l1: "L1. How many students are there in this school?"

	label variable modl_l1_check "ENUMERATOR: On the last screen you entered that the school has \${modl_l1} numbe"
	note modl_l1_check: "ENUMERATOR: On the last screen you entered that the school has \${modl_l1} number of students. This number seems low. Please confirm that it is correct"
	label define modl_l1_check 1 "Yes" 0 "No"
	label values modl_l1_check modl_l1_check

	label variable modl_l1b1 "Number of women:"
	note modl_l1b1: "Number of women:"

	label variable modl_l1b2 "Number of men:"
	note modl_l1b2: "Number of men:"

	label variable modl_l1c1 "Number of women:"
	note modl_l1c1: "Number of women:"

	label variable modl_l1c2 "Number of men:"
	note modl_l1c2: "Number of men:"

	label variable modl_l7 "L7.Currently, how many teachers are pregnant?"
	note modl_l7: "L7.Currently, how many teachers are pregnant?"

	label variable modl_l8 "L8. In this week, how many teachers are on maternity leave?"
	note modl_l8: "L8. In this week, how many teachers are on maternity leave?"

	label variable modl_l9 "L9. How many classrooms are there in this school?"
	note modl_l9: "L9. How many classrooms are there in this school?"

	label variable modl_l9_check "ENUMERATOR: On the last screen you entered that the school has \${modl_l9} numbe"
	note modl_l9_check: "ENUMERATOR: On the last screen you entered that the school has \${modl_l9} number of classrooms. This number seems low. Please confirm that it is correct"
	label define modl_l9_check 1 "Yes" 0 "No"
	label values modl_l9_check modl_l9_check

	label variable modl_l10 "L10. Is there running water in this school?"
	note modl_l10: "L10. Is there running water in this school?"
	label define modl_l10 1 "Yes" 0 "No"
	label values modl_l10 modl_l10

	label variable modl_l11 "L11. Is there electricity in this school?"
	note modl_l11: "L11. Is there electricity in this school?"
	label define modl_l11 1 "Yes" 0 "No"
	label values modl_l11 modl_l11

	label variable modl_l12 "L12. Are toilets for the staff separated from the students' toilets in this scho"
	note modl_l12: "L12. Are toilets for the staff separated from the students' toilets in this school?"
	label define modl_l12 1 "Yes" 0 "No"
	label values modl_l12 modl_l12

	label variable modl_l13 "L13. How many toilets do you have for students in this school?"
	note modl_l13: "L13. How many toilets do you have for students in this school?"

	label variable modl_l14 "L14. How many toilets do you have for staff in this school?"
	note modl_l14: "L14. How many toilets do you have for staff in this school?"

	label variable modl_l15 "L15. How many toilets do you have for staff and students in this school?"
	note modl_l15: "L15. How many toilets do you have for staff and students in this school?"

	label variable modl_l16 "L16. Are the toilets used by the staff separated by gender?"
	note modl_l16: "L16. Are the toilets used by the staff separated by gender?"
	label define modl_l16 1 "Yes" 0 "No"
	label values modl_l16 modl_l16

	label variable modl_l16a "L16a. Do you think there is enough space for classrooms in this school?"
	note modl_l16a: "L16a. Do you think there is enough space for classrooms in this school?"
	label define modl_l16a 1 "Yes, there is enough space" 2 "No, there is not enough space"
	label values modl_l16a modl_l16a

	label variable modl_l16b "L16b. Do you think there is enough extra space for staff in this school?"
	note modl_l16b: "L16b. Do you think there is enough extra space for staff in this school?"
	label define modl_l16b 1 "Yes, there is enough space" 2 "No, there is not enough space"
	label values modl_l16b modl_l16b

	label variable modl_l17 "L17. Have you ever received a visit from a Ministry of Health inspector since yo"
	note modl_l17: "L17. Have you ever received a visit from a Ministry of Health inspector since you started working as a headteacher in this school?"
	label define modl_l17 1 "Yes" 0 "No"
	label values modl_l17 modl_l17

	label variable modl_l18 "L18. What did they check?"
	note modl_l18: "L18. What did they check?"

	label variable modl_l23a "L23a. Suppose you receive a donation of 50,000KSH for improvements in the school"
	note modl_l23a: "L23a. Suppose you receive a donation of 50,000KSH for improvements in the school. How would you use the money?"

	label variable modl_l23b "L23b. What are the steps you should take to implement this project?"
	note modl_l23b: "L23b. What are the steps you should take to implement this project?"

	label variable modl_l23 "L23. Suppose you receive a donation of 50,000KSH for any type of improvement in "
	note modl_l23: "L23. Suppose you receive a donation of 50,000KSH for any type of improvement in the school. Do you agree with the following statement: 'It would be a good idea to use the money to set up a lactation room for the teachers and staff rather than for some other improvements'?"
	label define modl_l23 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree"
	label values modl_l23 modl_l23

	label variable modl_l24a "L24a. Do you ever allow your teachers to leave early to go home or to come in la"
	note modl_l24a: "L24a. Do you ever allow your teachers to leave early to go home or to come in late?"
	label define modl_l24a 1 "Yes, anytime that they ask" 2 "Yes, most of the time that they ask" 3 "Yes, but rarely" 4 "No, never"
	label values modl_l24a modl_l24a

	label variable modl_l24b "L24b. Under what circumstances WOULD you allow teachers to leave early or to arr"
	note modl_l24b: "L24b. Under what circumstances WOULD you allow teachers to leave early or to arrive late?"

	label variable modl_l24b_oth "Please specify the other reasons:"
	note modl_l24b_oth: "Please specify the other reasons:"

	label variable modl_l24c "L24c. Do you ever take into account the teacher's family situation when deciding"
	note modl_l24c: "L24c. Do you ever take into account the teacher's family situation when deciding on the timetable?"
	label define modl_l24c 1 "Yes" 0 "No"
	label values modl_l24c modl_l24c

	label variable modl_l24c_oth "L24d. If yes, how?"
	note modl_l24c_oth: "L24d. If yes, how?"

	label variable modl_l25a "L25a. Are you part of any union and/or association of headteachers?"
	note modl_l25a: "L25a. Are you part of any union and/or association of headteachers?"
	label define modl_l25a 1 "Yes" 0 "No"
	label values modl_l25a modl_l25a

	label variable modl_l25b "L25b. Which union and/or association of teachers do you belong to?"
	note modl_l25b: "L25b. Which union and/or association of teachers do you belong to?"

	label variable modl_l25b_oth "Specify the other headteacher association/union that you belong to"
	note modl_l25b_oth: "Specify the other headteacher association/union that you belong to"

	label variable modl_l25c "L25c. Are you a union representative in this school?"
	note modl_l25c: "L25c. Are you a union representative in this school?"
	label define modl_l25c 1 "Yes" 0 "No"
	label values modl_l25c modl_l25c

	label variable modl_l25d "L25d. How confortable would you be in asking one of your teachers to take on mor"
	note modl_l25d: "L25d. How confortable would you be in asking one of your teachers to take on more responsibilities on matters that influence the whole school?"
	label define modl_l25d 1 "Very comfortable" 2 "Indifferent" 3 "Not comfortable"
	label values modl_l25d modl_l25d

	label variable modl_l25e "L25e. To what extent do you agree with the following statement 'In this school, "
	note modl_l25e: "L25e. To what extent do you agree with the following statement 'In this school, sometimes there are disagreements between colleagues'."
	label define modl_l25e 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree"
	label values modl_l25e modl_l25e

	label variable modc_c0 "C0. In which year did you start to work as a teacher?"
	note modc_c0: "C0. In which year did you start to work as a teacher?"

	label variable modc_c1a "a. Number"
	note modc_c1a: "a. Number"

	label variable modc_c1b "b. Unit of time"
	note modc_c1b: "b. Unit of time"
	label define modc_c1b 1 "Weeks" 2 "Months" 3 "Years"
	label values modc_c1b modc_c1b

	label variable modc_c2 "C2. What type of employment contract do you have?"
	note modc_c2: "C2. What type of employment contract do you have?"
	label define modc_c2 1 "Teacher- TSC" 2 "Teacher- intern/praticum/ on practice" 3 "Teacher- board of directors" 4 "County Government (eg ECD teacher)" 5 "Contract with the school" -777 "Other Specify"
	label values modc_c2 modc_c2

	label variable modc_c2_oth "Specify the contract"
	note modc_c2_oth: "Specify the contract"

	label variable modc_c3a "a. Number"
	note modc_c3a: "a. Number"

	label variable modc_c3b "b. Unit of time"
	note modc_c3b: "b. Unit of time"
	label define modc_c3b 1 "Weeks" 2 "Months" 3 "Years"
	label values modc_c3b modc_c3b

	label variable modc_c3c "C3c. Is there any additional role that you have in the school?"
	note modc_c3c: "C3c. Is there any additional role that you have in the school?"
	label define modc_c3c 1 "Yes" 0 "No"
	label values modc_c3c modc_c3c

	label variable modc_c3c_oth "Please specify the additional role"
	note modc_c3c_oth: "Please specify the additional role"

	label variable modc_c3d "C3d. In this term, what time is your earliest class? Consider both regular class"
	note modc_c3d: "C3d. In this term, what time is your earliest class? Consider both regular classes or remedial classes."

	label variable modc_c3e "C3e. In this term, what time is your latest class? Consider both regular classes"
	note modc_c3e: "C3e. In this term, what time is your latest class? Consider both regular classes or remedial classes."

	label variable modc_c3f "C3f. Would you make any changes to your timetable?"
	note modc_c3f: "C3f. Would you make any changes to your timetable?"
	label define modc_c3f 1 "Yes" 0 "No"
	label values modc_c3f modc_c3f

	label variable modc_c3f1 "Start at:"
	note modc_c3f1: "Start at:"

	label variable modc_c3f2 "Finish at:"
	note modc_c3f2: "Finish at:"

	label variable modc_c3f3 "Teach _ days a week:"
	note modc_c3f3: "Teach _ days a week:"

	label variable modc_c3f4 "Would you make any other change?"
	note modc_c3f4: "Would you make any other change?"

	label variable modc_c4 "C4. Think about a typical working day. At what time do you typically leave your "
	note modc_c4: "C4. Think about a typical working day. At what time do you typically leave your home to get to school?"

	label variable modc_c5 "C5. At what time do you typically arrive at school?"
	note modc_c5: "C5. At what time do you typically arrive at school?"

	label variable modc_c6 "C6. At what time do you typically leave school?"
	note modc_c6: "C6. At what time do you typically leave school?"

	label variable modc_c7 "C7. At what time do you typically arrive home?"
	note modc_c7: "C7. At what time do you typically arrive home?"

	label variable modc_c12 "C12. How typically do you get to school?"
	note modc_c12: "C12. How typically do you get to school?"

	label variable modc_c12_oth "Specify the other means you use to get to school"
	note modc_c12_oth: "Specify the other means you use to get to school"

	label variable modc_c8a "C8a. Do you sometime work also from home (for example, to grade homeworks/exams)"
	note modc_c8a: "C8a. Do you sometime work also from home (for example, to grade homeworks/exams)?"
	label define modc_c8a 1 "Yes" 0 "No"
	label values modc_c8a modc_c8a

	label variable modc_c8b "C8b. On average, how many hours do you work from home each week?"
	note modc_c8b: "C8b. On average, how many hours do you work from home each week?"

	label variable modc_c8c "C8c. Do you think that the HT should take into account teachers' family needs wh"
	note modc_c8c: "C8c. Do you think that the HT should take into account teachers' family needs when deciding the timetable? For instance, to give early classes to those teachers with less family needs."
	label define modc_c8c 1 "Yes" 0 "No"
	label values modc_c8c modc_c8c

	label variable modc_c8d "C8d. Does the HT do it?"
	note modc_c8d: "C8d. Does the HT do it?"
	label define modc_c8d 1 "Yes" 0 "No"
	label values modc_c8d modc_c8d

	label variable modc_c9 "C9. Do you have managerial responsibilities?"
	note modc_c9: "C9. Do you have managerial responsibilities?"
	label define modc_c9 1 "Yes" 0 "No"
	label values modc_c9 modc_c9

	label variable modc_c9b "C9b. How many people do you supervise?"
	note modc_c9b: "C9b. How many people do you supervise?"

	label variable modc_c11a "C11a. Have you ever been invited to take part into one of the Board of Managemen"
	note modc_c11a: "C11a. Have you ever been invited to take part into one of the Board of Management meetings?"
	label define modc_c11a 1 "Yes, I am part of the BoM" 2 "Yes, occasionally I am invited" 3 "No, I have never been invited"
	label values modc_c11a modc_c11a

	label variable proximity "a. Proximity to home"
	note proximity: "a. Proximity to home"

	label variable flexi_work "b. Availability of flexible working arrangements"
	note flexi_work: "b. Availability of flexible working arrangements"

	label variable lac_rooms "c. Availability of a lactation room for mothers"
	note lac_rooms: "c. Availability of a lactation room for mothers"

	label variable nursery "d. Availability of a nursery at the workplace"
	note nursery: "d. Availability of a nursery at the workplace"

	label variable h_salary "e. High salary"
	note h_salary: "e. High salary"

	label variable f_progresion "f. Fast career progression"
	note f_progresion: "f. Fast career progression"

	label variable social_impact "g. Positive social impact"
	note social_impact: "g. Positive social impact"

	label variable rel_coleagues "h. Good relationships with colleagues"
	note rel_coleagues: "h. Good relationships with colleagues"

	label variable modc_c14 "C14. How long do you plan to continue working in this school?"
	note modc_c14: "C14. How long do you plan to continue working in this school?"
	label define modc_c14 1 "Less than one year" 2 "1 to 2 years" 3 "3 to 4 years" 4 "5 to 10 years" 5 "I intend to stay here for all my career"
	label values modc_c14 modc_c14

	label variable modc_c15 "C15. How would you describe your career aspirations for the next 5 years?"
	note modc_c15: "C15. How would you describe your career aspirations for the next 5 years?"
	label define modc_c15 1 "I'd like to stay in my current role" 2 "I'd like to become a union representative in this school within 5 years from now" 3 "I'd like to become a union leader within 5 years from now" 4 "I'd like to become a head teacher within 5 years from now" 5 "I'd like to become a senior head teacher within 5 years from now" 6 "I'd like to stay in current job with high salary" 8 "I'd like to expand my school" -777 "Other specify"
	label values modc_c15 modc_c15

	label variable modc_c15_oth "Specify the career aspiration"
	note modc_c15_oth: "Specify the career aspiration"

	label variable modc_c15_ht "C15. How would you describe your career aspirations for the next 5 years?"
	note modc_c15_ht: "C15. How would you describe your career aspirations for the next 5 years?"

	label variable modc_c16a "C16a. Are you part of any union and/or association of teachers?"
	note modc_c16a: "C16a. Are you part of any union and/or association of teachers?"
	label define modc_c16a 1 "Yes" 0 "No"
	label values modc_c16a modc_c16a

	label variable modc_c16b "C16b. Which union and/or association of teachers do you belong to?"
	note modc_c16b: "C16b. Which union and/or association of teachers do you belong to?"

	label variable modc_c16b_oth "Specify the other union/association"
	note modc_c16b_oth: "Specify the other union/association"

	label variable modc_c17 "C17. Are you a union representative for other teachers in this school?"
	note modc_c17: "C17. Are you a union representative for other teachers in this school?"
	label define modc_c17 1 "Yes" 0 "No"
	label values modc_c17 modc_c17

	label variable modc_c18 "C18. Have you ever heard of the Kenya Association for Breastfeeding?"
	note modc_c18: "C18. Have you ever heard of the Kenya Association for Breastfeeding?"
	label define modc_c18 1 "Yes, I am a member" 2 "Yes, I know some members" 3 "Yes, I heard of it but I don't know any member" 4 "No, I haven't heard of it"
	label values modc_c18 modc_c18

	label variable modc_c20 "C20. Overall, how satisfied are you with your work nowadays? 1=Not satisfied at "
	note modc_c20: "C20. Overall, how satisfied are you with your work nowadays? 1=Not satisfied at all, 10 =Very satisfied"

	label variable modc_c21 "C21. Overall, would you recommend to family and friends this school as a great p"
	note modc_c21: "C21. Overall, would you recommend to family and friends this school as a great place to work? 1=Not at all, 10=Absolutely"

	label variable modc_c22 "C22. Overall, how satisfied are you with the relationship with your colleagues? "
	note modc_c22: "C22. Overall, how satisfied are you with the relationship with your colleagues? 1=Not satisfied at all, 10=Very satisfied"

	label variable modc_c23 "C23. Overall, how satisfied are you with the facilities available to you in this"
	note modc_c23: "C23. Overall, how satisfied are you with the facilities available to you in this school? 1 = Not satisfied at all, 10 = Very satisfied"

	label variable modm_m1 "M1. What do you think are the most important problems at your school that you wo"
	note modm_m1: "M1. What do you think are the most important problems at your school that you would like to be solved?"

	label variable modc_c24 "C24. Suppose you receive a donation of 50,000KSH for improvements in the school."
	note modc_c24: "C24. Suppose you receive a donation of 50,000KSH for improvements in the school. How would you use the money?"

	label variable modm_m3 "M3. Overall, how supportive of mothers’ needs do you think is your workplace?"
	note modm_m3: "M3. Overall, how supportive of mothers’ needs do you think is your workplace?"
	label define modm_m3 4 "Very supportive" 3 "Somewhat supportive" 2 "Not very Supportive" 1 "Not Supportive at all"
	label values modm_m3 modm_m3

	label variable modm_m3a "M3a. What do you think are the biggest challenges that female teachers face when"
	note modm_m3a: "M3a. What do you think are the biggest challenges that female teachers face when coming back from maternity leave?"

	label variable modm_m3b "M3b. What do other teachers in this school do to help them?"
	note modm_m3b: "M3b. What do other teachers in this school do to help them?"

	label variable child_name "D0. What is the name of your youngest child?"
	note child_name: "D0. What is the name of your youngest child?"

	label variable modd_d1 "D1. When was \${child_name} born?"
	note modd_d1: "D1. When was \${child_name} born?"

	label variable modd_d2 "D2. What is \${child_name}'s gender?"
	note modd_d2: "D2. What is \${child_name}'s gender?"
	label define modd_d2 1 "Male" 0 "Female"
	label values modd_d2 modd_d2

	label variable modd_d3 "D3. Did \${gender2} ever breastfeed \${child_name} (or feed \${child_name} \${yo"
	note modd_d3: "D3. Did \${gender2} ever breastfeed \${child_name} (or feed \${child_name} \${your_their} pumped milk)?"
	label define modd_d3 1 "Yes, breastfeeding" 2 "Yes, pumped milk" 3 "Both (breastfeeding and pumped milk)" 4 "None of the above"
	label values modd_d3 modd_d3

	label variable modd_d4 "D4. Did \${gender2} ever breastfeed this baby at \${your_their} workplace or exp"
	note modd_d4: "D4. Did \${gender2} ever breastfeed this baby at \${your_their} workplace or expressed \${your_her} milk at the workplace to later feed your baby?"

	label variable modd_d5_filtre "D5a. \${are_is_cal} \${gender2} still feeding \${child_name} with breastmilk? CH"
	note modd_d5_filtre: "D5a. \${are_is_cal} \${gender2} still feeding \${child_name} with breastmilk? CHILD AGE: \${modd_d1_cal_year}"
	label define modd_d5_filtre 1 "Yes" 0 "No"
	label values modd_d5_filtre modd_d5_filtre

	label variable modd_d5 "D5b. How old was \${child_name} when \${gender2} completely stopped feeding \${c"
	note modd_d5: "D5b. How old was \${child_name} when \${gender2} completely stopped feeding \${child_name} with \${your_their} milk, either by breastfeeding and/or pumping milk?"

	label variable modd_d6a "D6a. Did \${gender2} breastfeed as long as \${she_you_cal} wanted to?"
	note modd_d6a: "D6a. Did \${gender2} breastfeed as long as \${she_you_cal} wanted to?"
	label define modd_d6a 1 "Yes" 0 "No"
	label values modd_d6a modd_d6a

	label variable modd_d6b "D6b. Until when would \${gender2} have liked to keep breastfeeding \${child_name"
	note modd_d6b: "D6b. Until when would \${gender2} have liked to keep breastfeeding \${child_name} ? '\${she_i} would have liked to stop when CHILD was ____ months'"

	label variable modd_d6b_confirm "You mentiond that \${gender2} completely stopped breastfeeding/feeding the baby "
	note modd_d6b_confirm: "You mentiond that \${gender2} completely stopped breastfeeding/feeding the baby with breast milk when they were \${modd_d5} months in question D5, but \${gender2} would have liked to stop when they were \${modd_d6b} which is a time before when you stopped breastfeeeding. Please confirm that this is correct"
	label define modd_d6b_confirm 1 "Yes" 0 "No"
	label values modd_d6b_confirm modd_d6b_confirm

	label variable modd_d6b_explain "Justify why this is correct"
	note modd_d6b_explain: "Justify why this is correct"

	label variable modd_d7 "D7. Until when \${do_does_cal} \${gender2} want to keep breastfeeding \${child_n"
	note modd_d7: "D7. Until when \${do_does_cal} \${gender2} want to keep breastfeeding \${child_name}? 'Until \${child_name} is ____ months old'"

	label variable modd_d_filtre "D8a. \${are_is_cal} \${gender2} still exclusively breastfeeding?"
	note modd_d_filtre: "D8a. \${are_is_cal} \${gender2} still exclusively breastfeeding?"
	label define modd_d_filtre 1 "Yes" 0 "No"
	label values modd_d_filtre modd_d_filtre

	label variable modd_d8b "D8b. How old was \${child_name} when \${gender2} started introducing formula or "
	note modd_d8b: "D8b. How old was \${child_name} when \${gender2} started introducing formula or other types of food? In other words, how old was \${child_name} when \${gender2} stopped exclusive breastfeeding?' '\${child_name} was ____ months old'"

	label variable modd_d8b_confirm "You mentiond that \${gender2} completely stopped breastfeeding/feeding the baby "
	note modd_d8b_confirm: "You mentiond that \${gender2} completely stopped breastfeeding/feeding the baby with breast milk when they were \${modd_d5} months in question D5, but \${gender2} introduced formula when they were \${modd_d8b} months which is later after you stopped breastfeeeding. Please confirm that this is correct"
	label define modd_d8b_confirm 1 "Yes" 0 "No"
	label values modd_d8b_confirm modd_d8b_confirm

	label variable modd_d8b_explain "Justify why this is correct"
	note modd_d8b_explain: "Justify why this is correct"

	label variable modd_d9a "D9a. Did \${gender2} exclusively breastfeed as long as \${she_you_cal} wanted to"
	note modd_d9a: "D9a. Did \${gender2} exclusively breastfeed as long as \${she_you_cal} wanted to?"
	label define modd_d9a 1 "Yes" 0 "No"
	label values modd_d9a modd_d9a

	label variable modd_d9b "D9b. When would \${gender2} have liked to stop exclusive breastfeeding.. '\${she"
	note modd_d9b: "D9b. When would \${gender2} have liked to stop exclusive breastfeeding.. '\${she_i} would have liked to stop exclusively breastfeeding when CHILD was _____ Months'"

	label variable modd_d9b_confirm "You mentiond that \${gender2} completely stopped exclusively breastfeeding/intro"
	note modd_d9b_confirm: "You mentiond that \${gender2} completely stopped exclusively breastfeeding/introducing formula when they were \${modd_d8b} months in question D8b, but \${gender2} would have liked to stop when they were \${modd_d9b} months which is a time before when you stopped exclusive breastfeeeding. Please confirm that this is correct"
	label define modd_d9b_confirm 1 "Yes" 0 "No"
	label values modd_d9b_confirm modd_d9b_confirm

	label variable modd_d9b_explain "Justify why this is correct"
	note modd_d9b_explain: "Justify why this is correct"

	label variable modd_d10 "D10. Until when \${do_does_cal} \${gender2} want to keep exclusively breastfeedi"
	note modd_d10: "D10. Until when \${do_does_cal} \${gender2} want to keep exclusively breastfeeding \${child_name}? 'Until \${child_name} is ____ months old'"

	label variable modd_d11a "D11a. Were YOU working when \${child_name} was born?"
	note modd_d11a: "D11a. Were YOU working when \${child_name} was born?"
	label define modd_d11a 1 "Yes, at this school" 2 "Yes, at another public school" 3 "Yes, at another private school" 4 "Yes, at another type of job" 5 "No"
	label values modd_d11a modd_d11a

	label variable modd_d11a_oth "What type of job were you doing?"
	note modd_d11a_oth: "What type of job were you doing?"

	label variable modd_d12 "D12. How many months of paid maternity leave did \${gender2} take at the time?"
	note modd_d12: "D12. How many months of paid maternity leave did \${gender2} take at the time?"

	label variable modd_d13a "a. Number"
	note modd_d13a: "a. Number"

	label variable modd_d13b "b. Unit of time"
	note modd_d13b: "b. Unit of time"
	label define modd_d13b 1 "Weeks" 2 "Months"
	label values modd_d13b modd_d13b

	label variable modd_d13c "D13c. Have you had any disagreement or discussion with your husband/partner abou"
	note modd_d13c: "D13c. Have you had any disagreement or discussion with your husband/partner about coming back to work?"
	label define modd_d13c 1 "Yes" 0 "No" 2 "I was not married or in a relationship at the time"
	label values modd_d13c modd_d13c

	label variable modd_d13d "D13d. What were the main reasons for your disagreements with your husband?"
	note modd_d13d: "D13d. What were the main reasons for your disagreements with your husband?"

	label variable modd_d14 "D14. After you came back to work, did you try to reach some formal or informal a"
	note modd_d14: "D14. After you came back to work, did you try to reach some formal or informal arrangements at your school in order to allow you to combine work and childrearing?"
	label define modd_d14 1 "Yes" 0 "No"
	label values modd_d14 modd_d14

	label variable modd_d15 "D15. After \${gender2} came back to work, \${was_were_cal} \${she_you_cal} able "
	note modd_d15: "D15. After \${gender2} came back to work, \${was_were_cal} \${she_you_cal} able to reach some formal or informal arrangements at \${workplace_cal} in order to allow \${you_her} to combine work and childrearing? Select all that apply. Be careful: you cannot select both 'no' and 'yes'"

	label variable modd_d15_other "Please specify the other arragements made based the ones listed above"
	note modd_d15_other: "Please specify the other arragements made based the ones listed above"

	label variable modd_d15a "Please specify the changes to the contract made"
	note modd_d15a: "Please specify the changes to the contract made"

	label variable modd_d15b "Please specify the informal agreements with the headteacher"
	note modd_d15b: "Please specify the informal agreements with the headteacher"

	label variable modd_d15c "Please specify the informal agreements with my collegues"
	note modd_d15c: "Please specify the informal agreements with my collegues"

	label variable modd_d15d "Explain the other arragements made"
	note modd_d15d: "Explain the other arragements made"

	label variable modd_d15e "On average, how many hours a week do you spend taking care of your child, \${chi"
	note modd_d15e: "On average, how many hours a week do you spend taking care of your child, \${child_name}?"

	label variable modd_d16_f "D16. You mentioned that YOU stopped breastfeeding or exclusively breastfeeding a"
	note modd_d16_f: "D16. You mentioned that YOU stopped breastfeeding or exclusively breastfeeding at least one of your children earlier than YOU wanted to. Which of the following reasons contributed to your decision to stop breastfeeding your baby?"

	label variable modd_d17 "Label"
	note modd_d17: "Label"
	label define modd_d17 1 "Yes" 2 "No" -999 "I don't know"
	label values modd_d17 modd_d17

	label variable modd_d17a "\${you_father}"
	note modd_d17a: "\${you_father}"
	label define modd_d17a 1 "Yes" 2 "No" -999 "I don't know"
	label values modd_d17a modd_d17a

	label variable modd_d17b "\${inlaw_grandmother}"
	note modd_d17b: "\${inlaw_grandmother}"
	label define modd_d17b 1 "Yes" 2 "No" -999 "I don't know"
	label values modd_d17b modd_d17b

	label variable modd_d17c "\${mother_inlaw}"
	note modd_d17c: "\${mother_inlaw}"
	label define modd_d17c 1 "Yes" 2 "No" -999 "I don't know"
	label values modd_d17c modd_d17c

	label variable modd_d17d "\${wifegrandmother}"
	note modd_d17d: "\${wifegrandmother}"
	label define modd_d17d 1 "Yes" 2 "No" -999 "I don't know"
	label values modd_d17d modd_d17d

	label variable modd_d17e "Another family member"
	note modd_d17e: "Another family member"
	label define modd_d17e 1 "Yes" 2 "No" -999 "I don't know"
	label values modd_d17e modd_d17e

	label variable modd_d17f "A doctor or other health professional"
	note modd_d17f: "A doctor or other health professional"
	label define modd_d17f 1 "Yes" 2 "No" -999 "I don't know"
	label values modd_d17f modd_d17f

	label variable modd_d18 "D18a. Think back to the timing of \${gender} pregnancy for each of your children"
	note modd_d18: "D18a. Think back to the timing of \${gender} pregnancy for each of your children. Did you take into consideration the school calendar (e.g., holidays) in order to time the birth date of any of your children?"
	label define modd_d18 1 "Yes" 0 "No"
	label values modd_d18 modd_d18

	label variable modd_d18b "D18b. Please explain Why?"
	note modd_d18b: "D18b. Please explain Why?"

	label variable modd_d19a "D19a. You mentioned that you have at least one kid who is younger than 6. Who ta"
	note modd_d19a: "D19a. You mentioned that you have at least one kid who is younger than 6. Who takes care of the child when you are at school ?"

	label variable modd_d19a_oth "D19b. Please specify the other person who takes care of the child"
	note modd_d19a_oth: "D19b. Please specify the other person who takes care of the child"

	label variable modd_d19c "D19c. How much do YOU pay monthly in total for these childcare services?"
	note modd_d19c: "D19c. How much do YOU pay monthly in total for these childcare services?"

	label variable modd_d20a "D20a. You mentioned that you have at least one kid who is older than 6. Who used"
	note modd_d20a: "D20a. You mentioned that you have at least one kid who is older than 6. Who used to take care of the child or children when \${gender2}\${was_were_cal} at \${school_work_cal}? [Allow for multiple options]"

	label variable modd_d20a_oth "D20b.Please specify the other person who takes care of the child"
	note modd_d20a_oth: "D20b.Please specify the other person who takes care of the child"

	label variable modd_d20c "D20c. How much did \${gender2} pay monthly for this childcare service?"
	note modd_d20c: "D20c. How much did \${gender2} pay monthly for this childcare service?"

	label variable modd_d21a_f "D21a. Did YOU ever use a breast pump to express YOUR milk?"
	note modd_d21a_f: "D21a. Did YOU ever use a breast pump to express YOUR milk?"
	label define modd_d21a_f 1 "Yes, Manual breast pump" 2 "Yes, Electric breast pump" 3 "Both electric and manual pump" 4 "No"
	label values modd_d21a_f modd_d21a_f

	label variable modd_d21b_f "D21b. How often did YOU use to breast-pump YOUR milk when you were at the workpl"
	note modd_d21b_f: "D21b. How often did YOU use to breast-pump YOUR milk when you were at the workplace?"
	label define modd_d21b_f 1 "Every day" 2 "Almost every day" 3 "At least once a week" 4 "Less than once a week" 5 "Never" -777 "other specify"
	label values modd_d21b_f modd_d21b_f

	label variable modd_d21b_f_oth "Specify the frequency"
	note modd_d21b_f_oth: "Specify the frequency"

	label variable modd_d21c_f "D21c. Did YOU ever express milk with your hands in order to relieve pressure whi"
	note modd_d21c_f: "D21c. Did YOU ever express milk with your hands in order to relieve pressure while you were at the workplace?"
	label define modd_d21c_f 1 "Yes" 2 "No" -888 "Refused to answer"
	label values modd_d21c_f modd_d21c_f

	label variable modd_d22_f "Label"
	note modd_d22_f: "Label"
	label define modd_d22_f 1 "Yes" 0 "No"
	label values modd_d22_f modd_d22_f

	label variable modd_d22a_f "a. A coworker made negative comments or complained to me about breastfeeding"
	note modd_d22a_f: "a. A coworker made negative comments or complained to me about breastfeeding"
	label define modd_d22a_f 1 "Yes" 0 "No"
	label values modd_d22a_f modd_d22a_f

	label variable modd_d22b_f "b. My employer or my supervisor made negative comments or complained to me about"
	note modd_d22b_f: "b. My employer or my supervisor made negative comments or complained to me about breastfeeding"
	label define modd_d22b_f 1 "Yes" 0 "No"
	label values modd_d22b_f modd_d22b_f

	label variable modd_d22c_f "c. It was hard for me to arrange break time for breastfeeding or pumping milk"
	note modd_d22c_f: "c. It was hard for me to arrange break time for breastfeeding or pumping milk"
	label define modd_d22c_f 1 "Yes" 0 "No"
	label values modd_d22c_f modd_d22c_f

	label variable modd_d22d_f "d. It was hard for me to find a place to breastfeed or pump milk"
	note modd_d22d_f: "d. It was hard for me to find a place to breastfeed or pump milk"
	label define modd_d22d_f 1 "Yes" 0 "No"
	label values modd_d22d_f modd_d22d_f

	label variable modd_d22e_f "e. It was hard for me to arrange a place to store pumped breast milk"
	note modd_d22e_f: "e. It was hard for me to arrange a place to store pumped breast milk"
	label define modd_d22e_f 1 "Yes" 0 "No"
	label values modd_d22e_f modd_d22e_f

	label variable modd_d22f_f "f. It was hard for me to carry the equipment I needed to pump milk at work"
	note modd_d22f_f: "f. It was hard for me to carry the equipment I needed to pump milk at work"
	label define modd_d22f_f 1 "Yes" 0 "No"
	label values modd_d22f_f modd_d22f_f

	label variable modd_d22g_f "g. I felt worried about keeping my job because of breastfeeding"
	note modd_d22g_f: "g. I felt worried about keeping my job because of breastfeeding"
	label define modd_d22g_f 1 "Yes" 0 "No"
	label values modd_d22g_f modd_d22g_f

	label variable modd_d22h_f "h. I felt worried about continuing to breastfeed because of my job"
	note modd_d22h_f: "h. I felt worried about continuing to breastfeed because of my job"
	label define modd_d22h_f 1 "Yes" 0 "No"
	label values modd_d22h_f modd_d22h_f

	label variable modd_d22i_f "i. I felt embarrassed among coworkers, my supervisor, or my employer because of "
	note modd_d22i_f: "i. I felt embarrassed among coworkers, my supervisor, or my employer because of breastfeeding"
	label define modd_d22i_f 1 "Yes" 0 "No"
	label values modd_d22i_f modd_d22i_f

	label variable modd_m11 "M11. Think back to the last 6 months. How many days of work did you miss? Exclud"
	note modd_m11: "M11. Think back to the last 6 months. How many days of work did you miss? Exclude days in which the school was closed."

	label variable modd_m11b "M11b. Out of these \${modd_m11} days, how many days were missed because of child"
	note modd_m11b: "M11b. Out of these \${modd_m11} days, how many days were missed because of childcare and/or breastfeeding?"

	label variable modd_d23_f "D23. Think about the first three months after YOU came back to work after having"
	note modd_d23_f: "D23. Think about the first three months after YOU came back to work after having a child, for ALL YOUR CHILDREN. On average for all your children, how many days of work did YOU miss because you had to take care of your child?"

	label variable modd_d23b_f "D23b. Think about the first three months after YOU came back to work after havin"
	note modd_d23b_f: "D23b. Think about the first three months after YOU came back to work after having a child, for ALL YOUR CHILDREN. On average for all your children, how many days of work did YOU miss because you had to breastfeed your child?"

	label variable modd_d22_f_no_children "Label"
	note modd_d22_f_no_children: "Label"
	label define modd_d22_f_no_children 1 "Yes" 0 "No"
	label values modd_d22_f_no_children modd_d22_f_no_children

	label variable modd_d22a_f_no_children "a. A coworker made negative comments or complained about a teacher breastfeeding"
	note modd_d22a_f_no_children: "a. A coworker made negative comments or complained about a teacher breastfeeding"
	label define modd_d22a_f_no_children 1 "Yes" 0 "No"
	label values modd_d22a_f_no_children modd_d22a_f_no_children

	label variable modd_d22b_f_no_children "b. The HT or Deputy HT made negative comments or complained about a teacher brea"
	note modd_d22b_f_no_children: "b. The HT or Deputy HT made negative comments or complained about a teacher breastfeeding"
	label define modd_d22b_f_no_children 1 "Yes" 0 "No"
	label values modd_d22b_f_no_children modd_d22b_f_no_children

	label variable modd_d22d_f_no_children "d. It is hard for breastfeeding teachers to find a place to breastfeed or pump m"
	note modd_d22d_f_no_children: "d. It is hard for breastfeeding teachers to find a place to breastfeed or pump milk"
	label define modd_d22d_f_no_children 1 "Yes" 0 "No"
	label values modd_d22d_f_no_children modd_d22d_f_no_children

	label variable modd_d22e_f_no_children "e. It is hard for breastfeeding teachers to arrange a place to store pumped brea"
	note modd_d22e_f_no_children: "e. It is hard for breastfeeding teachers to arrange a place to store pumped breast milk"
	label define modd_d22e_f_no_children 1 "Yes" 0 "No"
	label values modd_d22e_f_no_children modd_d22e_f_no_children

	label variable modd_d22f_f_no_children "f. It is hard for breastfeeding teachers to carry the equipment they needed to p"
	note modd_d22f_f_no_children: "f. It is hard for breastfeeding teachers to carry the equipment they needed to pump milk at work"
	label define modd_d22f_f_no_children 1 "Yes" 0 "No"
	label values modd_d22f_f_no_children modd_d22f_f_no_children

	label variable modd_d22g_f_no_children "g. Breastfeeding teachers felt worried about keeping their job because it is dif"
	note modd_d22g_f_no_children: "g. Breastfeeding teachers felt worried about keeping their job because it is difficult to combine it with breastfeeding"
	label define modd_d22g_f_no_children 1 "Yes" 0 "No"
	label values modd_d22g_f_no_children modd_d22g_f_no_children

	label variable modd_d22h_f_no_children "h. Breastfeeding teachers felt worried about continuing to breastfeed because it"
	note modd_d22h_f_no_children: "h. Breastfeeding teachers felt worried about continuing to breastfeed because it is difficult to combine it with their job"
	label define modd_d22h_f_no_children 1 "Yes" 0 "No"
	label values modd_d22h_f_no_children modd_d22h_f_no_children

	label variable modd_d22i_f_no_children "i. Breastfeeding teachers felt embarrassed among coworkers, supervisors, or HT b"
	note modd_d22i_f_no_children: "i. Breastfeeding teachers felt embarrassed among coworkers, supervisors, or HT because of breastfeeding"
	label define modd_d22i_f_no_children 1 "Yes" 0 "No"
	label values modd_d22i_f_no_children modd_d22i_f_no_children

	label variable modd_d24a_f "D24a. How often did YOU have trouble wrapping up the final details of a project "
	note modd_d24a_f: "D24a. How often did YOU have trouble wrapping up the final details of a project or assignment, once the challenging parts have been done?"
	label define modd_d24a_f 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24a_f modd_d24a_f

	label variable modd_d24b_f "D24b. How often did YOU have difficulty getting things in order when you had to "
	note modd_d24b_f: "D24b. How often did YOU have difficulty getting things in order when you had to do a task that required organisation?"
	label define modd_d24b_f 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24b_f modd_d24b_f

	label variable modd_d24c_f "D24c. How often did YOU have problems remembering appointments or obligations?"
	note modd_d24c_f: "D24c. How often did YOU have problems remembering appointments or obligations?"
	label define modd_d24c_f 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24c_f modd_d24c_f

	label variable modd_d24d_f "D24d. When YOU had a task that required a lot of thought, how often did you avoi"
	note modd_d24d_f: "D24d. When YOU had a task that required a lot of thought, how often did you avoid or delay getting started?"
	label define modd_d24d_f 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24d_f modd_d24d_f

	label variable modd_d24e_f "D24e. How often did YOU make careless mistakes when you had to work on a boring "
	note modd_d24e_f: "D24e. How often did YOU make careless mistakes when you had to work on a boring or difficult task?"
	label define modd_d24e_f 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24e_f modd_d24e_f

	label variable modd_d24f_f "D24f. How often did YOU have difficulty keeping attention when you were doing bo"
	note modd_d24f_f: "D24f. How often did YOU have difficulty keeping attention when you were doing boring or repetitive work?"
	label define modd_d24f_f 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24f_f modd_d24f_f

	label variable modd_d24g_f "D24g. How often did YOU have difficulty concentrating on what people were saying"
	note modd_d24g_f: "D24g. How often did YOU have difficulty concentrating on what people were saying to you even when they were speaking to you directly?"
	label define modd_d24g_f 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24g_f modd_d24g_f

	label variable modd_d24h_f "D24h. How often did YOU misplace or had difficulty finding things at home or at "
	note modd_d24h_f: "D24h. How often did YOU misplace or had difficulty finding things at home or at work?"
	label define modd_d24h_f 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24h_f modd_d24h_f

	label variable modd_d24i_f "D24i. How often was YOU distracted by activity or noise around you?"
	note modd_d24i_f: "D24i. How often was YOU distracted by activity or noise around you?"
	label define modd_d24i_f 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24i_f modd_d24i_f

	label variable modd_d24j_f "D24j. How often did YOU feel restless or fidgety?"
	note modd_d24j_f: "D24j. How often did YOU feel restless or fidgety?"
	label define modd_d24j_f 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24j_f modd_d24j_f

	label variable modd_d24k_f "D24k. How often did YOU have difficulty unwinding and relaxing when you had time"
	note modd_d24k_f: "D24k. How often did YOU have difficulty unwinding and relaxing when you had time to yourself?"
	label define modd_d24k_f 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24k_f modd_d24k_f

	label variable modd_d28 "D28. Do you plan to breastfeed your babies (or feed them your pumped milk)?"
	note modd_d28: "D28. Do you plan to breastfeed your babies (or feed them your pumped milk)?"
	label define modd_d28 1 "Yes, breastfeeding" 2 "Yes, pumped milk" 3 "Both (breastfeeding and pumped milk)" 4 "None of the above"
	label values modd_d28 modd_d28

	label variable modd_d29 "D29. Do you plan to breastfeed your babies at your workplace or express your mil"
	note modd_d29: "D29. Do you plan to breastfeed your babies at your workplace or express your milk at the workplace to later feed your babies?"

	label variable modd_d30 "D30. How old do you plan your babies to be when you'll completely stop breastfee"
	note modd_d30: "D30. How old do you plan your babies to be when you'll completely stop breastfeeding or feeding them with your milk?"

	label variable modd_d31 "D31. How old do you plan your babies to be when you'll start introducing formula"
	note modd_d31: "D31. How old do you plan your babies to be when you'll start introducing formula or other types of food? In other words, how old do you plan your babies to be when YOU'll stop exclusive breastfeeding?"

	label variable modd_d32 "D32. How many months of paid maternity leave do you plan to take?"
	note modd_d32: "D32. How many months of paid maternity leave do you plan to take?"

	label variable modd_d33 "D33. How many extra months or weeks of unpaid maternity leave do you plan to tak"
	note modd_d33: "D33. How many extra months or weeks of unpaid maternity leave do you plan to take?"

	label variable modd_d34 "D34. After you come back to work, do you think you will be able to reach some fo"
	note modd_d34: "D34. After you come back to work, do you think you will be able to reach some formal or informal arrangements at your school in order to allow you to combine work and childrearing?"

	label variable modd_d34a "D34a. Please explain how the contract would change"
	note modd_d34a: "D34a. Please explain how the contract would change"

	label variable modd_d34b "D34b. Please explain the informal agreements with teh headteacher/supervisor"
	note modd_d34b: "D34b. Please explain the informal agreements with teh headteacher/supervisor"

	label variable modd_d34c "D34c. Please explain the informal agreements with colleagues"
	note modd_d34c: "D34c. Please explain the informal agreements with colleagues"

	label variable modd_d34d "D34d. Please explain other arrangements"
	note modd_d34d: "D34d. Please explain other arrangements"

	label variable modd_d35 "D35. Think about the timing of your future pregnancies. Will you take into consi"
	note modd_d35: "D35. Think about the timing of your future pregnancies. Will you take into consideration the school calendar (e.g., holidays) in order to time the birth date of any of your children?"
	label define modd_d35 1 "Yes" 0 "No"
	label values modd_d35 modd_d35

	label variable modd_d36 "D36. Why would you do this?"
	note modd_d36: "D36. Why would you do this?"

	label variable modd_d37a "D37a. Who will take care of your children when you are at school?"
	note modd_d37a: "D37a. Who will take care of your children when you are at school?"

	label variable modd_d37a_oth "Specify who will take care of the children"
	note modd_d37a_oth: "Specify who will take care of the children"

	label variable modd_d38 "D38. Will you ever use a breast pump to express your milk?"
	note modd_d38: "D38. Will you ever use a breast pump to express your milk?"
	label define modd_d38 4 "No" 1 "Manual breast pump" 2 "Electric breast pump" 3 "Both electric and manual pump"
	label values modd_d38 modd_d38

	label variable modd_d38_oth "Specify other ways"
	note modd_d38_oth: "Specify other ways"

	label variable modd_d39 "D39. How often would you breast-pump your milk when you are at the workplace?"
	note modd_d39: "D39. How often would you breast-pump your milk when you are at the workplace?"
	label define modd_d39 1 "Every day" 2 "Almost every day" 3 "At least once a week" 4 "Less than once a week" 5 "Never"
	label values modd_d39 modd_d39

	label variable modd_d0_male "D0. What is the name of you youngest child?"
	note modd_d0_male: "D0. What is the name of you youngest child?"

	label variable modd_d1_male "D1. When was \${modd_d0_male} born?"
	note modd_d1_male: "D1. When was \${modd_d0_male} born?"

	label variable modd_d1b_male_old "D1b. How old is \${modd_d0_male}?"
	note modd_d1b_male_old: "D1b. How old is \${modd_d0_male}?"

	label variable modd_d2_male "D2. What is \${modd_d0_male}'s gender?"
	note modd_d2_male: "D2. What is \${modd_d0_male}'s gender?"
	label define modd_d2_male 1 "Male" 0 "Female"
	label values modd_d2_male modd_d2_male

	label variable breastpumping_knowledge_check "Do you know what breast pumping means? This is also called 'expressing milk'."
	note breastpumping_knowledge_check: "Do you know what breast pumping means? This is also called 'expressing milk'."
	label define breastpumping_knowledge_check 1 "Yes" 0 "No"
	label values breastpumping_knowledge_check breastpumping_knowledge_check

	label variable modd_d3_male "D3. Did your wife breastfeed this baby (or feed this baby with pumped milk)?"
	note modd_d3_male: "D3. Did your wife breastfeed this baby (or feed this baby with pumped milk)?"
	label define modd_d3_male 1 "Yes, pumped milk" 2 "Yes, breastfeeding" 3 "Both (breastfeeding and pumped milk)" 4 "None of the above" -999 "I don’t know" -888 "Prefer not to answer"
	label values modd_d3_male modd_d3_male

	label variable modd_d4_male "D4. Did your wife ever breastfeed this baby at her workplace or expressed milk a"
	note modd_d4_male: "D4. Did your wife ever breastfeed this baby at her workplace or expressed milk at the workplace to later feed the baby?"

	label variable modd_d5a_male "D5a. Is your wife still feeding this baby with breastmilk?"
	note modd_d5a_male: "D5a. Is your wife still feeding this baby with breastmilk?"
	label define modd_d5a_male 1 "Yes" 0 "No" -999 "I don’t know" -888 "Prefer not to answer"
	label values modd_d5a_male modd_d5a_male

	label variable modd_d5b_male "D5b. How old was the baby when your wife completely stopped feeding the baby wit"
	note modd_d5b_male: "D5b. How old was the baby when your wife completely stopped feeding the baby with milk, either by breastfeeding and/or pumping milk?"

	label variable modd_d5c_male "D5c. How often do or did you use to talk with your wife about matters related to"
	note modd_d5c_male: "D5c. How often do or did you use to talk with your wife about matters related to breastfeeding?"
	label define modd_d5c_male 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Always"
	label values modd_d5c_male modd_d5c_male

	label variable modd_d5d_male "D5d. How long does or did your wife want to breastfeed this baby for?"
	note modd_d5d_male: "D5d. How long does or did your wife want to breastfeed this baby for?"

	label variable modd_d5e_male "D5e. How long do or did you want your wife to breastfeed this baby for?"
	note modd_d5e_male: "D5e. How long do or did you want your wife to breastfeed this baby for?"

	label variable modd_d21a_male "D21a. Did YOUR WIFE ever use a breast pump to express HER milk?"
	note modd_d21a_male: "D21a. Did YOUR WIFE ever use a breast pump to express HER milk?"
	label define modd_d21a_male 1 "Yes, Manual breast pump" 2 "Yes, Electric breast pump" 3 "Both electric and manual pump" 4 "No" -999 "I don’t know" -888 "Prefer not to answer"
	label values modd_d21a_male modd_d21a_male

	label variable modd_d21b_male_other "D21b. Specify the frequency"
	note modd_d21b_male_other: "D21b. Specify the frequency"

	label variable modd_d11a_male "D11a. Were YOU working when \${modd_d0_male} was born?"
	note modd_d11a_male: "D11a. Were YOU working when \${modd_d0_male} was born?"
	label define modd_d11a_male 1 "Yes, at this school" 2 "Yes, at another public school" 3 "Yes, at another private school" 4 "Yes, at another type of job" 5 "No"
	label values modd_d11a_male modd_d11a_male

	label variable modd_d11a_male_other "D11a1. What type of job were you doing?"
	note modd_d11a_male_other: "D11a1. What type of job were you doing?"

	label variable modd_d11b_male "D11b. Was YOUR WIFE working when \${modd_d0_male} was born?"
	note modd_d11b_male: "D11b. Was YOUR WIFE working when \${modd_d0_male} was born?"
	label define modd_d11b_male 1 "Yes, fulltime" 2 "Yes, parttime" 3 "No" -999 "I don’t know" -888 "Prefer not to answer"
	label values modd_d11b_male modd_d11b_male

	label variable modd_d11b1_male "D11b1. What type of job was she doing?"
	note modd_d11b1_male: "D11b1. What type of job was she doing?"

	label variable modd_d11c_male "D11c. How old was CHILD when YOUR WIFE went back to work or started a new job? '"
	note modd_d11c_male: "D11c. How old was CHILD when YOUR WIFE went back to work or started a new job? 'When CHILD was _____ months old'"

	label variable modd_d13c_male "D13c. Have you had any disagreement or discussion with your wife/partner about s"
	note modd_d13c_male: "D13c. Have you had any disagreement or discussion with your wife/partner about she coming back to work?"
	label define modd_d13c_male 1 "Yes" 0 "No"
	label values modd_d13c_male modd_d13c_male

	label variable modd_d13d_male "D13d. What were the main reasons for your disagreements with your wife/partner?"
	note modd_d13d_male: "D13d. What were the main reasons for your disagreements with your wife/partner?"

	label variable modd_d14a_male "D14a. Did you take any paternity leave when CHILD was born?"
	note modd_d14a_male: "D14a. Did you take any paternity leave when CHILD was born?"
	label define modd_d14a_male 1 "Yes" 0 "No"
	label values modd_d14a_male modd_d14a_male

	label variable modd_d14b_male "D14b. How long was the paternity leave?"
	note modd_d14b_male: "D14b. How long was the paternity leave?"

	label variable modd_d14c_male "D14c. After you came back to work, did you try to reach some formal or informal "
	note modd_d14c_male: "D14c. After you came back to work, did you try to reach some formal or informal arrangements at your school in order to allow you to combine work and childrearing?"

	label variable modd_d15_male "D15. After you came back to work, were you able to reach some formal or informal"
	note modd_d15_male: "D15. After you came back to work, were you able to reach some formal or informal arrangements at your school in order to allow you to combine work and childrearing?"
	label define modd_d15_male 1 "Yes, contract formally changed" 2 "Yes, had informal agreements with the head teacher/supervisor" 3 "Yes, had informal agreements with colleagues" 4 "Yes, other (specify)" 5 "No" -999 "I don’t know" -888 "Prefer not to answer"
	label values modd_d15_male modd_d15_male

	label variable modd_d15a_male "D15a. Please specify the changes to the contract made"
	note modd_d15a_male: "D15a. Please specify the changes to the contract made"

	label variable modd_d15b_male "D15b. Please specify the informal agreements with the headteacher"
	note modd_d15b_male: "D15b. Please specify the informal agreements with the headteacher"

	label variable modd_d15c_male "D15c. Please specify the informal agreements with colleagues"
	note modd_d15c_male: "D15c. Please specify the informal agreements with colleagues"

	label variable modd_d15e_male "D15e. Explain the other arragements made"
	note modd_d15e_male: "D15e. Explain the other arragements made"

	label variable modd_d15d_male "D15d. On average, how many hours a week do you spend taking care of your child, "
	note modd_d15d_male: "D15d. On average, how many hours a week do you spend taking care of your child, \${modd_d0_male}?"

	label variable modd_d19a_male "D19a. You mentioned that you have at least one kid who is younger than 6. Who ta"
	note modd_d19a_male: "D19a. You mentioned that you have at least one kid who is younger than 6. Who takes care of the child when you are at school?"

	label variable modd_d19b_male "D19b. Please specify the other person who takes care of the child"
	note modd_d19b_male: "D19b. Please specify the other person who takes care of the child"

	label variable modd_d20a_male "D20a. You mentioned that you have at least one kid who is older than 6. Who used"
	note modd_d20a_male: "D20a. You mentioned that you have at least one kid who is older than 6. Who used to take care of the child or children when YOU were at school?"

	label variable modd_d20b_male "D20b. Please specify the other person who takes care of the child"
	note modd_d20b_male: "D20b. Please specify the other person who takes care of the child"

	label variable modd_d22a_male "D22a. A coworker made negative comments or complained about a teacher breastfeed"
	note modd_d22a_male: "D22a. A coworker made negative comments or complained about a teacher breastfeeding"
	label define modd_d22a_male 1 "Yes" 2 "No" -999 "I don't know"
	label values modd_d22a_male modd_d22a_male

	label variable modd_d22b_male "D22b. The HT or Deputy HT made negative comments or complained to about a teache"
	note modd_d22b_male: "D22b. The HT or Deputy HT made negative comments or complained to about a teacher breastfeeding"
	label define modd_d22b_male 1 "Yes" 2 "No" -999 "I don't know"
	label values modd_d22b_male modd_d22b_male

	label variable modd_d22d_male "D22d. It is hard for breastfeeding teachers to find a place to breastfeed or pum"
	note modd_d22d_male: "D22d. It is hard for breastfeeding teachers to find a place to breastfeed or pump milk"
	label define modd_d22d_male 1 "Yes" 2 "No" -999 "I don't know"
	label values modd_d22d_male modd_d22d_male

	label variable modd_d22e_male "D22e. It is hard for breastfeeding teachers to arrange a place to store pumped b"
	note modd_d22e_male: "D22e. It is hard for breastfeeding teachers to arrange a place to store pumped breast milk"
	label define modd_d22e_male 1 "Yes" 2 "No" -999 "I don't know"
	label values modd_d22e_male modd_d22e_male

	label variable modd_d22f_male "D22f. It is hard for breastfeeding teachers to carry the equipment they needed t"
	note modd_d22f_male: "D22f. It is hard for breastfeeding teachers to carry the equipment they needed to pump milk at work"
	label define modd_d22f_male 1 "Yes" 2 "No" -999 "I don't know"
	label values modd_d22f_male modd_d22f_male

	label variable modd_d22g_male "D22g. Breastfeeding teachers feel worried about keeping their job because it is "
	note modd_d22g_male: "D22g. Breastfeeding teachers feel worried about keeping their job because it is difficult to combine it with breastfeeding"
	label define modd_d22g_male 1 "Yes" 2 "No" -999 "I don't know"
	label values modd_d22g_male modd_d22g_male

	label variable modd_d22h_male "D22h. Breastfeeding teachers feel worried about continuing to breastfeed because"
	note modd_d22h_male: "D22h. Breastfeeding teachers feel worried about continuing to breastfeed because it is difficult to combine it with their job"
	label define modd_d22h_male 1 "Yes" 2 "No" -999 "I don't know"
	label values modd_d22h_male modd_d22h_male

	label variable modd_d22i_male "D22i. Breastfeeding teachers feel embarrassed among coworkers, supervisors, or H"
	note modd_d22i_male: "D22i. Breastfeeding teachers feel embarrassed among coworkers, supervisors, or HT because of breastfeeding"
	label define modd_d22i_male 1 "Yes" 2 "No" -999 "I don't know"
	label values modd_d22i_male modd_d22i_male

	label variable modd_m11_male "M11. Think back to the last 6 months. How many days of work did you miss? Exclud"
	note modd_m11_male: "M11. Think back to the last 6 months. How many days of work did you miss? Exclude days in which the school was closed."

	label variable modd_m11b_male "M11b. Out of these, how many days were missed because of childcare?"
	note modd_m11b_male: "M11b. Out of these, how many days were missed because of childcare?"

	label variable modd_m11c_male "D11c. Think about the first three months after YOU came back to work after havin"
	note modd_m11c_male: "D11c. Think about the first three months after YOU came back to work after having a child, for ALL YOUR CHILDREN. On average for all your children, how many days of work did YOU miss because you had to take care of your child?"

	label variable modd_d23_male "D23. Think about the first three months after YOUR WIFE came back to work after "
	note modd_d23_male: "D23. Think about the first three months after YOUR WIFE came back to work after having a child, for ALL YOUR CHILDREN. On average for all your children, how many days of work did SHE miss because she had to take care of your child?"

	label variable modd_d24a_male "D24a. How often did YOU have trouble wrapping up the final details of a project "
	note modd_d24a_male: "D24a. How often did YOU have trouble wrapping up the final details of a project or assignment, once the challenging parts have been done?"
	label define modd_d24a_male 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24a_male modd_d24a_male

	label variable modd_d24b_male "D24b. How often did YOU have difficulty getting things in order when you had to "
	note modd_d24b_male: "D24b. How often did YOU have difficulty getting things in order when you had to do a task that required organisation?"
	label define modd_d24b_male 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24b_male modd_d24b_male

	label variable modd_d24c_male "D24c. How often did YOU have problems remembering appointments or obligations?"
	note modd_d24c_male: "D24c. How often did YOU have problems remembering appointments or obligations?"
	label define modd_d24c_male 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24c_male modd_d24c_male

	label variable modd_d24d_male "D24d. When YOU had a task that required a lot of thought, how often did you avoi"
	note modd_d24d_male: "D24d. When YOU had a task that required a lot of thought, how often did you avoid or delay getting started?"
	label define modd_d24d_male 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24d_male modd_d24d_male

	label variable modd_d24e_male "D24e. How often did YOU make careless mistakes when you had to work on a boring "
	note modd_d24e_male: "D24e. How often did YOU make careless mistakes when you had to work on a boring or difficult task?"
	label define modd_d24e_male 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24e_male modd_d24e_male

	label variable modd_d24f_male "D24f. How often did YOU have difficulty keeping your attention when you were doi"
	note modd_d24f_male: "D24f. How often did YOU have difficulty keeping your attention when you were doing boring or repetitive work?"
	label define modd_d24f_male 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24f_male modd_d24f_male

	label variable modd_d24g_male "D24g. How often did YOU have difficulty concentrating on what people were saying"
	note modd_d24g_male: "D24g. How often did YOU have difficulty concentrating on what people were saying to you, even when they were speaking to you directly?"
	label define modd_d24g_male 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24g_male modd_d24g_male

	label variable modd_d24h_male "D24h. How often did YOU misplace or had difficulty finding things at home or at "
	note modd_d24h_male: "D24h. How often did YOU misplace or had difficulty finding things at home or at work?"
	label define modd_d24h_male 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24h_male modd_d24h_male

	label variable modd_d24i_male "D24i. How often were YOU distracted by activity or noise around you?"
	note modd_d24i_male: "D24i. How often were YOU distracted by activity or noise around you?"
	label define modd_d24i_male 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24i_male modd_d24i_male

	label variable modd_d24j_male "D24j. How often did YOU feel restless or fidgety?"
	note modd_d24j_male: "D24j. How often did YOU feel restless or fidgety?"
	label define modd_d24j_male 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24j_male modd_d24j_male

	label variable modd_d24k_male "D24k. How often did YOU have difficulty unwinding and relaxing when you had time"
	note modd_d24k_male: "D24k. How often did YOU have difficulty unwinding and relaxing when you had time to yourself?"
	label define modd_d24k_male 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24k_male modd_d24k_male

	label variable modd_d24a_male_nochild "D24a. How often did YOU have trouble wrapping up the final details of a project "
	note modd_d24a_male_nochild: "D24a. How often did YOU have trouble wrapping up the final details of a project or assignment, once the challenging parts have been done?"
	label define modd_d24a_male_nochild 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24a_male_nochild modd_d24a_male_nochild

	label variable modd_d24b_male_nochild "D24b. How often did YOU have difficulty getting things in order when you had to "
	note modd_d24b_male_nochild: "D24b. How often did YOU have difficulty getting things in order when you had to do a task that required organisation?"
	label define modd_d24b_male_nochild 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24b_male_nochild modd_d24b_male_nochild

	label variable modd_d24c_male_nochild "D24c. How often did YOU have problems remembering appointments or obligations?"
	note modd_d24c_male_nochild: "D24c. How often did YOU have problems remembering appointments or obligations?"
	label define modd_d24c_male_nochild 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24c_male_nochild modd_d24c_male_nochild

	label variable modd_d24d_male_nochild "D24d. When YOU had a task that required a lot of thought, how often did you avoi"
	note modd_d24d_male_nochild: "D24d. When YOU had a task that required a lot of thought, how often did you avoid or delay getting started?"
	label define modd_d24d_male_nochild 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24d_male_nochild modd_d24d_male_nochild

	label variable modd_d24e_male_nochild "D24e. How often did YOU make careless mistakes when you had to work on a boring "
	note modd_d24e_male_nochild: "D24e. How often did YOU make careless mistakes when you had to work on a boring or difficult task?"
	label define modd_d24e_male_nochild 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24e_male_nochild modd_d24e_male_nochild

	label variable modd_d24f_male_nochild "D24f. How often did YOU have difficulty keeping your attention when you were doi"
	note modd_d24f_male_nochild: "D24f. How often did YOU have difficulty keeping your attention when you were doing boring or repetitive work?"
	label define modd_d24f_male_nochild 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24f_male_nochild modd_d24f_male_nochild

	label variable modd_d24g_male_nochild "D24g. How often did YOU have difficulty concentrating on what people were saying"
	note modd_d24g_male_nochild: "D24g. How often did YOU have difficulty concentrating on what people were saying to you, even when they were speaking to you directly?"
	label define modd_d24g_male_nochild 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24g_male_nochild modd_d24g_male_nochild

	label variable modd_d24h_male_nochild "D24h. How often did YOU misplace or had difficulty finding things at home or at "
	note modd_d24h_male_nochild: "D24h. How often did YOU misplace or had difficulty finding things at home or at work?"
	label define modd_d24h_male_nochild 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24h_male_nochild modd_d24h_male_nochild

	label variable modd_d24i_male_nochild "D24i. How often were YOU distracted by activity or noise around you?"
	note modd_d24i_male_nochild: "D24i. How often were YOU distracted by activity or noise around you?"
	label define modd_d24i_male_nochild 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24i_male_nochild modd_d24i_male_nochild

	label variable modd_d24j_male_nochild "D24j. How often did YOU feel restless or fidgety?"
	note modd_d24j_male_nochild: "D24j. How often did YOU feel restless or fidgety?"
	label define modd_d24j_male_nochild 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24j_male_nochild modd_d24j_male_nochild

	label variable modd_d24k_male_nochild "D24k. How often did YOU have difficulty unwinding and relaxing when you had time"
	note modd_d24k_male_nochild: "D24k. How often did YOU have difficulty unwinding and relaxing when you had time to yourself?"
	label define modd_d24k_male_nochild 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Very Often"
	label values modd_d24k_male_nochild modd_d24k_male_nochild

	label variable knowledge_check_breastpumping_no "Do you know what breast pumping means? This is also called 'expressing milk'."
	note knowledge_check_breastpumping_no: "Do you know what breast pumping means? This is also called 'expressing milk'."
	label define knowledge_check_breastpumping_no 1 "Yes" 0 "No"
	label values knowledge_check_breastpumping_no knowledge_check_breastpumping_no

	label variable modd_d28_male "D28. Do you plan to encourage your spouse or partner to breastfeed your babies ("
	note modd_d28_male: "D28. Do you plan to encourage your spouse or partner to breastfeed your babies (or feed them your pumped milk)?"
	label define modd_d28_male 1 "Yes, breastfeeding" 2 "Yes, pumped milk" 3 "Both (breastfeeding and pumped milk)" 4 "None of the above"
	label values modd_d28_male modd_d28_male

	label variable modd_d29_male "D29. Would you agree if your spouse or partner breastfed your babies at the work"
	note modd_d29_male: "D29. Would you agree if your spouse or partner breastfed your babies at the workplace?"
	label define modd_d29_male 1 "Yes, I would strongly agree with breastfeed at the workplace at least sometimes" 2 "Yes, I would agree" 3 "No, I would not agree" 4 "No, I would strongly disagree"
	label values modd_d29_male modd_d29_male

	label variable modd_d29b_male "D29b. Would you agree if your spouse or partner expressed her milk at the workpl"
	note modd_d29b_male: "D29b. Would you agree if your spouse or partner expressed her milk at the workplace to later feed your babies using a pump, at leat sometimes?"
	label define modd_d29b_male 1 "Yes, I would strongly agree" 2 "Yes, I would agree" 3 "No, I would not agree" 4 "No, I would strongly disagree"
	label values modd_d29b_male modd_d29b_male

	label variable modd_d30_male "D30. For how long would you like your spouse or partner to breastfeed your babie"
	note modd_d30_male: "D30. For how long would you like your spouse or partner to breastfeed your babies?"

	label variable modd_d32_male "D32. How many weeks of paid paternity leave do you plan to take?"
	note modd_d32_male: "D32. How many weeks of paid paternity leave do you plan to take?"

	label variable modd_d34_male "D34. After you come back to work, do you think you will try to reach some formal"
	note modd_d34_male: "D34. After you come back to work, do you think you will try to reach some formal or informal arrangements at your school in order to allow you to combine work and childrearing?"

	label variable modd_d34a_male "D34a. Please explain how the contract would change"
	note modd_d34a_male: "D34a. Please explain how the contract would change"

	label variable modd_d34b_male "D34b. Please explain the informal agreements with the headteacher/supervisor"
	note modd_d34b_male: "D34b. Please explain the informal agreements with the headteacher/supervisor"

	label variable modd_d34c_male "D34c. Please explain the informal agreements with colleagues"
	note modd_d34c_male: "D34c. Please explain the informal agreements with colleagues"

	label variable modd_d34d_male "D34d. Please explain other arrangements"
	note modd_d34d_male: "D34d. Please explain other arrangements"

	label variable modd_d22a_male_nochild "D22a. A coworker made negative comments or complained about a teacher breastfeed"
	note modd_d22a_male_nochild: "D22a. A coworker made negative comments or complained about a teacher breastfeeding"
	label define modd_d22a_male_nochild 1 "Yes" 2 "No" -999 "I don't know"
	label values modd_d22a_male_nochild modd_d22a_male_nochild

	label variable modd_d22b_male_nochild "D22b. The HT or Deputy HT made negative comments or complained to about a teache"
	note modd_d22b_male_nochild: "D22b. The HT or Deputy HT made negative comments or complained to about a teacher breastfeeding"
	label define modd_d22b_male_nochild 1 "Yes" 2 "No" -999 "I don't know"
	label values modd_d22b_male_nochild modd_d22b_male_nochild

	label variable modd_d22d_male_nochild "D22d. It is hard for breastfeeding teachers to find a place to breastfeed or pum"
	note modd_d22d_male_nochild: "D22d. It is hard for breastfeeding teachers to find a place to breastfeed or pump milk"
	label define modd_d22d_male_nochild 1 "Yes" 2 "No" -999 "I don't know"
	label values modd_d22d_male_nochild modd_d22d_male_nochild

	label variable modd_d22e_male_nochild "D22e. It is hard for breastfeeding teachers to arrange a place to store pumped b"
	note modd_d22e_male_nochild: "D22e. It is hard for breastfeeding teachers to arrange a place to store pumped breast milk"
	label define modd_d22e_male_nochild 1 "Yes" 2 "No" -999 "I don't know"
	label values modd_d22e_male_nochild modd_d22e_male_nochild

	label variable modd_d22f_male_nochild "D22f. It is hard for breastfeeding teachers to carry the equipment they needed t"
	note modd_d22f_male_nochild: "D22f. It is hard for breastfeeding teachers to carry the equipment they needed to pump milk at work"
	label define modd_d22f_male_nochild 1 "Yes" 2 "No" -999 "I don't know"
	label values modd_d22f_male_nochild modd_d22f_male_nochild

	label variable modd_d22g_male_nochild "D22g. Breastfeeding teachers feel worried about keeping their job because it is "
	note modd_d22g_male_nochild: "D22g. Breastfeeding teachers feel worried about keeping their job because it is difficult to combine it with breastfeeding"
	label define modd_d22g_male_nochild 1 "Yes" 2 "No" -999 "I don't know"
	label values modd_d22g_male_nochild modd_d22g_male_nochild

	label variable modd_d22h_male_nochild "D22h. Breastfeeding teachers feel worried about continuing to breastfeed because"
	note modd_d22h_male_nochild: "D22h. Breastfeeding teachers feel worried about continuing to breastfeed because it is difficult to combine it with their job"
	label define modd_d22h_male_nochild 1 "Yes" 2 "No" -999 "I don't know"
	label values modd_d22h_male_nochild modd_d22h_male_nochild

	label variable modd_d22i_male_nochild "D22i. Breastfeeding teachers feel embarrassed among coworkers, supervisors, or H"
	note modd_d22i_male_nochild: "D22i. Breastfeeding teachers feel embarrassed among coworkers, supervisors, or HT because of breastfeeding"
	label define modd_d22i_male_nochild 1 "Yes" 2 "No" -999 "I don't know"
	label values modd_d22i_male_nochild modd_d22i_male_nochild

	label variable modf_f7 "F7. To what extent do you agree with the following statement: 'Breastfeeding is "
	note modf_f7: "F7. To what extent do you agree with the following statement: 'Breastfeeding is essential for an healthy development of a child'"
	label define modf_f7 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree"
	label values modf_f7 modf_f7

	label variable modf_f7_male "F7. To what extent do you agree with the following statement: 'Breastfeeding is "
	note modf_f7_male: "F7. To what extent do you agree with the following statement: 'Breastfeeding is essential for an healthy development of a child'"
	label define modf_f7_male 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree" -999 "I don't know" -888 "Prefer not to answer"
	label values modf_f7_male modf_f7_male

	label variable modf_f8a "a. Number"
	note modf_f8a: "a. Number"

	label variable modf_f8b "b. Unit of time"
	note modf_f8b: "b. Unit of time"
	label define modf_f8b 1 "Weeks" 2 "Months" 3 "Years"
	label values modf_f8b modf_f8b

	label variable modf_f8a_male "a. Number"
	note modf_f8a_male: "a. Number"

	label variable modf_f8b_male "b. Unit of time"
	note modf_f8b_male: "b. Unit of time"
	label define modf_f8b_male 1 "Weeks" 2 "Months" 3 "Years"
	label values modf_f8b_male modf_f8b_male

	label variable modf_f9a "a. Number"
	note modf_f9a: "a. Number"

	label variable modf_f9b "b. Unit of time"
	note modf_f9b: "b. Unit of time"
	label define modf_f9b 1 "Weeks" 2 "Months" 3 "Years"
	label values modf_f9b modf_f9b

	label variable modf_f9a_male "a. Number"
	note modf_f9a_male: "a. Number"

	label variable modf_f9b_male "b. Unit of time"
	note modf_f9b_male: "b. Unit of time"
	label define modf_f9b_male 1 "Weeks" 2 "Months" 3 "Years"
	label values modf_f9b_male modf_f9b_male

	label variable modf_f17 "F17. How supportive are you of using formula to feed children younger than 6 mon"
	note modf_f17: "F17. How supportive are you of using formula to feed children younger than 6 months?"
	label define modf_f17 4 "Very supportive" 3 "Somewhat supportive" 2 "Not very Supportive" 1 "Not Supportive at all"
	label values modf_f17 modf_f17

	label variable modf_f17_male "F17. How supportive are you of using formula to feed children younger than 6 mon"
	note modf_f17_male: "F17. How supportive are you of using formula to feed children younger than 6 months?"
	label define modf_f17_male 1 "Not supportive at all" 2 "Not very supportive" 3 "Somewhat supportive" 4 "Very supportive" -999 "I don't know" -888 "I prefer not to answer"
	label values modf_f17_male modf_f17_male

	label variable modf_f18 "F18. How supportive are you of using formula to feed children older than 6 month"
	note modf_f18: "F18. How supportive are you of using formula to feed children older than 6 months?"
	label define modf_f18 4 "Very supportive" 3 "Somewhat supportive" 2 "Not very Supportive" 1 "Not Supportive at all"
	label values modf_f18 modf_f18

	label variable modf_f18_male "F18. How supportive are you of using formula to feed children older than 6 month"
	note modf_f18_male: "F18. How supportive are you of using formula to feed children older than 6 months?"
	label define modf_f18_male 1 "Not supportive at all" 2 "Not very supportive" 3 "Somewhat supportive" 4 "Very supportive" -999 "I don't know" -888 "I prefer not to answer"
	label values modf_f18_male modf_f18_male

	label variable modf_f19 "F19. How supportive are you of breastpumping?"
	note modf_f19: "F19. How supportive are you of breastpumping?"
	label define modf_f19 4 "Very supportive" 3 "Somewhat supportive" 2 "Not very Supportive" 1 "Not Supportive at all"
	label values modf_f19 modf_f19

	label variable modf_f19_male "F19. How supportive are you of breastpumping?"
	note modf_f19_male: "F19. How supportive are you of breastpumping?"
	label define modf_f19_male 1 "Not supportive at all" 2 "Not very supportive" 3 "Somewhat supportive" 4 "Very supportive" -999 "I don't know" -888 "I prefer not to answer"
	label values modf_f19_male modf_f19_male

	label variable modf_f20 "F20. Are you aware of cultural beliefs related to breastpumping? If so, which on"
	note modf_f20: "F20. Are you aware of cultural beliefs related to breastpumping? If so, which ones?"

	label variable modf_f21a_y "F21a. If this was your friend, which of these three scenarios would you recommen"
	note modf_f21a_y: "F21a. If this was your friend, which of these three scenarios would you recommend for her?"
	label define modf_f21a_y 1 "Mother 1" 2 "Mother 2" 3 "Mother 3"
	label values modf_f21a_y modf_f21a_y

	label variable modf_f21b_y "F21b. What is the second best option?"
	note modf_f21b_y: "F21b. What is the second best option?"
	label define modf_f21b_y 1 "Mother 1" 2 "Mother 2" 3 "Mother 3"
	label values modf_f21b_y modf_f21b_y

	label variable modf_f21c_y "F21c. What do you think most teachers in your school would choose as the best op"
	note modf_f21c_y: "F21c. What do you think most teachers in your school would choose as the best option?"
	label define modf_f21c_y 1 "Mother 1" 2 "Mother 2" 3 "Mother 3"
	label values modf_f21c_y modf_f21c_y

	label variable modf_f21d_y "F21d. What do you think most husbands would choose if their wife was in this sit"
	note modf_f21d_y: "F21d. What do you think most husbands would choose if their wife was in this situation?"
	label define modf_f21d_y 1 "Mother 1" 2 "Mother 2" 3 "Mother 3"
	label values modf_f21d_y modf_f21d_y

	label variable modf_f21a_n "F21a. If this was your friend, which of these three scenarios would you recommen"
	note modf_f21a_n: "F21a. If this was your friend, which of these three scenarios would you recommend for her?"
	label define modf_f21a_n 1 "Mother 1" 2 "Mother 2" 3 "Mother 3"
	label values modf_f21a_n modf_f21a_n

	label variable modf_f21b_n "F21b. What is the second best option?"
	note modf_f21b_n: "F21b. What is the second best option?"
	label define modf_f21b_n 1 "Mother 1" 2 "Mother 2" 3 "Mother 3"
	label values modf_f21b_n modf_f21b_n

	label variable modf_f21c_n "F21c. What do you think most teachers in your school would choose as the best op"
	note modf_f21c_n: "F21c. What do you think most teachers in your school would choose as the best option?"
	label define modf_f21c_n 1 "Mother 1" 2 "Mother 2" 3 "Mother 3"
	label values modf_f21c_n modf_f21c_n

	label variable modf_f21d_n "F21d. What do you think most husbands would choose if their wife was in this sit"
	note modf_f21d_n: "F21d. What do you think most husbands would choose if their wife was in this situation?"
	label define modf_f21d_n 1 "Mother 1" 2 "Mother 2" 3 "Mother 3"
	label values modf_f21d_n modf_f21d_n

	label variable modf_f1 "F1. In your opinion, how supportive of breastfeeding is your place of employment"
	note modf_f1: "F1. In your opinion, how supportive of breastfeeding is your place of employment?"
	label define modf_f1 4 "Very supportive" 3 "Somewhat supportive" 2 "Not very Supportive" 1 "Not Supportive at all"
	label values modf_f1 modf_f1

	label variable modf_f2 "F2. Think about 10 of your female colleagues with breastfeeding experience. How "
	note modf_f2: "F2. Think about 10 of your female colleagues with breastfeeding experience. How many of them were ever forced to stop breastfeeding their child because of the need to go to work?"

	label variable modf_f3 "F3. Think about 10 of your female colleagues with children. How many of them wer"
	note modf_f3: "F3. Think about 10 of your female colleagues with children. How many of them were ever forced to stop working because of their child?"

	label variable modf_f4 "F4. Was any of these interruptions due to the need to breastfeed frequently?"
	note modf_f4: "F4. Was any of these interruptions due to the need to breastfeed frequently?"
	label define modf_f4 1 "Yes" 2 "No" -999 "I don't know"
	label values modf_f4 modf_f4

	label variable modf_f5a "F5a. Think about 10 of your female colleagues with breastfeeding experience. How"
	note modf_f5a: "F5a. Think about 10 of your female colleagues with breastfeeding experience. How many of them ever talked with you about balancing breastfeeding and work?"

	label variable modf_f5b "F5b. Did they complain about challenges of reconciling breastfeeding and work?"
	note modf_f5b: "F5b. Did they complain about challenges of reconciling breastfeeding and work?"
	label define modf_f5b 1 "Yes" 0 "No"
	label values modf_f5b modf_f5b

	label variable modf_f6 "F6. Think about your female friends or colleagues with breastfeeding experience."
	note modf_f6: "F6. Think about your female friends or colleagues with breastfeeding experience. Would they feel embarassed by breastfeeding in public?"
	label define modf_f6 1 "Yes, definitely" 2 "Yes" 3 "No" 4 "No, not at all"
	label values modf_f6 modf_f6

	label variable modf_f10 "F10. Think about your female friends or colleagues. Do you think their husbands "
	note modf_f10: "F10. Think about your female friends or colleagues. Do you think their husbands would approve if they breastfed or expressed milk at school?"
	label define modf_f10 1 "Yes, definitely" 2 "Yes" 3 "No" 4 "No, not at all"
	label values modf_f10 modf_f10

	label variable modf_f15 "F15. Think about your FEMALE friends or colleagues. Would they feel embarrassed "
	note modf_f15: "F15. Think about your FEMALE friends or colleagues. Would they feel embarrassed by talking with their FEMALE colleagues about breastfeeding?"
	label define modf_f15 1 "Yes, definitely" 2 "Yes" 3 "No" 4 "No, not at all"
	label values modf_f15 modf_f15

	label variable modf_f16 "F16. Think about your FEMALE friends or colleagues. Would they feel embarrassed "
	note modf_f16: "F16. Think about your FEMALE friends or colleagues. Would they feel embarrassed by talking with their MALE colleagues about breastfeeding?"
	label define modf_f16 1 "Yes, definitely" 2 "Yes" 3 "No" 4 "No, not at all"
	label values modf_f16 modf_f16

	label variable modf_f11 "F11.Think about female teachers in urban Kenya. Would they feel embarrassed by b"
	note modf_f11: "F11.Think about female teachers in urban Kenya. Would they feel embarrassed by breastfeeding in public?"
	label define modf_f11 1 "Yes, definitely" 2 "Yes" 3 "No" 4 "No, not at all"
	label values modf_f11 modf_f11

	label variable modf_f12 "F12.Think about any other woman in urban Kenya. Would she feel embarrassed by br"
	note modf_f12: "F12.Think about any other woman in urban Kenya. Would she feel embarrassed by breastfeeding in public?"
	label define modf_f12 1 "Yes, definitely" 2 "Yes" 3 "No" 4 "No, not at all"
	label values modf_f12 modf_f12

	label variable modf_f13 "F13. In which public places do you think it would be most appropriate to breastf"
	note modf_f13: "F13. In which public places do you think it would be most appropriate to breastfeed?"

	label variable modf_f14 "F14. In which public places do you think it would be least appropriate to breast"
	note modf_f14: "F14. In which public places do you think it would be least appropriate to breastfeed?"

	label variable modg_g1 "G1. Where I work, teachers can state their opinion without the fear of negative "
	note modg_g1: "G1. Where I work, teachers can state their opinion without the fear of negative consequences"
	label define modg_g1 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree"
	label values modg_g1 modg_g1

	label variable modg_g3 "G3. I trust my superiors in this school"
	note modg_g3: "G3. I trust my superiors in this school"
	label define modg_g3 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree"
	label values modg_g3 modg_g3

	label variable modg_g3b "G3b. I trust my colleagues in this school"
	note modg_g3b: "G3b. I trust my colleagues in this school"
	label define modg_g3b 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree"
	label values modg_g3b modg_g3b

	label variable modg_g5 "G5. Potential changes in this school are taken in consultation with the teachers"
	note modg_g5: "G5. Potential changes in this school are taken in consultation with the teachers who would be affected"
	label define modg_g5 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree"
	label values modg_g5 modg_g5

	label variable modg_g6 "G6. How are teachers consulted"
	note modg_g6: "G6. How are teachers consulted"

	label variable modg_g7 "G7. Changes in this school are decided by the Board of Management with little pe"
	note modg_g7: "G7. Changes in this school are decided by the Board of Management with little personal input from the teachers"
	label define modg_g7 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree"
	label values modg_g7 modg_g7

	label variable modg_g8 "G8. Where I work, people don't judge others negatively for taking up days of lea"
	note modg_g8: "G8. Where I work, people don't judge others negatively for taking up days of leave"
	label define modg_g8 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree"
	label values modg_g8 modg_g8

	label variable modg_g9 "G9. In this school, sometimes there are disagreements between colleagues"
	note modg_g9: "G9. In this school, sometimes there are disagreements between colleagues"
	label define modg_g9 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree"
	label values modg_g9 modg_g9

	label variable modg_g10 "G10. Where I work, I could ask a colleague to cover for me through a mutual info"
	note modg_g10: "G10. Where I work, I could ask a colleague to cover for me through a mutual informal arrangement if I need to be absent for some hours"
	label define modg_g10 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree"
	label values modg_g10 modg_g10

	label variable modg_g2 "G2. When any of the teachers suggests a new way to do something, it is taken for"
	note modg_g2: "G2. When any of the teachers suggests a new way to do something, it is taken forward"
	label define modg_g2 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Always"
	label values modg_g2 modg_g2

	label variable modg_g11 "G11. Is there a welfare organization in your school, where employees help each o"
	note modg_g11: "G11. Is there a welfare organization in your school, where employees help each other (for example, they collect money when someone gets a child, or if a relative dies)?"
	label define modg_g11 1 "Yes" 2 "No" -999 "I don't know"
	label values modg_g11 modg_g11

	label variable modg_g12 "G12. How often do the members meet?"
	note modg_g12: "G12. How often do the members meet?"
	label define modg_g12 1 "Every day" 2 "Once a week" 3 "Every two weeks" 4 "Once a month" 5 "Every three months" 6 "Less often than every three months" 7 "When need arises"
	label values modg_g12 modg_g12

	label variable modh_h0a "H0a. Are you aware of any workplace in which a lactation room is available?"
	note modh_h0a: "H0a. Are you aware of any workplace in which a lactation room is available?"
	label define modh_h0a 1 "Yes" 0 "No"
	label values modh_h0a modh_h0a

	label variable modh_h0b "H0b. Where are these lactation rooms?"
	note modh_h0b: "H0b. Where are these lactation rooms?"

	label variable modh_h0c "H0c. Do you personally know anyone who has been using a lactation room available"
	note modh_h0c: "H0c. Do you personally know anyone who has been using a lactation room available in their workplace?"
	label define modh_h0c 1 "Yes" 0 "No"
	label values modh_h0c modh_h0c

	label variable modh_h1 "H1. In this school, is there a lactation room?"
	note modh_h1: "H1. In this school, is there a lactation room?"
	label define modh_h1 1 "Yes, there is" 2 "No, there is not"
	label values modh_h1 modh_h1

	label variable modh_h2 "H2. What facilities are there?"
	note modh_h2: "H2. What facilities are there?"

	label variable modh_h2_oth "Please specify the other facilities"
	note modh_h2_oth: "Please specify the other facilities"

	label variable modh_h3 "H3. Is the space hygienic?"
	note modh_h3: "H3. Is the space hygienic?"
	label define modh_h3 1 "Yes" 2 "No" -999 "I don't know"
	label values modh_h3 modh_h3

	label variable modh_h4 "H4. What can this space be used for?"
	note modh_h4: "H4. What can this space be used for?"
	label define modh_h4 1 "Breastfeeding a baby" 2 "Expressing milk with a pump" 4 "Both Breastfeeding a baby and Expressing milk with a pump" 3 "None of the above" -999 "I don’t know"
	label values modh_h4 modh_h4

	label variable modh_h5 "H5. How did you find out about the existence of the lactation room?"
	note modh_h5: "H5. How did you find out about the existence of the lactation room?"
	label define modh_h5 1 "Word of mouth" 2 "I saw it by chance" 3 "Head teacher or principal told us" -777 "Other Specify"
	label values modh_h5 modh_h5

	label variable modh_h5_oth "Please specify the other way in which you found out about the lacation rooms"
	note modh_h5_oth: "Please specify the other way in which you found out about the lacation rooms"

	label variable modh_h5a "H5a. When was the lactation room created?'"
	note modh_h5a: "H5a. When was the lactation room created?'"

	label variable modh_h6 "H6. Do you remember whether teachers asked for the lactation room or whether it "
	note modh_h6: "H6. Do you remember whether teachers asked for the lactation room or whether it was a decision coming from the top?"
	label define modh_h6 1 "Employees asked for it" 2 "Management decided" -999 "I don't know"
	label values modh_h6 modh_h6

	label variable modh_h7 "H7. Do some mothers still breastfeed or express milk during working hours?"
	note modh_h7: "H7. Do some mothers still breastfeed or express milk during working hours?"
	label define modh_h7 1 "Yes, they breastfeed" 2 "Yes, they express milk" 3 "Yes, they both breastfeed and express milk" 4 "No" -999 "I don't know"
	label values modh_h7 modh_h7

	label variable modh_h8a "H8a. When can mothers express their milk or breastfeed?"
	note modh_h8a: "H8a. When can mothers express their milk or breastfeed?"

	label variable modh_h8a1 "H8a1. Where and how can mothers express their milk?"
	note modh_h8a1: "H8a1. Where and how can mothers express their milk?"

	label variable modh_h8a2 "H8a2. Where and how can mothers breastfeed?"
	note modh_h8a2: "H8a2. Where and how can mothers breastfeed?"

	label variable modh_h8b "H8b. Even if mothers are not expressing their milk during working hours, how and"
	note modh_h8b: "H8b. Even if mothers are not expressing their milk during working hours, how and when could they do so if they wanted to?"

	label variable modh_h9 "H9. When they start to work, are teachers oriented on which space they can use f"
	note modh_h9: "H9. When they start to work, are teachers oriented on which space they can use for breastfeeding or expressing milk and on the rules about breastfeeding and expressing milk during working hours?"
	label define modh_h9 1 "Yes" 2 "No" -999 "I don't know"
	label values modh_h9 modh_h9

	label variable modh_h10 "H10. Are there provisions for breastfeeding mothers to go to the baby or have th"
	note modh_h10: "H10. Are there provisions for breastfeeding mothers to go to the baby or have the baby brought to her if child care is reasonably close?"
	label define modh_h10 1 "Yes" 2 "No" -999 "I don't know"
	label values modh_h10 modh_h10

	label variable modh_h11 "H11. Is there an agreement between mothers and the head teacher or principal reg"
	note modh_h11: "H11. Is there an agreement between mothers and the head teacher or principal regarding her break time to breastfeed or express milk?"
	label define modh_h11 1 "Yes, it is written valid for everyone" 2 "Yes, it is a written agreement decided on a case-by-case basis" 3 "Yes, it is an oral agreement valid for everyone" 4 "Yes, it is an oral agreement decided on a case-by-case basis" 5 "No" -999 "I don’t know"
	label values modh_h11 modh_h11

	label variable modh_h12 "H12. What is the agreement in terms of the interval of the breaks?"
	note modh_h12: "H12. What is the agreement in terms of the interval of the breaks?"

	label variable modh_h13 "H13. What is the agreement in terms of the length of each break?"
	note modh_h13: "H13. What is the agreement in terms of the length of each break?"

	label variable modh_h14 "H14. Is there a committee responsible in this school for overseeing implementati"
	note modh_h14: "H14. Is there a committee responsible in this school for overseeing implementation of policies in the workplace related to breastfeeding?"
	label define modh_h14 1 "Yes there's a specific committee" 2 "yes, the welfare committee" -777 "Yes other" 3 "No" -999 "I don't know"
	label values modh_h14 modh_h14

	label variable modh_h14_oth "Specify the other committee"
	note modh_h14_oth: "Specify the other committee"

	label variable modh_h15 "H15. Is there a committee responsible in this school for overseeing implementati"
	note modh_h15: "H15. Is there a committee responsible in this school for overseeing implementation of policies in the workplace related to mothers or women in general?"
	label define modh_h15 1 "Yes there's a specific committee" 2 "yes, the welfare committee" -777 "Yes other" 3 "No" -999 "I don't know"
	label values modh_h15 modh_h15

	label variable modh_h15_oth "Specify the other committee"
	note modh_h15_oth: "Specify the other committee"

	label variable modc_c25 "Suppose you receive a donation of 50,000KSH for any type of improvement in the s"
	note modc_c25: "Suppose you receive a donation of 50,000KSH for any type of improvement in the school. Do you agree with the following statement: 'It would be a good idea to use the money to set up a lactation room for the teachers and staff rather than for some other improvements?'"
	label define modc_c25 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree"
	label values modc_c25 modc_c25

	label variable modi_i1a "I1a. To what extent do you agree with the following statement: 'It is a good ide"
	note modi_i1a: "I1a. To what extent do you agree with the following statement: 'It is a good idea to have a lactation room in this school for teachers and staff.'"
	label define modi_i1a 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree"
	label values modi_i1a modi_i1a

	label variable modi_i1a1 "I1a1. Why do you think it's a good idea?"
	note modi_i1a1: "I1a1. Why do you think it's a good idea?"

	label variable modi_i1a2 "I1a2. Why do you think it's not a good idea?"
	note modi_i1a2: "I1a2. Why do you think it's not a good idea?"

	label variable modi_i1b "I1b. To what extent do you agree with the following statement: 'It is a good ide"
	note modi_i1b: "I1b. To what extent do you agree with the following statement: 'It is a good idea to have a lactation room even if it can only be used for expressing their milk and mothers won't bring their babies to school'"
	label define modi_i1b 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree"
	label values modi_i1b modi_i1b

	label variable modi_i1b1 "I1b1. Why do you think it's a good idea?"
	note modi_i1b1: "I1b1. Why do you think it's a good idea?"

	label variable modi_i1b2 "I1b2. Why do you think it's not a good idea?"
	note modi_i1b2: "I1b2. Why do you think it's not a good idea?"

	label variable modi_i2a "I2a. Do you personally know anyone who uses or has used the lactation room?"
	note modi_i2a: "I2a. Do you personally know anyone who uses or has used the lactation room?"
	label define modi_i2a 1 "Yes" 0 "No"
	label values modi_i2a modi_i2a

	label variable modi_i2b "I2b. How do they use it?"
	note modi_i2b: "I2b. How do they use it?"
	label define modi_i2b 1 "They breastfeed their children directly at the workplace" 2 "They pump their milk and feed their children later on" 3 "Both (breastfeeding and pumping milk)"
	label values modi_i2b modi_i2b

	label variable modi_i3 "I3. According to what you know, do breastfeeding mothers use the lactation room "
	note modi_i3: "I3. According to what you know, do breastfeeding mothers use the lactation room regularly?"
	label define modi_i3 1 "Yes" 2 "No" -999 "I don't know"
	label values modi_i3 modi_i3

	label variable modi_i3a "I3a. Why not?"
	note modi_i3a: "I3a. Why not?"

	label variable modi_i4a "I4a. Do you think that some mothers would like to use this facility, but are als"
	note modi_i4a: "I4a. Do you think that some mothers would like to use this facility, but are also worried about using it?"
	label define modi_i4a 1 "Yes" 2 "No" -999 "I don't know"
	label values modi_i4a modi_i4a

	label variable modi_i4b "I4b. Why are they worried?"
	note modi_i4b: "I4b. Why are they worried?"

	label variable modi_i4b_oth "Specify the other reasons that make them worried"
	note modi_i4b_oth: "Specify the other reasons that make them worried"

	label variable modi_i5a "I5a. Is there some change that you think should be made to the lactation room?"
	note modi_i5a: "I5a. Is there some change that you think should be made to the lactation room?"
	label define modi_i5a 1 "Yes" 2 "No" -999 "I don't know"
	label values modi_i5a modi_i5a

	label variable modi_i5b "I5b. Please explain the change you would make"
	note modi_i5b: "I5b. Please explain the change you would make"

	label variable modi_i6a "I6a. Did the management of the school ask employees to contribute to the set-up "
	note modi_i6a: "I6a. Did the management of the school ask employees to contribute to the set-up and maintenance of the lactation room when they built it?"
	label define modi_i6a 1 "Yes" 2 "No" -999 "I don't know"
	label values modi_i6a modi_i6a

	label variable modi_i6b "I6b. How much did they ask for?"
	note modi_i6b: "I6b. How much did they ask for?"

	label variable modi_i6c "I6c. How much did you contribute?"
	note modi_i6c: "I6c. How much did you contribute?"

	label variable modi_i7a "I7a. In case management proposed cost sharing to set up and maintain lactation r"
	note modi_i7a: "I7a. In case management proposed cost sharing to set up and maintain lactation rooms, would you have contributed?"
	label define modi_i7a 1 "Yes" 2 "No" -999 "I don't know"
	label values modi_i7a modi_i7a

	label variable modi_i7b "I7b. How much would you have contributed?"
	note modi_i7b: "I7b. How much would you have contributed?"

	label variable modi_i8 "I8. How much do you think a breastfeeding woman would have been willing to contr"
	note modi_i8: "I8. How much do you think a breastfeeding woman would have been willing to contribute?"

	label variable modi_i9 "I9. How did male employees react to the creation of this space?"
	note modi_i9: "I9. How did male employees react to the creation of this space?"
	label define modi_i9 1 "Indifferent" 2 "Opposed to it" 3 "Supportive of it" 4 "I don’t know because I joined the school after the creation of the room"
	label values modi_i9 modi_i9

	label variable modi_i10 "I10. Have you ever heard male teachers complaining about the lactation room?"
	note modi_i10: "I10. Have you ever heard male teachers complaining about the lactation room?"
	label define modi_i10 1 "Yes" 0 "No"
	label values modi_i10 modi_i10

	label variable modi_j1a "J1a. To what extent do you agree with the following statement: 'It is a good ide"
	note modi_j1a: "J1a. To what extent do you agree with the following statement: 'It is a good idea to have a lactation room in this school for teachers and staff.'"
	label define modi_j1a 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree"
	label values modi_j1a modi_j1a

	label variable modi_j1a1 "J1a1. Why do you think it's a good idea?"
	note modi_j1a1: "J1a1. Why do you think it's a good idea?"

	label variable modi_j1a2 "J1a2. Why do you think it's not a good idea?"
	note modi_j1a2: "J1a2. Why do you think it's not a good idea?"

	label variable modi_j1b "J1b. To what extent do you agree with the following statement: 'It is a good ide"
	note modi_j1b: "J1b. To what extent do you agree with the following statement: 'It is a good idea to have a lactation room even if it can only be used for expressing milk and mothers won't bring their babies to school'"
	label define modi_j1b 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree"
	label values modi_j1b modi_j1b

	label variable modi_j1b1 "J1b1. Why do you think it's a good idea?"
	note modi_j1b1: "J1b1. Why do you think it's a good idea?"

	label variable modi_j1b2 "J1b2. Why do you think it's not a good idea?"
	note modi_j1b2: "J1b2. Why do you think it's not a good idea?"

	label variable modi_j1c "J1c.Why do you think there is not a lactation room in your school? Please select"
	note modi_j1c: "J1c.Why do you think there is not a lactation room in your school? Please select the most important reason"
	label define modi_j1c 1 "Lack of funding" 2 "Mothers don't want it" 3 "Husbands don't want it" 4 "Students' parents don't want it" 5 "Head teacher/Principal doesn't want it" 6 "Never thought about it so far" 7 "No need" -777 "Other reason (specify)"
	label values modi_j1c modi_j1c

	label variable modi_j1c_oth "Specify the other reasons why you think there is no laction room in your school"
	note modi_j1c_oth: "Specify the other reasons why you think there is no laction room in your school"

	label variable modi_j1d "J1c.Why they don't want it?"
	note modi_j1d: "J1c.Why they don't want it?"

	label variable modj_j2a "J2a. Do you think breastfeeding mothers would use this space regularly?"
	note modj_j2a: "J2a. Do you think breastfeeding mothers would use this space regularly?"
	label define modj_j2a 1 "Yes" 0 "No"
	label values modj_j2a modj_j2a

	label variable modj_j2c "J2c. Why not?"
	note modj_j2c: "J2c. Why not?"

	label variable modj_j2b "J2b. How would they use it?"
	note modj_j2b: "J2b. How would they use it?"
	label define modj_j2b 1 "They breastfeed their children directly at the workplace" 2 "They pump their milk and feed their children later on" 3 "Both (breastfeeding and pumping milk)"
	label values modj_j2b modj_j2b

	label variable modj_j3a "J3a. Do you think that some mothers would like to use this facility, but would a"
	note modj_j3a: "J3a. Do you think that some mothers would like to use this facility, but would also be worried about using it?"
	label define modj_j3a 1 "Yes" 2 "No" -999 "I don't know"
	label values modj_j3a modj_j3a

	label variable modj_j3b "J3b. Why would they be worried?"
	note modj_j3b: "J3b. Why would they be worried?"

	label variable modj_j3b_oth "J3b_other Specify why they would be worried?"
	note modj_j3b_oth: "J3b_other Specify why they would be worried?"

	label variable modj_j3c "J3c. Do you think that husbands would approve of their wifes breastfeeding or ex"
	note modj_j3c: "J3c. Do you think that husbands would approve of their wifes breastfeeding or expressing milk at school if there is a lactation room?"
	label define modj_j3c 1 "Yes, definitely" 2 "Yes" 3 "No" 4 "No, not at all"
	label values modj_j3c modj_j3c

	label variable modj_j4 "J4a. What facilities would you put for sure in the lactation room?"
	note modj_j4: "J4a. What facilities would you put for sure in the lactation room?"

	label variable modj_j4_oth "Specify what other facilities you would put in the lactation room?"
	note modj_j4_oth: "Specify what other facilities you would put in the lactation room?"

	label variable modj_j4b "J4b. How much do you think it would cost to set up a lactation room that has the"
	note modj_j4b: "J4b. How much do you think it would cost to set up a lactation room that has the facilities you have mentioned?"

	label variable modj_j5 "J5. Suppose that the management asked the teachers to contribute monetarily to t"
	note modj_j5: "J5. Suppose that the management asked the teachers to contribute monetarily to the set up and maintenance of a lactation room. Would you consider this fair?"
	label define modj_j5 1 "Yes" 0 "No"
	label values modj_j5 modj_j5

	label variable modj_j5_ht "J5. Suppose that you, together with the other management, asked the teachers to "
	note modj_j5_ht: "J5. Suppose that you, together with the other management, asked the teachers to contribute monetarily to the set up and maintenance of a lactation room. Would you consider this fair?"
	label define modj_j5_ht 1 "Yes" 0 "No"
	label values modj_j5_ht modj_j5_ht

	label variable modj_j6 "J6. In case management proposed cost sharing to set up and maintain lactation ro"
	note modj_j6: "J6. In case management proposed cost sharing to set up and maintain lactation rooms, would you contribute? Think about a one-time contribution"
	label define modj_j6 1 "Yes" 2 "No" -999 "I don't know"
	label values modj_j6 modj_j6

	label variable modj_j6b "J6b. How much would you contribute?"
	note modj_j6b: "J6b. How much would you contribute?"

	label variable modj_j7a "J7a. How much do you think a breastfeeding woman would be willing to contribute?"
	note modj_j7a: "J7a. How much do you think a breastfeeding woman would be willing to contribute?"

	label variable modj_j7b "J7b. How much do you think a teacher in this school would be willing to contribu"
	note modj_j7b: "J7b. How much do you think a teacher in this school would be willing to contribute, on average?"

	label variable modj_j8 "J8. How do you think that male teachers would react to the creation of this spac"
	note modj_j8: "J8. How do you think that male teachers would react to the creation of this space?"
	label define modj_j8 1 "Indifferent" 2 "Opposed to it" 3 "Supportive of it"
	label values modj_j8 modj_j8

	label variable modj_j9 "J9. Is there any room or space in this school that you think could be adapted to"
	note modj_j9: "J9. Is there any room or space in this school that you think could be adapted to become a private space for breastfeeding mothers when needed?"
	label define modj_j9 1 "Yes" 0 "No"
	label values modj_j9 modj_j9

	label variable modj_j9b "J10. Which space?"
	note modj_j9b: "J10. Which space?"

	label variable modj_j11 "J11. Do you think that this space could become permanently dedicated for this pu"
	note modj_j11: "J11. Do you think that this space could become permanently dedicated for this purpose only or would it be only used for this when needed by mothers?"
	label define modj_j11 1 "Could become permanently for mothers" 2 "Only when needed" -777 "Other (specify)"
	label values modj_j11 modj_j11

	label variable modj_j11_oth "Please specify"
	note modj_j11_oth: "Please specify"

	label variable modk_k1a "K1a. Select one man and one woman (remember it can't be the Head Teacher, or the"
	note modk_k1a: "K1a. Select one man and one woman (remember it can't be the Head Teacher, or the Deputy Head Teacher or you)"

	label variable modk_k1a_reson "K2a.Please state the reason for selecting \${modk_k1_name}"
	note modk_k1a_reson: "K2a.Please state the reason for selecting \${modk_k1_name}"

	label variable modk_k2a_reson "K2c. Please state the reason for selecting \${modk_k2_name}"
	note modk_k2a_reson: "K2c. Please state the reason for selecting \${modk_k2_name}"

	label variable modk_k1b "K1. Please write the full name of the teacher (ie. first name middle name and su"
	note modk_k1b: "K1. Please write the full name of the teacher (ie. first name middle name and surname)"

	label variable modk_k2b "K2. Please write the full name of the teacher (ie. first name middle name and su"
	note modk_k2b: "K2. Please write the full name of the teacher (ie. first name middle name and surname)"

	label variable modk_k1b_reson "Please state the reason for selecting \${modk_k1b}"
	note modk_k1b_reson: "Please state the reason for selecting \${modk_k1b}"

	label variable modk_k2b_reson "Please state the reason for selecting \${modk_k2b}"
	note modk_k2b_reson: "Please state the reason for selecting \${modk_k2b}"

	label variable modk_k5 "K5. Suppose that the school forms a committee in charge of creating a dedicated "
	note modk_k5: "K5. Suppose that the school forms a committee in charge of creating a dedicated space in your school for breastfeeding mothers. Would you be willing to be a member of the committee?"
	label define modk_k5 1 "Yes" 0 "No"
	label values modk_k5 modk_k5

	label variable modk_k5a "K5a. How many hours a month would you be willing to dedicate for this committee,"
	note modk_k5a: "K5a. How many hours a month would you be willing to dedicate for this committee, on a voluntary basis?"

	label variable modk_k4a "Incentives"
	note modk_k4a: "Incentives"

	label variable modk_k4a_oth "Specify the other incentive"
	note modk_k4a_oth: "Specify the other incentive"

	label variable modm_m4a "M4a. In those schools, I think that more teachers will breastfeed at school"
	note modm_m4a: "M4a. In those schools, I think that more teachers will breastfeed at school"
	label define modm_m4a 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree"
	label values modm_m4a modm_m4a

	label variable modm_m4b "M4b. In those schools, I think that teachers will be less likely to be absent fr"
	note modm_m4b: "M4b. In those schools, I think that teachers will be less likely to be absent from school"
	label define modm_m4b 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree"
	label values modm_m4b modm_m4b

	label variable modm_m4c "M4c. In those schools, I think that teachers will be more motivated to teach wel"
	note modm_m4c: "M4c. In those schools, I think that teachers will be more motivated to teach well"
	label define modm_m4c 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree"
	label values modm_m4c modm_m4c

	label variable modm_m4d "M4d. In those schools, I think that more teachers will want to become pregnant"
	note modm_m4d: "M4d. In those schools, I think that more teachers will want to become pregnant"
	label define modm_m4d 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree"
	label values modm_m4d modm_m4d

	label variable modm_m4d1 "M4d1. I think that female teachers will be more willing to work in those schools"
	note modm_m4d1: "M4d1. I think that female teachers will be more willing to work in those schools"
	label define modm_m4d1 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree"
	label values modm_m4d1 modm_m4d1

	label variable modm_m4e "M4e. On average, how many days a year are teachers absent in this school?"
	note modm_m4e: "M4e. On average, how many days a year are teachers absent in this school?"

	label variable modm_m4f "M4f. Consider women who are just back from maternity leave. On average, how many"
	note modm_m4f: "M4f. Consider women who are just back from maternity leave. On average, how many days in a year would they be absent in this school?"

	label variable modm_m4g "M4g. Think about a mother coming back from maternity leave. How many days of abs"
	note modm_m4g: "M4g. Think about a mother coming back from maternity leave. How many days of absence do you think that she will take over a year after establishing a lactation room?"

	label variable modm_m4h "M4h. Think about other teachers. How many days of absence do you think that an a"
	note modm_m4h: "M4h. Think about other teachers. How many days of absence do you think that an average teacher will take over a year after establishing a lactation room?"

	label variable modm_m5 "M5. For this question, we are giving you 50 KHS. We ask you to decide how much t"
	note modm_m5: "M5. For this question, we are giving you 50 KHS. We ask you to decide how much to keep for yourself, and how much to donate for a lactation room for your school. Any amount you keep for yourself will be added to the participation fee and given to you as airtime. Any amount you decide to donate to the school will be transferred to the school or HT Mpesa account for a lactation room project. How much would you like to donate out of 50 KHS?"

	label variable modm_m6a_a "a. What did you do?"
	note modm_m6a_a: "a. What did you do?"

	label variable modm_m6b_a "b. Could you satisfy this need?"
	note modm_m6b_a: "b. Could you satisfy this need?"
	label define modm_m6b_a 1 "Yes" 0 "No"
	label values modm_m6b_a modm_m6b_a

	label variable modm_m6c_a "c. How did you feel?"
	note modm_m6c_a: "c. How did you feel?"

	label variable modm_m6a_b "a. What would you have done?"
	note modm_m6a_b: "a. What would you have done?"

	label variable modm_m6b_b "b. Could you satisfy this need?"
	note modm_m6b_b: "b. Could you satisfy this need?"

	label variable modm_m6c_b "c. How would you have felt?"
	note modm_m6c_b: "c. How would you have felt?"

	label variable upload_picture "Please take a picture of the text."
	note upload_picture: "Please take a picture of the text."

	label variable s_status "ENUMERATOR: What is the final status of this survey?"
	note s_status: "ENUMERATOR: What is the final status of this survey?"
	label define s_status 0 "Incomplete" 1 "Complete" 2 "Appointment" 3 "Refusal" 4 "Respondent is on leave" 5 "Respondent is absent from school (with permission)" 6 "Respondent is absent from school (without permission)" 7 "Respondent transferred to another school" 8 "School closed for half term/holiday break" -777 "Other status"
	label values s_status s_status

	label variable s_status_oth "Specify the other survey status"
	note s_status_oth: "Specify the other survey status"

	label variable final_comment "ENUMERATOR:Please write here detailed notes on the breastfeeding experiences whi"
	note final_comment: "ENUMERATOR:Please write here detailed notes on the breastfeeding experiences which the respondent has shared with you"


	* append old, previously-imported data (if any)
	cap confirm file "`dtafile'"
	if _rc == 0 {
		* mark all new data before merging with old data
		gen new_data_row=1
		
		* pull in old data
		append using "`dtafile'", force
		
		* drop duplicates in favor of old, previously-imported data if overwrite_old_data is 0
		* (alternatively drop in favor of new data if overwrite_old_data is 1)
		sort key
		by key: gen num_for_key = _N
		drop if num_for_key > 1 & ((`overwrite_old_data' == 0 & new_data_row == 1) | (`overwrite_old_data' == 1 & new_data_row ~= 1))
		drop num_for_key

		* drop new-data flag
		drop new_data_row
	}
	
	* save data to Stata format
	save "`dtafile'", replace

	* show codebook and notes
	codebook
	notes list
}

disp
disp "Finished import of: `csvfile'"
disp

* OPTIONAL: LOCALLY-APPLIED STATA CORRECTIONS
*
* Rather than using SurveyCTO's review and correction workflow, the code below can apply a list of corrections
* listed in a local .csv file. Feel free to use, ignore, or delete this code.
*
*   Corrections file path and filename:  Baseline_Survey_Lactation_Rooms_Scaleup_corrections.csv
*
*   Corrections file columns (in order): key, fieldname, value, notes

capture confirm file "`corrfile'"
if _rc==0 {
	disp
	disp "Starting application of corrections in: `corrfile'"
	disp

	* save primary data in memory
	preserve

	* load corrections
	insheet using "`corrfile'", names clear
	
	if _N>0 {
		* number all rows (with +1 offset so that it matches row numbers in Excel)
		gen rownum=_n+1
		
		* drop notes field (for information only)
		drop notes
		
		* make sure that all values are in string format to start
		gen origvalue=value
		tostring value, format(%100.0g) replace
		cap replace value="" if origvalue==.
		drop origvalue
		replace value=trim(value)
		
		* correct field names to match Stata field names (lowercase, drop -'s and .'s)
		replace fieldname=lower(subinstr(subinstr(fieldname,"-","",.),".","",.))
		
		* format date and date/time fields (taking account of possible wildcards for repeat groups)
		forvalues i = 1/100 {
			if "`datetime_fields`i''" ~= "" {
				foreach dtvar in `datetime_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						gen origvalue=value
						replace value=string(clock(value,"DMYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
						* allow for cases where seconds haven't been specified
						replace value=string(clock(origvalue,"DMYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
						drop origvalue
					}
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						replace value=string(clock(value,"DMY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
					}
				}
			}
		}

		* write out a temp file with the commands necessary to apply each correction
		tempfile tempdo
		file open dofile using "`tempdo'", write replace
		local N = _N
		forvalues i = 1/`N' {
			local fieldnameval=fieldname[`i']
			local valueval=value[`i']
			local keyval=key[`i']
			local rownumval=rownum[`i']
			file write dofile `"cap replace `fieldnameval'="`valueval'" if key=="`keyval'""' _n
			file write dofile `"if _rc ~= 0 {"' _n
			if "`valueval'" == "" {
				file write dofile _tab `"cap replace `fieldnameval'=. if key=="`keyval'""' _n
			}
			else {
				file write dofile _tab `"cap replace `fieldnameval'=`valueval' if key=="`keyval'""' _n
			}
			file write dofile _tab `"if _rc ~= 0 {"' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab _tab `"disp "CAN'T APPLY CORRECTION IN ROW #`rownumval'""' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab `"}"' _n
			file write dofile `"}"' _n
		}
		file close dofile
	
		* restore primary data
		restore
		
		* execute the .do file to actually apply all corrections
		do "`tempdo'"

		* re-save data
		save "`dtafile'", replace
	}
	else {
		* restore primary data		
		restore
	}

	disp
	disp "Finished applying corrections in: `corrfile'"
	disp
}
