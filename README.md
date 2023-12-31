# High_frequency_checks

## Overview:
This repository contains the code to an example of high frequency checks for field work, based in part on the [IPA stata template](https://github.com/PovertyAction/high-frequency-checks). These will be used during data collection in a field experiment in Kenya.
The aim of this repository is to provide an example for inspiration in producing ones own high frequency checks for development field work dealing with a large-scale survey.

## The program requires:
* Stata
* Excel
* SurveyCTO, from which the data is automatically pulled daily

## ipacheck installation
```
net install ipacheck, all replace from("https://raw.githubusercontent.com/PovertyAction/high-frequency-checks/master")
ipacheck update
```
To create the folder structure for the high frequency checks
```
ipacheck new, surveys("SURVEY_NAME_1") folder("path/to/project")
```

## Folders and files
I am publishing:
* The [master.do file](HFC/0_master.do)
* [Other .do files](HFC/2_dofiles): 1_globals_Baseline_do, 3_prepsurvey_Baseline.do, 4_checksurvey_Baseline.do, import_Baseline.do, 7_checksurvey_Baeline_newsubmissions.do
* [Example input excel files](HFC/3_checks/1_inputs/1_Baseline)
* [Example final output excel files](HFC/HFC_lactationrooms_field/2023-09-15) that will we shared with the field team
* A [guide](HFC/HFC_lactationrooms_field/Guide_interpreting_HFCs.pdf) to interpret the final output
* [Extra outputs](HFC/3_checks/2_outputs/1_Baseline) for more detailed checks and plots

Note: all the information present in the files has been produced as a random test sample by the research team and is therefore made up with the sole purpose of testing the high-frequency checks. Any other file mentioned in this repository cannot be made public, but it is not necessary for the purpose of illustrating one possible approach to designing high frequency checks.
