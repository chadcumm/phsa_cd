/*****************************************************************************
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   eks_bc_dot_rpt_560201.prg
  Object name:        eks_bc_dot_rpt_560201
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
drop program eks_bc_dot_rpt_560201:dba go
create program eks_bc_dot_rpt_560201:dba

set retval = -1

call echo(build("loading script:",curprog))
set nologvar = 1	;do not create log = 1		, create log = 0
set debug_ind = 0	;0 = no debug, 1=basic debug with echo, 2=msgview debug

%i cust_script:bc_common_routines.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Report *********************************************"))

/*
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
*/

free set t_rec
record t_rec
(
	1 cnt			= i4
	1 person_id		= f8
	1 encntr_id		= f8
	1 order_id		= f8
	1 event_name    = vc
	1 beg_date		= dq8
	1 end_date		= dq8
	1 rpt_beg_date	= vc
	1 rpt_end_date	= vc
	1 dot_order_action_found_ind = i2
	1 event_cnt = i2
	1 event_qual[*]
	 2 event_id = f8
	1 post_event_cnt = i2
	1 post_event_qual[*]
	 2 event_id = f8
)

set bc_common->log_level = 2
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

set t_rec->event_name = eks_common->event_name
set t_rec->person_id = trigger_personid
set t_rec->encntr_id = trigger_encntrid
set t_rec->order_id = trigger_orderid


call writeLog(build2("t_rec->event_name=",t_rec->event_name))

if (t_rec->person_id = 0.0)
	set log_message = "Missing Person ID"
	go to exit_script
endif


if ((t_rec->order_id = 0.0) and (t_rec->event_name="ORDER_EVENT"))
	set log_message = "Missing Order ID"
	go to exit_script
endif

call writeLog(build2("person_id: ",t_rec->person_id))
call writeLog(build2("order_id: ",t_rec->order_id))

if (t_rec->encntr_id = 0.0)
select into "nl:"
	from
		orders o
	plan o
		where o.order_id = t_rec->order_id
	detail
		if (o.encntr_id > 0.0)
			t_rec->encntr_id = o.encntr_id
		elseif (o.originating_encntr_id > 0.0)
			t_rec->encntr_id = o.originating_encntr_id
		endif	
	with nocounter
endif

/*
if (validate(requestin) = 1)
	if (program_log->produce_log = 0)
		call writeLog(build2("-->writing requestin to ",program_log->files.filename_audit))
		call echojson(requestin,program_log->files.filename_audit,1)
	endif
	;call echorecord(requestin)
	
	if (validate(requestin->request))
		if (requestin->request->personid = 0)
			go to exit_script
		else
			set t_rec->person_id = requestin->request->personid
			if (validate(requestin->request->orderList))
				if (size(requestin->request->orderList, 5) > 0)
					set t_rec->encntr_id = requestin->request->orderList[1].encntrid
					
					if (t_rec->encntr_id = 0.0)
						set t_rec->encntr_id = requestin->request->orderList[1].originatingencounterid
						
						if (t_rec->encntr_id = 0.0)
							select into "nl:"
							from
								orders o
							plan o
								where o.order_id = requestin->request->orderList[1].orderid
							detail
								if (o.encntr_id > 0.0)
									t_rec->encntr_id = o.encntr_id
								elseif (o.originating_encntr_id > 0.0)
									t_rec->encntr_id = o.originating_encntr_id
								endif	
							with nocounter
						endif
					endif
				endif
			endif
		endif
	endif
endif
*/
/*
call writeLog(build2("call pause(1)"))
	call pause(1)

call writeLog(build2("call pause(1)"))
	call pause(1)

call writeLog(build2("call pause(1)"))
	call pause(1)
*/

set retval = 0
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
		call writeLog(build2("->found DOT powerplan with orders in range"))
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
			call writeLog(build2("->found Planned reginem powerplan"))
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
		execute bc_onc_inerror_document ^NOFORMS^,value(t_rec->event_qual[i].event_id)
		call writeLog(build2("t_rec->event_qual[i].event_id: ",t_rec->event_qual[i].event_id))
	endfor
endif
/* Final check before running the report */
if ((t_rec->dot_order_action_found_ind = 1) and (t_rec->encntr_id > 0.0))
 
    call writeLog(build2("encntr_id: ",t_rec->encntr_id))
    call writeLog(build2("t_rec->rpt_beg_date: ", t_rec->rpt_beg_date))
    call writeLog(build2("t_rec->rpt_end_date: ", t_rec->rpt_end_date))
    call writeLog(build2("running report program"))
	
	execute bc_all_onc_dot_orders_rpt ^NL:^,^-|1|D^,^+|5|D^, t_rec->encntr_id
	set retval = 100
endif

call writeLog(build2("* END   Report   *******************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call echorecord(t_rec)

call exitScript(null)
call echorecord(t_rec)
call echorecord(program_log)

end 
go
