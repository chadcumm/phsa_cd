/*****************************************************************************
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:
  Source file name:   bc_all_rm_audit_unproc_drv.prg
  Object name:        bc_all_rm_audit_unproc_drv
  Request #:
 
  Program purpose:
 
  Executing from:
 
  Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   01/20/2020  Chad Cummings			REMOVE OR UPDATE AFTER POC
001   12/01/2020  Chad Cummings			Updated to return CEID
002   12/07/2020  Chad Cummings			Included Priority
003   12/07/2020  Chad Cummings			Included Sub Activity Type
004   12/07/2020  Chad Cummings			Removed Requisition from type name
005   12/10/2020  Chad Cummings			Added priority and sub-type lists
006   12/16/2020  Chad Cummings			Updated statuses to match Sprint 5
007   01/05/2021  Chad Cummings			Subtype uses code set logic
008   01/06/2021  Chad Cummings			Priority uses code set
009   03/12/2021  Chad Cummings			Converted to use location of order not encounter
010   04/01/2021  Chad Cummings			Added View flag
011   04/16/2021  Chad Cummings			Requested Start Date and Time * restricted to day only (no time)
******************************************************************************/
DROP PROGRAM bc_all_rm_audit_unproc_drv GO
CREATE PROGRAM bc_all_rm_audit_unproc_drv
 prompt
	"Output to File/Printer/MINE" = "MINE"
	, "User ID:" = 0.0
	, "Position Cd:" = 0.0
	, "Start Date:" = ""
	, "End Date:" = ""
	, "REQ_START_DT" = ""
	, "REQ_END_DT" = ""
	, "Location:" = 0.0
	, "LOC_PATIENT" = 0
	, "LOC_PROVIDER" = 0
	, "ORDER_DATE_LABEL" = ""
	, "REQUESTED_DATE_LABEL" = ""
 
with OUTDEV, USER_ID, POSITION_CD, START_DT, END_DT, REQ_START_DT, REQ_END_DT,
	LOC_PROMPT, LOC_PATIENT, LOC_PROVIDER, ORDER_DATE_LABEL, REQUESTED_DATE_LABEL
 
call echo(build("loading script:",curprog))
declare nologvar = i2 with noconstant(1)	;do not create log = 1		, create log = 0
declare debug_ind = i2 with noconstant(0)	;0 = no debug, 1=basic debug with echo, 2=msgview debug ;000
declare rec_to_file = i2 with noconstant(0)
 
select into "nl:"
from
	 code_value_set cvs
	,code_value cv
plan cvs
	where cvs.definition = "PRINTTOPDF"
	and   cvs.code_set > 0.0
join cv
	where cv.code_set = cvs.code_set
	and   cv.active_ind 	= 1
	and   cv.cdf_meaning	= "LOGGING"
order by
	 cv.begin_effective_dt_tm desc
	,cv.cdf_meaning
head report
	stat = 0
head cv.cdf_meaning
	if (cnvtint(cv.definition) > 0)
		rec_to_file = 1
		nologvar = 0
	endif
with nocounter
 
%i cust_script:bc_all_rm_audit_unproc_drv.inc
 
call bc_custom_code_set(0)
 
 
record output_data (
	1 cnt = i4
	1 yesterday_start_dt_tm = dq8
	1 yesterday_end_dt_tm = dq8
	1 qual[*]
	 2 parent_event_id = f8
	 2 ordered_dt_tm = dq8
	 2 ordered_dt = vc
	 2 requested_dt_tm = dq8
	 2 requested_dt = vc
	 2 requisition_type = vc
	 2 printed_ind = i2
	 2 printed_dt_tm = dq8
	 2 printed_dt = vc
	 2 processed_yesterday_ind = i2
	 2 net_new_yesterday_ind = i2
	 2 processed_ind = i2
	 2 overdue_ind = i2
	 2 current_req_status = vc
	 2 req_status_dt_tm = dq8
	 2 req_status_dt = vc
	 2 calc_requested_dt_tm = dq8
	 2 calc_request_dt = vc
	 2 completed_dt_tm = dq8
	 2 completed_dt = vc
	 2 priority = vc
	 2 unit = vc
	 2 mrn = vc
	 2 subtype = vc
	 2 req_title = vc
	 2 ordering_provider = vc
)
 
 
;FREE RECORD record_data
RECORD record_data (
  1 date_used = i2
  1 document_start_date = dq8
  1 document_end_date = dq8
  1 requested_start_date = dq8
  1 requested_end_date = dq8
  1 start_check = vc
  1 end_check = vc
  1 requested_start_check = vc
  1 requested_end_check = vc
  1 order_data_label = vc
  1 requested_data_label = vc
  1 task_info_text = vc
  1 allow_req_print = i2
  1 labreq_prg = vc
  1 autolog_spec_ind = i2
  1 lock_chart_access = i2
  1 label_print_type = vc
  1 label_print_auto_off = vc
  1 allow_depart = i2
  1 depart_label = vc
  1 adv_print_ind = i2
  1 adv_print_codeset = f8
  1 form_ind = i2
  1 formslist [* ]
    2 form_id = f8
    2 form_name = vc
  /* start 009 */
  1 loc_list [* ]
    2 org_name = vc
    2 org_id = f8
    2 unit[*]
     3 unit_name = vc
     3 unit_id = f8
     3 selected = i2
  /*end 009 */
  1 tlist [* ]
    2 person_id = f8
    2 encounter_id = f8
    2 person_name = vc
    2 phn = vc
    2 mrn = vc
    2 gender = vc
    2 gender_char = vc
    2 dob = vc
    2 age = vc
    2 age_long = vc
    2 fin = vc
    2 encntr_type = vc
    2 encntr_status = vc
    2 unit = vc
    2 room_bed = vc
    2 task_type = vc
    2 task_id = f8
    2 task_type_ind = i2
    2 task_describ = vc
    2 task_display = vc
    2 task_prn_ind = i2
    2 task_date = vc
    2 task_overdue = i2
    2 task_time = vc
    2 task_dt_tm_num = dq8
    2 task_dt_tm_utc = vc
    2 task_form_id = f8
    2 charge_ind = i2
    2 task_status = vc
    2 clerk_status = vc
    2 display_status = vc
    2 inprocess_ind = i2
    2 order_id = vc
    2 order_id_real = f8
    2 ordered_as_name = vc
    2 order_cdl = vc
    2 orig_order_dt = vc
    2 order_dt_tm_utc = vc
    2 ordering_provider = vc
    2 ord_comment = vc
    2 task_note = vc
    2 task_resched_time = i2
    2 can_chart_ind = i2
    2 visit_loc = vc
    2 visit_date = vc
    2 visit_date_display = vc
    2 visit_dt_tm_num = dq8
    2 visit_dt_utc = vc
    2 charted_by = vc
    2 charted_dt = vc
    2 charted_dt_utc = vc
    2 not_done = i2
    2 result_set_id = f8
    2 not_done_reason = vc
    2 not_done_reason_comm = vc
    2 status_reason_cd = f8
    2 powerplan_ind = i2
    2 powerplan_name = vc
    2 event_id = f8
    2 parent_event_id = f8
    2 normal_ref_range_txt = vc
    2 requisition_format_cd = f8
    2 dfac_activity_id = f8
    2 priority = vc ;002
    2 priority_rank = i2 ;002
    2 sub_activity_type = vc ;003
    2 action_history = vc ;006
    2 comment_history = vc
    2 status_history = vc
    2 latest_comment = vc
    2 latest_status = vc
    2 latest_status_dt_tm = dq8
    2 keep_ind = i2
    2 olist_cnt = i2
    2 multiple_order_dates_ind = i2
    2 loc_unit_cd = f8 ;009
    2 future_location_unit_cd = f8 ;009
    2 olist [* ]
      3 order_name = vc
      3 ordering_prov = vc
      3 order_id = f8
      3 requested_start_dt_tm = dq8
      3 priority = vc
      3 priority_rank = i2
      3 dlist [* ]
        4 rank_seq = vc
        4 diag = vc
        4 code = vc
    2 dlist [* ]
      3 rank_seq = vc
      3 diag = vc
      3 code = vc
    2 asc_num = vc
    2 contain_list [* ]
      3 contain_sent = vc
      3 task_id = f8
    2 order_cnt = i2
    2 abn_track_ids = vc
    2 abn_list [* ]
      3 order_disp = vc
      3 alert_date = vc
      3 alert_state = vc
  1 status_list [* ]
    2 status = vc
    2 selected = i2
  1 cler_status_list [* ]
    2 status = vc
    2 selected = i2
  1 type_pref_found = i2
  1 type_list [* ]
    2 type = vc
    2 selected = i2
  1 subtype_pref_found = i2
  1 subtype_list [* ]
    2 type = vc
    2 selected = i2
  1 gsubtype_pref_found = i2
  1 gsubtype_list [* ]
    2 type = vc
    2 selected = i2
  1 priority_pref_found = i2
  1 priority_list [* ]
   2 group_name = vc
   2 group[*]
    3 priority = vc
    3 selected = i2
  1 timer_cnt = i2
  1 timer_final = vc
  1 timer_qual[*]
   2 section = vc
   2 start_time = dq8
   2 end_time = dq8
   2 elapsed = i2
  1 error_message = vc
  1 status_data
    2 status = c1
    2 subeventstatus [1 ]
      3 operationname = c25
      3 operationstatus = c1
      3 targetobjectname = c25
      3 targetobjectvalue = vc
)
 
record 1120120request (
 1 event_qual [*]
  2 event_id = f8
)
 
DECLARE log_program_name = vc WITH protect ,noconstant ("" )
DECLARE log_override_ind = i2 WITH protect ,noconstant (0 )
SET log_program_name = curprog
SET log_override_ind = 1
DECLARE log_level_error = i2 WITH protect ,noconstant (0 )
DECLARE log_level_warning = i2 WITH protect ,noconstant (1 )
DECLARE log_level_audit = i2 WITH protect ,noconstant (2 )
DECLARE log_level_info = i2 WITH protect ,noconstant (3 )
DECLARE log_level_debug = i2 WITH protect ,noconstant (4 )
DECLARE hsys = i4 WITH protect ,noconstant (0 )
DECLARE sysstat = i4 WITH protect ,noconstant (0 )
DECLARE serrmsg = c132 WITH protect ,noconstant (" " )
DECLARE ierrcode = i4 WITH protect ,noconstant (error (serrmsg ,1 ) )
DECLARE crsl_msg_default = i4 WITH protect ,noconstant (0 )
DECLARE crsl_msg_level = i4 WITH protect ,noconstant (0 )
EXECUTE msgrtl
SET crsl_msg_default = uar_msgdefhandle ()
SET crsl_msg_level = uar_msggetlevel (crsl_msg_default )
DECLARE lcrslsubeventcnt = i4 WITH protect ,noconstant (0 )
DECLARE icrslloggingstat = i2 WITH protect ,noconstant (0 )
DECLARE lcrslsubeventsize = i4 WITH protect ,noconstant (0 )
DECLARE icrslloglvloverrideind = i2 WITH protect ,noconstant (0 )
DECLARE scrsllogtext = vc WITH protect ,noconstant ("" )
DECLARE scrsllogevent = vc WITH protect ,noconstant ("" )
DECLARE icrslholdloglevel = i2 WITH protect ,noconstant (0 )
DECLARE icrslerroroccured = i2 WITH protect ,noconstant (0 )
DECLARE lcrsluarmsgwritestat = i4 WITH protect ,noconstant (0 )
DECLARE crsl_info_domain = vc WITH protect ,constant ("DISCERNABU SCRIPT LOGGING" )
DECLARE crsl_logging_on = c1 WITH protect ,constant ("L" )
IF ((((logical ("MP_LOGGING_ALL" ) > " " ) ) OR ((logical (concat ("MP_LOGGING_" ,log_program_name) ) > " " ) )) )
 SET log_override_ind = 1
ENDIF
DECLARE log_message ((logmsg = vc ) ,(loglvl = i4 ) ) = null
DECLARE getencntrreltn ((dencntr_id = f8 ) ,(dreltn_cd = f8 ) ,(dprov_id = f8 ) ) = null
DECLARE validatefxreltn ((dencntr_id = f8 ) ,(dprov_id = f8 ) ) = f8
DECLARE validatefx2reltn ((dencntr_id = f8 ) ,(dprov_id = f8 ) ) = f8
DECLARE validatecustomsettings ((codeset = f8 ) ,(encntrid = f8 ) ,(cve_fieldparse = vc ) ) = vc
DECLARE subroutine_status = f8 WITH noconstant (0 ) ,protect
IF ((validate (89_powerchart ,- (99 ) ) = - (99 ) ) )
 DECLARE 89_powerchart = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,89 ,"POWERCHART" ) )
ENDIF
IF ((validate (48_inactive ,- (99 ) ) = - (99 ) ) )
 DECLARE 48_inactive = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,48 ,"INACTIVE" ) )
ENDIF
IF ((validate (48_active ,- (99 ) ) = - (99 ) ) )
 DECLARE 48_active = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,48 ,"ACTIVE" ) )
ENDIF
SET log_program_name = "REQ_CUST_MP_TASK_BY_LOC_DT"
DECLARE gathercomponentsettings ((parentid = f8 ) ) = null WITH protect ,copy
DECLARE gatherpagecomponentsettings ((parentid = f8 ) ) = null WITH protect ,copy
DECLARE gathertasksbylocdt (dummy ) = null WITH protect ,copy
DECLARE gatherlabsbylocdt (dummy ) = null WITH protect ,copy
DECLARE gatherorderdiags (dummy ) = null WITH protect ,copy
DECLARE gatherenctrorgsecurity ((persid = f8 ) ,(userid = f8 ) ) = null WITH protect ,copy
DECLARE gathertasktypes (dummy ) = null WITH protect ,copy
DECLARE gatheruserprefs ((prsnl_id = f8 ) ,(pref_id = vc ) ) = null WITH protect ,copy
DECLARE gatherpowerformname (dummy ) = null WITH protect ,copy
DECLARE gatheruserlockedchartsaccess ((userid = f8 ) ) = null WITH protect ,copy
DECLARE gatherclericalstatus (dummy ) = null WITH protect ,copy
DECLARE gathernotdonereason ((resultid = f8 ) ) = null WITH protect ,copy
DECLARE gatherchartedforms ((eventid = f8 ) ) = null WITH protect ,copy
DECLARE gatherlocations ((persid = f8 ) ) = null WITH protect ,copy ;009
DECLARE current_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,protect
DECLARE 6025_cont = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!3243" ) )
DECLARE 6000_meds = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!3079" ) )
DECLARE 6000_eandm = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!10700" ) )
DECLARE 6000_charge = f8 WITH public ,constant (uar_get_code_by ("DISPLAYKEY" ,6000 ,"CHARGES" ) )
DECLARE deleted = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!17013" ) )
DECLARE completed = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2791" ) )
DECLARE inprocess = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2792" ) )
DECLARE 222_fac = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2844" ) )
DECLARE order_comment = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!3944" ) )
DECLARE task_note = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2936879" ) )
DECLARE not_done = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!17619" ) )
DECLARE ocfcomp_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,120 ,"OCFCOMP" ) )
DECLARE rtf_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,23 ,"RTF" ) )
DECLARE inerror = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,8 ,"INERROR" ) )
DECLARE 27113_mednec = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,27113 ,"MEDNEC" ) )
DECLARE 27112_required = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,27112 ,"REQUIRED" ))
DECLARE abn_status_meaning = vc WITH constant ("ABNSTATUS" )
DECLARE start_parser = vc WITH public ,noconstant ("0" )
DECLARE end_parser = vc WITH public ,noconstant ("0" )
 
 
DECLARE encntr_location_parser = vc WITH public ,noconstant ("1=1" )
DECLARE task_type_parser = vc WITH public ,noconstant ("1=1" )
DECLARE task_type_cv_parser = vc WITH public ,noconstant ("1=1" )
DECLARE encntr_type_parser = vc WITH public ,noconstant ("1=1" )
DECLARE not_done_reason = vc WITH public ,noconstant ("" )
DECLARE not_done_reason_comm = vc WITH public ,noconstant ("" )
DECLARE charted_form_id = f8 WITH public ,noconstant (0.0 )
DECLARE position_bedrock_settings = i2
DECLARE user_pref_string = vc
DECLARE user_pref_found = i2
DECLARE tasks_back = i4
DECLARE task_max = i4
DECLARE tcnt = i4
DECLARE lcnt = i4
DECLARE ignore_data = i2
SET tasks_back = 200
DECLARE confid_ind = i2
DECLARE confid_level = i2
DECLARE confid_security_parser = vc WITH public ,noconstant ("1=1" )
DECLARE indx_type = i4 WITH protect ,noconstant (0 )
DECLARE logging = i4 WITH protect ,noconstant (0 )
declare replace_string = vc with protect, noconstant("")
 
declare notfnd = vc with constant("<not found>")
declare order_string = vc with noconstant(" ")
declare i = i4 with noconstant(0)
declare k = i4 with noconstant(0)
declare j = i4 with noconstant(0)
declare pos = i4 with noconstant(0)
 
CALL log_message (concat ("Begin script: " ,log_program_name ) ,log_level_debug )
SET record_data->status_data.status = "F"
set record_data->error_message = "Current Filter Settings Returned No Results"
 
SET record_data->allow_req_print = 0
 
set record_data->timer_cnt = (record_data->timer_cnt + 1)
set stat = alterlist(record_data->timer_qual,record_data->timer_cnt)
set record_data->timer_qual[record_data->timer_cnt].start_time = cnvtdatetime(curdate,curtime3)
set record_data->timer_qual[record_data->timer_cnt].section = "Template"
set record_data->timer_qual[record_data->timer_cnt].end_time = cnvtdatetime(curdate,curtime3)
set record_data->timer_qual[record_data->timer_cnt].elapsed = datetimediff(
	 record_data->timer_qual[record_data->timer_cnt].end_time
	,record_data->timer_qual[record_data->timer_cnt].start_time
	,6)
 
set record_data->timer_cnt = (record_data->timer_cnt + 1)
set stat = alterlist(record_data->timer_qual,record_data->timer_cnt)
set record_data->timer_qual[record_data->timer_cnt].start_time = cnvtdatetime(curdate,curtime3)
set record_data->timer_qual[record_data->timer_cnt].section = "Patient"
 
/* setup the patients */
declare patient_parser = vc with public ,noconstant ("" )
record temp_patient
(
	1 cnt = i2
	1 list[*]
	 2 name = vc
	 2 person_id = f8
) with protect
 
select into "nl:"
from
	person p
plan p
	where p.person_id = $LOC_PATIENT
	and   p.person_id != 0.0
order by
	p.person_id
head report
	null
head p.person_id
	temp_patient->cnt = (temp_patient->cnt + 1)
	stat = alterlist(temp_patient->list,temp_patient->cnt)
	temp_patient->list[temp_patient->cnt].person_id = p.person_id
	temp_patient->list[temp_patient->cnt].name = p.name_full_formatted
with nocounter
;call echorecord(temp_patient)
 
if (temp_patient->cnt = 0)
	set patient_parser = "1=1"
else
	set patient_parser = "ce.person_id in("
	for (i = 1 to temp_patient->cnt)
		if (i>1)
			set patient_parser = concat(patient_parser,^,^)
		endif
		set patient_parser = concat(patient_parser,trim(cnvtstring(temp_patient->list[i].person_id)),".0")
	endfor
	set patient_parser = concat(patient_parser,^)^)
endif
 
;call echo(build2("patient_parser=",trim(patient_parser)))
 
set record_data->timer_qual[record_data->timer_cnt].end_time = cnvtdatetime(curdate,curtime3)
set record_data->timer_qual[record_data->timer_cnt].elapsed = datetimediff(
	 record_data->timer_qual[record_data->timer_cnt].end_time
	,record_data->timer_qual[record_data->timer_cnt].start_time
	,6)
 
set record_data->timer_cnt = (record_data->timer_cnt + 1)
set stat = alterlist(record_data->timer_qual,record_data->timer_cnt)
set record_data->timer_qual[record_data->timer_cnt].start_time = cnvtdatetime(curdate,curtime3)
set record_data->timer_qual[record_data->timer_cnt].section = "Provider"
set record_data->timer_qual[record_data->timer_cnt].end_time = cnvtdatetime(curdate,curtime3)
set record_data->timer_qual[record_data->timer_cnt].elapsed = datetimediff(
	 record_data->timer_qual[record_data->timer_cnt].end_time
	,record_data->timer_qual[record_data->timer_cnt].start_time
	,6)
 
/* setup the providers */
declare provider_parser = vc with public ,noconstant ("" )
record temp_provider
(
	1 cnt = i2
	1 list[*]
	 2 name = vc
	 2 person_id = f8
) with protect
 
select into "nl:"
from
	prsnl p
plan p
	where p.person_id = $LOC_PROVIDER
	and   p.person_id != 0.0
order by
	p.person_id
head report
	null
head p.person_id
	temp_provider->cnt = (temp_provider->cnt + 1)
	stat = alterlist(temp_provider->list,temp_provider->cnt)
	temp_provider->list[temp_provider->cnt].person_id = p.person_id
	temp_provider->list[temp_provider->cnt].name = p.name_full_formatted
with nocounter
;call echorecord(temp_provider)
 
if (temp_provider->cnt = 0)
	set provider_parser = "1=1"
else
	set provider_parser = "p.person_id in("
	for (i = 1 to temp_provider->cnt)
		if (i>1)
			set provider_parser = concat(provider_parser,^,^)
		endif
		set provider_parser = concat(provider_parser,trim(cnvtstring(temp_provider->list[i].person_id)),".0")
	endfor
	set provider_parser = concat(provider_parser,^)^)
endif
 
;call echo(build2("provider_parser=",trim(provider_parser)))
 
set record_data->timer_cnt = (record_data->timer_cnt + 1)
set stat = alterlist(record_data->timer_qual,record_data->timer_cnt)
set record_data->timer_qual[record_data->timer_cnt].start_time = cnvtdatetime(curdate,curtime3)
set record_data->timer_qual[record_data->timer_cnt].section = "Location"
 
call gatherlocations(1.0) ;009
 
/* setup the locations */
declare location_parser = vc with public ,noconstant ("" )
record temp_loc
(
	1 cnt = i2
	1 list[*]
	 2 display = vc
	 2 location_cd = f8
	 2 location_type_cd = f8
) with protect
 
select into "nl:"
from
	location l
plan l
	where l.location_cd = $LOC_PROMPT
	and   l.location_cd != 0.0
order by
	l.location_cd
head report
	null
head l.location_cd
	temp_loc->cnt = (temp_loc->cnt + 1)
	stat = alterlist(temp_loc->list,temp_loc->cnt)
	temp_loc->list[temp_loc->cnt].location_cd = l.location_cd
	temp_loc->list[temp_loc->cnt].location_type_cd = l.location_type_cd
	temp_loc->list[temp_loc->cnt].display = uar_get_code_display(l.location_cd)
with nocounter
;call echorecord(temp_loc)
 
if (temp_loc->cnt = 0)
	set location_parser = "1=1"
else
	set location_parser = "e.loc_nurse_unit_cd in("
	for (i = 1 to temp_loc->cnt)
		if (i>1)
			set location_parser = concat(location_parser,^,^)
		endif
		set location_parser = concat(location_parser,trim(cnvtstring(temp_loc->list[i].location_cd)),".0")
	endfor
	set location_parser = concat(location_parser,^)^)
endif
 
;call echo(build2("location_parser=",trim(location_parser)))
 
set encntr_location_parser = "e.loc_nurse_unit_cd in("
set pos = 0
for (j=1 to size(record_data->loc_list,5))
	for (i = 1 to size(record_data->loc_list[j].unit,5))
		set pos = (pos + 1)
		if (pos>1)
			set encntr_location_parser = concat(encntr_location_parser,^,^)
		endif
		set encntr_location_parser = concat(encntr_location_parser,trim(cnvtstring(record_data->loc_list[j].unit[i].unit_id)),".0")
	endfor
endfor
set encntr_location_parser = concat(encntr_location_parser,^)^)
;call echo(build2("encntr_location_parser=",trim(encntr_location_parser)))
 
set record_data->timer_qual[record_data->timer_cnt].end_time = cnvtdatetime(curdate,curtime3)
set record_data->timer_qual[record_data->timer_cnt].elapsed = datetimediff(
	 record_data->timer_qual[record_data->timer_cnt].end_time
	,record_data->timer_qual[record_data->timer_cnt].start_time
	,6)
 
 
 
set record_data->timer_cnt = (record_data->timer_cnt + 1)
set stat = alterlist(record_data->timer_qual,record_data->timer_cnt)
set record_data->timer_qual[record_data->timer_cnt].start_time = cnvtdatetime(curdate,curtime3)
set record_data->timer_qual[record_data->timer_cnt].section = "Date"
/* setup the dates */
declare dtformat = vc 					with public ,constant ("DD-MMM-YYYY" )
declare document_date_parser = vc 		with public ,noconstant ("1=1" )
declare requested_date_parser = vc 		with public ,noconstant ("1=1" )
 
set record_data->end_check 				=  $END_DT
set record_data->start_check 			=  $START_DT
set record_data->requested_end_check	=  $REQ_END_DT
set record_data->requested_start_check	=  $REQ_START_DT
set record_data->order_data_label		=  $ORDER_DATE_LABEL
set record_data->requested_data_label	=  $REQUESTED_DATE_LABEL
 
if (record_data->order_data_label in("Any Date"))
	set stat = 0
else
 
	if ((record_data->start_check > " "))
		set record_data->document_start_date = CNVTDATETIME(CNVTDATE2(record_data->start_check, dtformat),0)
	endif
 
	if ((record_data->end_check > " "))
		set record_data->document_end_date = CNVTDATETIME(CNVTDATE2(record_data->end_check, dtformat),2359)
	endif
 
	if ((record_data->document_start_date > 0.0) and (record_data->document_end_date > 0.0))
		set document_date_parser = build2(
											 "pe.event_end_dt_tm between "
											,"cnvtdatetime(record_data->document_start_date) "
											,"and cnvtdatetime(record_data->document_end_date)"
										 )
	endif
endif
 
if (record_data->requested_data_label in("Any Date","Default Any Date"))
	set record_data->requested_start_date = CNVTDATETIME(CNVTDATE2("01-JAN-1900", dtformat),0)
	set record_data->requested_end_date = CNVTDATETIME(CNVTDATE2("31-DEC-2100", dtformat),2359)
else
	if ((record_data->requested_start_check > " "))
		set record_data->requested_start_date = CNVTDATETIME(CNVTDATE2(record_data->requested_start_check, dtformat),0)
	endif
 
	if ((record_data->requested_end_check > " "))
		set record_data->requested_end_date = CNVTDATETIME(CNVTDATE2(record_data->requested_end_check, dtformat),2359)
	endif
	set requested_date_parser = "filtered"
endif
;call echo(build2("requested_date_parser=",trim(requested_date_parser)))
;call echo(build2("document_date_parser=",trim(document_date_parser)))
set record_data->timer_qual[record_data->timer_cnt].end_time = cnvtdatetime(curdate,curtime3)
set record_data->timer_qual[record_data->timer_cnt].elapsed = datetimediff(
	 record_data->timer_qual[record_data->timer_cnt].end_time
	,record_data->timer_qual[record_data->timer_cnt].start_time
	,6)
 
;CALL gathertasktypes (0 )
;CALL gatherclericalstatus (0 )
;CALL gatheruserprefs ( $USER_ID ,"PWX_MPAGE_ORG_TASK_LIST_TYPES" )
 
 
 
 
CALL gathertasksbylocdt (0)
 
 SUBROUTINE  gathertasksbylocdt (dummy )
  CALL log_message ("In GatherTasksByLocDt()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
 
  SET record_data->date_used = 1
 
  CALL error_and_zero_check_rec (curqual ,"AMB_CUST_MP_TASK_LOC_DT" ,"GatherTasksByLocDt" ,1 ,0 ,record_data )
  CALL log_message (build ("Exit GatherTasksByLocDt(), Elapsed time in seconds:" ,
  		datetimediff (cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 
	set record_data->timer_cnt = (record_data->timer_cnt + 1)
	set stat = alterlist(record_data->timer_qual,record_data->timer_cnt)
	set record_data->timer_qual[record_data->timer_cnt].start_time = cnvtdatetime(curdate,curtime3)
	set record_data->timer_qual[record_data->timer_cnt].section = "Initial Data"
 
	select into "nl:"
	from
		 clinical_event ce
		,clinical_event pe
		,encounter e
		,ce_blob_result ceb
		,prsnl p1
		,person p
	plan ce
		where ce.event_cd = value(uar_get_code_by("DISPLAY",72,"Print to PDF Req"))
		and	  ce.result_status_cd in(
										  value(uar_get_code_by("MEANING",8,"AUTH"))
										 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
										 ;003 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
										 ;003 ,value(uar_get_code_by("MEANING",8,"INERROR"))
									)
 
		and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
		and   ce.event_tag        != "Date\Time Correction"
;		and   parser(document_date_parser)
		and   parser(patient_parser)
	join pe
		where pe.event_id = ce.parent_event_id
		and	  pe.result_status_cd in(
										  value(uar_get_code_by("MEANING",8,"AUTH"))
										 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
										 ;003 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
										 ;003 ,value(uar_get_code_by("MEANING",8,"INERROR"))
									)
		;and   parser(document_date_parser)
		and   pe.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
		and   pe.event_tag        != "Date\Time Correction"
	join ceb
		where ceb.event_id = ce.event_id
	    and   ceb.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	join p1
		where p1.person_id = ce.verified_prsnl_id
	join e
		where e.encntr_id = ce.encntr_id
		;009 and parser(location_parser)
		;and parser(encntr_location_parser) ;009
	join p
		where p.person_id = e.person_id
	order by
		;003 ce.event_end_dt_tm desc
		 pe.event_end_dt_tm desc ;003
		,ce.event_end_dt_tm ;003
		,ce.event_id
		,ce.clinical_event_id
     head report
     	tcnt = size(record_data->tlist,5)
    	ignore_data = 0
    	order_string = ""
    	k = 1
   	HEAD ce.event_id
   	 ;call echo(concat("evaluating pe ",trim(pe.event_title_text),cnvtstring(pe.event_id)))
     ignore_data = 1
     order_string = ""
     if (record_data->date_used = 1)
		if ((record_data->start_check = "01-Jan-1900") and (record_data->end_check = "01-Jan-1900"))
			ignore_data = 0
		else
	     	if (cnvtdatetime(pe.event_end_dt_tm)
	     		between cnvtdatetime(record_data->document_start_date) and cnvtdatetime(record_data->document_end_date))
	     		ignore_data = 0
	     	endif
	     endif
     else
     	ignore_data = 1
     endif
     ;if (ce.valid_from_dt_tm >= datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,curtime3)), 'M', 'B', 'B'))
     ;	ignore_data = 1
    ;endif
     if (ignore_data = 0)
		tcnt = (tcnt + 1 )
     	IF ((mod (tcnt ,100 ) = 1 ) ) stat = alterlist (record_data->tlist ,(tcnt + 99 ) ) ENDIF
     	record_data->tlist[tcnt ].can_chart_ind = 1
 
    	record_data->tlist[tcnt ].dob = datetimezoneformat (p.birth_dt_tm ,p.birth_tz ,"dd-mmm-yyyy" )
     	record_data->tlist[tcnt ].encounter_id = e.encntr_id
     	record_data->tlist[tcnt ].encntr_type = uar_Get_code_display(e.encntr_type_cd)
     	record_data->tlist[tcnt ].encntr_status = uar_Get_code_display(e.encntr_status_cd)
     	record_data->tlist[tcnt ].unit = uar_get_code_display(e.loc_nurse_unit_cd)
     	record_data->tlist[tcnt ].loc_unit_cd = e.loc_nurse_unit_cd ;009
     	if (trim(uar_get_code_display(e.loc_bed_cd)) > " ")
     		record_data->tlist[tcnt ].room_bed = concat(
													trim(uar_get_code_display(e.loc_room_cd)),"-",
													trim(uar_get_code_display(e.loc_bed_cd))
												)
		else
			record_data->tlist[tcnt ].room_bed = concat(trim(uar_get_code_display(e.loc_room_cd)))
		endif
	 	record_data->tlist[tcnt ].gender = uar_get_code_display (p.sex_cd )
	 	record_data->tlist[tcnt ].gender_char = cnvtupper (substring ( 1 ,1 ,record_data->tlist[tcnt ].gender ) )
	 	age_str = cnvtlower (trim (substring (1 ,12 , cnvtage (p.birth_dt_tm ) ) ,4 ) )
     	IF ((findstring ("days" ,age_str ,0 ) > 0 ) )
			days = findstring ("days" ,age_str ,0 )
			record_data->tlist[tcnt ].age = substring (1 ,days ,age_str )
     	ELSEIF ((findstring ("weeks" ,age_str ,0 ) > 0 ) )
			weeks = findstring ("weeks" ,age_str ,0 ) ,
			record_data->tlist[tcnt ].age = substring (1 ,weeks ,age_str )
     	ELSEIF ((findstring ("months" ,age_str ,0 ) > 0 ) )
			months = findstring ("months" ,age_str ,0 )
			record_data->tlist[tcnt ].age = substring (1 ,months ,age_str )
     	ELSEIF ((findstring ("years" ,age_str ,0 ) > 0 ) )
			years = findstring ("years" ,age_str ,0 ) ,
			record_data->tlist[tcnt ].age = substring (1 ,years ,age_str )
     	ENDIF
         record_data->tlist[tcnt ].age_long =  cnvtlower (trim (substring (1 ,12 , cnvtage (p.birth_dt_tm ) ) ,4 ) )
		 record_data->tlist[tcnt ].person_id = p.person_id ,record_data->tlist[tcnt ].person_name = trim (p.name_full_formatted )
		 ;001 record_data->tlist[tcnt ].task_id = ce.event_id
		 record_data->tlist[tcnt ].task_id = ce.clinical_event_id
		 record_data->tlist[tcnt ].event_id = ce.event_id
		 record_data->tlist[tcnt ].parent_event_id = ce.parent_event_id
		 record_data->tlist[tcnt ].task_describ = trim( pe.event_title_text)
		 record_data->tlist[tcnt ].task_display = record_data->tlist[tcnt ].task_describ
		 record_data->tlist[tcnt ].visit_loc = trim (uar_get_code_description (e.location_cd ) )
		 ;record_data->tlist[tcnt ].visit_date = format (cnvtdatetime (e.reg_dt_tm ) ,"MM/DD/YYYY;;d" )
		 ;record_data->tlist[tcnt ].visit_date_display = format (cnvtdatetime (e.reg_dt_tm ) ,"dd-mm-yy hh:mm;;d" )
		 ;record_data->tlist[tcnt ].visit_dt_tm_num = e.reg_dt_tm
		 ;record_data->tlist[tcnt ].visit_dt_utc = build (replace (datetimezoneformat (cnvtdatetime (e.reg_dt_tm ) ,
		; 		datetimezonebyname ("UTC" ) ,"yyyy-MM-dd HH:mm:ss" ,curtimezonedef ) ," " ,"T" ,1 ) ,"Z" )
		record_data->tlist[tcnt ].charted_by = trim (p1.name_full_formatted )
		record_data->tlist[tcnt ].charted_dt = format (pe.event_end_dt_tm , "MM/DD/YYYY;4;D" )
		record_data->tlist[tcnt ].charted_dt_utc = build (replace (datetimezoneformat (cnvtdatetime (pe.event_end_dt_tm ) ,
				datetimezonebyname ("UTC" ) ,"yyyy-MM-dd HH:mm:ss" ,curtimezonedef ) ," " ,"T" ,1 ) ,"Z" )
 
		record_data->tlist[tcnt ].task_status = piece(record_data->tlist[tcnt ].task_display,":",1,"")
		record_data->tlist[tcnt ].task_status = cnvtcap(record_data->tlist[tcnt ].task_status)
		;call echo(concat("record status =",record_data->tlist[tcnt ].task_status))
		replace_string = concat(trim(cnvtupper(record_data->tlist[tcnt ].task_status)),":")
		;call echo(concat("record status for conversion =",trim(replace_string)))
 
		;if (record_data->tlist[tcnt ].task_status = record_data->tlist[tcnt ].task_display)
		if (record_data->tlist[tcnt ].task_status not in("Actioned","Modified","Canceled"))
			record_data->tlist[tcnt ].task_status = "Pending"
		else
			;call echo("replacing status")
			record_data->tlist[tcnt ].task_display = replace(record_data->tlist[tcnt ].task_display,replace_string,"")
		endif
 
		/* start 006 */
		if (record_data->tlist[tcnt ].task_status in("Actioned"))
			record_data->tlist[tcnt ].task_status = "Printed"
		else
			record_data->tlist[tcnt ].task_status = "Pending"
		endif
		/* end 006 */
		record_data->tlist[tcnt ].task_describ = record_data->tlist[tcnt ].task_describ
		record_data->tlist[tcnt ].display_status = record_data->tlist[tcnt ].task_status
	    record_data->tlist[tcnt ].task_type = ""
	    record_data->tlist[tcnt ].task_date = format (pe.event_end_dt_tm ,"MM/DD/YY;;q" )
	    record_data->tlist[tcnt ].task_time = format (pe.event_end_dt_tm ,"hh:mm tt;;q" )
	    record_data->tlist[tcnt ].task_dt_tm_num = pe.event_end_dt_tm ;datetimezone (pe.event_end_dt_tm ,pe.event_end_tz )
	    ;record_data->tlist[tcnt ].task_dt_tm_utc = build (replace (datetimezoneformat (cnvtdatetime (ce.event_end_dt_tm )
	    ;											,datetimezonebyname ("UTC" ) , "yyyy-MM-dd HH:mm:ss" ,curtimezonedef ) ," " ,"T" ,1 ) ,"Z" )
 		record_data->tlist[tcnt ].task_dt_tm_utc = concat(
 													format(pe.event_end_dt_tm,"dd-mmm-yyyy;;q")
 													,"<br>",
 													format(pe.event_end_dt_tm,"hh:mm;;q")
 													)
 		record_data->tlist[tcnt ].normal_ref_range_txt = pe.normal_ref_range_txt
 		/*
 		k = 1
 		order_string = piece(record_data->tlist[tcnt ].normal_ref_range_txt,":",k,notfnd)
 		call echo(build("-->order_string=",order_string))
 		if (order_string = notfnd)
 			order_string = record_data->tlist[tcnt ].normal_ref_range_txt
		endif
 		record_data->tlist[tcnt ].order_id = order_string
		record_data->tlist[tcnt ].order_id_real = cnvtreal(order_string)
		*/
		k = 1
		;call echo(build("order_string=",order_string))
		while (order_string != notfnd)
			order_string = piece(record_data->tlist[tcnt ].normal_ref_range_txt,":",k,notfnd)
			;call echo(build2("-->inside while order_string=",order_string))
			pos = locateval(
									 j
									,1
									,record_data->tlist[tcnt ].olist_cnt
									,cnvtreal(order_string)
									,record_data->tlist[tcnt ].olist[j].order_id
								)
			;call echo(build2("-->inside while pos=",pos))
			if ((pos = 0) and (cnvtreal(order_string) > 0))
				record_data->tlist[tcnt ].olist_cnt = (record_data->tlist[tcnt ].olist_cnt + 1)
				stat = alterlist(record_data->tlist[tcnt ].olist,record_data->tlist[tcnt ].olist_cnt)
				record_data->tlist[tcnt ].olist[record_data->tlist[tcnt ].olist_cnt].order_id = cnvtreal(order_string)
				record_data->tlist[tcnt ].order_id_real = cnvtreal(order_string) ;remove after finalizing
			endif
			k = (k + 1)
		endwhile
	endif
	foot report
		stat = alterlist (record_data->tlist ,tcnt )
	with nocounter
    set record_data->timer_qual[record_data->timer_cnt].end_time = cnvtdatetime(curdate,curtime3)
	set record_data->timer_qual[record_data->timer_cnt].elapsed = datetimediff(
			 record_data->timer_qual[record_data->timer_cnt].end_time
			,record_data->timer_qual[record_data->timer_cnt].start_time
			,6)
 
	set record_data->timer_cnt = (record_data->timer_cnt + 1)
	set stat = alterlist(record_data->timer_qual,record_data->timer_cnt)
	set record_data->timer_qual[record_data->timer_cnt].start_time = cnvtdatetime(curdate,curtime3)
	set record_data->timer_qual[record_data->timer_cnt].section = "Ordering Provider"
 
	/*
	if (record_data->tlist[tcnt ].olist_cnt = 0)
		go to exit_script
	endif
	*/
	select into "nl:"
	from
		 (dummyt d1 with seq=size(record_data->tlist,5))
		,(dummyt d2 with seq=1)
		,orders o
		,order_action oa
		,prsnl p
	plan d1
		where maxrec(d2,record_data->tlist[d1.seq].olist_cnt)
	join d2
	join o
		where o.order_id = record_data->tlist[d1.seq].olist[d2.seq].order_id
	join oa
		where oa.order_id = o.order_id
	join p
		where p.person_id = oa.order_provider_id
		and parser(provider_parser)
	order by
		 o.order_id
		,oa.action_sequence desc
	head report
		stat = 0
		order_id = 0.0
		;call echo("inside orders query")
	head o.order_id
		record_data->tlist[d1.seq].ordering_provider = p.name_full_formatted
		record_data->tlist[d1.seq].keep_ind = 2
	foot report
		stat = 0
	with nocounter,nullreport
 
	if (temp_provider->cnt > 0)
		set _i = 1
		while(_i > 0)
		    if(record_data->tlist[_i].keep_ind != 2)
		        ;call echo(build("Removing index ", _i, " from record_data->tlist"))
		        set stat = alterlist(record_data->tlist, size(record_data->tlist, 5)-1, _i-1)
		        set _i = _i - 1
		    endif
 
		    if(_i = size(record_data->tlist, 5))
		        set _i = 0
		    else
		        set _i = _i + 1
		    endif
		endwhile
	endif
 
	set record_data->timer_qual[record_data->timer_cnt].end_time = cnvtdatetime(curdate,curtime3)
	set record_data->timer_qual[record_data->timer_cnt].elapsed = datetimediff(
		 record_data->timer_qual[record_data->timer_cnt].end_time
		,record_data->timer_qual[record_data->timer_cnt].start_time
		,6)
 
 
 
    set record_data->timer_cnt = (record_data->timer_cnt + 1)
	set stat = alterlist(record_data->timer_qual,record_data->timer_cnt)
	set record_data->timer_qual[record_data->timer_cnt].start_time = cnvtdatetime(curdate,curtime3)
	set record_data->timer_qual[record_data->timer_cnt].section = "Requisition Type"
 
    ;call echo("Starting query to find requisition type")
    select into "nl:"
	 event_id = record_data->tlist[d1.seq].event_id
	 ,sel_order_id = record_data->tlist[d1.seq].olist[d2.seq].order_id
	from
		 (dummyt d1 with seq=size(record_data->tlist,5))
		,(dummyt d2 with seq=1)
		,(dummyt d3)
		,(dummyt d4)
		,orders o
		,order_catalog oc
		,order_detail od
		,order_detail od2
		,order_entry_fields oef ;008
		,oe_format_fields off	;008
		,code_value cv1 ;007
		,code_value cv2 ;007
		,code_value_extension cve1 ;007
		,code_value_extension cve2 ;008
	plan d1
		where maxrec(d2,record_data->tlist[d1.seq].olist_cnt)
	join d2
	join o
		where (		(o.order_id = record_data->tlist[d1.seq].olist[d2.seq].order_id)
				or 	(o.template_order_id = record_data->tlist[d1.seq].olist[d2.seq].order_id)
				or 	(o.protocol_order_id = record_data->tlist[d1.seq].olist[d2.seq].order_id)
			  )
 
		and   o.order_status_cd in(
										 value(uar_get_code_by("MEANING",6004,"FUTURE"))
										;002 ,value(uar_get_code_by("MEANING",6004,"ORDERED"))
									)
	join oc
		where oc.catalog_cd = o.catalog_cd
	;start 007
	join cv1
		where cv1.code_value = oc.requisition_format_cd
	join cv2
		where cv2.code_set = bc_common->code_set
		and   cv2.active_ind = 1
		and   cv2.cdf_meaning = "REQUISITION"
		and   cv2.description = cv1.cdf_meaning
	join cve1
		where cve1.code_set = bc_common->code_set
		and   cve1.code_value = cv2.code_value
		and   cve1.field_name = "SUBTYPE_PROCESSING"
	;start 008
	join cve2
		where cve2.code_set = bc_common->code_set
		and   cve2.code_value = cv2.code_value
		and   cve2.field_name = "RM_PRIORITY_OEM"
	;end 008
	;end 007
	join d3
	join od
		where od.order_id = o.order_id
		and   od.oe_field_meaning = "REQSTARTDTTM"
	join d4
	join od2
		where od2.order_id = o.order_id
		and   od2.oe_field_meaning in( "PRIORITY","COLLPRI")
	join oef
		where oef.oe_field_id = od2.oe_field_id
	join off
		where off.oe_field_id = od2.oe_field_id
		and   off.oe_format_id = o.oe_format_id
		and   off.label_text = cve2.field_value
	order by
		 event_id
		,sel_order_id
		,o.order_id
		,o.protocol_order_id
		,o.template_order_id
		,od.action_sequence
		,od2.action_sequence
	head report
		stat = 0
		order_id = 0.0
		;call echo("inside orders query")
	;head event_id
	head sel_order_id
		order_id = o.order_id
		;call echo(build2("selected order_id:",trim(cnvtstring(order_id))))
	head o.order_id
		;call echo(build2("reviewing ",trim(o.order_mnemonic),",order_id:",trim(cnvtstring(o.order_id))))
		record_data->tlist[d1.seq].requisition_format_cd = oc.requisition_format_cd
	head od.action_sequence
		if (od.order_id = order_id)
			;call echo(build2("->order_id matched, setting dates"))
			;record_data->tlist[d1.seq ].visit_date = format (cnvtdatetime (od.oe_field_dt_tm_value ) ,"dd-mmm-yyyy hh:mm;;d" )
			;record_data->tlist[d1.seq ].visit_date_display = format (cnvtdatetime (od.oe_field_dt_tm_value ) ,"dd-mmm-yyyy hh:mm;;d" )
			;record_data->tlist[d1.seq ].visit_dt_tm_num = od.oe_field_dt_tm_value
			;record_data->tlist[d1.seq ].visit_dt_utc = build (replace (datetimezoneformat (cnvtdatetime (od.oe_field_dt_tm_value ) ,
		 	;	datetimezonebyname ("UTC" ) ,"yyyy-MM-dd HH:mm:ss" ,curtimezonedef ) ," " ,"T" ,1 ) ,"Z" )
		    record_data->tlist[d1.seq ].olist[d2.seq].requested_start_dt_tm = od.oe_field_dt_tm_value
		    record_data->tlist[d1.seq ].olist[d2.seq].order_name = o.order_mnemonic
		endif
	foot o.order_id
		;record_data->tlist[d1.seq ].priority = od2.oe_field_display_value ;002
		record_data->tlist[d1.seq ].future_location_unit_cd = o.future_location_nurse_unit_cd;009
		record_data->tlist[d1.seq ].olist[d2.seq].priority = od2.oe_field_display_value
	 	if (uar_get_code_meaning(oc.requisition_format_cd) in("OPREQWRAP"))
	 		case (od2.oe_field_display_value)
	 			;STAT>Urgent>Timed>AM Draw>Routine
	 			of "STAT": record_data->tlist[d1.seq ].olist[d2.seq].priority_rank 		= 1000
	 			of "Urgent": record_data->tlist[d1.seq ].olist[d2.seq].priority_rank 	= 300
	 			of "Timed": record_data->tlist[d1.seq ].olist[d2.seq].priority_rank 	= 200
	 			of "AM Draw": record_data->tlist[d1.seq ].olist[d2.seq].priority_rank 	= 100
	 			of "Routine": record_data->tlist[d1.seq ].olist[d2.seq].priority_rank 	= 0
	 		endcase
	 	else
	 		record_data->tlist[d1.seq ].priority = od2.oe_field_display_value
	 	endif
		/*start 002 *
		if (uar_get_code_meaning(oc.catalog_type_cd) in("CARDIOLOGY","AMB REFERRAL"))
			record_data->tlist[d1.seq ].sub_activity_type = trim(uar_get_code_display(oc.activity_type_cd)) ;002
		elseif (uar_get_code_meaning(oc.catalog_type_cd) in("RADIOLOGY"))
			record_data->tlist[d1.seq ].sub_activity_type = trim(uar_get_code_display(oc.activity_subtype_cd)) ;002
		elseif (oc.primary_mnemonic in("Group and Screen","ABO and Rh Group","Group and Screen Preadmit"))
			record_data->tlist[d1.seq ].sub_activity_type = "Group and Screen"
		elseif (oc.primary_mnemonic = "Bone Marrow*")
			record_data->tlist[d1.seq ].sub_activity_type = "Bone Marrow Biopsy/ Aspirate"
		elseif (uar_get_code_meaning(oc.catalog_type_cd) in("GENERAL LAB"))
			record_data->tlist[d1.seq ].sub_activity_type = "Outpatient Lab(s)"
		endif
 
		if (record_data->tlist[d1.seq ].sub_activity_type = "")
			record_data->tlist[d1.seq ].sub_activity_type = trim(uar_get_code_display(oc.activity_type_cd))
		endif
		/*end 002*/
		/*start 007*/
		if (cve1.field_value = "activity_type_cd")
			record_data->tlist[d1.seq ].sub_activity_type = trim(uar_get_code_display(oc.activity_type_cd))
		elseif (cve1.field_value = "activity_subtype_cd")
			record_data->tlist[d1.seq ].sub_activity_type = trim(uar_get_code_display(oc.activity_subtype_cd))
		else
			record_data->tlist[d1.seq ].sub_activity_type = trim(cve1.field_value)
		endif
		/*end 007*/
		/*
		if (record_data->tlist[d1.seq ].visit_dt_tm_num between cnvtdatetime(record_data->requested_start_date)
														and 	cnvtdatetime(record_data->requested_end_date))
			record_data->tlist[d1.seq ].keep_ind = 1
		endif
		*/
		order_id = 0.0
	foot report
		stat = 0
	with nocounter,nullreport
 
	;call echo("checking each order requested date and priority")
	for (i=1 to size(record_data->tlist,5))
		set k = 0
		for (j=1 to record_data->tlist[i].olist_cnt)
		 if (record_data->tlist[i].olist[j].requested_start_dt_tm = 0.0)
		 	set stat = 0
		 else
		 	set k = (k + 1)
			if (k=1)
				set record_data->tlist[i].visit_dt_tm_num = record_data->tlist[i].olist[j].requested_start_dt_tm
			else
				if (cnvtdatetime(record_data->tlist[i].olist[j].requested_start_dt_tm)
						< cnvtdatetime(record_data->tlist[i].visit_dt_tm_num))
					set record_data->tlist[i].visit_dt_tm_num = record_data->tlist[i].olist[j].requested_start_dt_tm
				endif
				if (format(cnvtdatetime(record_data->tlist[i].olist[j].requested_start_dt_tm),"mm-dd-yyyy;;d")  ;011
							!= format(cnvtdatetime(record_data->tlist[i].visit_dt_tm_num),"mm-dd-yyyy;;d")) ;011
						set record_data->tlist[i].multiple_order_dates_ind = 1
				endif
			endif
		endif
		endfor
		set record_data->tlist[i].visit_date = concat(
				format (cnvtdatetime (record_data->tlist[i].visit_dt_tm_num ) ,"dd-mmm-yyyy;;d" )
				,"<br>",
				format (cnvtdatetime (record_data->tlist[i].visit_dt_tm_num ) ,"hh:mm;;d" )
				)
		if (record_data->tlist[i].visit_dt_tm_num between cnvtdatetime(record_data->requested_start_date)
													and 	cnvtdatetime(record_data->requested_end_date))
			set record_data->tlist[i].keep_ind = 1
		endif
		if (record_data->tlist[i].priority = "")
			for (j=1 to record_data->tlist[i].olist_cnt)
				if (record_data->tlist[i ].olist[j].priority_rank > record_data->tlist[i ].priority_rank)
					set record_data->tlist[i ].priority_rank = record_data->tlist[i ].olist[j].priority_rank
				endif
			endfor
			case (record_data->tlist[i ].priority_rank)
				of 1000 :	set record_data->tlist[i ].priority = "STAT"
				of 300 	:	set record_data->tlist[i ].priority = "Urgent"
				of 200 	:	set record_data->tlist[i ].priority = "Timed"
				of 100 	:	set record_data->tlist[i ].priority = "AM Draw"
				of 0 	:	set record_data->tlist[i ].priority = "Routine"
			endcase
		endif
	endfor
 
	if (requested_date_parser != "1=1")
		set _i = 1
		while(_i > 0)
		    if(record_data->tlist[_i].keep_ind != 1)
		        ;call echo(build("Removing index ", _i, " from record_data->tlist"))
		        set stat = alterlist(record_data->tlist, size(record_data->tlist, 5)-1, _i-1)
		        set _i = _i - 1
		    endif
 
		    if(_i = size(record_data->tlist, 5))
		        set _i = 0
		    else
		        set _i = _i + 1
		    endif
		endwhile
	endif
 
	/*start 009 */
	if (location_parser != "1=1")
	;call echo("checking location on encounter and order")
	for (k=1 to size(record_data->tlist,5))
		set pos = locateval(i,1,temp_loc->cnt,record_data->tlist[k].loc_unit_cd,temp_loc->list[i].location_cd)
		;call echo(build2("pos=",pos))
		;call echo(build2("record_data->tlist[k].future_location_unit_cd=",record_data->tlist[k].future_location_unit_cd))
		;call echo(build2("record_data->tlist[k].future_location_unit_disp="
		;	,uar_get_code_display(record_data->tlist[k].future_location_unit_cd)))
		if ((pos > 0) and (record_data->tlist[k].future_location_unit_cd = 0.0)) 	;added to surpress requisitions from showing in 2
																					;locations
		;if ((pos > 0) ) 	;added to surpress requisitions from showing in 2
			set record_data->tlist[k].keep_ind = 3
			;call echo(build2("->matched on encounter location ",trim(uar_get_code_display(record_data->tlist[k].loc_unit_cd))))
		else
			;call echo(build2("-->checking order location ",trim(cnvtstring(record_data->tlist[k].order_id_real))," "
			;	,trim(uar_get_code_display(record_data->tlist[k].future_location_unit_cd))))
			set pos = locateval(i,1,temp_loc->cnt,record_data->tlist[k].future_location_unit_cd,temp_loc->list[i].location_cd)
			if (pos > 0)
				set record_data->tlist[k].keep_ind = 3
				;call echo(build2("-->matched on order location "
				;	,trim(uar_get_code_display(record_data->tlist[k].future_location_unit_cd))))
			endif
		endif
	endfor
	set _i = 1
		while(_i > 0)
		    if(record_data->tlist[_i].keep_ind != 3)
		        ;call echo(build("Removing index ", _i, " from record_data->tlist"))
		        set stat = alterlist(record_data->tlist, size(record_data->tlist, 5)-1, _i-1)
		        set _i = _i - 1
		    endif
 
		    if(_i = size(record_data->tlist, 5))
		        set _i = 0
		    else
		        set _i = _i + 1
		    endif
		endwhile
	endif
	set _i = 1
		while(_i > 0)
		    if(record_data->tlist[_i].requisition_format_cd = 0.0)
		        ;call echo(build("Removing index ", _i, " from record_data->tlist"))
		        set stat = alterlist(record_data->tlist, size(record_data->tlist, 5)-1, _i-1)
		        set _i = _i - 1
		    endif
 
		    if(_i = size(record_data->tlist, 5))
		        set _i = 0
		    else
		        set _i = _i + 1
		    endif
		endwhile
	/*select into "nl:"
	from
		(dummyt d1 with seq=size(record_data->tlist,5))
	where d1
	and
		(
			expand(i,1,temp_loc->cnt,record_data->tlist[d1.seq].loc_unit_cd,temp_loc->list[i].location_cd)
		 or expand(i,1,temp_loc->cnt,record_data->tlist[d1.seq].future_location_unit_cd,temp_loc->list[i].location_cd)
		)
	head report
		null
	detail
		call echo("->location match")
	foot report
		null
	with nocounter
	endif*/
	/*end 009*/
 
	/*start 010*/
 
	record req_view
	(
		1 cnt = i2
		1 qual[*]
		 2 format_cd = f8
		 2 format_display = vc
		 2 start_exclude_dt_tm_vc = vc
		 2 start_exclude_dt_tm = dq8
		 2 end_exclude_dt_tm_vc = vc
		 2 end_exclude_dt_tm = dq8
		1 loc_cnt = i2
		1 loc_qual[*]
		 2 location_cd = f8
		 2 display = vc
	) with protect
 
	select distinct into "nl:"
		 cv1.display
		,cv2.display
		,cve1.field_name
		,cve1.field_value
	from
		 code_value cv1
		,code_value cv2
		,code_value_extension cve1
	plan cv1
		where cv1.code_set = 103507
		and   cv1.cdf_meaning = "REQUISITION"
		and	  cv1.active_ind = 1
	join cv2
		where cv2.code_set = 6002
		and   cv2.cdf_meaning = cv1.description
	join cve1
		where cve1.code_value = cv1.code_value
		and   cve1.field_name in("EXCLUDE_DATE_START","EXCLUDE_DATE_END")
	order by
		 cv1.display
		,cv1.code_value
		,cve1.field_name
	head report
		cnt = 0
	head cv1.code_value
		cnt = (cnt + 1)
		stat = alterlist(req_view->qual,cnt)
		req_view->qual[cnt].format_cd = cv2.code_value
		req_view->qual[cnt].format_display = cv2.display
	head cve1.field_name
		case (cve1.field_name)
		 of "EXCLUDE_DATE_END": req_view->qual[cnt].end_exclude_dt_tm_vc = cve1.field_value
		 of "EXCLUDE_DATE_START": req_view->qual[cnt].start_exclude_dt_tm_vc = cve1.field_value
		endcase
	foot cv1.code_value
		if (
				(req_view->qual[cnt].end_exclude_dt_tm_vc = "")
			 or (req_view->qual[cnt].start_exclude_dt_tm_vc = "")
			)
			req_view->qual[cnt].format_cd = 0.0
			req_view->qual[cnt].format_display = ""
		else
			req_view->qual[cnt].end_exclude_dt_tm = cnvtdatetime(req_view->qual[cnt].end_exclude_dt_tm_vc)
			req_view->qual[cnt].start_exclude_dt_tm = cnvtdatetime(req_view->qual[cnt].start_exclude_dt_tm_vc)
		endif
	foot report
		req_view->cnt = cnt
	with nocounter
 
	select distinct  into "nl:"
		 cv3.display
		,cv3.code_value
		,cve1.field_name
		,cve1.field_value
	from
		 code_value cv1
		,code_value_extension cve1
		,code_value cv3
	plan cv1
		where cv1.code_set = 103507
		and   cv1.cdf_meaning in("LOCATION")
		and	  cv1.active_ind = 1
	join cve1
		where cve1.code_value = cv1.code_value
		and   cve1.field_name in("EXCLUDE_OVERRIDE")
		and   cve1.field_value in("1")
	join cv3
		where cv3.code_set = 220
		and   cv3.display = cv1.display
	order by
		 cv3.display
		,cv3.code_value
	head report
		cnt = 0
	head cv1.code_value
		cnt = (cnt + 1)
		stat = alterlist(req_view->loc_qual,cnt)
		req_view->loc_qual[cnt].display = cv3.display
		req_view->loc_qual[cnt].location_cd = cv3.code_value
	foot report
		req_view->loc_cnt = cnt
	with nocounter
 
	;call echorecord(req_view)
 
  if (size(record_data->tlist,5) > 0)
	;call echo("checking dates and times ")
	select into "nl:"
	from
		(dummyt d1 with seq=size(record_data->tlist,5))
	detail
		record_data->tlist[d1.seq].keep_ind = 4
		loc_pos = 0
		loc_pos = locateval(i,1,req_view->loc_cnt,record_data->tlist[d1.seq].loc_unit_cd,req_view->loc_qual[i].location_cd)
		if (loc_pos = 0)
		;if (uar_get_code_display(record_data->tlist[d1.seq].loc_unit_cd) != "SPH MSSU OPAT")
			pos = 0
			pos = locateval(i,1,req_view->cnt,record_data->tlist[d1.seq].requisition_format_cd,req_view->qual[i].format_cd)
			if (pos > 0)
				;call echo("->found req in exclude dates")
				;call echo(build("task_dt_tm_num=",format(record_data->tlist[d1.seq].task_dt_tm_num,";;q")))
				;call echo(build("start_exclude_dt_tm=",format(req_view->qual[pos].start_exclude_dt_tm,";;q")))
				;call echo(build("end_exclude_dt_tm=",format(req_view->qual[pos].end_exclude_dt_tm,";;q")))
				if (
						(cnvtdatetime(record_data->tlist[d1.seq].task_dt_tm_num) > cnvtdatetime(req_view->qual[pos].start_exclude_dt_tm))
				    and (cnvtdatetime(record_data->tlist[d1.seq].task_dt_tm_num) < cnvtdatetime(req_view->qual[pos].end_exclude_dt_tm))
 
				    )
				    record_data->tlist[d1.seq].keep_ind = 0
				   ;call echo("-->EXCLUDED")
				endif
			endif
		endif
 
		;call echo("remove those that don't match ")
 
		set _i = 1
		while(_i > 0)
		    if(record_data->tlist[_i].keep_ind != 4)
		       ; call echo(build("Removing index ", _i, " from record_data->tlist"))
		        set stat = alterlist(record_data->tlist, size(record_data->tlist, 5)-1, _i-1)
		        set _i = _i - 1
		    endif
 
		    if(_i = size(record_data->tlist, 5))
		        set _i = 0
		    else
		        set _i = _i + 1
		    endif
		endwhile
	endif
	/*end 010*/
 
	set record_data->timer_qual[record_data->timer_cnt].end_time = cnvtdatetime(curdate,curtime3)
	set record_data->timer_qual[record_data->timer_cnt].elapsed = datetimediff(
			 record_data->timer_qual[record_data->timer_cnt].end_time
			,record_data->timer_qual[record_data->timer_cnt].start_time
			,6)
 
 
 
	set record_data->timer_cnt = (record_data->timer_cnt + 1)
	set stat = alterlist(record_data->timer_qual,record_data->timer_cnt)
	set record_data->timer_qual[record_data->timer_cnt].start_time = cnvtdatetime(curdate,curtime3)
	set record_data->timer_qual[record_data->timer_cnt].section = "Requisition Display"
	for (i = 1 to size(record_data->tlist,5))
		set k = 1
		set order_string = ""
		if (record_data->tlist[i].requisition_format_cd > 0.0)
			set order_string = uar_get_code_meaning(record_data->tlist[i].requisition_format_cd)
		endif
		select into "nl:"
		from code_value cv
		plan cv
			where cv.code_set = bc_common->code_set
			and   cv.active_ind = 1
			and   cv.description = order_string
		detail
			;004 record_data->tlist[i].task_type = cv.display
			record_data->tlist[i].task_type = cv.display
			record_data->tlist[i].task_type = replace(record_data->tlist[i].task_type,"Requisition","") ;004
			record_data->tlist[i].task_type = replace(record_data->tlist[i].task_type,"Diagnostic","") ;004
			;record_data->tlist[i].task_describ = replace(record_data->tlist[tcnt ].task_describ,trim(cv.display),"")
			record_data->tlist[i].task_display = replace(record_data->tlist[i].task_display,concat(" - ",trim(cv.display)),"")
		with nocounter
	endfor
	set record_data->timer_qual[record_data->timer_cnt].end_time = cnvtdatetime(curdate,curtime3)
	set record_data->timer_qual[record_data->timer_cnt].elapsed = datetimediff(
		 record_data->timer_qual[record_data->timer_cnt].end_time
		,record_data->timer_qual[record_data->timer_cnt].start_time
		,6)
 
	set record_data->timer_cnt = (record_data->timer_cnt + 1)
	set stat = alterlist(record_data->timer_qual,record_data->timer_cnt)
	set record_data->timer_qual[record_data->timer_cnt].start_time = cnvtdatetime(curdate,curtime3)
	set record_data->timer_qual[record_data->timer_cnt].section = "Requisition History"
 
	select into "nL:"
	from
		ce_event_prsnl cep
		,(dummyt d1 with seq=size(record_data->tlist,5))
	plan d1
		where record_data->tlist[d1.seq].event_id > 0.0
	join cep
		where cep.event_id =   record_data->tlist[d1.seq].parent_event_id
		and   cep.action_type_cd in(
										value(uar_get_code_by("MEANING",21,"AUTHOR"))
									)
		and   cnvtdatetime(curdate,curtime3) between cep.valid_from_dt_tm and cep.valid_until_dt_tm
	order by
		cep.event_id
		,cep.action_dt_tm desc
	head cep.event_id
		record_data->tlist[d1.seq].latest_status = cep.action_comment
		record_data->tlist[d1.seq].latest_status_dt_tm = cep.action_dt_tm
		;call echo(build(cep.event_id,":latest_status=",trim(record_data->tlist[d1.seq].latest_status)))
	with nocounter
 
	for (i = 1 to size(record_data->tlist,5))
		if (record_data->tlist[i].latest_status = "")
			set record_data->tlist[i].latest_status = "To Be Actioned"
		endif
	endfor
 
	select into "nL:"
	from
		ce_event_prsnl cep
		,(dummyt d1 with seq=size(record_data->tlist,5))
	plan d1
		where record_data->tlist[d1.seq].event_id > 0.0
	join cep
		where cep.event_id =   record_data->tlist[d1.seq].parent_event_id
		and   cep.action_type_cd in(
										value(uar_get_code_by("MEANING",21,"ASSIST"))
									)
		and   cnvtdatetime(curdate,curtime3) between cep.valid_from_dt_tm and cep.valid_until_dt_tm
	order by
		cep.event_id
		,cep.action_dt_tm desc
	head cep.event_id
		record_data->tlist[d1.seq].latest_comment = cep.action_comment
		;call echo(build(cep.event_id,":latest_comment=",trim(record_data->tlist[d1.seq].latest_comment)))
	with nocounter
 
 
	set record_data->timer_qual[record_data->timer_cnt].end_time = cnvtdatetime(curdate,curtime3)
	set record_data->timer_qual[record_data->timer_cnt].elapsed = datetimediff(
		 record_data->timer_qual[record_data->timer_cnt].end_time
		,record_data->timer_qual[record_data->timer_cnt].start_time
		,6)
 
	set record_data->timer_cnt = (record_data->timer_cnt + 1)
	set stat = alterlist(record_data->timer_qual,record_data->timer_cnt)
	set record_data->timer_qual[record_data->timer_cnt].start_time = cnvtdatetime(curdate,curtime3)
	set record_data->timer_qual[record_data->timer_cnt].section = "Alias"
 
 
	select into "nl:"
	from
		 (dummyt d1 with seq=size(record_data->tlist,5))
		,encounter e
		,encntr_alias ea
		,person_alias pa
		,(dummyt d2)
	plan d1
		where record_data->tlist[d1.seq].encounter_id > 0.0
	join e
		where e.encntr_id = record_data->tlist[d1.seq].encounter_id
	join ea
		where ea.encntr_id = e.encntr_id
		and   ea.encntr_alias_type_cd in(
											 value(uar_get_code_by("MEANING",319,"MRN"))
											,value(uar_get_code_by("MEANING",319,"FIN NBR"))
										)
		and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
		and   ea.active_ind = 1
	join d2
	join pa
		where pa.person_id = e.person_id
		and   pa.person_alias_type_cd in(value(uar_get_code_by("MEANING",4,"NHIN")))
		and   cnvtdatetime(curdate,curtime3) between pa.beg_effective_dt_tm and pa.end_effective_dt_tm
		and   pa.active_ind = 1
	order by
		pa.beg_effective_dt_tm
		,ea.beg_effective_dt_tm
	head report
		stat = 0
		;call echo("inside alias query")
	detail
		record_data->tlist[d1.seq].phn = cnvtalias(pa.alias,pa.alias_pool_cd)
		case (uar_get_code_meaning(ea.encntr_alias_type_cd))
		  of "MRN": record_data->tlist[d1.seq].mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
		  of "FIN NBR": record_data->tlist[d1.seq].fin = cnvtalias(ea.alias,ea.alias_pool_cd)
		endcase
	foot report
		stat = 0
	with nocounter,nullreport,outerjoin=d2
 
 
	set record_data->timer_qual[record_data->timer_cnt].end_time = cnvtdatetime(curdate,curtime3)
	set record_data->timer_qual[record_data->timer_cnt].elapsed = datetimediff(
		 record_data->timer_qual[record_data->timer_cnt].end_time
		,record_data->timer_qual[record_data->timer_cnt].start_time
		,6)
 END ;Subroutine
 
 
 
 
for (i=1 to record_data->timer_cnt)
	if (i>1)
		set record_data->timer_final = build(	 record_data->timer_final,"; ")
	endif
	set record_data->timer_final = concat(	 record_data->timer_final
											,record_data->timer_qual[i].section
											,":"
											,trim(cnvtstring(record_data->timer_qual[i].elapsed)))
 
	;call echo(build2("record_data->timer_qual[i].section=",record_data->timer_qual[i].section))
	;call echo(build2("record_data->timer_qual[i].elapsed=",record_data->timer_qual[i].elapsed))
endfor
if (tcnt > 0)
	SET record_data->status_data.status = "S"
else
	SET record_data->status_data.status = "S"
endif
SET modify maxvarlen 50000000
;SET _memory_reply_string = cnvtrectojson (record_data )
/*
select into "cclscratch:req_temp.csv"
 person_id  = record_data->tlist[d1.seq].person_id
,encounter_id  = record_data->tlist[d1.seq].encounter_id
,person_name  = substring(1,100,record_data->tlist[d1.seq].person_name )
,phn  = substring(1,100,record_data->tlist[d1.seq].phn )
,mrn  = substring(1,100,record_data->tlist[d1.seq].mrn )
,gender  = substring(1,100,record_data->tlist[d1.seq].gender )
,gender_char  = substring(1,100,record_data->tlist[d1.seq].gender_char )
,dob  = substring(1,100,record_data->tlist[d1.seq].dob )
,age  = substring(1,100,record_data->tlist[d1.seq].age )
,age_long  = substring(1,100,record_data->tlist[d1.seq].age_long )
,fin  = substring(1,100,record_data->tlist[d1.seq].fin )
,encntr_type  = substring(1,100,record_data->tlist[d1.seq].encntr_type )
,encntr_status  = substring(1,100,record_data->tlist[d1.seq].encntr_status )
,unit  = substring(1,100,record_data->tlist[d1.seq].unit )
,room_bed  = substring(1,100,record_data->tlist[d1.seq].room_bed )
,task_type  = substring(1,100,record_data->tlist[d1.seq].task_type )
,task_id  = record_data->tlist[d1.seq].task_id
,task_type_ind  = record_data->tlist[d1.seq].task_type_ind
,task_describ  = substring(1,100,record_data->tlist[d1.seq].task_describ )
,task_display  = substring(1,100,record_data->tlist[d1.seq].task_display )
,task_prn_ind  = record_data->tlist[d1.seq].task_prn_ind
,task_date  = substring(1,100,record_data->tlist[d1.seq].task_date )
,task_overdue  = record_data->tlist[d1.seq].task_overdue
,task_time  = substring(1,100,record_data->tlist[d1.seq].task_time )
,task_dt_tm_num  = format(record_data->tlist[d1.seq].task_dt_tm_num, ";;q")
,task_dt_tm_utc  = substring(1,100,record_data->tlist[d1.seq].task_dt_tm_utc )
,task_form_id  = record_data->tlist[d1.seq].task_form_id
,charge_ind  = record_data->tlist[d1.seq].charge_ind
,task_status  = substring(1,100,record_data->tlist[d1.seq].task_status )
,clerk_status  = substring(1,100,record_data->tlist[d1.seq].clerk_status )
,display_status  = substring(1,100,record_data->tlist[d1.seq].display_status )
,inprocess_ind  = record_data->tlist[d1.seq].inprocess_ind
,order_id  = substring(1,100,record_data->tlist[d1.seq].order_id )
,order_id_real  = record_data->tlist[d1.seq].order_id_real
,ordered_as_name  = substring(1,100,record_data->tlist[d1.seq].ordered_as_name )
,order_cdl  = substring(1,100,record_data->tlist[d1.seq].order_cdl )
,orig_order_dt  = substring(1,100,record_data->tlist[d1.seq].orig_order_dt )
,order_dt_tm_utc  = substring(1,100,record_data->tlist[d1.seq].order_dt_tm_utc )
,ordering_provider  = substring(1,100,record_data->tlist[d1.seq].ordering_provider )
,ord_comment  = substring(1,100,record_data->tlist[d1.seq].ord_comment )
,task_note  = substring(1,100,record_data->tlist[d1.seq].task_note )
,task_resched_time  = record_data->tlist[d1.seq].task_resched_time
,can_chart_ind  = record_data->tlist[d1.seq].can_chart_ind
,visit_loc  = substring(1,100,record_data->tlist[d1.seq].visit_loc )
,visit_date  = substring(1,100,record_data->tlist[d1.seq].visit_date )
,visit_date_display  = substring(1,100,record_data->tlist[d1.seq].visit_date_display )
,visit_dt_tm_num  = format(record_data->tlist[d1.seq].visit_dt_tm_num, ";;q")
,visit_dt_utc  = substring(1,100,record_data->tlist[d1.seq].visit_dt_utc )
,charted_by  = substring(1,100,record_data->tlist[d1.seq].charted_by )
,charted_dt  = substring(1,100,record_data->tlist[d1.seq].charted_dt )
,charted_dt_utc  = substring(1,100,record_data->tlist[d1.seq].charted_dt_utc )
,not_done  = record_data->tlist[d1.seq].not_done
,result_set_id  = record_data->tlist[d1.seq].result_set_id
,not_done_reason  = substring(1,100,record_data->tlist[d1.seq].not_done_reason )
,not_done_reason_comm  = substring(1,100,record_data->tlist[d1.seq].not_done_reason_comm )
,status_reason_cd  = record_data->tlist[d1.seq].status_reason_cd
,powerplan_ind  = record_data->tlist[d1.seq].powerplan_ind
,powerplan_name  = substring(1,100,record_data->tlist[d1.seq].powerplan_name )
,event_id  = record_data->tlist[d1.seq].event_id
,parent_event_id  = record_data->tlist[d1.seq].parent_event_id
,normal_ref_range_txt  = substring(1,100,record_data->tlist[d1.seq].normal_ref_range_txt )
,requisition_format_cd  = record_data->tlist[d1.seq].requisition_format_cd
,dfac_activity_id  = record_data->tlist[d1.seq].dfac_activity_id
,priority  = substring(1,100,record_data->tlist[d1.seq].priority )
,priority_rank  = record_data->tlist[d1.seq].priority_rank
,sub_activity_type  = substring(1,100,record_data->tlist[d1.seq].sub_activity_type )
,action_history  = substring(1,100,record_data->tlist[d1.seq].action_history )
,comment_history  = substring(1,100,record_data->tlist[d1.seq].comment_history )
,status_history  = substring(1,100,record_data->tlist[d1.seq].status_history )
,latest_comment  = substring(1,100,record_data->tlist[d1.seq].latest_comment )
,latest_status  = substring(1,100,record_data->tlist[d1.seq].latest_status )
,keep_ind  = record_data->tlist[d1.seq].keep_ind
,olist_cnt  = record_data->tlist[d1.seq].olist_cnt
,multiple_order_dates_ind  = record_data->tlist[d1.seq].multiple_order_dates_ind
,loc_unit_cd  = record_data->tlist[d1.seq].loc_unit_cd
,future_location_unit_cd  = record_data->tlist[d1.seq].future_location_unit_cd
from
	(dummyt d1 with seq=size(record_data->tlist,5))
plan d1
	with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,maxcol=64000,format
*/
 
 
record temp_priority
(
	1 cnt = i2
	1 qual[*]
	 2 display = vc
	 2 lookahead = vc
)
 
set temp_priority->cnt = 14
set stat = alterlist(temp_priority->qual,temp_priority->cnt)
 
set temp_priority->qual[1].display = "Within 1 Week"
set temp_priority->qual[2].display = "Within 2 Weeks"
set temp_priority->qual[3].display = "As Per Special Instructions"
set temp_priority->qual[4].display = "Next Available Appointment"
set temp_priority->qual[5].display = "Within 24 hours"
set temp_priority->qual[6].display = "Within 48 hours"
set temp_priority->qual[7].display = "Within 72 hours"
set temp_priority->qual[8].display = "Within 4 Weeks"
set temp_priority->qual[9].display = "Within 6 Weeks"
set temp_priority->qual[10].display = "Within 2 Months"
set temp_priority->qual[11].display = "Within 4 Months"
set temp_priority->qual[12].display = "Within 6 Months"
set temp_priority->qual[13].display = "Within 1 Year"
set temp_priority->qual[14].display = "Within 3 Months"
 
set temp_priority->qual[1].lookahead = "7	,D"
set temp_priority->qual[2].lookahead = "14	,D"
set temp_priority->qual[3].lookahead = "0	,D"
set temp_priority->qual[4].lookahead = "0	,D"
set temp_priority->qual[5].lookahead = "1	,D"
set temp_priority->qual[6].lookahead = "2	,D"
set temp_priority->qual[7].lookahead = "3	,D"
set temp_priority->qual[8].lookahead = "28	,D"
set temp_priority->qual[9].lookahead = "42	,D"
set temp_priority->qual[10].lookahead ="2	,M"
set temp_priority->qual[11].lookahead ="4	,M"
set temp_priority->qual[12].lookahead ="6	,M"
set temp_priority->qual[13].lookahead ="1	,Y"
set temp_priority->qual[14].lookahead ="3	,M"
 
select into "nl:"
	parent_event_id  = record_data->tlist[d1.seq].parent_event_id
from
	(dummyt d1 with seq=size(record_data->tlist,5))
order by
	parent_event_id
head report
	output_data->cnt = 0
	valid_ind = 0
	pos = 0
head parent_event_id
	valid_ind = 0
	if (record_data->tlist[d1.seq].parent_event_id > 0.0)
		if (record_data->tlist[d1.seq].visit_dt_tm_num > 0.0)
			valid_ind = 1
		endif
	endif
	if ((record_data->tlist[d1.seq].unit not in("BCC VA*"))
		and
		(uar_Get_code_display(record_data->tlist[d1.seq].future_location_unit_cd) not in("BCC VA*"))
		)
		valid_ind = 0
	endif
foot parent_event_id
 if (valid_ind = 1)
	output_data->cnt = (output_data->cnt + 1)
	stat = alterlist(output_data->qual,output_data->cnt)
	output_data->qual[output_data->cnt].parent_event_id 	= record_data->tlist[d1.seq].parent_event_id
	output_data->qual[output_data->cnt].ordered_dt_tm 		= record_data->tlist[d1.seq].task_dt_tm_num
	output_data->qual[output_data->cnt].ordered_dt 			= format(record_data->tlist[d1.seq].task_dt_tm_num,"dd-mmm-yyyy;;q")
	output_data->qual[output_data->cnt].requested_dt_tm 	= record_data->tlist[d1.seq].visit_dt_tm_num
	output_data->qual[output_data->cnt].requested_dt	 	= format(record_data->tlist[d1.seq].visit_dt_tm_num,"dd-mmm-yyyy;;q")
	output_data->qual[output_data->cnt].current_req_status 	= record_data->tlist[d1.seq].latest_status
	output_data->qual[output_data->cnt].requisition_type 	= record_data->tlist[d1.seq].task_type
	output_data->qual[output_data->cnt].unit 				= record_data->tlist[d1.seq].unit
	output_data->qual[output_data->cnt].req_status_dt_tm	= record_data->tlist[d1.seq].latest_status_dt_tm
	output_data->qual[output_data->cnt].priority			= record_data->tlist[d1.seq].priority
	output_data->qual[output_data->cnt].mrn					= record_data->tlist[d1.seq].mrn
	output_data->qual[output_data->cnt].subtype				= record_data->tlist[d1.seq].sub_activity_type
	output_data->qual[output_data->cnt].req_title			= record_data->tlist[d1.seq].task_display
	output_data->qual[output_data->cnt].ordering_provider	= record_data->tlist[d1.seq].ordering_provider
	output_data->qual[output_data->cnt].req_status_dt		= format(record_data->tlist[d1.seq].latest_status_dt_tm,"dd-mmm-yyyy;;q")
 
	if (record_data->tlist[d1.seq].task_status = "Printed")
		output_data->qual[output_data->cnt].printed_ind = 1
		output_data->qual[output_data->cnt].processed_ind = 1
	endif
 
	if (output_data->qual[output_data->cnt].current_req_status in("*Complete*","*Clinician Printed*"))
		output_data->qual[output_data->cnt].processed_ind = 1
		output_data->qual[output_data->cnt].completed_dt_tm = record_data->tlist[d1.seq].latest_status_dt_tm
		output_data->qual[output_data->cnt].completed_dt = format(record_data->tlist[d1.seq].latest_status_dt_tm,"dd-mmm-yyyy;;q")
	endif
 
	if (output_data->qual[output_data->cnt].processed_ind = 0)
		pos = 0
		pos = locateval(i,1,temp_priority->cnt,output_data->qual[output_data->cnt].priority,temp_priority->qual[i].display)
		if ((pos > 0) and (output_data->qual[output_data->cnt].requested_dt_tm < cnvtdatetime(curdate,curtime3)))
			output_data->qual[output_data->cnt].calc_requested_dt_tm = cnvtlookahead(
																						 temp_priority->qual[pos].lookahead
																						,output_data->qual[output_data->cnt].requested_dt_tm
																					)
			output_data->qual[output_data->cnt].calc_request_dt
				= format(output_data->qual[output_data->cnt].calc_requested_dt_tm,"dd-mmm-yyyy;;q")
		endif
		if (output_data->qual[output_data->cnt].requested_dt_tm < cnvtdatetime(curdate,curtime3))
			output_data->qual[output_data->cnt].overdue_ind = 1
		endif
	endif
 endif
foot report
	null
with nocounter
 
set output_data->yesterday_start_dt_tm = datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'B', 'B')
set output_data->yesterday_end_dt_tm = datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'E', 'E')
 
select into "nL:"
from
	ce_event_prsnl cep
	,(dummyt d1 with seq=output_data->cnt)
plan d1
	where output_data->qual[d1.seq].parent_event_id > 0.0
	and   output_data->qual[d1.seq].printed_ind = 1
join cep
	where cep.event_id =   output_data->qual[d1.seq].parent_event_id
	and   cep.action_type_cd in(
									value(uar_get_code_by("MEANING",21,"CONFIRM"))
								)
	and   cnvtdatetime(curdate,curtime3) between cep.valid_from_dt_tm and cep.valid_until_dt_tm
order by
	cep.event_id
	,cep.action_dt_tm desc
head cep.event_id
	output_data->qual[d1.seq].printed_dt_tm = cep.action_dt_tm
	output_data->qual[d1.seq].printed_dt = format(cep.action_dt_tm,"dd-mmm-yyyy;;q")
with nocounter
 
select into "nl:"
from
	(dummyt d1 with seq=output_data->cnt)
plan d1
detail
 if (output_data->qual[d1.seq].processed_ind = 1)
	if (output_data->qual[d1.seq].printed_dt_tm
			between cnvtdatetime(output_data->yesterday_start_dt_tm) and cnvtdatetime(output_data->yesterday_end_dt_tm))
		output_data->qual[d1.seq].processed_yesterday_ind = 1
	endif
	if (output_data->qual[d1.seq].completed_dt_tm
			between cnvtdatetime(output_data->yesterday_start_dt_tm) and cnvtdatetime(output_data->yesterday_end_dt_tm))
		output_data->qual[d1.seq].processed_yesterday_ind = 1
	endif
 endif
 
 if (output_data->qual[d1.seq].ordered_dt_tm
			between cnvtdatetime(output_data->yesterday_start_dt_tm) and cnvtdatetime(output_data->yesterday_end_dt_tm))
		output_data->qual[d1.seq].net_new_yesterday_ind = 1
	endif
 
with nocounter
 
 
#exit_script
	;call echo("exit_script")
#exit_program
 CALL log_message (concat ("Exiting script: " ,log_program_name ) ,log_level_debug )
 CALL log_message (build ("Total time in seconds:" ,
 	datetimediff (cnvtdatetime (curdate ,curtime3 ) ,current_date_time ,5 ) ) ,log_level_debug )
 ;call echo(build("req count=",size(record_data->tlist,5)))
 ;call echorecord(record_data)
 ;call echorecord(output_data)
 
 FREE RECORD record_data
 
END GO
