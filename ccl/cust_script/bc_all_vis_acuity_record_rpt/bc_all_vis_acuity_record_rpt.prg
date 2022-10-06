/***********************************************************************************************************************
  Program Name:       	bc_all_vis_acuity_record_rpt
  Source File Name:   	bc_all_vis_acuity_record_rpt.prg
  Program Written By: 	Chad Cummings
  Date:  			  	17-Aug-2022
  Program Purpose:   	Visual Acuity Monitoring Report - Powerform
 
************************************************************************************************************************
												*MODIFICATION HISTORY*
************************************************************************************************************************
 
Rev  Date         Jira       Programmer             Comment
---  -----------  ---------  ---------------------  --------------------------------------------------------------------
000  17-Aug-2022  CST-174111 Chad Cummings          Created
***********************************************************************************************************************/
 
 
drop program bc_all_vis_acuity_record_rpt:dba go
create program bc_all_vis_acuity_record_rpt:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Encounter ID" = 112848566.0 

with OUTDEV, encntr_id

call echo(build2("$encntr_id = ",$encntr_id))
 
; Standard executes
execute bc_all_all_date_routines
execute bc_all_all_std_routines
execute bc_all_all_pdf_to_chart
execute bc_all_code_value_forms_func 
 
; Read all code values in from reference template JSON document
execute bc_all_ccl_ref_template "bc_all_vis_acuity_record_rpt", 1

 
; Misc variables
declare nNum = i4
declare cString = vc

declare cv8_Auth = f8 with noconstant(uar_get_code_by("MEANING", 8, "AUTH"))
declare cv8_Modified = f8 with noconstant(uar_get_code_by("MEANING", 8, "MODIFIED"))
declare cv8_InError1 = f8 with noconstant(uar_get_code_by("MEANING", 8, "IN ERROR"))
declare cv8_InError2 = f8 with noconstant(uar_get_code_by("MEANING", 8, "INERRNOMUT"))
declare cv8_InError3 = f8 with noconstant(uar_get_code_by("MEANING", 8, "INERRNOVIEW"))
declare cv8_InError4 = f8 with noconstant(uar_get_code_by("MEANING", 8, "INERROR"))
declare cv48_Active = f8 with noconstant(uar_get_code_by("MEANING", 48, "ACTIVE"))
declare cv73_CommonSrc = f8 with noconstant(uar_get_code_by("DISPLAYKEY",73,"COMMONSRC"))

;active
DECLARE cvACTIVE = F8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",48,"ACTIVE")), PROTECT 

;catalog type
DECLARE cvPHARMACY = F8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",6000,"PHARMACY")), PROTECT 
 
;activity type
DECLARE cvAT_CPHARMACY = F8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",106,"PHARMACY")), PROTECT 
 
;order statuses
DECLARE cvFUTURE = F8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",6004,"FUTURE")), PROTECT 
DECLARE cvORDERED = F8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",6004,"ORDERED")), PROTECT 
DECLARE cvINPROCESS = F8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",6004,"INPROCESS")), PROTECT 
DECLARE cvPENDING = F8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",6004,"PENDING")), PROTECT 
DECLARE cvPENDING_REV = F8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",6004,"PENDING REV")), PROTECT
DECLARE cvUNSCHEDULED = F8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",6004,"UNSCHEDULED")), PROTECT 

declare sAction = vc with noconstant(""), protect
declare sNoteDispKey = vc with constant("VISUALACUITYMONITORINGRECORDTEXT"), protect
declare sNoteDisplay = vc with constant("Visual Acuity Monitoring Record (PDF)"), protect
declare sNoteText = vc with constant("Visual Acuity Monitoring Record"), protect
declare nTargetParentEventId = f8 with noconstant(0.00), protect
declare sMsgReply = vc with noconstant(""),protect
declare dTimeStampDt = dm12 with constant(SYSTIMESTAMP), protect
declare sFolder = vc with constant(concat(trim(LOGICAL("CCLUSERDIR"),3),"/")), protect
declare sFile = vc with constant(build("pdfattach_",format(dTimeStampDt,"YYYYMMDDHHMM_SSCCCCCC;;D"),".pdf")), protect	;unique name
declare nDelFile = i4 with noconstant(0),protect
 

record 4170162request (
  1 person_id = f8   
  1 life_cycle_status_flag = i2   
) 


record 4170154request (
  1 encntr_id = f8   
  1 clinical_service_list [*]   
    2 clinical_service_cd = f8   
  1 diag_type_list [*]   
    2 diag_type_cd = f8   
  1 classification_list [*]   
    2 classification_cd = f8   
  1 inactive_ind = i2   
  1 encntr_id_list [*]   
    2 encntr_id = f8   
  1 trans_nomen_ind = i2   
) 



; Define report structure
free record outrec
record outrec (
    1 data[*]
        2 person_id                 = f8
        2 encntr_id                 = f8
        2 link_clineventid			= f8
        2 nDcpFormsRefId			= f8
        2 nTargetParentEventId		= f8
        2 updt_id					= f8
        2 prim_event_end_dt_tm_gen	= dq8
        2 qualified                 = i4
        2 cdr_name_full_formatted   = vc
        2 cdr_birth_date            = vc
        2 cdr_age                   = vc
        2 cdr_mrn                   = vc
        2 cdr_encounter             = vc
        2 cdr_phn                   = vc
        2 dual_modality             = vc
        2 encntr_location			= vc
        2 identifier				= vc
        2 blind_main				= i2
        2 blind_left				= i2
        2 blind_right				= i2
        2 glaucoma_main				= i2
        2 glaucoma_right			= i2
        2 glaucoma_left				= i2
        2 cataract_main				= i2
        2 cataract_left				= i2
        2 cataract_right			= i2
        2 ethambutol_ind			= i2
        2 rifabutin_ind				= i2
        2 rifampin_ind 				= i2
        2 form_instance_cnt			= i2
        2 form_instance[*]
         	3 dcp_forms_activity_id	= f8
         	3 form_dt_tm			= dq8
         	3 Visual_Acuity_Form_ST = vc
			3 Visual_Acuity_Eye_Chart_Used = vc
			3 Corrective_Lenses_Worn = vc
			3 Pinhole_Occluder_Used = vc
			3 Eye_Right_Visual_Acuity = vc
			3 Eye_Left_Visual_Acuity = vc
			3 Eye_Right_Snellen_Chart_with_Pinhole = vc
			3 Eye_Left_Snellen_Chart_with_Pinhole = vc
			3 Colour_Discrimination_Right_Eye = vc
			3 Colour_Discrimination_Left_Eye = vc
			3 Subjective_Symptoms_for_Bilateral_Eyes = vc
			3 Visual_Acuity_Assessment_Date = dq8
			3 Initials = vc
)
 
;default to creating a new document
set sAction = "CREATE"

; Collect the core data
select into "nl:"
from   encounter       e
plan e
   where e.encntr_id = $encntr_id
   and e.active_ind = 1
head report
   nCount = 0
detail
   nCount = nCount + 1
   stat = alterlist(outrec->data, nCount)

   outrec->data[nCount].encntr_id = e.encntr_id
   outrec->data[nCount].person_id = e.person_id
   outrec->data[nCount].prim_event_end_dt_tm_gen = cnvtdatetime(sysdate)
   outrec->data[nCount].updt_id = 1
   outrec->data[nCount].encntr_location = concat(trim(uar_get_code_display(e.loc_nurse_unit_cd)))
   
with counter, time=200

if (validate(link_clineventid) = TRUE)
	set outrec->data[1].link_clineventid = link_clineventid
   	call echo(build("link_clineventid=",link_clineventid))
endif


set outrec->data[1].nDcpFormsRefId = bc_get_dcp_form_ref_id_by("DFR_DESCRIPTION","Visual Acuity Monitoring Record")
call bc_load_events_by_dcp_form_ref_id(outrec->data[1].nDcpFormsRefId,0) 

if (validate(rFormEvents))
	call echorecord(rFormEvents)
endif

select into $outdev;"nl:"
	dcp_forms_activity_id	= dfa.dcp_forms_activity_id,
	form_dt_tm				= dfa.form_dt_tm,
	form_status_cd			= dfa.form_status_cd,
	updt_dt_tm				= dfa.updt_dt_tm,
	encntr_id				= ce1.encntr_id,
	person_id				= ce1.person_id,
	event_display_key		= substring(1,40,uar_get_displaykey(ce3.event_cd)),
	result					= substring(1,255,ce3.event_tag),
	string_result			= replace(replace(csr.string_result_text, char(10), ""), char(13), " "),
	date_result				= sCST_DT_TM(cdr.result_dt_tm),
	time_result				= format(cdr.result_dt_tm, "hh:mm;;q)")
from	dcp_forms_activity		dfa,
		dcp_forms_activity_comp	dfac,
		clinical_event			ce1,
		clinical_event			ce2,
		clinical_event			ce3,
		ce_string_result		csr,
		ce_date_result			cdr,
		code_value 				cv,
		prsnl					p
plan dfa
	where dfa.encntr_id = outrec->data[1].encntr_id
	and dfa.dcp_forms_ref_id = outrec->data[1].nDcpFormsRefId
	and dfa.form_status_cd in (cv8_Auth, cv8_Modified)
	and dfa.active_ind = 1
join dfac
	where dfac.dcp_forms_activity_id = dfa.dcp_forms_activity_id
	and dfac.parent_entity_name = "CLINICAL_EVENT"
join ce1
	where ce1.event_id = dfac.parent_entity_id
	and ce1.valid_until_dt_tm > sysdate
	and ce1.result_status_cd in (cv8_Auth, cv8_Modified)
join ce2
	where ce2.parent_event_id = ce1.event_id
	and ce2.valid_until_dt_tm > sysdate
	and ce2.result_status_cd in (cv8_Auth, cv8_Modified)
join ce3
	where ce3.parent_event_id = ce2.event_id
	and ce3.valid_until_dt_tm > sysdate
	and ce3.result_status_cd in (cv8_Auth, cv8_Modified)
join cv
	where cv.code_value = ce3.event_cd
join p
	where p.person_id = ce3.verified_prsnl_id
join csr
	where csr.event_id = outerjoin(ce3.event_id)
	and csr.valid_until_dt_tm > outerjoin(sysdate)
join cdr
	where cdr.event_id = outerjoin(ce3.event_id)
	and cdr.valid_until_dt_tm > outerjoin(sysdate)
order dcp_forms_activity_id
head report
	nCount = 0
head dcp_forms_activity_id
	outrec->data[1].form_instance_cnt += 1
	stat = alterlist(outrec->data[1].form_instance,outrec->data[1].form_instance_cnt)
	outrec->data[1].form_instance[outrec->data[1].form_instance_cnt].dcp_forms_activity_id = dfa.dcp_forms_activity_id
	outrec->data[1].form_instance[outrec->data[1].form_instance_cnt].form_dt_tm = dfa.beg_activity_dt_tm
detail
	call echo(build2(	"ce3.event_cd = "
						,trim(cv.display)
						,";",trim(cv.display_key)
						,":",trim(ce3.result_val)
						,":",trim(p.name_full_formatted)))
	case(cv.display_key)
		 of ^VISUALACUITYFORMST^: 
		 	outrec->data[1].form_instance[outrec->data[1].form_instance_cnt].Visual_Acuity_Form_ST = ce3.result_val
		 of ^VISUALACUITYEYECHARTUSED^: 
		 	outrec->data[1].form_instance[outrec->data[1].form_instance_cnt].Visual_Acuity_Eye_Chart_Used = ce3.result_val
		 of ^CORRECTIVELENSESWORN^: 
		 	outrec->data[1].form_instance[outrec->data[1].form_instance_cnt].Corrective_Lenses_Worn = ce3.result_val
		 of ^PINHOLEOCCLUDERUSED^: 
		 	outrec->data[1].form_instance[outrec->data[1].form_instance_cnt].Pinhole_Occluder_Used = ce3.result_val
		 of ^EYERIGHTVISUALACUITY^: 
		 	outrec->data[1].form_instance[outrec->data[1].form_instance_cnt].Eye_Right_Visual_Acuity = ce3.result_val
		 of ^EYELEFTVISUALACUITY^: 
		 	outrec->data[1].form_instance[outrec->data[1].form_instance_cnt].Eye_Left_Visual_Acuity = ce3.result_val
		 of ^EYERIGHTSNELLENCHARTWITHPINHOLE^: 
		 	outrec->data[1].form_instance[outrec->data[1].form_instance_cnt].Eye_Right_Snellen_Chart_with_Pinhole = ce3.result_val
		 of ^EYELEFTSNELLENCHARTWITHPINHOLE^: 
		 	outrec->data[1].form_instance[outrec->data[1].form_instance_cnt].Eye_Left_Snellen_Chart_with_Pinhole = ce3.result_val
		 of ^COLOURDISCRIMINATIONRIGHTEYE^: 
		 	outrec->data[1].form_instance[outrec->data[1].form_instance_cnt].Colour_Discrimination_Right_Eye = ce3.result_val
		 of ^COLOURDISCRIMINATIONLEFTEYE^: 
		 	outrec->data[1].form_instance[outrec->data[1].form_instance_cnt].Colour_Discrimination_Left_Eye = ce3.result_val
		 of ^SUBJECTIVESYMPTOMSFORBILATERALEYES^: 
		 	outrec->data[1].form_instance[outrec->data[1].form_instance_cnt].Subjective_Symptoms_for_Bilateral_Eyes = ce3.result_val
		 of ^VISUALACUITYASSESSMENTDATE^: 
		 	outrec->data[1].form_instance[outrec->data[1].form_instance_cnt].Visual_Acuity_Assessment_Date = cdr.result_dt_tm	
	endcase
	outrec->data[1].form_instance[outrec->data[1].form_instance_cnt].Initials = concat(
																							substring(1,1,p.name_first_key)
																							,substring(1,1,p.name_last_key)
																						)
with nocounter

;Check Problems
set stat = initrec(4170162request)
free record 4170162reply

set 4170162request->person_id = outrec->data[1].person_id
set 4170162request->life_cycle_status_flag = 0

set stat = tdbexecute(600005,4170146,4170162,"REC",4170162request,"REC",4170162reply)
call echorecord(4170162reply)

for (nNum = 1 to size(4170162reply->problem,5))
	;blind
	if (	(cnvtlower(4170162reply->problem[nNum].annotated_display) = "*blind*")
		 or	(cnvtlower(4170162reply->problem[nNum].source_string) = "*blind*")
		)
		call echo("Found Blind Problem")
		set outrec->data[1].blind_main = 1
		
			if (	(cnvtlower(4170162reply->problem[nNum].annotated_display) = "*left*")
			 	or	(cnvtlower(4170162reply->problem[nNum].source_string) = "*left*")
				)
				call echo("Found Left-Blind Problem")
				set outrec->data[1].blind_left = 1
			endif		

			if (	(cnvtlower(4170162reply->problem[nNum].annotated_display) = "*right*")
			 	or	(cnvtlower(4170162reply->problem[nNum].source_string) = "*right*")
				)
				call echo("Found Right-Blind Problem")
				set outrec->data[1].blind_right = 1
			endif		
	endif

	;glaucoma
	if (	(cnvtlower(4170162reply->problem[nNum].annotated_display) = "*glaucoma*")
		 or	(cnvtlower(4170162reply->problem[nNum].source_string) = "*glaucoma*")
		)
		call echo("Found Glaucoma Problem")
		set outrec->data[1].glaucoma_main = 1
		
			if (	(cnvtlower(4170162reply->problem[nNum].annotated_display) = "*left*")
			 	or	(cnvtlower(4170162reply->problem[nNum].source_string) = "*left*")
				)
				set outrec->data[1].glaucoma_left = 1
			endif		

			if (	(cnvtlower(4170162reply->problem[nNum].annotated_display) = "*right*")
			 	or	(cnvtlower(4170162reply->problem[nNum].source_string) = "*right*")
				)
				set outrec->data[1].glaucoma_right = 1
			endif		
	endif
	
	;cataract
	if (	(cnvtlower(4170162reply->problem[nNum].annotated_display) = "*cataract*")
		 or	(cnvtlower(4170162reply->problem[nNum].source_string) = "*cataract*")
		)
		set outrec->data[1].cataract_main = 1
		
			if (	(cnvtlower(4170162reply->problem[nNum].annotated_display) = "*left*")
			 	or	(cnvtlower(4170162reply->problem[nNum].source_string) = "*left*")
				)
				set outrec->data[1].cataract_left = 1
			endif		

			if (	(cnvtlower(4170162reply->problem[nNum].annotated_display) = "*right*")
			 	or	(cnvtlower(4170162reply->problem[nNum].source_string) = "*right*")
				)
				set outrec->data[1].cataract_right = 1
			endif		
	endif
endfor

;Check Diagnosis
set stat = initrec(4170154request)
free record 4170154reply

set 4170154request->encntr_id = outrec->data[1].encntr_id
set 4170154request->inactive_ind = 0

set stat = tdbexecute(600005,4170139,4170154,"REC",4170154request,"REC",4170154reply)
call echorecord(4170154reply)

for (nNum = 1 to size(4170154reply->item,5))
	call echo(build("4170154reply->item[",nNum,"].diagnosis_display=",4170154reply->item[nNum].diagnosis_display))
	call echo(build("4170154reply->item[",nNum,"].clinical_diag=",4170154reply->item[nNum].clinical_diag))
	
	;blind
	if (	(cnvtlower(4170154reply->item[nNum].diagnosis_display) = "*blind*")
		or	(cnvtlower(4170154reply->item[nNum].clinical_diag) = "*blind*")
		)
		set outrec->data[1].blind_main = 1
		
		if (	(cnvtlower(4170154reply->item[nNum].diagnosis_display) = "*left*")
			or	(cnvtlower(4170154reply->item[nNum].clinical_diag) = "*left*")
			)
			set outrec->data[1].blind_left = 1
		endif

		if (	(cnvtlower(4170154reply->item[nNum].diagnosis_display) = "*right*")
			or	(cnvtlower(4170154reply->item[nNum].clinical_diag) = "*right*")
			)
			set outrec->data[1].blind_right = 1
		endif	
	endif

	;cataract
	if (	(cnvtlower(4170154reply->item[nNum].diagnosis_display) = "*cataract*")
		or	(cnvtlower(4170154reply->item[nNum].clinical_diag) = "*cataract*")
		)
		call echo(build("Found Cataract Diagnosis"))
		set outrec->data[1].cataract_main = 1
		
		if (	(cnvtlower(4170154reply->item[nNum].diagnosis_display) = "*left*")
			or	(cnvtlower(4170154reply->item[nNum].clinical_diag) = "*left*")
			)
			call echo(build("Found Cataract-Left Diagnosis"))
			set outrec->data[1].cataract_left = 1
		endif

		if (	(cnvtlower(4170154reply->item[nNum].diagnosis_display) = "*right*")
			or	(cnvtlower(4170154reply->item[nNum].clinical_diag) = "*right*")
			)
			call echo(build("Found Cataract-Right Diagnosis"))
			set outrec->data[1].cataract_right = 1
		endif	
	endif
	
	;glaucoma
	if (	(cnvtlower(4170154reply->item[nNum].diagnosis_display) = "*glaucoma*")
		or	(cnvtlower(4170154reply->item[nNum].clinical_diag) = "*glaucoma*")
		)
		set outrec->data[1].glaucoma_main = 1
		
		if (	(cnvtlower(4170154reply->item[nNum].diagnosis_display) = "*left*")
			or	(cnvtlower(4170154reply->item[nNum].clinical_diag) = "*left*")
			)
			set outrec->data[1].glaucoma_left = 1
		endif

		if (	(cnvtlower(4170154reply->item[nNum].diagnosis_display) = "*right*")
			or	(cnvtlower(4170154reply->item[nNum].clinical_diag) = "*right*")
			)
			set outrec->data[1].glaucoma_right = 1
		endif	
	endif	

endfor

;get meds
select 
		order_id			= o.order_id,
		action_sequence		= oi.action_sequence,
		catalog_disp		= uar_get_code_display(o.catalog_cd),
		ordered_as_mnemonic	= o.ordered_as_mnemonic,
		clinical_display	= o.clinical_display_line,
		order_status_disp	= uar_get_code_display(o.order_status_cd),
		stop_type_disp		= uar_get_code_display(o.stop_type_cd),
		soft_stop_dt_tm_disp= sCST_DT_TM(o.soft_stop_dt_tm),
		facility_disp		= if (o.encntr_id = 0)
								uar_get_code_display(o.future_location_facility_cd)
							  else
							  	uar_get_code_display(e.loc_facility_cd)
							  endif,
		nurse_unit_disp		= if (o.encntr_id = 0)
								uar_get_code_display(o.future_location_nurse_unit_cd)
							  else
							  	uar_get_code_display(e.loc_nurse_unit_cd)
							  endif,
		encntr_type_disp	= uar_get_code_display(e.encntr_type_cd),
		prn_ind 			= o.prn_ind,
		last_action_sequence= o.last_action_sequence ;*/
	from	orders				o,
			order_ingredient	oi,
			encounter			e,
			order_product		op
	plan o
		where o.order_status_cd in (cvOrdered, cvFuture, cvInProcess, cvPending, cvPending_Rev, cvUnscheduled)
		and o.person_id = outrec->data[1].person_id
		and o.catalog_type_cd = cvPharmacy
		and o.activity_type_cd = cvAt_CPharmacy
		and o.orig_ord_as_flag = 0
		and o.discontinue_ind = 0
		and o.active_ind = 1
		and o.active_status_cd = cvActive
	join e
		where e.encntr_id = o.encntr_id
	join oi
		where oi.order_id = o.order_id
	join op
		where op.order_id = outerjoin(oi.order_id)
		and op.action_sequence = outerjoin(oi.action_sequence)
		and op.ingred_sequence = outerjoin(oi.comp_sequence)
	
	order order_id, action_sequence desc 
	
	detail
		call echo(build2("order=",o.order_mnemonic))
		if (cnvtlower(o.order_mnemonic) = "*rifampin*")	
			outrec->data[1].rifampin_ind = 1
		endif
		
		if (cnvtlower(o.order_mnemonic) = "*rifabutin*")	
			outrec->data[1].rifabutin_ind = 1
		endif
		
		if (cnvtlower(o.order_mnemonic) = "*ethambutol*")	
			outrec->data[1].ethambutol_ind = 1
		endif
	with nocounter
 
 
 
call echo(" Execute the CDR to collect common data")
execute bc_all_common_data_collection

call echo(" find existing document") 
select into "nl:"
from 
	clinical_event ce 
plan ce 
	where ce.encntr_id = outrec->data[1].encntr_id
	and ce.event_cd = value(uar_get_code_by("DISPLAYKEY",72,"VISUALACUITYMONITORINGRECORDTEXT"))
	and ce.entry_mode_cd not in(value(uar_get_code_by("MEANING",29520,"POWERFORMS")))
order by 
	 ce.event_cd
	,ce.event_end_dt_tm desc
head report
	null
head ce.event_cd
	nTargetParentEventId = ce.parent_event_id
	sAction = "MODIFY"
	outrec->data[1].nTargetParentEventId = nTargetParentEventId
with format(date,";;q"), uar_code(d) 


if(validate(eksdata))
	call echo(" execute layout")	
	execute bc_all_vis_acuity_record_lyt sFile




	set sMsgReply = pdfStoreAttachToChart	(	1														;use 1 for rule execution, 0 for report/backend
												,sAction													;Actions: CREATE,MODIFY or INERROR
												,outrec->data[1].person_id									;used for all actions (create/modify/in-error)
												,outrec->data[1].encntr_id									;used for all actions (create/modify/in-error)
												,outrec->data[1].updt_id									;used for all actions (create/modify/in-error)
												,nTargetParentEventId										;used for modify/in-error, use 0.00 for create
												,cnvtdatetime(outrec->data[1].prim_event_end_dt_tm_gen)		;same as soource event_end_dt_tm
												,sNoteDispKey												;used for create, note type displaykey (specific users can see certain types)
												,sNoteDisplay												;name, note display
												,sNoteText													;note subtext
												,sFolder													;file details
												,sFile														;file details
												,nDelFile													;delete file indicator
											)	;go to end_report

else
	call echo(" execute layout")	
	execute bc_all_vis_acuity_record_lyt $OUTDEV
endif


if(validate(retval))
	set retval = 100
endif
if(validate(log_message))		
	set log_message = build2("Encntr_id: ",outrec->data[1].encntr_id,"; Clinical event: ",0.0
																,"; Reply Status: ",sMsgReply,cnvtrectojson(outrec))
endif
if(validate(log_misc1))			
	if(substring(1,7,sMsgReply) = "CREATE:")								;customized message to end user
		set log_misc1 = concat("Created ",trim(sNoteDisplay,3)," on "
			,trim(outrec->data[1].cdr_name_full_formatted,3)
			," in documents section for Enc#: "
			,trim(outrec->data[1].cdr_encounter,3))
	elseif(substring(1,9,sMsgReply) = "MODIFIED:")
		set log_misc1 = concat("Modified ",trim(sNoteDisplay,3)," on "
		,trim(outrec->data[1].cdr_name_full_formatted,3)
		," in documents section for Enc#: "
		,trim(outrec->data[1].cdr_encounter,3))
	elseif(substring(1,11,sMsgReply) = "IN-ERRORED:")
		set log_misc1 = concat("In-Errored ",trim(sNoteDisplay,3)," on "
			,trim(outrec->data[1].cdr_name_full_formatted,3)
			," in documents section for Enc#: "
			,trim(outrec->data[1].cdr_encounter,3))
	else	;show error for troubleshooting
		set log_misc1 = concat("Error trying to attach PDF ",trim(sNoteDisplay,3)," on "
			,trim(outrec->data[1].cdr_name_full_formatted,3)
			," in documents section for Enc#: "
			,trim(outrec->data[1].cdr_encounter,3),"."
			;," prim_clinical_event_id: ",build(outrec->data[1].prim_clinical_event_id)
			," Please report the following error to the reporting team: "
			,trim(sMsgReply,3))
	endif
endif


#end_program

	call echorecord(outrec) 
 
end go
