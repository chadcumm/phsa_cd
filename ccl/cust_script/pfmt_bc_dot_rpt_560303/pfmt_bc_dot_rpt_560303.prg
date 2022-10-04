/*****************************************************************************
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   pfmt_bc_dot_rpt_560303.prg
  Object name:        pfmt_bc_dot_rpt_560303
  Request #:

  Program purpose:

  Executing from:     

  Special Notes:       

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   10/01/2019  Chad Cummings			Initial Release
******************************************************************************/
drop program pfmt_bc_dot_rpt_560303:dba go
create program pfmt_bc_dot_rpt_560303:dba

call echo(build("loading script:",curprog))
set nologvar = 1	;do not create log = 1		, create log = 0
set debug_ind = 0	;0 = no debug, 1=basic debug with echo, 2=msgview debug

%i cust_script:bc_common_routines.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))

if (not(validate(reply,0)))
record  reply
(
	1 text = vc
	1 status_data
	 2 status = c1
	 2 subeventstatus[1]
	  3 operationname = c15
	  3 operationstatus = c1
	  3 targetobjectname = c15
	  3 targetobjectvalue = c100
)
endif

free set t_rec
record t_rec
(
	1 cnt			= i4
	1 person_id		= f8
	1 encntr_id		= f8
	1 beg_date		= dq8
	1 end_date		= dq8
	1 rpt_beg_date	= vc
	1 rpt_end_date	= vc
	1 dot_order_action_found_ind = i2
	1 trigger = vc
	1 audit_mode = i2
	1 event_cnt = i2
	1 event_qual[*]
	 2 event_id = f8
	1 post_event_cnt = i2
	1 post_event_qual[*]
	 2 event_id = f8
)

record EKSOPSRequest (
   1 expert_trigger	= vc
   1 qual[*]
	2 person_id	= f8
	2 sex_cd	= f8
	2 birth_dt_tm	= dq8
	2 encntr_id	= f8
	2 accession_id	= f8
	2 order_id	= f8
	2 data[*]
	     3 vc_var		= vc
	     3 double_var	= f8
	     3 long_var		= i4
	     3 short_var	= i2
)

set bc_common->log_level = 2
set t_rec->audit_mode = 0

;call bc_custom_code_set(0)
;call bc_check_validation(0)

declare cv_6003_activate = f8 with constant(uar_get_code_by("MEANING", 6003, "ACTIVATE")), protect
declare cv_6003_order = f8 with constant(uar_get_code_by("MEANING", 6003, "ORDER")), protect
declare cv_6003_modify = f8 with constant(uar_get_code_by("MEANING", 6003, "MODIFY")), protect
declare cv_6003_resched = f8 with constant(uar_get_code_by("MEANING", 6003, "RESCHEDULE")), protect
declare cv_16769_planned = f8 with constant(uar_get_code_by("MEANING", 16769, "PLANNED")), protect
 
set t_rec->beg_date = datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'B', 'B')
set t_rec->end_date = datetimefind(cnvtlookahead("5,D",cnvtdatetime(curdate,curtime3)), 'D', 'E', 'E')
set t_rec->rpt_beg_date = format(cnvtdatetime(t_rec->beg_date), "dd-mmm-yyyy;;q")
set t_rec->rpt_end_date = format(cnvtdatetime(t_rec->end_date), "dd-mmm-yyyy;;q")

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))

/*
{"REQUESTIN":{
 "REQUEST":{
  "MOD_LIST":[
  {
   "TASK_ID":371221369.000000,
   "UPDT_CNT":0,
   "TASK_STATUS_MEANING":"COMPLETE    ",
   "TASK_DT_TM":"\/Date(2021-
   */
if (validate(requestin) = 1)
	if (program_log->produce_log = 0)
		call writeLog(build2("-->writing requestin to ",program_log->files.filename_audit))
		call echojson(requestin,program_log->files.filename_audit,1)
	endif
	call echorecord(requestin)
	
	if (validate(requestin->request->mod_list))
		if (size(requestin->request->mod_list,5) > 0)
			select into "nl:"
			from
				task_activity ta
				,clinical_event ce
			plan ta
				where ta.task_id = requestin->request->mod_list[1].task_id
				and   ta.active_ind = 1
				and   ta.task_type_cd in(value(uar_get_code_by("MEANING",6026,"MED")))
			join ce
				where ce.person_id = ta.person_id
				and   ce.event_cd in(value(uar_get_code_by("DISPLAY_KEY", 72, "DOWNTIMEDOTORDERSREPORT")))
				and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
				and	  ce.result_status_cd in(
												  value(uar_get_code_by("MEANING",8,"AUTH"))
												 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
												 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
											)
				and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
				and   ce.event_tag        != "Date\Time Correction"
			order by
				ta.person_id
			head ta.person_id
				t_rec->person_id = ta.person_id
				t_rec->encntr_id = ta.encntr_id
		endif
	endif
	/*
	set t_rec->person_id = requestin->request->person_id
	if (validate(requestin->request->phases[1].encounter_id))
		set t_rec->encntr_id = requestin->request->phases[1].encounter_id
	endif
	*/
endif

/*
call writeLog(build2("call pause(1)"))
	call pause(1)

call writeLog(build2("call pause(1)"))
	call pause(1)

call writeLog(build2("call pause(1)"))
	call pause(1)
*/

if (t_rec->encntr_id > 0.0)
	call writeLog(build2("checking for DOT PowerPlans"))
	select distinct
		o.encntr_id
		,o.originating_encntr_id
	from
		 orders o
		,act_pw_comp apc
		,pathway p
	plan o
		where o.person_id = t_rec->person_id
		and o.order_status_cd in(
									  value(uar_get_code_by("MEANING",6004,"ORDERED"))
									 ,value(uar_get_code_by("MEANING",6004,"FUTURE"))
									 ,value(uar_get_code_by("MEANING",6004,"PENDING"))
									)
	 
		and o.current_start_dt_tm between cnvtdatetime(t_rec->beg_date) and cnvtdatetime(t_rec->end_date)
	join apc
		where apc.parent_entity_id = o.order_id
	join p
		where p.pathway_id = apc.pathway_id
		and   p.type_mean = "DOT"
	order by
		o.person_id
	head o.person_id
		t_rec->dot_order_action_found_ind = 1
		call writeLog(build2("qualified on active plan"))
	with nocounter
	 
	if (t_rec->dot_order_action_found_ind = 0)
		call writeLog(build2("checking for Planned PowerPlans"))
		select into "nl:"
		from
			 pathway p
			 ,regimen_detail rd
			 ,regimen r
		plan p
			where p.pw_status_cd in(value(uar_get_code_by("MEANING",16769,"PLANNED")))
			;and   p.duration_qty > 0
			and   p.person_id = t_rec->person_id
		join rd												
			where rd.activity_entity_id = p.pw_group_nbr	
		join r												
			where r.regimen_id = rd.regimen_id	
		order by
			 p.person_id
		head p.person_id
			t_rec->dot_order_action_found_ind = 1
			call writeLog(build2("qualified on planned plan"))
		with nocounter
		
		if (t_rec->dot_order_action_found_ind = 0)
			call writeLog(build2("checking for Proposed PowerPlans"))
			select into "nl:"
		    from
		    	pathway p
		    plan p
		    	where p.person_id = t_rec->person_id
		    	and   p.pw_status_cd in(
		    									 value(uar_get_code_by("MEANING",16769,"PLANNED"))
		    									,value(uar_get_code_by("MEANING",16769,"ORDERED"))
		    									,value(uar_get_code_by("MEANING",16769,"STARTED"))
		    									,value(uar_get_code_by("MEANING",16769,"FUTURE"))
		    									,value(uar_get_code_by("MEANING",16769,"PROPOSED"))
		    									,value(uar_get_code_by("MEANING",16769,"FUTURPROPOSE"))
		    									,value(uar_get_code_by("MEANING",16769,"INITIATED")))
		    	and   p.review_status_flag = 1
		    	and   p.type_mean = "DOT"
		    	and   p.start_dt_tm between cnvtdatetime(t_rec->beg_date) and cnvtdatetime(t_rec->end_date)
		    order by
		   		p.person_id
		   	head p.person_id
		   		t_rec->dot_order_action_found_ind = 1
		   		call writeLog(build2("qualified on proposed plan"))
		    with nocounter
		endif
	endif
endif

;Find existing Downtime documents to remove
call writeLog(build2("Find existing Downtime documents to remove"))
select into "nl:"
from
	clinical_event ce
plan ce
	where ce.person_id = t_rec->person_id
	and ce.event_cd in(
							value(uar_get_code_by("DISPLAY_KEY", 72, "DOWNTIMEDOTORDERSREPORT")))
	and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
order by
	 ce.person_id
	,ce.parent_event_id
head report
	i = 0
head ce.person_id
	null
head ce.parent_event_id
	i = (i + 1)
	stat = alterlist(t_rec->event_qual,i)
	t_rec->event_qual[i].event_id = ce.parent_event_id
foot ce.parent_event_id
	null
foot ce.person_id
	null
foot report
	t_rec->event_cnt = i
with nocounter
 
if (t_rec->encntr_id > 0.0)
	call writeLog(build2("removing existing documents count: ",t_rec->event_cnt))
	for (i = 1 to t_rec->event_cnt)
		;execute bc_onc_inerror_document ^NOFORMS^,value(t_rec->event_qual[i].event_id)
		;call writeLog(build2("t_rec->event_qual[i].event_id: ",t_rec->event_qual[i].event_id))
		set t_rec->dot_order_action_found_ind = 1
	endfor
endif
/* Final check before running the report */
if ((t_rec->dot_order_action_found_ind = 1) and (t_rec->encntr_id > 0.0))
 
    call writeLog(build2("encntr_id: ",t_rec->encntr_id))
    call writeLog(build2("t_rec->rpt_beg_date: ", t_rec->rpt_beg_date))
    call writeLog(build2("t_rec->rpt_end_date: ", t_rec->rpt_end_date))
    call writeLog(build2("calling rule"))
    
%i cclsource:eks_run3091001.inc

	
	set t_rec->trigger = "BCC_DOT_EE_DOWNTIME_RPT"
	
	call writeLog(build2("-->Setting Expert Trigger to ",t_rec->trigger))
	set stat = initrec(EKSOPSRequest)
	select into "NL:"
		e.encntr_id,
		e.person_id,
		e.reg_dt_tm,
		p.birth_dt_tm,
		p.sex_cd
	from
		person p,
		encounter e
	plan e
		where e.encntr_id = t_rec->encntr_id
	join p where p.person_id= e.person_id
	head report
		cnt = 0
		EKSOPSRequest->expert_trigger = t_rec->trigger
	detail
		cnt = cnt +1
		stat = alterlist(EKSOPSRequest->qual, cnt)
		EKSOPSRequest->qual[cnt].person_id = p.person_id
		EKSOPSRequest->qual[cnt].sex_cd  = p.sex_cd
		EKSOPSRequest->qual[cnt].birth_dt_tm  = p.birth_dt_tm
		EKSOPSRequest->qual[cnt].encntr_id  = e.encntr_id
		call writeLog(build2("---->EKSOPSRequest->qual[",trim(cnvtstring(cnt)),"].person_id=",
			trim(cnvtstring(EKSOPSRequest->qual[cnt].person_id))))
		call writeLog(build2("---->EKSOPSRequest->qual[",trim(cnvtstring(cnt)),"].encntr_id=",
			trim(cnvtstring(EKSOPSRequest->qual[cnt].encntr_id))))
	with nocounter
	set dparam = 0
	if (t_rec->audit_mode != 1)
		call writeLog(build2("------>CALLING srvRequest"))
		;002 call srvRequest(dparam)
		;002 call pause(3)
		set dparam = tdbexecute(3055000,4801,3091001,"REC",EKSOPSRequest,"REC",ReplyOut) ;002
		call writeLog(build2(cnvtrectojson(ReplyOut)))	;002
	else
		call writeLog(build2("------>AUDIT MODE, Not calling srvRequest"))
	endif
	call writeLog(build2(cnvtrectojson(EKSOPSRequest)))	;002
endif

call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

#exit_script
if (validate(t_rec) = 1)
	if (program_log->produce_log = 0)
		call writeLog(build2("-->writing t_rec to ",program_log->files.filename_audit))
		call echojson(t_rec,program_log->files.filename_audit,1)
	endif
	call echorecord(t_rec)
endif
call exitScript(null)
call echorecord(t_rec)
call echorecord(program_log)

end 
go
