/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       12/02/2021
  Solution:
  Source file name:   bc_std_ce_routines.prg
  Object name:        bc_std_ce_routines
  Request #:
 
  Program purpose:
 
  Executing from:     CCL
 
  Special Notes:      Additional Required Scripts:
 
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   12/02/2021  Chad Cummings			initial build
******************************************************************************/
drop program bc_std_ce_routines:dba go
create program bc_std_ce_routines:dba
 
call echo(build2("starting ",trim(cnvtlower(curprog))))

execute bc_std_log_routines
 
declare i=i4 with noconstant(0), protect
declare j=i4 with noconstant(0), protect
declare k=i4 with noconstant(0), protect
 
/* Subroutines */

/**********************************************************************************************************************
** Function GetEventIDbyCEventID(Clinical_Event_ID)
** ---------------------------------------------------------------------------------------
** Return an event_id for a given clinical_event_id
**********************************************************************************************************************/
declare GetEventIDbyCEventID(vCEventID=f8) = f8 with copy, persist
subroutine GetEventIDbyCEventID(vCEventID)
 
	declare rEventID = f8 with noconstant(0.0), protect
 
	select into "nl:"
	from
		clinical_event ce
	plan ce
		where ce.clinical_event_id = vCEventID
		and   ce.clinical_event_id > 0.0
	detail
		rEventID = ce.event_id
	with nocounter
 
	return(rEventID)
end ;GetEventIDbyCEventID

/**********************************************************************************************************************
** Function sGetPowerFormRefbyDesc(vPowerFormDesc)
** ---------------------------------------------------------------------------------------
** Return a dcp_forms_ref_id for a given Powerform description
**********************************************************************************************************************/
declare sGetPowerFormRefbyDesc(vPowerFormDesc) = f8 with copy, persist
subroutine sGetPowerFormRefbyDesc(vPowerFormDesc)

	declare vReturnDCPRefID = f8 with noconstant(0.0)
	
	select into "nl:"
	from
		dcp_forms_ref dfr
	plan dfr
		where dfr.description = vPowerFormDesc
		and   dfr.active_ind = 1
		and   cnvtdatetime(curdate,curtime3) between dfr.beg_effective_dt_tm and dfr.end_effective_dt_tm
	order by
		dfr.description
		,dfr.beg_effective_dt_tm desc
	head dfr.description
		vReturnDCPRefID = dfr.dcp_forms_ref_id
	with nocounter
	
	return (vReturnDCPRefID)
end ;sGetPowerFormRefbyDesc

/**********************************************************************************************************************
** Function sMostRecentPowerForm(vPersonID,vEncntrID,vDCPRefID,vLookbackDays)
** ---------------------------------------------------------------------------------------
** Return a dcp_forms_activity_id for a given patient, encounter and PowerForm.  Leave vEncntrID 0.0 to
** search all encounters
**********************************************************************************************************************/
declare sMostRecentPowerForm(vPersonID=f8,vEncntrID=f8,vDCPRefID=f8,vLookbackDays=i4(VALUE,0)) = f8 with copy, persist
subroutine sMostRecentPowerForm(vPersonID,vEncntrID,vDCPRefID,vLookbackDays)

	call SubroutineLog(build2(^start sMostRecentPowerForm(	^,vPersonID,^,^,vDCPRefID,^,^,vDCPRefID,^,^,vLookbackDays,^)^))
	
	declare vReturnDCPActID = f8 with noconstant(0.0)
	declare encntrParser = vc with noconstant("1=1")
	
	if (vEncntrID > 0.0)
		set encntrParser = build2("dfa.encntr_id = ",vEncntrID)
	endif
	
	select into "nl:"
	from
    	 dcp_forms_activity dfa
    	,dcp_forms_ref dfr
	plan dfr
		where dfr.dcp_forms_ref_id = vDCPRefID
	join dfa 
		where dfa.dcp_forms_ref_id 	= dfr.dcp_forms_ref_id
	    and dfa.active_ind 			= 1
	    and dfa.person_id 			= vPersonID
	    and parser(encntrParser)
	    and dfa.form_status_cd in(
	    								 value(uar_get_code_by("MEANING", 8, "AUTH"))
	                              		,value(uar_get_code_by("MEANING", 8, "MODIFIED"))
	                              )
		order by
			 dfa.dcp_forms_ref_id
			,dfa.form_dt_tm desc
		head dfa.dcp_forms_ref_id
			vReturnDCPActID = dfa.dcp_forms_activity_id
		with nocounter
	
	return (vReturnDCPActID)
end

/**********************************************************************************************************************
** Function ()
** ---------------------------------------------------------------------------------------
** Return a record structure named  
**********************************************************************************************************************/


declare Add_CEResult(
						 vEncntrID=f8
						,vEventCD=f8
						,vResult=vc
						,vEventDateTime=dq8(VALUE,sysdate)
						,vEventClass=vc(VALUE,"TXT")
		) = f8 with copy, persist	
						
subroutine Add_CEResult(vEncntrID,vEventCD,vResult,vEventDateTime,vEventClass)
	
	call SubroutineLog(build2(^start Add_CEResult(	^,vEncntrID,^,^
													 ,vEventCD,^,^
													 ,vResult,^,^
													 ,vEventDateTime,^,^
												  	 ,vEventClass,^)^))
	
	declare vReturnSuccess = f8 with noconstant(FALSE)
 
	if ((vEventCD > 0.0) and (vEncntrID > 0.0) and (vResult > ""))
		free record cerequest
		free record cereply
		
%i cclsource:eks_rprq1000012.inc

		select into "nl:"
		from
			encounter e
		plan e
			where e.encntr_id = vEncntrID
		detail
			cerequest->ensure_type = 2
			cerequest->clin_event.view_level = 1
			cerequest->clin_event.person_id = e.person_id
			cerequest->clin_event.encntr_id = e.encntr_id
			cerequest->clin_event.contributor_system_cd = uar_get_code_by("MEANING",89,"POWERCHART")
			cerequest->clin_event.event_class_cd = uar_get_code_by("MEANING",53,vEventClass)
			cerequest->clin_event.event_cd = vEventCD
			cerequest->clin_event.event_tag = vResult
			cerequest->clin_event.event_start_dt_tm = vEventDateTime
			cerequest->clin_event.event_end_dt_tm = vEventDateTime
			cerequest->clin_event.event_end_dt_tm_os_ind = 1
			cerequest->clin_event.record_status_cd = uar_get_code_by("MEANING",48,"ACTIVE")
			cerequest->clin_event.result_status_cd = uar_get_code_by("MEANING",8,"AUTH")
			cerequest->clin_event.authentic_flag_ind = 1
			cerequest->clin_event.publish_flag = 1
			cerequest->clin_event.normalcy_cd = uar_get_code_by_cki("CKI.CODEVALUE!2690")	;Normal
			cerequest->clin_event.subtable_bit_map = 8193
			cerequest->clin_event.expiration_dt_tm_ind = 1
			cerequest->clin_event.valid_from_dt_tm = cnvtdatetime(sysdate)
			cerequest->clin_event.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
			cerequest->clin_event.valid_from_dt_tm_ind = 1
			cerequest->clin_event.valid_until_dt_tm_ind = 1
			cerequest->clin_event.verified_dt_tm_ind = 1
			cerequest->clin_event.performed_dt_tm = cnvtdatetime(sysdate)
			cerequest->clin_event.performed_prsnl_id = 1
			cerequest->clin_event.updt_id = 1
			cerequest->clin_event.updt_dt_tm = cnvtdatetime(sysdate)
			cerequest->ensure_type2 = 1
 
			stat = alterlist(cerequest->clin_event.string_result,1)
			cerequest->clin_event.string_result.string_result_text = vResult
			cerequest->clin_event.string_result.string_result_format_cd = uar_get_code_by("MEANING",14113,"ALPHA")
			cerequest->clin_event.string_result.last_norm_dt_tm_ind = 1
			cerequest->clin_event.string_result.feasible_ind_ind = 1
			cerequest->clin_event.string_result.inaccurate_ind_ind = 1
 
			stat = alterlist(cerequest->clin_event.event_prsnl_list,2)
			cerequest->clin_event.event_prsnl_list[1].person_id = 1.0 ;update this to possibly include a passed in value
			cerequest->clin_event.event_prsnl_list[1].action_type_cd = 112
			cerequest->clin_event.event_prsnl_list[1].request_dt_tm_ind = 1
			cerequest->clin_event.event_prsnl_list[1].action_dt_tm = cnvtdatetime(sysdate)
			cerequest->clin_event.event_prsnl_list[1].action_prsnl_id = 1.0
			cerequest->clin_event.event_prsnl_list[1].action_status_cd = 653
			cerequest->clin_event.event_prsnl_list[1].valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
 
			cerequest->clin_event.event_prsnl_list[2].person_id = 1.0 ;update this to possibly include a passed in value
			cerequest->clin_event.event_prsnl_list[2].action_type_cd = 104
			cerequest->clin_event.event_prsnl_list[2].request_dt_tm_ind = 1
			cerequest->clin_event.event_prsnl_list[2].action_dt_tm = cnvtdatetime(curdate,curtime3)
			cerequest->clin_event.event_prsnl_list[2].action_prsnl_id = 1.0
			cerequest->clin_event.event_prsnl_list[2].action_status_cd = 653
			cerequest->clin_event.event_prsnl_list[2].valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
		with nocounter
 
		set stat = tdbexecute(0,3055000,1000012,"REC",CERequest,"REC",CEReply,1)
 
		call echorecord(CERequest)
		call echorecord(CEReply)
		call echo(build2("CEReply->rb_list[1].event_id=",CEReply->rb_list[1].event_id))
		
		if (validate(CEReply->rb_list[1].event_id))
			set vReturnSuccess = CEReply->rb_list[1].event_id
		else
			call echo("CEReply->rb_list[1].event_id not valid")
			set vReturnSuccess = FALSE
		endif
	endif
 
	return (vReturnSuccess)
end 

call echo(build2("finishing ",trim(cnvtlower(curprog))))
 
end go

