/***********************************************************************************************************************
  Program Name:       	bc_all_onc_dot_rpt_ops
  Source File Name:   	bc_all_onc_dot_rpt_ops.prg
  Program Written By: 	Chad Cummings
  Date:  			  	20-May-2021
  Program Purpose:   	PowerPlan and non-PowerPlan orders for downtime purposes
 
************************************************************************************************************************
												*MODIFICATION HISTORY*
************************************************************************************************************************
 
Rev  Date         Jira       Programmer             Comment
---  -----------  ---------  ---------------------  --------------------------------------------------------------------
000  26-May-2021  CST-96425  Chad Cummings          Created
001  17-Jun-2021  CST-96425  Chad Cummings			Added logic to prefer BC Cancer encounters
002  17-Jun-2021  CST-96425  Chad Cummings			Updated logic to remove and add together
003  17-Jun-2021  CST-96425  Chad Cummings			BCC Encounter logic
003  12-Jan-2022  CST-149979 Chad Cummings			DOT Downtime Orders Report - Configuration & Testing for BCW BCCH deployment
***********************************************************************************************************************/
drop program bc_all_onc_dot_rpt_ops go
create program bc_all_onc_dot_rpt_ops
 
call echo(build("loading script:",curprog))
declare nologvar = i2 with noconstant(0), protect	;do not create log = 1		, create log = 0
declare debug_ind = i2 with noconstant(0), protect	;0 = no debug, 1=basic debug with echo, 2=msgview debug ;000
declare rec_to_file = i2 with noconstant(0), protect
 
set modify maxvarlen 368435456
 
if (validate(reply->status_data) = 0)
  record reply
  (
%i cclsource:status_block.inc
  )
endif
 
set reply->status_data->status = "F"
 
%i cust_script:bc_play_routines.inc
%i cust_script:bc_play_req.inc
 
call bc_custom_code_set(0)
call bc_log_level(0)
 
record t_rec
(
    1 beg_date = dq8
    1 end_date = dq8
    1 rpt_beg_date = vc
    1 rpt_end_date = vc
	1 existing_doc_cnt = i4
	1 existing_doc_qual[*]
	 2 encntr_id = f8
	 2 person_id = f8
	 2 event_id = f8
	 2 in_error_flag = i2
	 2 process_flag = i2
	 2 new_doc_pos = i2 ;002
	 2 fin = vc
	 2 name = vc
	1 new_doc_cnt = i2
	1 new_doc_qual[*]
	 2 encntr_id = f8
	 2 person_id = f8
	 2 process_flag = i2
	 2 existing_doc_pos = i2 ;002
	 2 fin = vc
	 2 name = vc
)
 
declare i = i4 with noconstant(0), protect
declare j = i4 with noconstant(0), protect
declare pos = i4 with noconstant(0), protect
 
declare test_person_id = f8 with constant(22107154.00), protect ;ONCPOWER, FORM
 
set t_rec->beg_date = datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'B', 'B')
set t_rec->end_date = datetimefind(cnvtlookahead("5,D",cnvtdatetime(curdate,curtime3)), 'D', 'E', 'E')
set t_rec->rpt_beg_date = format(cnvtdatetime(t_rec->beg_date), "dd-mmm-yyyy;;q")
set t_rec->rpt_end_date = format(cnvtdatetime(t_rec->end_date), "dd-mmm-yyyy;;q")
 
 
set reply->status_data->status = "S"
 
 
call writeLog(build2("***************************************************************"))
call writeLog(build2("* START Find Existing Reports *********************************"))
 
select into "nl:"
from
	clinical_event ce
plan ce
	where ce.event_cd in(
							value(uar_get_code_by("DISPLAY_KEY", 72, "DOWNTIMEDOTORDERSREPORT")))
	and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	;and   ce.person_id = test_person_id
order by
	 ce.person_id
	,ce.valid_from_dt_tm desc
	,ce.event_id
head report
	i = 0
	j = 0
head ce.event_id
	i = (i + 1)
	stat = alterlist(t_rec->existing_doc_qual,i)
	t_rec->existing_doc_qual[i].encntr_id = ce.encntr_id
	t_rec->existing_doc_qual[i].event_id = ce.event_id
	t_rec->existing_doc_qual[i].person_id = ce.person_id
	t_rec->existing_doc_qual[i].process_flag = 1
foot report
	t_rec->existing_doc_cnt = i
with nocounter
 
call writeLog(build2("t_rec->existing_doc_cnt=",t_rec->existing_doc_cnt))
 
call writeLog(build2("* END   Find Existing Reports *********************************"))
call writeLog(build2("***************************************************************"))
 
call writeLog(build2("***************************************************************"))
call writeLog(build2("* START Finding Qualifying Persons by Orders ******************"))
 
select into "nl:"
from
	 orders o
	,act_pw_comp apc
	,pathway p
plan o
	where o.order_status_cd in(
								  value(uar_get_code_by("MEANING",6004,"ORDERED"))
								 ,value(uar_get_code_by("MEANING",6004,"FUTURE"))
								 ,value(uar_get_code_by("MEANING",6004,"PENDING"))
								)
	and o.current_start_dt_tm between cnvtdatetime(t_rec->beg_date) and cnvtdatetime(t_rec->end_date)
	;and o.person_id = test_person_id
join apc
	where apc.parent_entity_id = o.order_id
join p
	where p.pathway_id = apc.pathway_id
	and   p.type_mean = "DOT"
order by
	o.person_id
	,o.orig_order_dt_tm desc
head report
	i = 0
head o.person_id
	i = (i + 1)
	stat = alterlist(t_rec->new_doc_qual,i)
	if (o.originating_encntr_id > 0.0)
		t_rec->new_doc_qual[i].encntr_id = o.originating_encntr_id
	elseif (o.encntr_id > 0.0)
		t_rec->new_doc_qual[i].encntr_id = o.encntr_id
	endif
	t_rec->new_doc_qual[i].person_id = o.person_id
	t_rec->new_doc_qual[i].process_flag = 1
foot report
	t_rec->new_doc_cnt = i
with nocounter
 
call writeLog(build2("t_rec->new_doc_cnt=",t_rec->new_doc_cnt))
 
call writeLog(build2("* END   Finding Qualifying Persons by Orders ******************"))
call writeLog(build2("***************************************************************"))
 
call writeLog(build2("***************************************************************"))
call writeLog(build2("* START Finding Planned Phases ********************************"))
/*
select into "nl:"
from
	 pathway p
plan p
	where p.pw_status_cd in(value(uar_get_code_by("MEANING",16769,"PLANNED")))
	and   p.duration_qty > 0
order by
	 p.person_id
	,p.order_dt_tm desc
head report
	i = t_rec->new_doc_cnt
	pos = 0
head p.person_id
	pos = 0
	pos = locateval(j,1,t_rec->new_doc_cnt,p.person_id,t_rec->new_doc_qual[j].person_id)
	if (pos = 0)
		i = (i + 1)
		stat = alterlist(t_rec->new_doc_qual,i)
		t_rec->new_doc_qual[i].encntr_id = p.encntr_id
		t_rec->new_doc_qual[i].person_id = p.person_id
	endif
foot report
	t_rec->new_doc_cnt = i
with nocounter
*/
 
select into "nl:"
from
	 pathway p
	 ,regimen_detail rd
	 ,regimen r
	 ,act_pw_comp apc
plan p
	where p.pw_status_cd in(value(uar_get_code_by("MEANING",16769,"PLANNED")))
	;and   p.duration_qty > 0
	;and   p.person_id = test_person_id
join apc
	where apc.pathway_id = p.pathway_id
	and ((apc.parent_entity_name in ("ORDERS", "PROPOSAL") and apc.included_ind = 1))
join rd
	where rd.activity_entity_id = p.pw_group_nbr
join r
	where r.regimen_id = rd.regimen_id
order by
	 p.person_id
head report
	i = t_rec->new_doc_cnt
	pos = 0
head p.person_id
	pos = 0
	pos = locateval(j,1,t_rec->new_doc_cnt,p.person_id,t_rec->new_doc_qual[j].person_id)
	if (pos = 0)
		i = (i + 1)
		stat = alterlist(t_rec->new_doc_qual,i)
		t_rec->new_doc_qual[i].encntr_id = p.encntr_id
		t_rec->new_doc_qual[i].person_id = p.person_id
		t_rec->new_doc_qual[i].process_flag = 2
	endif
foot report
	t_rec->new_doc_cnt = i
with nocounter
 
call writeLog(build2("t_rec->new_doc_cnt=",t_rec->new_doc_cnt))
 
call writeLog(build2("* END   Finding Planned Phases ********************************"))
call writeLog(build2("***************************************************************"))
 
call writeLog(build2("***************************************************************"))
call writeLog(build2("* START Finding Proposed Plans *******************************"))
 
select into "nl:"
    from
    	pathway p
    plan p
    	where p.pw_status_cd not in(
    									 value(uar_get_code_by("MEANING",16769,"EXCLUDED"))
    									,value(uar_get_code_by("MEANING",16769,"DISCONTINUED")))
    	and   p.review_status_flag = 1
    	and   p.type_mean = "DOT"
    	and   p.start_dt_tm between cnvtdatetime(t_rec->beg_date) and cnvtdatetime(t_rec->end_date)
    	;and   p.person_id = test_person_id
    order by
   		p.person_id
	head report
		i = t_rec->new_doc_cnt
		pos = 0
	head p.person_id
		pos = 0
		pos = locateval(j,1,t_rec->new_doc_cnt,p.person_id,t_rec->new_doc_qual[j].person_id)
		if (pos = 0)
			i = (i + 1)
			stat = alterlist(t_rec->new_doc_qual,i)
			t_rec->new_doc_qual[i].encntr_id = p.encntr_id
			t_rec->new_doc_qual[i].person_id = p.person_id
		endif
	foot report
		t_rec->new_doc_cnt = i
    with nocounter
 
call writeLog(build2("t_rec->new_doc_cnt=",t_rec->new_doc_cnt))
 
call writeLog(build2("* END   Finding Proposed Plans *******************************"))
 
/* start 002 */
call writeLog(build2("***************************************************************"))
call writeLog(build2("* START Compare Remove and Adding Data ************************"))
 
call writeLog(build2("  ->marking existing documents"))
call writeLog(build2("  ->t_rec->existing_doc_cnt=",trim(cnvtstring(t_rec->existing_doc_cnt))))
;if (t_rec->new_doc_cnt > 0)
	for (i=1 to t_rec->existing_doc_cnt)
		call writeLog(build2("  -->looking at existing item #",trim(cnvtstring(i))))
		if (t_rec->existing_doc_qual[i].event_id > 0.0)
			set pos = 0
			set pos = locateval(j,1,t_rec->new_doc_cnt,t_rec->existing_doc_qual[i].person_id,t_rec->new_doc_qual[j].person_id)
			set t_rec->existing_doc_qual[i].new_doc_pos = pos
			call writeLog(build2("  --->found pos=",trim(cnvtstring(pos))))
		endif
	endfor
;endif
 
call writeLog(build2("  ->marking new documents"))
call writeLog(build2("  ->t_rec->new_doc_cnt=",trim(cnvtstring(t_rec->new_doc_cnt))))
;if (t_rec->existing_doc_cnt > 0)
	for (i=1 to t_rec->new_doc_cnt)
		call writeLog(build2("  -->looking at new item #",trim(cnvtstring(i))))
		if (t_rec->new_doc_qual[i].encntr_id > 0.0)
			set pos = 0
			set pos = locateval(j,1,t_rec->existing_doc_cnt,t_rec->new_doc_qual[i].person_id,t_rec->existing_doc_qual[j].person_id)
			set t_rec->new_doc_qual[i].existing_doc_pos = pos
			call writeLog(build2("  --->found pos=",trim(cnvtstring(pos))))
		endif
	endfor
;endif
call writeLog(build2("* END   Compare Remove and Adding Data ************************"))
call writeLog(build2("***************************************************************"))
/* end 002 */
 
/* start 003 */
call writeLog(build2("***************************************************************"))
call writeLog(build2("* START Checking for BCC Encounter ****************************"))
 
select into "nl:"
	 recurring_sort = evaluate(e2.encntr_type_cd,value(uar_get_code_by("DISPLAY",71,"Recurring")),0,1)
	,e2.reg_dt_tm
from
	 (dummyt d1 with seq=t_rec->new_doc_cnt)
	,encounter e1
	,code_value cv1
	,encounter e2
	,code_value cv2
plan d1
	where t_rec->new_doc_qual[d1.seq].encntr_id > 0.0
join e1
	where e1.encntr_id = t_rec->new_doc_qual[d1.seq].encntr_id
join cv1
	where cv1.code_value = e1.loc_facility_cd
	and   cv1.display not in(
                                 "BCC VA*"
                                ,"BCH*"
                                ,"BCW*"
                                ,"SSH*"
                            )
join e2
	where e2.person_id = e1.person_id
	and   e2.encntr_id != e1.encntr_id
	and   e2.active_ind = 1
join cv2
	where cv2.code_value = e2.loc_facility_cd
	and   cv2.display in(
                                 "BCC VA*"
                                ,"BCH*"
                                ,"BCW*"
                                ,"SSH*"
                         )
order by
	 e2.person_id
	,recurring_sort
	,e2.reg_dt_tm desc
head e2.person_id
	t_rec->new_doc_qual[d1.seq].encntr_id = e2.encntr_id
	call writeLog(build2("->encounter switch from ",trim(cnvtstring(e1.encntr_id))," with ",trim(cnvtstring(e2.encntr_id))))
	call writeLog(build2("->encounter switch from ",trim(uar_get_code_display(e1.loc_facility_cd))
		," with ",trim(uar_get_code_display(e2.loc_facility_cd))))
	call writeLog(build2("->encounter switch from ",trim(uar_get_code_display(e1.encntr_type_cd))
		," with ",trim(uar_get_code_display(e2.encntr_type_cd))))
with nocounter
call writeLog(build2("* END   Checking for BCC Encounter ****************************"))
call writeLog(build2("***************************************************************"))
/* end 003 */
 
call writeLog(build2("***************************************************************"))
call writeLog(build2("* START Remove Existing Documents *****************************"))
 
for (i = 1 to t_rec->existing_doc_cnt)
 if (t_rec->existing_doc_qual[i].event_id > 0.0)
 	if (t_rec->existing_doc_qual[i].new_doc_pos = 0)
		execute bc_onc_inerror_document ^NOFORMS^,value(t_rec->existing_doc_qual[i].event_id)
		call writeLog(build2("t_rec->existing_doc_qual[",trim(cnvtstring(i)),"].event_id: ",t_rec->existing_doc_qual[i].event_id))
	else
		call writeLog(build2("skipping t_rec->existing_doc_qual["
			,trim(cnvtstring(i)),"].event_id: ",t_rec->existing_doc_qual[i].event_id," as new document will be created in "
			,trim(cnvtstring(t_rec->existing_doc_qual[i].new_doc_pos))))
	endif
 endif
endfor
call writeLog(build2("* END   Remove Existing Documents *****************************"))
call writeLog(build2("***************************************************************"))
 
call writeLog(build2("***************************************************************"))
call writeLog(build2("* START Calling Document Creation *****************************"))
 
set t_rec->beg_date = datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'B', 'B')
set t_rec->end_date = datetimefind(cnvtlookahead("5,D",cnvtdatetime(curdate,curtime3)), 'D', 'E', 'E')
set t_rec->rpt_beg_date = format(cnvtdatetime(t_rec->beg_date), "dd-mmm-yyyy;;q")
set t_rec->rpt_end_date = format(cnvtdatetime(t_rec->end_date), "dd-mmm-yyyy;;q")
 
for (i = 1 to t_rec->new_doc_cnt)
	if (t_rec->new_doc_qual[i].encntr_id > 0.0)
		call writeLog(build2("t_rec->new_doc_qual[",trim(cnvtstring(i)),"].encntr_id: ",t_rec->new_doc_qual[i].encntr_id))
		call writeLog(build2("t_rec->new_doc_qual[",trim(cnvtstring(i)),"].person_id: ",t_rec->new_doc_qual[i].person_id))
		if (t_rec->new_doc_qual[i].existing_doc_pos > 0)
			for (j = 1 to t_rec->existing_doc_cnt)
				if (t_rec->existing_doc_qual[j].person_id = t_rec->new_doc_qual[i].person_id)
					execute bc_onc_inerror_document ^NOFORMS^,value(t_rec->existing_doc_qual[j].event_id)
					call writeLog(build2("->removing report t_rec->existing_doc_qual[",trim(cnvtstring(j)),"].event_id: "
						,t_rec->existing_doc_qual[j].event_id))
				endif
			endfor
		endif
 
 		call writeLog(build2("executing report"))
		execute bc_all_onc_dot_orders_rpt ^NL:^,^-|1|D^,^+|5|D^, t_rec->new_doc_qual[i].encntr_id
 
	endif
endfor
call writeLog(build2("* END   Calling Document Creation *****************************"))
call writeLog(build2("***************************************************************"))
 
/*
call writeLog(build2("***************************************************************"))
call writeLog(build2("* START Gathering Names ***************************************"))
call writeLog(build2("->existing documents"))
select into "nl:"
from
	 (dummyt d1 with seq = t_rec->existing_doc_cnt)
	,person p
plan d1
	where t_rec->existing_doc_qual[d1.seq].person_id > 0.0
join p
	where p.person_id = t_rec->existing_doc_qual[d1.seq].person_id
detail
	t_rec->existing_doc_qual[d1.seq].name = p.name_full_formatted
with nocounter
 
 
call writeLog(build2("->new documents"))
select into "nl:"
from
	 (dummyt d1 with seq = t_rec->new_doc_cnt)
	,person p
plan d1
	where t_rec->new_doc_qual[d1.seq].person_id > 0.0
join p
	where p.person_id = t_rec->new_doc_qual[d1.seq].person_id
detail
	t_rec->new_doc_qual[d1.seq].name = p.name_full_formatted
with nocounter
 
call writeLog(build2("* END   Gathering Names ***************************************"))
call writeLog(build2("***************************************************************"))
 
call writeLog(build2("***************************************************************"))
call writeLog(build2("* START Gathering FIN ******************************************"))
call writeLog(build2("->existing documents"))
select into "nl:"
from
	 (dummyt d1 with seq = t_rec->existing_doc_cnt)
	,encntr_alias ea
plan d1
	where t_rec->existing_doc_qual[d1.seq].encntr_id > 0.0
join ea
	where ea.encntr_id = t_rec->existing_doc_qual[d1.seq].encntr_id
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
	and   ea.active_ind = 1
detail
	t_rec->existing_doc_qual[d1.seq].fin = ea.alias
with nocounter
 
 
call writeLog(build2("->new documents"))
select into "nl:"
from
	 (dummyt d1 with seq = t_rec->new_doc_cnt)
	,encntr_alias ea
plan d1
	where t_rec->new_doc_qual[d1.seq].encntr_id > 0.0
join ea
	where ea.encntr_id = t_rec->new_doc_qual[d1.seq].encntr_id
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
	and   ea.active_ind = 1
detail
	t_rec->new_doc_qual[d1.seq].fin = ea.alias
with nocounter
call writeLog(build2("* END   Gathering FIN ******************************************"))
call writeLog(build2("***************************************************************"))
 
call writeLog(build2("***************************************************************"))
call writeLog(build2("* START Section ***********************************************"))
 
call writeLog(build2("* END   Section ***********************************************"))
call writeLog(build2("***************************************************************"))
*/
 
set reply->status_data->status = "S"
 
#exit_script
call echorecord(t_rec)
;call writeLog(build2("-->writing t_rec to ",program_log->files.filename_audit))
;call echojson(t_rec,program_log->files.filename_audit,1)
call exitScript(null)
 
#exit_script_no_log
 
end
go
