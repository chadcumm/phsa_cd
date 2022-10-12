/***********************************************************************************************************************
  Program Name:			bc_amb_st_bridge_pl
  Source File Name:		bc_amb_st_bridge_pl.prg
  Layout File Name:		N/A
  Program Written By:	
  Date:					
  Program Purpose:		
 
************************************************************************************************************************
												*MODIFICATION HISTORY*
************************************************************************************************************************
 
Rev	Date		Jira		Programmer				Comment
---	-----------	----------	---------------------	----------------------------------------------------------
000 05-JUL-2022 CST-154241	Chad Cummings			Copied and updated for new Powerform	 
***********************************************************************************************************************/
 
drop program bc_amb_st_bridge_pl:dba go
create program bc_amb_st_bridge_pl:dba
 
execute bc_all_all_date_routines
execute bc_all_all_std_routines
execute bc_std_ce_routines
 
; Include custom rich text library
%include cust_script:bc_all_cht_rtf.inc
 
;===================================================================================================
; DECLARED RECORDS
;===================================================================================================

record t_rec
(
	1 form_cnt            	 	= i4
	1 qual[*]
		2 bridging_date_day_neg_1 = dq8
		2 bridging_date_day_neg_2 = dq8
		2 bridging_date_day_neg_3 = dq8
		2 bridging_date_day_neg_4 = dq8
		2 bridging_date_day_neg_5 = dq8
		2 bridging_date_day_neg_6 = dq8
		2 bridging_date_day_neg_7 = dq8
		2 bridging_date_day_1 = dq8
		2 bridging_date_day_10 = dq8
		2 bridging_date_day_2 = dq8
		2 bridging_date_day_3 = dq8
		2 bridging_date_day_4 = dq8
		2 bridging_date_day_5 = dq8
		2 bridging_date_day_6 = dq8
		2 bridging_date_day_7 = dq8
		2 bridging_date_day_8 = dq8
		2 bridging_date_day_9 = dq8
		2 bridging_day_of_surgery_0 = dq8
		2 bridging_notes_neg_1 = vc
		2 bridging_notes_neg_2 = vc
		2 bridging_notes_neg_3 = vc
		2 bridging_notes_neg_4 = vc
		2 bridging_notes_neg_5 = vc
		2 bridging_notes_neg_6 = vc
		2 bridging_notes_neg_7 = vc
		2 bridging_notes_0 = vc
		2 bridging_notes_1 = vc
		2 bridging_notes_10 = vc
		2 bridging_notes_2 = vc
		2 bridging_notes_3 = vc
		2 bridging_notes_4 = vc
		2 bridging_notes_5 = vc
		2 bridging_notes_6 = vc
		2 bridging_notes_7 = vc
		2 bridging_notes_8 = vc
		2 bridging_notes_9 = vc
		2 bridging_warfarin_day_neg_1 = vc
		2 bridging_warfarin_day_neg_2 = vc
		2 bridging_warfarin_day_neg_3 = vc
		2 bridging_warfarin_day_neg_4 = vc
		2 bridging_warfarin_day_neg_5 = vc
		2 bridging_warfarin_day_neg_6 = vc
		2 bridging_warfarin_day_neg_7 = vc
		2 bridging_warfarin_day_0 = vc
		2 bridging_warfarin_day_1 = vc
		2 bridging_warfarin_day_10 = vc
		2 bridging_warfarin_day_2 = vc
		2 bridging_warfarin_day_3 = vc
		2 bridging_warfarin_day_4 = vc
		2 bridging_warfarin_day_5 = vc
		2 bridging_warfarin_day_6 = vc
		2 bridging_warfarin_day_7 = vc
		2 bridging_warfarin_day_8 = vc
		2 bridging_warfarin_day_9 = vc
		2 lmwh_instructions_day_neg_1 = vc
		2 lmwh_instructions_day_neg_2 = vc
		2 lmwh_instructions_day_neg_3 = vc
		2 lmwh_instructions_day_neg_4 = vc
		2 lmwh_instructions_day_neg_5 = vc
		2 lmwh_instructions_day_neg_6 = vc
		2 lmwh_instructions_day_neg_7 = vc
		2 lmwh_instructions_day_0 = vc
		2 lmwh_instructions_day_1 = vc
		2 lmwh_instructions_day_10 = vc
		2 lmwh_instructions_day_2 = vc
		2 lmwh_instructions_day_3 = vc
		2 lmwh_instructions_day_4 = vc
		2 lmwh_instructions_day_5 = vc
		2 lmwh_instructions_day_6 = vc
		2 lmwh_instructions_day_7 = vc
		2 lmwh_instructions_day_8 = vc
		2 lmwh_instructions_day_9 = vc
		2 procedure_notes = vc
			
) with protect

record outrec
(
	1 procedure = vc
	1 row_cnt = i4
	1 qual[*]
	 2 day = vc
	 2 date = vc
	 2 war_instr = vc
	 2 lmwh_instr = vc
	 2 notes = vc
)

;===================================================================================================
; DECLARED CODE SET VARIABLES
;===================================================================================================
declare cvActive	= f8 with noconstant(uar_get_code_by("DISPLAYKEY", 48, "ACTIVE"))
declare cvAuth 		= f8 with noconstant(uar_get_code_by("MEANING", 8, "AUTH"))
declare cvModified 	= f8 with noconstant(uar_get_code_by("MEANING", 8, "MODIFIED"))
 
; Required variables
declare nEncntrId = f8
if(validate(request->visit[1].encntr_id) = 1)
	set nEncntrId = request->visit[1].encntr_id
endif
 
declare nPersonId = f8
if(validate(request->person[1].person_id) = 1)
	set nPersonId = request->person[1].person_id
endif

if (nPersonId = 0.0)
	select into "nl:"
	from
		encounter e
	plan e
		where e.encntr_id = nEncntrId
	detail
		nPersonId = e.person_id
	with nocounter
endif
 

;Anticoagulation Bridge Therapy Form
declare pfBridgeForm = F8 with constant(sGetPowerFormRefbyDesc("Anticoagulation Bridge Therapy")), protect

call SubroutineLog(build2("pfBridgeForm=",pfBridgeForm))
;===================================================================================================
; DECLARED VARIABLES
;===================================================================================================
;helper variable for expand/locateval
declare vNum = i4
declare nPos = i4
declare fCnt = I4 WITH NOCONSTANT(0), PROTECT ;forms count
declare fiCnt = I4 WITH NOCONSTANT(0), PROTECT ;formItems Count
declare i = i4 with noconstant(0), protect

;===================================================================================================
; SET REPORT HEADERS AND PARSE STRINGS
;===================================================================================================
; Used only if testing from the back-end
if (validate(reply->text) = 0)
 set nPersonId = $1
 free record reply
 record reply (
  1 text    = vc
 )
endif
;===================================================================================================
; MAIN LOGIC
;===================================================================================================
call rtf_header(0)
 
call LoadTheForm(null)
 
;Exit if no qualifying orders
if(t_rec->form_cnt = 0)
	call add_rtf( "{\f0 No Anticoagulation Bridge Therapy Form Found}" )
	go to exit_script
endif
;===================================================================================================
;SUBROUTINE - load the forms
;===================================================================================================
subroutine LoadTheForm(null)
	declare pfBridgeFormAct = f8 with constant(sMostRecentPowerForm(nPersonId,nEncntrId,pfBridgeForm))
	call SubroutineLog(build2("pfBridgeFormAct=",pfBridgeFormAct))
	
	select into "nl:"
	from
	      dcp_forms_activity dfa
	    , dcp_forms_activity_comp dfac
	    , clinical_event ce1
	    , clinical_event ce2
	    , clinical_event ce3
	    , ce_date_result cdr
	    , discrete_task_assay dta
	plan dfa 
		where 	dfa.dcp_forms_activity_id = pfBridgeFormAct
	    and 	dfa.active_ind = 1
	    and 	dfa.form_status_cd in(
	    								 value(uar_get_code_by("MEANING", 8, "AUTH"))
	                              		,value(uar_get_code_by("MEANING", 8, "MODIFIED"))
	                              	)
	join dfac 
		where 	dfac.dcp_forms_activity_id = dfa.dcp_forms_activity_id
	    and 	dfac.component_cd = value(uar_get_code_by("DISPLAY_KEY", 18189, "PRIMARYEVENTID"))
	    and 	dfac.parent_entity_name = "CLINICAL_EVENT"
	join ce1 
		where 	ce1.event_id = dfac.parent_entity_id
	    and 	ce1.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.000")
	    and 	ce1.result_status_cd in(
	    									 value(uar_get_code_by("MEANING", 8, "AUTH"))
	                                		,value(uar_get_code_by("MEANING", 8, "MODIFIED"))
	                                	)
	    and 	ce1.event_reltn_cd = value(uar_get_code_by("MEANING", 24, "ROOT"))
	join ce2 
		where 	ce2.parent_event_id = ce1.event_id
	    and 	ce2.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.000")
	    and 	ce2.result_status_cd in (	 value(uar_get_code_by("MEANING", 8, "AUTH"))
	            		                    ,value(uar_get_code_by("MEANING", 8, "MODIFIED")))
	    and 	ce2.event_reltn_cd = value(uar_get_code_by("MEANING", 24, "CHILD")) 
	join ce3 
		where 	ce3.parent_event_id = ce2.event_id
	    and 	ce3.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.000")
	    and 	ce3.result_status_cd in (value(uar_get_code_by("MEANING", 8, "AUTH"))
	                                , value(uar_get_code_by("MEANING", 8, "MODIFIED")))
	    and 	ce3.event_reltn_cd = value(uar_get_code_by("MEANING", 24, "CHILD")) 
	join cdr
		where 	cdr.event_id = outerjoin(ce3.event_id)
		and     cdr.valid_until_dt_tm = outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.000"))
	join dta
		where dta.task_assay_cd = ce3.task_assay_cd
		and   dta.default_result_type_cd != value(uar_get_code_by("MEANING",289,"8"))
	order by
		 dfa.dcp_forms_activity_id
		,dfa.form_dt_tm desc
		,ce3.event_cd
		,ce3.valid_from_dt_tm desc
	head report
		i = 0
	head dfa.dcp_forms_activity_id
		i = (i + 1)
		stat = alterlist(t_rec->qual,i)
	head ce3.event_cd
		case (uar_get_code_display(ce3.event_cd))
		of "Bridging Date Day -1": t_rec->qual[i].bridging_date_day_neg_1 = cdr.result_dt_tm
		of "Bridging Date Day -2": t_rec->qual[i].bridging_date_day_neg_2 = cdr.result_dt_tm
		of "Bridging Date Day -3": t_rec->qual[i].bridging_date_day_neg_3 = cdr.result_dt_tm
		of "Bridging Date Day -4": t_rec->qual[i].bridging_date_day_neg_4 = cdr.result_dt_tm
		of "Bridging Date Day -5": t_rec->qual[i].bridging_date_day_neg_5 = cdr.result_dt_tm
		of "Bridging Date Day -6": t_rec->qual[i].bridging_date_day_neg_6 = cdr.result_dt_tm
		of "Bridging Date Day -7": t_rec->qual[i].bridging_date_day_neg_7 = cdr.result_dt_tm
		of "Bridging Date Day 1": t_rec->qual[i].bridging_date_day_1 = cdr.result_dt_tm
		of "Bridging Date Day 10": t_rec->qual[i].bridging_date_day_10 = cdr.result_dt_tm
		of "Bridging Date Day 2": t_rec->qual[i].bridging_date_day_2 = cdr.result_dt_tm
		of "Bridging Date Day 3": t_rec->qual[i].bridging_date_day_3 = cdr.result_dt_tm
		of "Bridging Date Day 4": t_rec->qual[i].bridging_date_day_4 = cdr.result_dt_tm
		of "Bridging Date Day 5": t_rec->qual[i].bridging_date_day_5 = cdr.result_dt_tm
		of "Bridging Date Day 6": t_rec->qual[i].bridging_date_day_6 = cdr.result_dt_tm
		of "Bridging Date Day 7": t_rec->qual[i].bridging_date_day_7 = cdr.result_dt_tm
		of "Bridging Date Day 8": t_rec->qual[i].bridging_date_day_8 = cdr.result_dt_tm
		of "Bridging Date Day 9": t_rec->qual[i].bridging_date_day_9 = cdr.result_dt_tm
		of "Bridging Day of Surgery 0": t_rec->qual[i].bridging_day_of_surgery_0 = cdr.result_dt_tm
		of "Bridging Notes -1": t_rec->qual[i].bridging_notes_neg_1 = ce3.result_val
		of "Bridging Notes -2": t_rec->qual[i].bridging_notes_neg_2 = ce3.result_val
		of "Bridging Notes -3": t_rec->qual[i].bridging_notes_neg_3 = ce3.result_val
		of "Bridging Notes -4": t_rec->qual[i].bridging_notes_neg_4 = ce3.result_val
		of "Bridging Notes -5": t_rec->qual[i].bridging_notes_neg_5 = ce3.result_val
		of "Bridging Notes -6": t_rec->qual[i].bridging_notes_neg_6 = ce3.result_val
		of "Bridging Notes -7": t_rec->qual[i].bridging_notes_neg_7 = ce3.result_val
		of "Bridging Notes 0": t_rec->qual[i].bridging_notes_0 = ce3.result_val
		of "Bridging Notes 1": t_rec->qual[i].bridging_notes_1 = ce3.result_val
		of "Bridging Notes 10": t_rec->qual[i].bridging_notes_10 = ce3.result_val
		of "Bridging Notes 2": t_rec->qual[i].bridging_notes_2 = ce3.result_val
		of "Bridging Notes 3": t_rec->qual[i].bridging_notes_3 = ce3.result_val
		of "Bridging Notes 4": t_rec->qual[i].bridging_notes_4 = ce3.result_val
		of "Bridging Notes 5": t_rec->qual[i].bridging_notes_5 = ce3.result_val
		of "Bridging Notes 6": t_rec->qual[i].bridging_notes_6 = ce3.result_val
		of "Bridging Notes 7": t_rec->qual[i].bridging_notes_7 = ce3.result_val
		of "Bridging Notes 8": t_rec->qual[i].bridging_notes_8 = ce3.result_val
		of "Bridging Notes 9": t_rec->qual[i].bridging_notes_9 = ce3.result_val
		of "Antithrombotic Instructions Day -1": t_rec->qual[i].bridging_warfarin_day_neg_1 = ce3.result_val
		of "Antithrombotic Instructions Day -2": t_rec->qual[i].bridging_warfarin_day_neg_2 = ce3.result_val
		of "Antithrombotic Instructions Day -3": t_rec->qual[i].bridging_warfarin_day_neg_3 = ce3.result_val
		of "Antithrombotic Instructions Day -4": t_rec->qual[i].bridging_warfarin_day_neg_4 = ce3.result_val
		of "Antithrombotic Instructions Day -5": t_rec->qual[i].bridging_warfarin_day_neg_5 = ce3.result_val
		of "Antithrombotic Instructions Day -6": t_rec->qual[i].bridging_warfarin_day_neg_6 = ce3.result_val
		of "Antithrombotic Instructions Day -7": t_rec->qual[i].bridging_warfarin_day_neg_7 = ce3.result_val
		of "Antithrombotic Instructions Day 0": t_rec->qual[i].bridging_warfarin_day_0 = ce3.result_val
		of "Antithrombotic Instructions Day 1": t_rec->qual[i].bridging_warfarin_day_1 = ce3.result_val
		of "Antithrombotic Instructions Day 10": t_rec->qual[i].bridging_warfarin_day_10 = ce3.result_val
		of "Antithrombotic Instructions Day 2": t_rec->qual[i].bridging_warfarin_day_2 = ce3.result_val
		of "Antithrombotic Instructions Day 3": t_rec->qual[i].bridging_warfarin_day_3 = ce3.result_val
		of "Antithrombotic Instructions Day 4": t_rec->qual[i].bridging_warfarin_day_4 = ce3.result_val
		of "Antithrombotic Instructions Day 5": t_rec->qual[i].bridging_warfarin_day_5 = ce3.result_val
		of "Antithrombotic Instructions Day 6": t_rec->qual[i].bridging_warfarin_day_6 = ce3.result_val
		of "Antithrombotic Instructions Day 7": t_rec->qual[i].bridging_warfarin_day_7 = ce3.result_val
		of "Antithrombotic Instructions Day 8": t_rec->qual[i].bridging_warfarin_day_8 = ce3.result_val
		of "Antithrombotic Instructions Day 9": t_rec->qual[i].bridging_warfarin_day_9 = ce3.result_val
		of "LMWH Instructions Day -1": t_rec->qual[i].lmwh_instructions_day_neg_1 = ce3.result_val
		of "LMWH Instructions Day -2": t_rec->qual[i].lmwh_instructions_day_neg_2 = ce3.result_val
		of "LMWH Instructions Day -3": t_rec->qual[i].lmwh_instructions_day_neg_3 = ce3.result_val
		of "LMWH Instructions Day -4": t_rec->qual[i].lmwh_instructions_day_neg_4 = ce3.result_val
		of "LMWH Instructions Day -5": t_rec->qual[i].lmwh_instructions_day_neg_5 = ce3.result_val
		of "LMWH Instructions Day -6": t_rec->qual[i].lmwh_instructions_day_neg_6 = ce3.result_val
		of "LMWH Instructions Day -7": t_rec->qual[i].lmwh_instructions_day_neg_7 = ce3.result_val
		of "LMWH Instructions Day 0": t_rec->qual[i].lmwh_instructions_day_0 = ce3.result_val
		of "LMWH Instructions Day 1": t_rec->qual[i].lmwh_instructions_day_1 = ce3.result_val
		of "LMWH Instructions Day 10": t_rec->qual[i].lmwh_instructions_day_10 = ce3.result_val
		of "LMWH Instructions Day 2": t_rec->qual[i].lmwh_instructions_day_2 = ce3.result_val
		of "LMWH Instructions Day 3": t_rec->qual[i].lmwh_instructions_day_3 = ce3.result_val
		of "LMWH Instructions Day 4": t_rec->qual[i].lmwh_instructions_day_4 = ce3.result_val
		of "LMWH Instructions Day 5": t_rec->qual[i].lmwh_instructions_day_5 = ce3.result_val
		of "LMWH Instructions Day 6": t_rec->qual[i].lmwh_instructions_day_6 = ce3.result_val
		of "LMWH Instructions Day 7": t_rec->qual[i].lmwh_instructions_day_7 = ce3.result_val
		of "LMWH Instructions Day 8": t_rec->qual[i].lmwh_instructions_day_8 = ce3.result_val
		of "LMWH Instructions Day 9": t_rec->qual[i].lmwh_instructions_day_9 = ce3.result_val
		of "Procedure Notes": t_rec->qual[i].procedure_notes = ce3.result_val
		endcase
	foot report
		t_rec->form_cnt = i	
	with nocounter,uar_code(d,1),format(date,";;q")

	call SubroutineLog('t_rec','RECORD')
	
end ;LoadTheForm*/
 

;===================================================================================================
; OUTPUT
;===================================================================================================
;declare NumberofFormsOutput = i4 with constant(3);last 3 forms

declare vDay = vc with noconstant(" ")
declare vDate = vc with noconstant(" ")
declare vWarfarin_Instr = vc with noconstant(" ")
declare vLMWH_Instr = vc with noconstant(" ")
declare vNotes = vc with noconstant(" ")

set outrec->row_cnt = 18

set stat = alterlist(outrec->qual,outrec->row_cnt)
;for (j=1 to t_rec->form_cnt)
set j = 1
set outrec->procedure = t_rec->qual[j].procedure_notes
 for (i=1 to outrec->row_cnt)

	set vDay = ""
	set vDate = ""
	set vWarfarin_Instr = ""
	set vLMWH_Instr = ""
	set vNotes = ""
	
	case (i)
		of 1:
				set vDay = "-7"
				set vDate = format(t_rec->qual[j].bridging_date_day_neg_7,"DD-Mmm-YYYY;;d")
				set vWarfarin_Instr = t_rec->qual[j].bridging_warfarin_day_neg_7
				set vLMWH_Instr = t_rec->qual[j].lmwh_instructions_day_neg_7
				set vNotes = t_rec->qual[j].bridging_notes_neg_7
		of 2:
				set vDay = "-6"
				set vDate = format(t_rec->qual[j].bridging_date_day_neg_6,"DD-Mmm-YYYY;;d")
				set vWarfarin_Instr = t_rec->qual[j].bridging_warfarin_day_neg_6
				set vLMWH_Instr = t_rec->qual[j].lmwh_instructions_day_neg_6
				set vNotes = t_rec->qual[j].bridging_notes_neg_6
		of 3:
				set vDay = "-5"
				set vDate = format(t_rec->qual[j].bridging_date_day_neg_5,"DD-Mmm-YYYY;;d")
				set vWarfarin_Instr = t_rec->qual[j].bridging_warfarin_day_neg_5
				set vLMWH_Instr = t_rec->qual[j].lmwh_instructions_day_neg_5
				set vNotes = t_rec->qual[j].bridging_notes_neg_5
		of 4:
				set vDay = "-4"
				set vDate = format(t_rec->qual[j].bridging_date_day_neg_4,"DD-Mmm-YYYY;;d")
				set vWarfarin_Instr = t_rec->qual[j].bridging_warfarin_day_neg_4
				set vLMWH_Instr = t_rec->qual[j].lmwh_instructions_day_neg_4
				set vNotes = t_rec->qual[j].bridging_notes_neg_4
		of 5:
				set vDay = "-3"
				set vDate = format(t_rec->qual[j].bridging_date_day_neg_3,"DD-Mmm-YYYY;;d")
				set vWarfarin_Instr = t_rec->qual[j].bridging_warfarin_day_neg_3
				set vLMWH_Instr = t_rec->qual[j].lmwh_instructions_day_neg_3
				set vNotes = t_rec->qual[j].bridging_notes_neg_3
		of 6:
				set vDay = "-2"
				set vDate = format(t_rec->qual[j].bridging_date_day_neg_2,"DD-Mmm-YYYY;;d")
				set vWarfarin_Instr = t_rec->qual[j].bridging_warfarin_day_neg_2
				set vLMWH_Instr = t_rec->qual[j].lmwh_instructions_day_neg_2
				set vNotes = t_rec->qual[j].bridging_notes_neg_2
		of 7:
				set vDay = "-1"
				set vDate = format(t_rec->qual[j].bridging_date_day_neg_1,"DD-Mmm-YYYY;;d")
				set vWarfarin_Instr = t_rec->qual[j].bridging_warfarin_day_neg_1
				set vLMWH_Instr = t_rec->qual[j].lmwh_instructions_day_neg_1
				set vNotes = t_rec->qual[j].bridging_notes_neg_1
		of 8:
				set vDay = "Day of Procedure"
				set vDate = format(t_rec->qual[j].bridging_day_of_surgery_0,"DD-Mmm-YYYY;;d")
				set vWarfarin_Instr = t_rec->qual[j].bridging_warfarin_day_0
				set vLMWH_Instr = t_rec->qual[j].lmwh_instructions_day_0
				set vNotes = t_rec->qual[j].bridging_notes_0
		of 9:
				set vDay = "1"
				set vDate = format(t_rec->qual[j].bridging_date_day_1,"DD-Mmm-YYYY;;d")
				set vWarfarin_Instr = t_rec->qual[j].bridging_warfarin_day_1
				set vLMWH_Instr = t_rec->qual[j].lmwh_instructions_day_1
				set vNotes = t_rec->qual[j].bridging_notes_1
		of 10:
				set vDay = "2"
				set vDate = format(t_rec->qual[j].bridging_date_day_2,"DD-Mmm-YYYY;;d")
				set vWarfarin_Instr = t_rec->qual[j].bridging_warfarin_day_2
				set vLMWH_Instr = t_rec->qual[j].lmwh_instructions_day_2
				set vNotes = t_rec->qual[j].bridging_notes_2
		of 11:
				set vDay = "3"
				set vDate = format(t_rec->qual[j].bridging_date_day_3,"DD-Mmm-YYYY;;d")
				set vWarfarin_Instr = t_rec->qual[j].bridging_warfarin_day_3
				set vLMWH_Instr = t_rec->qual[j].lmwh_instructions_day_3
				set vNotes = t_rec->qual[j].bridging_notes_3
		of 12:
				set vDay = "4"
				set vDate = format(t_rec->qual[j].bridging_date_day_4,"DD-Mmm-YYYY;;d")
				set vWarfarin_Instr = t_rec->qual[j].bridging_warfarin_day_4
				set vLMWH_Instr = t_rec->qual[j].lmwh_instructions_day_4
				set vNotes = t_rec->qual[j].bridging_notes_4
		of 13:
				set vDay = "5"
				set vDate = format(t_rec->qual[j].bridging_date_day_5,"DD-Mmm-YYYY;;d")
				set vWarfarin_Instr = t_rec->qual[j].bridging_warfarin_day_5
				set vLMWH_Instr = t_rec->qual[j].lmwh_instructions_day_5
				set vNotes = t_rec->qual[j].bridging_notes_5
		of 14:
				set vDay = "6"
				set vDate = format(t_rec->qual[j].bridging_date_day_6,"DD-Mmm-YYYY;;d")
				set vWarfarin_Instr = t_rec->qual[j].bridging_warfarin_day_6
				set vLMWH_Instr = t_rec->qual[j].lmwh_instructions_day_6
				set vNotes = t_rec->qual[j].bridging_notes_6
		of 15:
				set vDay = "7"
				set vDate = format(t_rec->qual[j].bridging_date_day_7,"DD-Mmm-YYYY;;d")
				set vWarfarin_Instr = t_rec->qual[j].bridging_warfarin_day_7
				set vLMWH_Instr = t_rec->qual[j].lmwh_instructions_day_7
				set vNotes = t_rec->qual[j].bridging_notes_7
		of 16:
				set vDay = "8"
				set vDate = format(t_rec->qual[j].bridging_date_day_8,"DD-Mmm-YYYY;;d")
				set vWarfarin_Instr = t_rec->qual[j].bridging_warfarin_day_8
				set vLMWH_Instr = t_rec->qual[j].lmwh_instructions_day_8
				set vNotes = t_rec->qual[j].bridging_notes_8
		of 17:
				set vDay = "9"
				set vDate = format(t_rec->qual[j].bridging_date_day_9,"DD-Mmm-YYYY;;d")
				set vWarfarin_Instr = t_rec->qual[j].bridging_warfarin_day_9
				set vLMWH_Instr = t_rec->qual[j].lmwh_instructions_day_9
				set vNotes = t_rec->qual[j].bridging_notes_9
		of 18:
				set vDay = "10"
				set vDate = format(t_rec->qual[j].bridging_date_day_10,"DD-Mmm-YYYY;;d")
				set vWarfarin_Instr = t_rec->qual[j].bridging_warfarin_day_10
				set vLMWH_Instr = t_rec->qual[j].lmwh_instructions_day_10
				set vNotes = t_rec->qual[j].bridging_notes_10
	endcase
	
	set outrec->qual[i].day = vDay
	set outrec->qual[i].date = vDate
	set outrec->qual[i].war_instr = vWarfarin_Instr
	set outrec->qual[i].lmwh_instr = vLMWH_Instr
	set outrec->qual[i].notes = vNotes

 endfor
;endfor
call SubroutineLog('outrec','RECORD')

call SubroutineLog('Building Output')

select into "nl:"
	     day = substring(1,50,outrec->qual[d.seq].day)
	   , date  = substring(1,50,outrec->qual[d.seq].date)
	   , war_instr = substring(1,50,outrec->qual[d.seq].war_instr)
	   , lmwh_instr  = substring(1,50,outrec->qual[d.seq].lmwh_instr)
	   , notes = substring(1,50,outrec->qual[d.seq].notes)

from
	  (dummyt d  with seq = outrec->row_cnt)
 
plan d
 
head report
	vFormCnt 	= 0

	vColDay			= 1300
	vColDate		= 1700
	vColWarInstr   	= 2000
	vColLMWHInstr  	= 2000
	vColNotes		= 3600
	
	vColProc		= 10600
 
 	call clear_row(0, 18)
	call add_cell( build2("\b Procedure Notes / Information:\b0 "," ",trim(outrec->procedure)), "BOX", vColProc, 0, 0 )
	call write_row(0)
 
	call clear_row(0, 18)
	call add_cell( "\b Date", "BOX", vColDate, 0, 0 )
	call add_cell( "\b Day", "BOX", vColDay, 0, 0 )
	call add_cell( "\b Antithrombotics Instructions", "BOX", vColWarInstr, 0, 0 )
	call add_cell( "\b LMWH Instructions", "BOX", vColLMWHInstr, 0, 0 )
	call add_cell( "\b Notes", "BOX", vColNotes, 0, 0 )
 
 	call write_row(0)
 
	Qualify = 1
	vFormCnt += 1
 
;if (vFormCnt > outrec->form_cnt - NumberofFormsOutput) qualify = 1 endif
 
detail
if (qualify = 1)

	call clear_row(0, 18)
	call add_cell( concat(" ",date), "BOX", vColDate, 0, 0 )
	call add_cell( concat(" ",day), "BOX", vColDay, 0, 0 )
	call add_cell( concat(" ",war_instr), "BOX", vColWarInstr, 0, 0 )
	call add_cell( concat(" ",lmwh_instr), "BOX", vColLMWHInstr, 0, 0 )
	call add_cell( concat(" ",notes), "BOX", vColNotes, 0, 0 )
 
	call write_row(0)
endif
 
go to exit_script
 
/* ready to exit..... */
#exit_script
call add_rtf("}")
 
;call echorecord(outrec)
call echo(reply->text)
 
end go
