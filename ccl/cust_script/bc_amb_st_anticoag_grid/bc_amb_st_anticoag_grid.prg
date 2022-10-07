/***********************************************************************************************************************
  Program Name:			bc_amb_st_anticoag_grid
  Source File Name:		bc_amb_st_anticoag_grid.prg
  Layout File Name:		N/A
  Program Written By:	Farzad Sharif
  Date:					15-OCT-2021
  Program Purpose:		A table with Date (chronologically arranged), INR, Dose Taken Pt Confirmed, Recommended Dose and
  						Notes from the Warfarin Monitoring log powerform in a patient-friendly format.
 
************************************************************************************************************************
												*MODIFICATION HISTORY*
************************************************************************************************************************
 
Rev	Date		Jira		Programmer				Comment
---	-----------	----------	---------------------	----------------------------------------------------------
000 15-OCT-2021 CST-141693	Farzad Sharif			Initial Development
000 05-JUL-2022 CST-154241	Chad Cummings			Copied and updated for new Powerform	 
***********************************************************************************************************************/
 
drop program bc_amb_st_anticoag_grid:dba go
create program bc_amb_st_anticoag_grid:dba
 
execute bc_all_all_date_routines
execute bc_all_all_std_routines
 
; Include custom rich text library
%include cust_script:bc_all_cht_rtf.inc
 
;===================================================================================================
; DECLARED RECORDS
;===================================================================================================
free record outrec
record outrec
(
	1 form_cnt            	 	= i4
	1 qual[*]
		2 event_id				= f8
		2 form_status			= vc
		2 form_name				= vc
		2 from_dt_tm			= dq8
		2 component_cnt			= i4
		2 form_components[*]
			3 event_id 			= f8
			3 component_name 	= vc
			3 dose_taken 		= vc
			3 dose_taken_row_cnt= i2
			3 dose_taken_split[*]
			 4 dose_taken		= vc
			3 antixa			= vc
			3 inr				= vc
			3 type				= vc
			3 recommended_dose 	= vc
			3 rec_dose_row_cnt	= i2
			3 rec_dose_split[*]
			 4 rec_dose			= vc
			3 recommended_by     = vc
			3 rec_by_row_cnt	= i2
			3 rec_by_split[*]
			 4 rec_by			= vc
			3 patient_contacted = vc
			3 contact_date		= dq8
			3 comm_method		= vc
			3 next_check		= dq8
			3 notes				= vc
			3 notes_row_cnt		= i2
			3 notes_split[*]
			 4 notes			= vc
			3 result_dt			= dq8
			
) with persist

free set pt 
record pt
	( 
		1 line_cnt = i2
	  	1 lns[*]
	     2 line = vc
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
 
;person type
declare cvPerson_type	= f8 with noconstant(uar_get_code_by("DISPLAYKEY",302,"PERSON"))
 
;Component_cd
declare cvClinicalEvent = F8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",18189,"CLINCALEVENT")), PROTECT
 
;Warfarin Form
declare cvWarfarinForm = F8 with constant(UAR_GET_CODE_BY("DISPLAYKEY",72,"WARFARINMONITORINGLOGFORM")), protect
 
;event class
declare cvDOC = F8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",53,"DOC")), PROTECT
declare cvTXT = F8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",53,"TXT")), PROTECT
declare cvNUM = F8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",53,"NUM")), PROTECT
declare cvDATE = F8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",53,"DATE")), PROTECT
declare cvGRP = F8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",53,"GRP")), PROTECT
;===================================================================================================
; DECLARED VARIABLES
;===================================================================================================
;helper variable for expand/locateval
declare vNum = i4
declare nPos = i4
declare fCnt = I4 WITH NOCONSTANT(0), PROTECT ;forms count
declare fiCnt = I4 WITH NOCONSTANT(0), PROTECT ;formItems Count
declare dose_taken_vc = vc with noconstant(" "), protect
declare dose_rec_vc = vc with noconstant(" "), protect
declare notes_max = f8 with constant(30.0), protect
declare dose_taken_max = f8 with constant(30.0), protect
declare dose_rec_max = f8 with constant(26.0), protect
declare rec_by_max = f8 with constant(30.0), protect


declare row_cnt = i2 with noconstant(0), protect
declare start_pos = i2 with noconstant(0), protect
declare cur_pos = i2 with noconstant(0), protect 
declare row_max = i2 with noconstant(0), protect 
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
if(outrec->form_cnt = 0)
	call add_rtf( "{\f0 No Anticoagulation Monitoring Log Form Found}" )
	go to exit_script
endif
;===================================================================================================
;SUBROUTINE - load the forms
;===================================================================================================
subroutine LoadTheForm(null)
	select into "nl:"
		form_status		=	uar_get_code_display(ce.result_status_cd)
		;, form_name		= uar_get_code_display (dfr.event_cd)
		,form_name = dfr.description
		, assay_id = cea.clinical_event_id
		, assay_event_disp = UAR_GET_CODE_DISPLAY(cea.event_cd)
		, ultra_event_disp = UAR_GET_CODE_DISPLAY(ceu.event_cd)
		, ultra_result_val = substring(1,255,trim(ceu.result_val,3))
		, ultra_result_val_dt = cedu.result_dt_tm
	from
 		 dcp_forms_ref   			dfr
		, dcp_forms_activity   		dfa
		, dcp_forms_activity_comp   dfac
		, clinical_event			ce
		, encounter					e
		, clinical_event 			ceh
		, clinical_event   			ceg		;grid events
		, ce_date_result			cedg
		, clinical_event   			cea		;individual assays (outerjoin)
		, ce_date_result			ceda
		, clinical_event   			ceu		;individual assays (outerjoin)
		, ce_date_result			cedu	;grid event date (outerjoin)*/
 
 
	plan dfr
	where dfr.active_ind = 1
	;and dfr.event_cd = cvWarfarinForm
 	;and dfr.dcp_forms_ref_id =     477860013.00
 	and dfr.description in( "Anticoagulation Monitoring Log","Warfarin Monitoring Log")
 	
	join dfa
	where dfa.dcp_forms_ref_id = dfr.dcp_forms_ref_id
	and dfa.person_id = nPersonId
	;and dfa.encntr_id = nEncntrId
	and dfa.form_dt_tm >= cnvtlookbehind("6,M")
 
	join dfac
	where dfac.dcp_forms_activity_id =dfa.dcp_forms_activity_id
	and dfac.component_cd = cvClinicalEvent
 
 	join ce
 	where ce.event_id =	dfac.parent_entity_id
 	and ce.valid_from_dt_tm	<	sysdate
 	and ce.valid_until_dt_tm >	sysdate
 	and ce.result_status_cd	in (cvAuth, cvModified);check with end user
 
 	join e
 	where e.encntr_id =	ce.encntr_id
 
 	join ceh
	where ceh.parent_event_id = ce.event_id
	and ceh.event_id != ce.event_id
	and ceh.valid_from_dt_tm < sysdate
	and ceh.valid_until_dt_tm > sysdate
	and ceh.record_status_cd = cvACTIVE
	and ceh.event_class_cd = cvGRP ;should only be groups at this level
 
	join ceg
	where ceg.parent_event_id =	ceh.event_id
	and ceg.valid_from_dt_tm < sysdate
	and ceg.valid_until_dt_tm >	sysdate
	and ceg.event_class_cd = cvGRP ;Only pulling the Grid
 
	join cedg
	where cedg.event_id	= outerjoin(ceg.event_id)
 	and cedg.valid_from_dt_tm < outerjoin(sysdate)
	and cedg.valid_until_dt_tm > outerjoin(sysdate)
 
	join cea
	where cea.parent_event_id = outerjoin(ceg.event_id)
	and cea.valid_from_dt_tm < outerjoin(sysdate)
	and cea.valid_until_dt_tm >	outerjoin(sysdate)
 
	join ceda
	where ceda.event_id = outerjoin(cea.event_id)
 	and ceda.valid_from_dt_tm <	outerjoin(sysdate)
	and ceda.valid_until_dt_tm > outerjoin(sysdate)
 
	join ceu
	where ceu.parent_event_id =	outerjoin(cea.event_id)
	and ceu.valid_from_dt_tm <	outerjoin(sysdate)
	and ceu.valid_until_dt_tm >	outerjoin(sysdate)
 
 
 	join cedu
	where cedu.event_id	=	outerjoin(ceu.event_id)
 	and cedu.valid_from_dt_tm <	outerjoin(sysdate)
	and cedu.valid_until_dt_tm > outerjoin(sysdate)
 
 	order by ce.event_id, ceg.event_id, cea.event_id, ceu.event_id
 
	head report
		vNum = 0
 
	head ce.event_id
		vNum += 1
		stat = alterlist(outrec->qual,vNum)
		vFormComp = 0
 
		outrec->qual[vNum].event_id 	= ce.event_id
		outrec->qual[vNum].form_status	= form_status
		outrec->qual[vNum].from_dt_tm 	= dfa.form_dt_tm
		outrec->qual[vNum].form_name	= form_name
 
	head ceg.event_id
		x=0
 
 	head cea.event_id
 		vFormComp += 1
 		stat = alterlist(outrec->qual[vNum].form_components, vFormComp)
 
 		outrec->qual[vNum].form_components[vFormComp].event_id 			= cea.event_id
		outrec->qual[vNum].form_components[vFormComp].component_name 	= assay_event_disp
 
 		call echo(build2("->Form:",trim(cea.event_tag)," on ",trim(format(cea.event_end_dt_tm,";;q"))))
 	detail
		outrec->qual[vNum].form_components[vFormComp].event_id			= ceu.parent_event_id
 

		call echo(build2("-->results:",trim(ceu.event_title_text),":",ultra_result_val_dt,":",ultra_result_val))
 	  if (dfr.description in("Anticoagulation Monitoring Log")) ;,"Warfarin Monitoring Log")
		case (ceu.event_title_text)
			of "Result Date" 		:
				outrec->qual[vNum].form_components[vFormComp].result_dt			= ultra_result_val_dt
			of "INR" 		:
				outrec->qual[vNum].form_components[vFormComp].INR				= ultra_result_val
			of "Anti-Xa" 	:
				outrec->qual[vNum].form_components[vFormComp].antixa		 	= ultra_result_val
			of "Type" 	:
				outrec->qual[vNum].form_components[vFormComp].type		 	= ultra_result_val
			of "Dose Taken Pt Confirmed" :
				outrec->qual[vNum].form_components[vFormComp].dose_taken		= ultra_result_val
			of "Recommended Dose" 	:
				outrec->qual[vNum].form_components[vFormComp].recommended_dose 	= ultra_result_val
				
			;	outrec->qual[vNum].form_components[vFormComp].recommended_dose = substring(1,27,
			;		outrec->qual[vNum].form_components[vFormComp].recommended_dose)
					
			;	if (size(outrec->qual[vNum].form_components[vFormComp].recommended_dose) > 27)
		
			;		outrec->qual[vNum].form_components[vFormComp].recommended_dose = concat(
			;				 substring(1,27,outrec->qual[vNum].form_components[vFormComp].recommended_dose)
			;				,"\par\pard "
			;				,substring(28,100,outrec->qual[vNum].form_components[vFormComp].recommended_dose)
			;			)
			;		call echo(build("->new rec dose:",outrec->qual[vNum].form_components[vFormComp].recommended_dose))
				
			;	endif
				
			of "Recommended By" 	:
				outrec->qual[vNum].form_components[vFormComp].recommended_by 	= ultra_result_val
			of "*Patient Contacted" :
				outrec->qual[vNum].form_components[vFormComp].patient_contacted	= ultra_result_val
			of "Contact Date" :
				outrec->qual[vNum].form_components[vFormComp].contact_date		= ultra_result_val_dt
			of "Communication Method" :
				outrec->qual[vNum].form_components[vFormComp].comm_method		= ultra_result_val
			of "Next Check" :
				outrec->qual[vNum].form_components[vFormComp].next_check		= ultra_result_val_dt
			of "Notes" :
				outrec->qual[vNum].form_components[vFormComp].notes 			= ultra_result_val
			endcase
		 
		 elseif (dfr.description in("Warfarin Monitoring Log"))
		 	case (ceu.event_title_text)
			of "Date" 		:
				outrec->qual[vNum].form_components[vFormComp].result_dt			= ultra_result_val_dt
			of "INR" 		:
				outrec->qual[vNum].form_components[vFormComp].INR				= ultra_result_val
			of "Anti-Xa" 	:
				outrec->qual[vNum].form_components[vFormComp].antixa		 	= ultra_result_val
			of "Type" 	:
				outrec->qual[vNum].form_components[vFormComp].type		 	= ultra_result_val
			of "Dose Taken Pt Confirmed" :
				outrec->qual[vNum].form_components[vFormComp].dose_taken		= ultra_result_val
			of "Recommended Dose" 	:
				outrec->qual[vNum].form_components[vFormComp].recommended_dose 	= ultra_result_val
			of "Recommended By" 	:
				outrec->qual[vNum].form_components[vFormComp].recommended_by 	= ultra_result_val
			of "*Patient Contacted" :
				outrec->qual[vNum].form_components[vFormComp].patient_contacted	= ultra_result_val
			of "Contact Date" :
				outrec->qual[vNum].form_components[vFormComp].contact_date		= ultra_result_val_dt
			of "Communication Method" :
				outrec->qual[vNum].form_components[vFormComp].comm_method		= ultra_result_val
			of "Next Check" :
				outrec->qual[vNum].form_components[vFormComp].next_check		= ultra_result_val_dt
			of "Notes*" :
				outrec->qual[vNum].form_components[vFormComp].notes 			= ultra_result_val
			endcase	
		 endif
		 
		
	foot cea.event_id
		call echo(build2("rec dose size=",size(outrec->qual[vNum].form_components[vFormComp].recommended_dose)))
		call echo(build2("rec by size=",size(outrec->qual[vNum].form_components[vFormComp].recommended_by)))
		
		call echo(build2("notes size=",size(outrec->qual[vNum].form_components[vFormComp].notes)))
		call echo(build2("notes check=",(size(outrec->qual[vNum].form_components[vFormComp].notes)/notes_max)))
		call echo(build2("notes ceil=",ceil(
				(size(outrec->qual[vNum].form_components[vFormComp].notes)/notes_max))))
				
		;notes
		/*		
		if (size(outrec->qual[vNum].form_components[vFormComp].notes) > notes_max)
			/*
			outrec->qual[vNum].form_components[vFormComp].notes_row_cnt = ceil(
				(size(outrec->qual[vNum].form_components[vFormComp].notes)/notes_max))
			row_cnt = 1
			start_pos = 1
			cur_pos = notes_max
			while (row_cnt <= outrec->qual[vNum].form_components[vFormComp].notes_row_cnt)
				stat = alterlist(outrec->qual[vNum].form_components[vFormComp].notes_split,row_cnt)
				outrec->qual[vNum].form_components[vFormComp].notes_split[row_cnt].notes = substring(start_pos,cnvtint(notes_max),
					outrec->qual[vNum].form_components[vFormComp].notes)
				start_pos = (start_pos + notes_max)
				row_cnt += 1
			endwhile
			
			stat = initrec(pt)
			dcp_parse_text value(outrec->qual[vNum].form_components[vFormComp].notes), value(notes_max)
			outrec->qual[vNum].form_components[vFormComp].notes_row_cnt = pt->line_cnt
			row_cnt = 1
			for (row_cnt = 1 to pt->line_cnt)
				stat = alterlist(outrec->qual[vNum].form_components[vFormComp].notes_split,row_cnt)
				outrec->qual[vNum].form_components[vFormComp].notes_split[row_cnt].notes = pt->lns[row_cnt].line
			endfor
		endif
		
		
		;recommended by
		if (size(outrec->qual[vNum].form_components[vFormComp].recommended_by) > rec_by_max)
			outrec->qual[vNum].form_components[vFormComp].rec_by_row_cnt = ceil(
				(size(outrec->qual[vNum].form_components[vFormComp].recommended_by)/rec_by_max))
			row_cnt = 1
			start_pos = 1
			cur_pos = rec_by_max
			while (row_cnt <= outrec->qual[vNum].form_components[vFormComp].rec_by_row_cnt)
				stat = alterlist(outrec->qual[vNum].form_components[vFormComp].rec_by_split,row_cnt)
				outrec->qual[vNum].form_components[vFormComp].rec_by_split[row_cnt].rec_by = substring(start_pos,cnvtint(rec_by_max),
					outrec->qual[vNum].form_components[vFormComp].recommended_by)
				start_pos = (start_pos + rec_by_max)
				row_cnt += 1
			endwhile
		endif

		;recommended dose
		if (size(outrec->qual[vNum].form_components[vFormComp].recommended_dose) > dose_rec_max)
			outrec->qual[vNum].form_components[vFormComp].rec_dose_row_cnt = ceil(
				(size(outrec->qual[vNum].form_components[vFormComp].recommended_dose)/dose_rec_max))
			row_cnt = 1
			start_pos = 1
			cur_pos = dose_rec_max
			while (row_cnt <= outrec->qual[vNum].form_components[vFormComp].rec_dose_row_cnt)
				stat = alterlist(outrec->qual[vNum].form_components[vFormComp].rec_dose_split,row_cnt)
				outrec->qual[vNum].form_components[vFormComp].rec_dose_split[row_cnt].rec_dose = substring(start_pos,cnvtint(dose_rec_max),
					outrec->qual[vNum].form_components[vFormComp].recommended_dose)
				start_pos = (start_pos + dose_rec_max)
				row_cnt += 1
			endwhile
		endif

		;dose taken
		if (size(outrec->qual[vNum].form_components[vFormComp].dose_taken) > dose_taken_max)
			outrec->qual[vNum].form_components[vFormComp].dose_taken_row_cnt = ceil(
				(size(outrec->qual[vNum].form_components[vFormComp].dose_taken)/dose_taken_max))
			row_cnt = 1
			start_pos = 1
			cur_pos = dose_taken_max
			while (row_cnt <= outrec->qual[vNum].form_components[vFormComp].dose_taken_row_cnt)
				stat = alterlist(outrec->qual[vNum].form_components[vFormComp].dose_taken_split,row_cnt)
				outrec->qual[vNum].form_components[vFormComp].dose_taken_split[row_cnt].dose_taken 
					= substring(start_pos,cnvtint(dose_taken_max),outrec->qual[vNum].form_components[vFormComp].dose_taken)
				start_pos = (start_pos + dose_taken_max)
				row_cnt += 1
			endwhile
		endif
		*/			
	foot ce.event_id
		outrec->qual[vNum].component_cnt = vFormComp
 
	foot report
	outrec->form_cnt = vNum
 
	WITH counter, expand=2
	
	
	for (vNum = 1 to size(outrec->qual,5))
		for (vFormComp = 1 to size(outrec->qual[vNum].form_components,5))
			;notes
			if (size(outrec->qual[vNum].form_components[vFormComp].notes) > notes_max)
				set stat = initrec(pt)
				execute dcp_parse_text value(outrec->qual[vNum].form_components[vFormComp].notes), value(notes_max)
				set outrec->qual[vNum].form_components[vFormComp].notes_row_cnt = pt->line_cnt
				set row_cnt = 1
				for (row_cnt = 1 to pt->line_cnt)
					set stat = alterlist(outrec->qual[vNum].form_components[vFormComp].notes_split,row_cnt)
					set outrec->qual[vNum].form_components[vFormComp].notes_split[row_cnt].notes = pt->lns[row_cnt].line
				endfor
			endif
			
			;recommended by
			if (size(outrec->qual[vNum].form_components[vFormComp].recommended_by) > rec_by_max)
				set stat = initrec(pt)
				execute dcp_parse_text value(outrec->qual[vNum].form_components[vFormComp].recommended_by), value(rec_by_max)
				set outrec->qual[vNum].form_components[vFormComp].rec_by_row_cnt = pt->line_cnt
				set row_cnt = 1
				for (row_cnt = 1 to pt->line_cnt)
					set stat = alterlist(outrec->qual[vNum].form_components[vFormComp].rec_by_split,row_cnt)
					set outrec->qual[vNum].form_components[vFormComp].rec_by_split[row_cnt].rec_by = pt->lns[row_cnt].line
				endfor
			endif

			;recommended dose
			if (size(outrec->qual[vNum].form_components[vFormComp].recommended_dose) > dose_rec_max)
				set stat = initrec(pt)
				execute dcp_parse_text value(outrec->qual[vNum].form_components[vFormComp].recommended_dose), value(dose_rec_max)
				set outrec->qual[vNum].form_components[vFormComp].rec_dose_row_cnt = pt->line_cnt
				set row_cnt = 1
				for (row_cnt = 1 to pt->line_cnt)
					set stat = alterlist(outrec->qual[vNum].form_components[vFormComp].rec_dose_split,row_cnt)
					set outrec->qual[vNum].form_components[vFormComp].rec_dose_split[row_cnt].rec_dose = pt->lns[row_cnt].line
				endfor
			endif

			;dose taken
			if (size(outrec->qual[vNum].form_components[vFormComp].dose_taken) > dose_taken_max)
				set stat = initrec(pt)
				execute dcp_parse_text value(outrec->qual[vNum].form_components[vFormComp].dose_taken), value(dose_taken_max)
				set outrec->qual[vNum].form_components[vFormComp].dose_taken_row_cnt = pt->line_cnt
				set row_cnt = 1
				for (row_cnt = 1 to pt->line_cnt)
					set stat = alterlist(outrec->qual[vNum].form_components[vFormComp].dose_taken_split,row_cnt)
					set outrec->qual[vNum].form_components[vFormComp].dose_taken_split[row_cnt].dose_taken = pt->lns[row_cnt].line
				endfor
			endif			
		endfor
	endfor
end ;LoadTheForm*/
 
call echorecord(outrec)
;===================================================================================================
; OUTPUT
;===================================================================================================
declare NumberofFormsOutput = i4 with constant(3);last 3 forms
 
select into "nl:"
	    result_val_dt = format(outrec->qual[d.seq].form_components[d2.seq].result_dt, "YYYY-MM-DD ;;Q")
	   , INR		= substring(1,50,outrec->qual[d.seq].form_components[d2.seq].INR)
	   , AntiXa		= substring(1,50,outrec->qual[d.seq].form_components[d2.seq].antixa)
	   , type	  	= substring(1,50,outrec->qual[d.seq].form_components[d2.seq].type)
	   , dose_taken  = substring(1,15,outrec->qual[d.seq].form_components[d2.seq].dose_taken)
	   , recommended_dose = substring(1,50,outrec->qual[d.seq].form_components[d2.seq].recommended_dose)
	   , recommended_by = substring(1,50,outrec->qual[d.seq].form_components[d2.seq].recommended_by)
	   , pt_contacted  = substring(1,50,outrec->qual[d.seq].form_components[d2.seq].patient_contacted)
	   , contact_dt = format(outrec->qual[d.seq].form_components[d2.seq].contact_date, "YYYY-MM-DD ;;Q")
	   , comm_method  = substring(1,50,outrec->qual[d.seq].form_components[d2.seq].comm_method)
	   , next_check = format(outrec->qual[d.seq].form_components[d2.seq].next_check, "YYYY-MM-DD ;;Q")
	   , notes		= substring(1,255,outrec->qual[d.seq].form_components[d2.seq].notes)
	   ,form_date	= outrec->qual[d.seq].from_dt_tm
	   ,form_name	= substring(1,60,outrec->qual[d.seq].form_name)
from
	  (dummyt d  with seq = outrec->form_cnt)
	, (dummyt d2 with seq = 1)
 
plan d
where maxrec( d2, outrec->qual[d.seq].component_cnt)
 
join d2
 
order by form_date desc, result_val_dt desc
 
head report
	vFormCnt 	= 0

	vDate		= 1100
	vINR		= 500
	vAntiXa		= 750
	vType		= 1200
	vDoseTaken	= 1750
	vRcmDose	= 2600
	vRcmBy		= 1750
	vPatCont	= 1200
	vContDate	= 1200
	vCommMeth	= 1400
	vNextCheck	= 1100
	vNotes		= 2600
	
	vLast		= 500
 
	call clear_row(0, 18)
	call add_cell( "\b  Date", "NONE", vDate, 0, 0 )
	call add_cell( "\b  INR", "NONE", vINR, 0, 0 )
	call add_cell( "\b  Anti-Xa", "NONE", vAntiXa, 0, 0 )
	call add_cell( "\b  Type", "NONE", vType, 0, 0 )
	call add_cell( "\b  Dose Taken", "NONE", vDoseTaken, 0, 0 )
	call add_cell( "\b  Rec Dose", "NONE", vRcmDose, 0, 0 )
	call add_cell( "\b  Rec By", "NONE", vRcmBy, 0, 0 )
	;call add_cell( "\b  Pt Contacted", "NONE", vPatCont, 0, 0 )
	call add_cell( "\b  Contact Date", "NONE", vContDate, 0, 0 )
	call add_cell( "\b  Comm. Method", "NONE", vCommMeth, 0, 0 )
	call add_cell( "\b  Next Check", "NONE", vNextCheck, 0, 0 )
	call add_cell( "\b  Notes", "NONE", vNotes, 0, 0 )
 	 	
 	call write_row(0)
 
head form_date
	Qualify = 1
	vFormCnt += 1
 
;if (vFormCnt > outrec->form_cnt - NumberofFormsOutput) qualify = 1 endif
 
detail
row_max = 0

if (outrec->qual[d.seq].form_components[d2.seq].dose_taken_row_cnt > row_max)
	row_max = outrec->qual[d.seq].form_components[d2.seq].dose_taken_row_cnt
endif

if (outrec->qual[d.seq].form_components[d2.seq].notes_row_cnt > row_max)
	row_max = outrec->qual[d.seq].form_components[d2.seq].notes_row_cnt
endif

if (outrec->qual[d.seq].form_components[d2.seq].rec_by_row_cnt > row_max)
	row_max = outrec->qual[d.seq].form_components[d2.seq].rec_by_row_cnt
endif

if (outrec->qual[d.seq].form_components[d2.seq].rec_dose_row_cnt > row_max)
	row_max = outrec->qual[d.seq].form_components[d2.seq].rec_dose_row_cnt
endif


if (qualify = 1)
	
	if (row_max = 0)
		call clear_row(0, 18)
		call add_cell( concat(" ",result_val_dt), "NONE", vDate, 0, 1 )
		call add_cell( concat(" ",INR), "NONE", vINR, 0, 1 )
		call add_cell( concat(" ",AntiXa), "NONE", vAntiXa, 0, 1 )
		call add_cell( concat(" ",type), "NONE", vType, 0, 1 )
		call add_cell( concat(" ",dose_taken), "NONE", vDoseTaken, 0, 1 )
		
		call add_cell( concat(" ",recommended_dose), "NONE", vRcmDose, 0, 1 )
		call add_cell( concat(" ",recommended_by), "NONE", vRcmBy, 0, 1 )
		;call add_cell( concat(" ",pt_contacted), "NONE", vPatCont, 0, 1 )
		call add_cell( concat(" ",contact_dt), "NONE", vContDate, 0, 1 )
		call add_cell( concat(" ",comm_method), "NONE", vCommMeth, 0, 1 )
		call add_cell( concat(" ",next_check), "NONE", vNextCheck, 0, 1 )
		call add_cell( concat(" ",notes), "NONE", vNotes, 0, 1 )
	 
		call write_row(0)
		
		else
			row_cnt = 1
			while (row_cnt <= row_max)
				call clear_row(0, 18)
				
				if (row_cnt = 1)
					call add_cell( concat(" ",result_val_dt), "NONE", vDate, 0, 1 )
				else
					call add_cell( concat(" "), "NONE", vDate, 0, 1 )
				endif
				
				if (row_cnt = 1)
					call add_cell( concat(" ",INR), "NONE", vINR, 0, 1 )
				else
					call add_cell( concat(" "), "NONE", vINR, 0, 1 )
				endif
				
				if (row_cnt = 1)
					call add_cell( concat(" ",AntiXa), "NONE", vAntiXa, 0, 1 )
				else
					call add_cell( concat(" "), "NONE", vAntiXa, 0, 1 )
				endif
				
				if (row_cnt = 1)
					call add_cell( concat(" ",type), "NONE", vType, 0, 1 )
				else
					call add_cell( concat(" "), "NONE", vType, 0, 1 )
				endif
				
				;dose taken
				if ((outrec->qual[d.seq].form_components[d2.seq].dose_taken_row_cnt = 0) and (row_cnt = 1))
					call add_cell( concat(" ",dose_taken), "NONE", vDoseTaken, 0, 1 )
				else
					if (row_cnt > outrec->qual[d.seq].form_components[d2.seq].dose_taken_row_cnt)
						call add_cell( concat(" "), "NONE", vDoseTaken, 0, 1 )
					else
						call add_cell( concat(" ",outrec->qual[d.seq].form_components[d2.seq].dose_taken_split[row_cnt].dose_taken)
							, "NONE", vDoseTaken, 0, 1 )
					endif
				endif
				
				;recommended dose
				if ((outrec->qual[d.seq].form_components[d2.seq].rec_dose_row_cnt = 0) and (row_cnt = 1))
					call add_cell( concat(" ",recommended_dose), "NONE", vRcmDose, 0, 1 )
				else
					if (row_cnt > outrec->qual[d.seq].form_components[d2.seq].rec_dose_row_cnt)
						call add_cell( concat(" "), "NONE", vRcmDose, 0, 1 )
					else
						call add_cell( concat(" ",outrec->qual[d.seq].form_components[d2.seq].rec_dose_split[row_cnt].rec_dose)
							, "NONE", vRcmDose, 0, 1 )
					endif
				endif
				
				;recommended by
				if ((outrec->qual[d.seq].form_components[d2.seq].rec_by_row_cnt = 0) and (row_cnt = 1))
					call add_cell( concat(" ",recommended_by), "NONE", vRcmBy, 0, 1 )
				else
					if (row_cnt > outrec->qual[d.seq].form_components[d2.seq].rec_by_row_cnt)
						call add_cell( concat(" "), "NONE", vRcmBy, 0, 1 )
					else
						call add_cell( concat(" ",outrec->qual[d.seq].form_components[d2.seq].rec_by_split[row_cnt].rec_by)
							, "NONE", vRcmBy, 0, 1 )
					endif
				endif
				
				if (row_cnt = 1)
					call add_cell( concat(" ",contact_dt), "NONE", vContDate, 0, 1 )
				else
					call add_cell( concat(" "), "NONE", vContDate, 0, 1 )
				endif
				
				if (row_cnt = 1)
					call add_cell( concat(" ",comm_method), "NONE", vCommMeth, 0, 1 )
				else
					call add_cell( concat(" "), "NONE", vCommMeth, 0, 1 )
				endif
				
				if (row_cnt = 1)
					call add_cell( concat(" ",next_check), "NONE", vNextCheck, 0, 1 )
				else
					call add_cell( concat(" "), "NONE", vNextCheck, 0, 1 )
				endif
				
				;notes
				if ((outrec->qual[d.seq].form_components[d2.seq].notes_row_cnt = 0) and (row_cnt = 1))
					call add_cell( concat(" ",notes), "NONE", vNotes, 0, 1 )
				else
					if (row_cnt > outrec->qual[d.seq].form_components[d2.seq].notes_row_cnt)
						call add_cell( concat(" "), "NONE", vNotes, 0, 1 )
					else
						call add_cell( concat(" ",outrec->qual[d.seq].form_components[d2.seq].notes_split[row_cnt].notes)
							, "NONE", vNotes, 0, 1 )
					endif
				endif
				
				call write_row(0)
				row_cnt += 1
			endwhile
	endif
endif
 
go to exit_script
 
/* ready to exit..... */
#exit_script
call add_rtf("}")
 
;call echorecord(outrec)
call echo(reply->text)
 
end go
