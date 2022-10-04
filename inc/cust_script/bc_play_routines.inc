/*****************************************************************************
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:
  Source file name:   bc_common_routines.inc
  Object name:        n/a
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
002   12/02/2021  Chad Cummings			CST-137152 Added LTD Locations
******************************************************************************/
 
;*************************************************************************
;* COMMON RECORD STRUCTURES
;*************************************************************************
;the frec record structure is used by CCLIO() for the log file
free record frec
record frec
	(
     1 file_desc = i4
     1 file_offset = i4
     1 file_dir = i4
     1 file_name = vc
     1 file_buf = vc
)
 
 
free record program_log
record program_log
	(
	 1 produce_log				= i2	;0 to start a log, 1 to not create a log
	 1 msgview_log				= i2    ;0 not to write to msgview, 1 will write to msgview
	 1 curdomain				= vc	;store the current domain
	 1 curprog					= vc    ;store the current program
	 1 display_on_exit			= i2	;display audit log on exit if 1
	 1 run_from_ops				= i2	;set to 1 if run from ops
	 1 run_from_eks				= i2 	;set to 1 if the script is executed from a rule
	 1 ops_request				= f8	;ops request number
	 1 ops_date					= dq8	;ops date
	 1 files							;files used in the program
	  2 file_path				= vc	;path to domain cclscratch
	  2 ccluserdir				= vc	;path to domain ccluserdir
	  2 filename_log 			= vc	;log filename
	  2 filename_zip			= vc	;zip filename
	  2 filename_audit 			= vc	;audit filename
	  2 filename_audit_zip		= vc	;audit zip filename
	  2 attachments_cnt			= i2	;number of attachments
	  2 attachments[*]
	   3 file_path				= vc	;path to attachments
	   3 filename				= vc    ;file_names
)
 
free record bc_common
record bc_common
(
	1 code_set 					= i4	;custom code set for process options
	1 validation_mode_ind		= i2	;validation mode indicator 0 = no, 1 = last name
	1 validation_param			= vc	;validation parameter, based on mode indicator
	1 valid_ind					= i2	;1 = valid patient, 0 = invalid patient (exit)
	1 requisition_cnt			= i2	;number of requisitions to qualify
	1 requisition_qual[*]				;list of requisitions that qualify for PDF mode
	 2 requisition_format_cd	= f8	;code value of the requisition to match
	 2 requisition_object		= vc	;object name of the program to execute to generate the req
	 2 requisition_title		= vc	;title used to store single ordres
	 2 collation_seq			= i2	;collation_seq states single order req (1) or multiple (2)
	1 req_multiple_cnt	= i2			;number of requisitions to qualify
	1 req_multiple_qual[*]				;list of requisitions that qualify for PDF mode
	 2 requisition_format_cd	= f8	;code value of the requisition to match
	 2 requisition_object		= vc	;object name of the program to execute to generate the req
	 2 requisition_title		= vc	;title used to store single ordres
	 2 collation_seq			= i2	;collation_seq states single order req (1) or multiple (2)
	1 catalog_type_cnt			= i2	;catalog type count
	1 catalog_type[*]					;list of catalog types to qualify
	 2 catalog_type_cd			= f8	;catalog type code value
	1 oef_cnt					= i2
	1 oef_qual[*]
	 2 oef_req_format_cd		= f8
	 2 oef_req_type				= vc
	 2 oef_change_processing 	= i2
	 2 field_cnt				= i2
	 2 field_qual[*]
	  3 oe_field_id				= f8
	  3 oe_format_id			= f8
	1 app_cnt 					= i2	;014
	1 app_qual[*]						;014
	 2 app_nbr_string			= vc	;014
	 2 app_nbr					= i4	;014
	1 storage_event_cd			= f8	;event code to use when saving the PDF
	1 storage_content_type_cd	= f8	;content type to use when storing the document
	1 person_id					= f8	;person_id of the patient
	1 encntr_id					= f8	;encntr_id of the patient's encoutner (originating encoutner for future orders)
	1 person_name_last 			= vc	;last name of the patient (valued if used in validation)
	1 log_level					= i2	;0-default,1-echo and file logging,2-msgview
	1 pdf_event_cd				= f8	;event code for clinical documentation
	1 pdf_display_key			= vc	;display key for the event code
	1 pdf_content_type			= vc	;content type name
	1 reference_task_id			= f8	;reference_task_id for the task that will indicate a new print is needed
	1 requestin_ind				= i2    ;1-indicates requestin->request is used
	1 scheduling_location_field_id = f8
	1 scheduling_location_field_non_radiology_id = f8
	1 print_to_paper_cd			= f8
	1 paper_referral_cd			= f8
	1 location_cnt				= i2	;total number of locations that qualify (translated to unit level)
	1 location_qual[*]
	 2 display					= vc	;location display
	 2 code_value				= f8	;code_value of the unit level
)
 
 
 
/************************************************************************************
 *                   Get the Scheduling Location Field Id                           *
 ************************************************************************************/
 
 
;*************************************************************************
;* Find the SAMPLE ROUTINE
;*************************************************************************
declare	   bc_common_sample(null) = null
subroutine bc_common_sample(null)
	call writeLog(build2("* START bc_common_sample *********************************"))
	call writeLog(build2("* END   bc_common_sample *********************************"))
end ;subroutine bc_common_sample(null)
 
 
/*start 014*/
;*************************************************************************
;* Find the App Numbers allowed to tag modfications
;*************************************************************************
declare	   bc_get_modification_app_nbrs(null) = null
subroutine bc_get_modification_app_nbrs(null)
	call writeLog(build2("* START bc_get_modification_app_nbrs *********************************"))
 
	select into "nl:"
	from
		 code_value cv
	plan cv
		where cv.code_set 		= bc_common->code_set
		and   cv.active_ind 	= 1
		and   cv.cdf_meaning	= "APP_UPDATES"
	order by
		 cv.definition
	head report
		stat = 0
	head cv.definition
		bc_common->app_cnt = (bc_common->app_cnt + 1)
		stat = alterlist(bc_common->app_qual,bc_common->app_cnt)
		bc_common->app_qual[bc_common->app_cnt].app_nbr_string = cv.definition
		bc_common->app_qual[bc_common->app_cnt].app_nbr = cnvtint(cv.definition)
	with nocounter
 
 
	call writeLog(build2("* END   bc_get_modification_app_nbrs *********************************"))
end ;subroutine bc_common_sample(null)
/*end 014*/
 
;*************************************************************************
;* Find the SAMPLE ROUTINE
;*************************************************************************
declare	   bc_get_scheduling_fields(null) = null
subroutine bc_get_scheduling_fields(null)
	call writeLog(build2("* START bc_get_scheduling_fields *********************************"))
 
	set bc_common->print_to_paper_cd = value(uar_get_code_by("DISPLAY_KEY",100301,"PRINTTOPAPER"))
	set bc_common->paper_referral_cd = value(uar_get_code_by("DISPLAY_KEY",100173,"PAPERREFERRAL"))
 
	select into "nl:"
	from order_entry_fields o
	plan o
	   where o.description = "Scheduling Location"
	      and o.codeset = 100301
	head report
	   bc_common->scheduling_location_field_id = o.oe_field_id
	with nocounter
	call writeLog(build2("bc_common->scheduling_location_field_id = ",bc_common->scheduling_location_field_id ))
 
	; Non-Radiology
	select into "nl:"
	from order_entry_fields o
	plan o
	   where o.description = "Scheduling Locations - Non Radiology"
	      and o.codeset = 100173
	head report
	   bc_common->scheduling_location_field_non_radiology_id = o.oe_field_id
	with nocounter
	call writeLog(build2("bc_common->scheduling_location_field_non_radiology_id = ",
		bc_common->scheduling_location_field_non_radiology_id ))
	call writeLog(build2("* END   bc_get_scheduling_fields *********************************"))
end ;subroutine bc_get_scheduling_fields(null)
 
 
;*************************************************************************
;* Find the task to print defintion
;*************************************************************************
declare	   bc_get_task_definition(null) = null
subroutine bc_get_task_definition(null)
	call writeLog(build2("* START bc_get_task_definition *********************************"))
	select into "nl:"
	from
		 code_value cv
		,order_task ot
	plan cv
		where cv.code_set 		= bc_common->code_set
		and   cv.active_ind 	= 1
		and   cv.cdf_meaning	= "TASK"
	join ot
		where ot.task_description 	= cv.definition
		and   ot.active_ind		= 1
	order by
		 cv.begin_effective_dt_tm desc
		,cv.cdf_meaning
		,ot.updt_dt_tm desc
		,ot.task_description
	head report
		stat = 0
	head ot.task_description
		bc_common->reference_task_id = ot.reference_task_id
		call writeLog(build2("* ->reference_task_id = ",trim(cnvtstring(bc_common->reference_task_id))))
	with nocounter
 
	if (bc_common->reference_task_id = 0.0)
		set reply->status_data.status = "Z"
		call writeLog(build2("* TASK: Reference Task Not Found"))
		go to exit_script
	endif
	call writeLog(build2("* END   bc_get_task_definition *********************************"))
end ;subroutine bc_get_task_definition(null)
 
;*************************************************************************
;* Find the included locations
;*************************************************************************
declare	   bc_get_included_locations(null) = null
subroutine bc_get_included_locations(null)
	call writeLog(build2("* START bc_get_included_locations *********************************"))
	select into "nl:"
	from
		 code_value cv1
		,code_value cv2
		,code_value_group cvg1
	plan cv1
		where cv1.code_set = 103507
		and   cv1.cdf_meaning = "LOCATION"
		and	  cv1.active_ind = 1
	join cvg1
		where cvg1.parent_code_value = cv1.code_value
		and   cvg1.code_set = 220
	join cv2
		where cv2.code_value = cvg1.child_code_value
	order by
		 cv1.code_value
		,cv2.code_value
	head report
		stat = 0
	head cv1.code_value
		stat = 0
	head cv2.code_value
		bc_common->location_cnt = (bc_common->location_cnt + 1)
		stat = alterlist(bc_common->location_qual,bc_common->location_cnt)
		bc_common->location_qual[bc_common->location_cnt].display = cv2.display
		bc_common->location_qual[bc_common->location_cnt].code_value = cv2.code_value
	with nocounter
/*
	select into "nl:"
	from
		 code_value cv1
	plan cv1
		where cv1.code_set = 220
		and   cv1.cdf_meaning in("NURSEUNIT","AMBULATORY")
		and	  cv1.active_ind = 1
		and   cv1.display = "BCC*"
	order by
		 cv1.code_value
	head report
		stat = 0
	head cv1.code_value
		bc_common->location_cnt = (bc_common->location_cnt + 1)
		stat = alterlist(bc_common->location_qual,bc_common->location_cnt)
		bc_common->location_qual[bc_common->location_cnt].display = cv1.display
		bc_common->location_qual[bc_common->location_cnt].code_value = cv1.code_value
	with nocounter
*/
	SELECT DISTINCT into "nl:"
	   location_cd = l3.location_cd ,
	   location = trim (uar_get_code_display (l3.location_cd ) ),
	   facility = trim (uar_get_code_description (l.location_cd ) )
	FROM
		prsnl_org_reltn por,
	    organization org,
	    location l,
	    location_group lg,
	    location l2,
	    location_group lg2,
	    location l3,
	    code_value cv1,
	    code_value cv2,
	    code_value cv3,
	    dummyt d1
	plan por
		where por.person_id = 2
	    and por.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3)
	    and por.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3)
	    and por.active_ind = 1
	join org
	    where org.organization_id = por.organization_id
	    and org.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 )
	    and org.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 )
	    and org.active_ind = 1
	join l
	   	where l.organization_id = org.organization_id
	    and l.location_type_cd = value(uar_get_code_by_cki("CKI.CODEVALUE!2844"))
	    and l.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 )
	    and l.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 )
	    and l.active_ind = 1
	join cv1
	    where cv1.code_value = l.location_cd
	join lg
	    where lg.parent_loc_cd = l.location_cd
	    and lg.root_loc_cd = 0
	    and lg.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 )
	    and lg.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 )
	    and lg.active_ind = 1
	join l2
	    where l2.location_cd = lg.child_loc_cd
	    and l2.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 )
	    and l2.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 )
	    and l2.active_ind = 1
	join lg2
	    where lg.child_loc_cd = lg2.parent_loc_cd
	    and lg2.root_loc_cd = 0
	    and lg2.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 )
	    and lg2.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 )
	    and lg2.active_ind = 1
	join l3
	    where l3.location_cd = lg2.child_loc_cd
	    and l3.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 )
	    and l3.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 )
	    and l3.active_ind = 1
	    and l3.location_type_cd in(
	    							 select
								     cv.code_value
								     from code_value cv
								     where cv.cdf_meaning in("AMBULATORY","NURSEUNIT")
								   )
	join cv2
	    where cv2.code_value = l3.location_cd
	join d1
	join cv3
	    where cv3.code_set = 103507
	    and   cv3.cdf_meaning in("LOCATION","LOCATION_LTD")
	    and   cv3.active_ind = 1
	    and   cv3.display = cv2.display
	order by
	   	facility ,
	   	location,
	   	l.location_cd,
	    l3.location_cd
	detail
		bc_common->location_cnt = (bc_common->location_cnt + 1)
		stat = alterlist(bc_common->location_qual,bc_common->location_cnt)
		bc_common->location_qual[bc_common->location_cnt].display = location
		bc_common->location_qual[bc_common->location_cnt].code_value = l3.location_cd
	with nocounter
 
	if (bc_common->location_cnt = 0)
		set reply->status_data.status = "Z"
		call writeLog(build2("* LOCATION: Locations Not Found"))
		go to exit_script
	endif
	call writeLog(build2("* END   bc_get_included_locations *********************************"))
end ;subroutine bc_get_included_locations(null)
 
;*************************************************************************
;* Setup Logging
;*************************************************************************
execute msgrtl
 
set stat = initrec(program_log)
set program_log->curprog			= cnvtlower(trim(curprog))
set program_log->curdomain			= cnvtlower(trim(curdomain))
set program_log->files.file_path	= build("/cerner/d_",cnvtlower(trim(curdomain)),"/cclscratch/")
set program_log->files.ccluserdir	= build("/cerner/d_",cnvtlower(trim(curdomain)),"/ccluserdir/")
set program_log->files.filename_log = build(
										 program_log->files.file_path
										,cnvtlower(trim(curdomain))
										,"_",cnvtlower(trim(curprog))
										,"_",format(cnvtdatetime(curdate, curtime3)
										,"yyyy_mm_dd_hh_mm_ss;;d")
										,".log"
										)
set program_log->files.filename_audit = build(
										 program_log->files.file_path
										,cnvtlower(trim(curdomain))
										,"_",cnvtlower(trim(curprog))
										,"_",format(cnvtdatetime(curdate, curtime3)
										,"yyyy_mm_dd_hh_mm_ss;;d")
										,".dat"
										)
 
call echo2(build2("program_log->files.filename_log = ",program_log->files.filename_log))
call echo2(build2("program_log->files.filename_audit = ",program_log->files.filename_audit))
 
if (validate(nologvar) = 1)
	set program_log->produce_log = nologvar
	call echo2(build2("program_log->produce_log = ",program_log->produce_log))
endif
 
;*************************************************************************
;* Set debugging variables if defined in Request.
;*************************************************************************
 
call echo2(build2("debug_ind validate = ",cnvtstring(validate(debug_ind))))
 
if (validate(debug_ind) = 0)
	declare debug_ind		= i2 with protect, noconstant(0)
endif
 
if (validate(request->debug_ind) = 1)
  set debug_ind = request->debug_ind
endif
if (validate(request->echorecord_ind) = 1)
  set echorecord_ind = request->echorecord_ind
endif
 
if (validate(debug_ind) = 1)
	if (debug_ind > 1)
		set program_log->msgview_log = 1
	endif
endif
 
call echo2(build2("debug_ind = ",cnvtstring(debug_ind)))
 
call startLog(program_log->files.filename_log)			;start log file
 
 
if (validate(manual_ind) = 1)
	if (manual_ind = 1)
		set bc_common->log_level = 2								;000
		set bc_common->pdf_event_cd 		= 2595426677.00			;000
		set bc_common->reference_task_id 	= 2595731141.00			;000
		set bc_common->pdf_content_type		= "PATIENT_PROVIDED"	;000
 
		select into "nl:"																;000
		from code_value cv where cv.code_value = bc_common->pdf_event_cd				;000
		detail																			;000
			bc_common->pdf_display_key							= cv.display_key		;000
		with nocounter																	;000
 
		set bc_common->requisition_cnt		= 9
		set stat = alterlist(bc_common->requisition_qual,bc_common->requisition_cnt)	;000
		set bc_common->requisition_qual[1].requisition_format_cd 	= 2553014753
		;set bc_common->requisition_qual[1].requisition_object		= "CCMIREQUISITN"
		set bc_common->requisition_qual[1].requisition_object		= "MIREQUISITN"
		set bc_common->requisition_qual[1].requisition_title		= "Medical Imaging Requisition"
 
		set bc_common->requisition_qual[2].requisition_format_cd 	= 2554787169
		;set bc_common->requisition_qual[2].requisition_object		= "ccoutpatw:group1"
		set bc_common->requisition_qual[2].requisition_object		= "LABOUTPATW"
		;set bc_common->requisition_qual[2].requisition_object		= "OPREQWRAP"
		;set bc_common->requisition_qual[2].requisition_object		= "CCOPREQWRAP"
		set bc_common->requisition_qual[2].requisition_title		= "Laboratory Requisition"
 
		set bc_common->requisition_qual[3].requisition_format_cd 	= 2553479159
		;set bc_common->requisition_qual[3].requisition_object		= "CCAMBREFERREQ"
		set bc_common->requisition_qual[3].requisition_object		= "AMBREFERREQ"
		set bc_common->requisition_qual[3].requisition_title		= "Referral"
 
		set bc_common->requisition_qual[4].requisition_format_cd 	= 2555181737
		set bc_common->requisition_qual[4].requisition_object		= "ECGORDERREQ"
		set bc_common->requisition_qual[4].requisition_title		= "Medical Imaging Requisition"
 
		set bc_common->requisition_qual[5].requisition_format_cd 	= 2552936143
		set bc_common->requisition_qual[5].requisition_object		= "REQBLOODGAS"
		set bc_common->requisition_qual[5].requisition_title		= "Laboratory Requisition"
 
		set bc_common->requisition_qual[6].requisition_format_cd 	= 2556445043
		;set bc_common->requisition_qual[6].requisition_object		= "ccgrpscrnwrap"
		set bc_common->requisition_qual[6].requisition_object		= "LABOUTPATW"
		set bc_common->requisition_qual[6].requisition_title		= "Laboratory Requisition"
 
		set bc_common->requisition_qual[7].requisition_format_cd 	= 2555169917
		set bc_common->requisition_qual[7].requisition_object		= "REQCRDBLOOD"
		set bc_common->requisition_qual[7].requisition_title		= "Laboratory Requisition"
 
		set bc_common->requisition_qual[8].requisition_format_cd 	= 2554612947
		set bc_common->requisition_qual[8].requisition_object		= "LABPATHORAL"
		set bc_common->requisition_qual[8].requisition_title		= "Laboratory Requisition"
 
		set bc_common->requisition_qual[9].requisition_format_cd 	= 2593843391
		set bc_common->requisition_qual[9].requisition_object		= "LABVENOSAMP"
		set bc_common->requisition_qual[9].requisition_title		= "Laboratory Requisition"
	endif
endif
 
 
;*************************************************************************
;* COMMON SUBROUTINES
;*************************************************************************
 
;*************************************************************************
;* Find the PDF Event Code
;*************************************************************************
declare	   bc_pdf_content_type(null) = null
subroutine bc_pdf_content_type(null)
	call writeLog(build2("* START bc_pdf_content_type *********************************"))
	select into "nl:"
	from
		 code_value cv
		,dms_content_type dct
	plan cv
		where cv.code_set 		= bc_common->code_set
		and   cv.active_ind 	= 1
		and   cv.cdf_meaning	= "CONTENTTYPE"
	join dct
		where dct.content_type_key 	= cv.definition
		and   dct.active_ind		= 1
	order by
		 cv.begin_effective_dt_tm desc
		,cv.cdf_meaning
		,dct.updt_dt_tm desc
		,dct.content_type_key
	head report
		stat = 0
	head dct.content_type_key
		bc_common->pdf_content_type = dct.content_type_key
		call writeLog(build2("* ->pdf_content_type = ",trim(bc_common->pdf_content_type)))
	with nocounter
 
	if (bc_common->pdf_content_type = " ")
		set reply->status_data.status = "F"
		call writeLog(build2("* ERROR: Content Type for PDF Not Found"))
		go to exit_script
	endif
	call writeLog(build2("* END   bc_pdf_content_type *********************************"))
end ;subroutine bc_pdf_content_type(null)
 
;*************************************************************************
;* Find Qualifying Requisitions
;*************************************************************************
declare	   bc_get_requisitions(null) = null
subroutine bc_get_requisitions(null)
	call writeLog(build2("* START bc_get_requisitions *********************************"))
	select into "nl:"
	from
		 code_value cv
		,code_value ec
	plan cv
		where cv.code_set 		= bc_common->code_set
		and   cv.active_ind 	= 1
		and   cv.cdf_meaning	= "REQUISITION"
	join ec
		where ec.code_set 		= 6002
		and   ec.cdf_meaning	= cv.description
		and   ec.active_ind		= 1
	order by
		 cv.begin_effective_dt_tm desc
		,cv.cdf_meaning
		,ec.begin_effective_dt_tm desc
		,ec.code_value
	head report
		stat = 0
	head ec.code_value
		bc_common->requisition_cnt = (bc_common->requisition_cnt + 1)
		stat = alterlist(bc_common->requisition_qual,bc_common->requisition_cnt)
		bc_common->requisition_qual[bc_common->requisition_cnt].requisition_format_cd	= ec.code_value
		bc_common->requisition_qual[bc_common->requisition_cnt].requisition_object		= cv.definition
		bc_common->requisition_qual[bc_common->requisition_cnt].requisition_title		= cv.display
		bc_common->requisition_qual[bc_common->requisition_cnt].collation_seq			= cv.collation_seq
		call writeLog(build2("* ->requisition_format_cd = ",
				trim(cnvtstring(bc_common->requisition_qual[bc_common->requisition_cnt].requisition_format_cd))))
		call writeLog(build2("* ->requisition_object = ",
				trim(bc_common->requisition_qual[bc_common->requisition_cnt].requisition_object)))
		call writeLog(build2("* ->requisition_title = ",
				trim(bc_common->requisition_qual[bc_common->requisition_cnt].requisition_title)))
	with nocounter
 
	call writeLog(build2("* END   bc_get_requisitions *********************************"))
end ;subroutine bc_get_requisitions(null)
 
declare	   bc_get_single_ord_requisitions(null) = null
subroutine bc_get_single_ord_requisitions(null)
	call writeLog(build2("* START bc_get_lab_requisitions *********************************"))
	select into "nl:"
	from
		 code_value cv
		,code_value ec
	plan cv
		where cv.code_set 		= bc_common->code_set
		and   cv.active_ind 	= 1
		and   cv.cdf_meaning	= "REQUISITION"
		and   cv.collation_seq	= 1
	join ec
		where ec.code_set 		= 6002
		and   ec.cdf_meaning	= cv.description
		and   ec.active_ind		= 1
	order by
		 cv.begin_effective_dt_tm desc
		,cv.cdf_meaning
		,ec.begin_effective_dt_tm desc
		,ec.code_value
	head report
		stat = 0
	head ec.code_value
		bc_common->requisition_cnt = (bc_common->requisition_cnt + 1)
		stat = alterlist(bc_common->requisition_qual,bc_common->requisition_cnt)
		bc_common->requisition_qual[bc_common->requisition_cnt].requisition_format_cd	= ec.code_value
		bc_common->requisition_qual[bc_common->requisition_cnt].requisition_object		= cv.definition
		bc_common->requisition_qual[bc_common->requisition_cnt].requisition_title		= cv.display
		bc_common->requisition_qual[bc_common->requisition_cnt].collation_seq			= cv.collation_seq
		call writeLog(build2("* ->requisition_format_cd = ",
				trim(cnvtstring(bc_common->requisition_qual[bc_common->requisition_cnt].requisition_format_cd))))
		call writeLog(build2("* ->requisition_object = ",
				trim(bc_common->requisition_qual[bc_common->requisition_cnt].requisition_object)))
		call writeLog(build2("* ->requisition_title = ",
				trim(bc_common->requisition_qual[bc_common->requisition_cnt].requisition_title)))
	with nocounter
 
	call writeLog(build2("* END   bc_get_requisitions *********************************"))
end ;subroutine bc_get_requisitions(null)
 
declare	   bc_get_multi_ord_requisitions(null) = null
subroutine bc_get_multi_ord_requisitions(null)
	call writeLog(build2("* START bc_get_nonlab_requisitions *********************************"))
	select into "nl:"
	from
		 code_value cv
		,code_value ec
	plan cv
		where cv.code_set 		= bc_common->code_set
		and   cv.active_ind 	= 1
		and   cv.cdf_meaning	= "REQUISITION"
		and   cv.collation_seq	= 2
	join ec
		where ec.code_set 		= 6002
		and   ec.cdf_meaning	= cv.description
		and   ec.active_ind		= 1
	order by
		 cv.begin_effective_dt_tm desc
		,cv.cdf_meaning
		,ec.begin_effective_dt_tm desc
		,ec.code_value
	head report
		stat = 0
	head ec.code_value
		bc_common->requisition_cnt = (bc_common->requisition_cnt + 1)
		stat = alterlist(bc_common->requisition_qual,bc_common->requisition_cnt)
		bc_common->requisition_qual[bc_common->requisition_cnt].requisition_format_cd	= ec.code_value
		bc_common->requisition_qual[bc_common->requisition_cnt].requisition_object		= cv.definition
		bc_common->requisition_qual[bc_common->requisition_cnt].requisition_title		= cv.display
		bc_common->requisition_qual[bc_common->requisition_cnt].collation_seq			= cv.collation_seq
		call writeLog(build2("* ->requisition_format_cd = ",
				trim(cnvtstring(bc_common->requisition_qual[bc_common->requisition_cnt].requisition_format_cd))))
		call writeLog(build2("* ->requisition_object = ",
				trim(bc_common->requisition_qual[bc_common->requisition_cnt].requisition_object)))
		call writeLog(build2("* ->requisition_title = ",
				trim(bc_common->requisition_qual[bc_common->requisition_cnt].requisition_title)))
	with nocounter
 
	call writeLog(build2("* END   bc_get_requisitions *********************************"))
end ;subroutine bc_get_requisitions(null)
 
declare	   bc_get_multiple_ord_requisitions(null) = null
subroutine bc_get_multiple_ord_requisitions(null)
	call writeLog(build2("* START bc_get_nonlab_requisitions *********************************"))
	select into "nl:"
	from
		 code_value cv
		,code_value ec
	plan cv
		where cv.code_set 		= bc_common->code_set
		and   cv.active_ind 	= 1
		and   cv.cdf_meaning	= "REQUISITION"
		and   cv.collation_seq	= 2
	join ec
		where ec.code_set 		= 6002
		and   ec.cdf_meaning	= cv.description
		and   ec.active_ind		= 1
	order by
		 cv.begin_effective_dt_tm desc
		,cv.cdf_meaning
		,ec.begin_effective_dt_tm desc
		,ec.code_value
	head report
		stat = 0
	head ec.code_value
		bc_common->req_multiple_cnt = (bc_common->req_multiple_cnt + 1)
		stat = alterlist(bc_common->req_multiple_qual,bc_common->req_multiple_cnt)
		bc_common->req_multiple_qual[bc_common->req_multiple_cnt].requisition_format_cd	= ec.code_value
		bc_common->req_multiple_qual[bc_common->req_multiple_cnt].requisition_object		= cv.definition
		bc_common->req_multiple_qual[bc_common->req_multiple_cnt].requisition_title		= cv.display
		bc_common->req_multiple_qual[bc_common->req_multiple_cnt].collation_seq			= cv.collation_seq
		call writeLog(build2("* ->requisition_format_cd = ",
				trim(cnvtstring(bc_common->req_multiple_qual[bc_common->req_multiple_cnt].requisition_format_cd))))
		call writeLog(build2("* ->requisition_object = ",
				trim(bc_common->req_multiple_qual[bc_common->req_multiple_cnt].requisition_object)))
		call writeLog(build2("* ->requisition_title = ",
				trim(bc_common->req_multiple_qual[bc_common->req_multiple_cnt].requisition_title)))
	with nocounter
 
	call writeLog(build2("* END   bc_get_requisitions *********************************"))
end ;subroutine bc_get_multiple_ord_requisitions(null)
 
declare	   bc_get_oef_changes(null) = null
subroutine bc_get_oef_changes(null)
	call writeLog(build2("* START bc_get_oef_changes *********************************"))
	select into "nl:"
	from
		 code_value cv
		,code_value ec
		,code_value_extension cve1
		,code_value cf
		,code_value_extension cfe1
		,code_value_extension cfe2
		,code_value_extension cfe3
	plan cv
		where cv.code_set 		= 103507
		and   cv.active_ind 	= 1
		and   cv.cdf_meaning	= "REQUISITION"
	join ec
		where ec.code_set 		= 6002
		and   ec.cdf_meaning	= cv.description
		and   ec.active_ind		= 1
	join cve1
		where cve1.code_value = cv.code_value
		and   cve1.field_name = "OE_CHANGE_PROCESSING"
		and   cnvtint(cve1.field_value) > 0
	join cfe1
		where cfe1.code_set = 103509
		and   cfe1.field_name = "REQUISITION_FORMAT_CD"
		and   cnvtreal(cfe1.field_value)	= ec.code_value
	join cf
		where cf.code_value	= cfe1.code_value
		and   cf.active_ind = 1
	join cfe2
		where cfe2.code_value = cf.code_value
		and   cfe2.field_name = "OE_FIELD_ID"
	join cfe3
		where cfe3.code_value = cf.code_value
		and   cfe3.field_name = "OE_FORMAT_ID"
	order by
		  cv.code_value
		 ,ec.code_value
		 ,cf.code_value
	head report
		field_cnt = 0
	head cv.code_value
		field_cnt = 0
		bc_common->oef_cnt = (bc_common->oef_cnt + 1)
		stat = alterlist(bc_common->oef_qual,bc_common->oef_cnt)
		bc_common->oef_qual[bc_common->oef_cnt].oef_req_type = cv.display
		bc_common->oef_qual[bc_common->oef_cnt].oef_req_format_cd = ec.code_value
		bc_common->oef_qual[bc_common->oef_cnt].oef_change_processing = cnvtint(cve1.field_value)
	head cf.code_value
		field_cnt = (field_cnt + 1)
		stat = alterlist(bc_common->oef_qual[bc_common->oef_cnt].field_qual,field_cnt)
		bc_common->oef_qual[bc_common->oef_cnt].field_qual[field_cnt].oe_field_id = cnvtreal(cfe2.field_value)
		bc_common->oef_qual[bc_common->oef_cnt].field_qual[field_cnt].oe_format_id = cnvtreal(cfe3.field_value)
	foot cf.code_value
		bc_common->oef_qual[bc_common->oef_cnt].field_cnt = field_cnt
	foot report
		null
	with nocounter
 
	call writeLog(build2("* END   bc_get_oef_changes *********************************"))
end ;subroutine bc_get_oef_changes(null)
 
;*************************************************************************
;* Find the PDF Event Code
;*************************************************************************
declare	   bc_pdf_event_code(null) = null
subroutine bc_pdf_event_code(null)
	call writeLog(build2("* START bc_pdf_event_code *********************************"))
	select into "nl:"
	from
		 code_value cv
		,code_value ec
	plan cv
		where cv.code_set 		= bc_common->code_set
		and   cv.active_ind 	= 1
		and   cv.cdf_meaning	= "PDFEC"
	join ec
		where ec.code_set 		= 72
		and   ec.display		= cv.definition
		and   ec.active_ind		= 1
	order by
		 cv.begin_effective_dt_tm desc
		,cv.cdf_meaning
		,ec.begin_effective_dt_tm desc
		,ec.code_value
	head report
		stat = 0
	head ec.code_value
		bc_common->pdf_event_cd = ec.code_value
		bc_common->pdf_display_key = ec.display_key
		call writeLog(build2("* ->pdf_event_cd = ",trim(cnvtstring(bc_common->pdf_event_cd))))
		call writeLog(build2("* ->pdf_display_key = ",trim(bc_common->pdf_display_key)))
	with nocounter
 
	if (bc_common->pdf_event_cd = 0.0)
		set reply->status_data.status = "F"
		call writeLog(build2("* ERROR: Event Code for PDF Not Found"))
		go to exit_script
	endif
	call writeLog(build2("* END   bc_pdf_event_code *********************************"))
end ;subroutine bc_pdf_event_code(null)
 
;*************************************************************************
;* Find the logging level
;*************************************************************************
declare	   bc_log_level(null) = null
subroutine bc_log_level(null)
	call writeLog(build2("* START bc_log_level *********************************"))
	select into "nl:"
	from
		code_value cv
	plan cv
		where cv.code_set 		= bc_common->code_set
		and   cv.active_ind 	= 1
		and   cv.cdf_meaning	= "LOGGING"
	order by
		 cv.begin_effective_dt_tm desc
		,cv.cdf_meaning
	head report
		stat = 0
	head cv.cdf_meaning
		bc_common->log_level = cnvtint(cv.definition)
		call writeLog(build2("* ->log_level = ",trim(cnvtstring(bc_common->log_level))))
	with nocounter
 
	if (bc_common->log_level = 1)
		set debug_ind = 1
		call writeLog(build2("* --> setting debug_ind = ",trim(cnvtstring(debug_ind))))
		if (nologvar = 1)
			call writeLog(build2("* --> global logging off, turning on"))
			set program_log->produce_log = 0
			call startLog(program_log->files.filename_log)
		endif
	elseif (bc_common->log_level = 2)
		set debug_ind = 2
		call writeLog(build2("* --> setting debug_ind = ",trim(cnvtstring(debug_ind))))
		set program_log->msgview_log = 1
		call writeLog(build2("* --> setting program_log->msgview_log = ",trim(cnvtstring(program_log->msgview_log))))
		if (nologvar = 1)
			call writeLog(build2("* --> global logging off, turning on"))
			set program_log->produce_log = 0
			call startLog(program_log->files.filename_log)
		endif
	endif
	call writeLog(build2("* END   bc_log_level *********************************"))
end ;subroutine bc_log_level(null)
 
;*************************************************************************
;* Check Validation Mode
;*************************************************************************
declare	   bc_check_validation(null) = null
subroutine bc_check_validation(null)
	call writeLog(build2("* START bc_check_validation *********************************"))
	select into "nl:"
	from
		 code_value cv
		,code_value_extension cve
	plan cv
		where cv.code_set 		= bc_common->code_set
		and   cv.active_ind 	= 1
		and   cv.cdf_meaning	= "VALIDATION"
	join cve
		where cve.code_value 	= cv.code_value
		and   cve.field_name	= "SCRIPT"
		and   cnvtupper(cve.field_value)	= cnvtupper(curprog)
	order by
		 cv.begin_effective_dt_tm desc
		,cv.cdf_meaning
	head report
		stat = 0
	head cv.cdf_meaning
		case (cv.description)
			of "LAST_NAME":	bc_common->validation_mode_ind  = 1
							bc_common->validation_param		= cv.definition
		endcase
		call writeLog(build2("* ->validation_mode_ind = ",trim(cnvtstring(bc_common->validation_mode_ind))))
		call writeLog(build2("* ->validation_param = ",trim(bc_common->validation_param)))
	with nocounter
 
	if (bc_common->validation_mode_ind > 0)
		set bc_common->valid_ind = 0
		call writeLog(build2("* -->entering validation_mode_ind = ",trim(cnvtstring(bc_common->validation_mode_ind))))
		if (bc_common->validation_mode_ind = 1)
			call writeLog(build2("* --->finding param for person_id=",trim(cnvtstring(bc_common->validation_mode_ind))))
			select into "nl:"
			from
				person p
			plan p
				where p.person_id = bc_common->person_id
				and   p.active_ind = 1
			head report
				stat = 0
			detail
				bc_common->person_name_last = trim(p.name_last)
				call writeLog(build2("* --->FOUND=",trim(bc_common->person_name_last)))
			with nocounter
 
			call writeLog(build2("* --->checking param=",trim(bc_common->validation_param),"and value=",trim(bc_common->person_name_last)))
			if (bc_common->person_name_last = bc_common->validation_param)
				set bc_common->valid_ind = 1
				call writeLog(build2("* --->MATCH, bc_common->valid_ind=",trim(cnvtstring(bc_common->valid_ind))))
			endif
		endif
 
		if (bc_common->valid_ind = 0)
			set reply->status_data.status = "Z"
			call writeLog(build2("* ->SKIPPING: Patient Validation is on and this patient did not pass"))
			go to exit_script
		endif
	endif
	call writeLog(build2("* END   bc_check_validation *********************************"))
end ;subroutine bc_check_validation(null)
 
;*************************************************************************
;* Find the Custom Code Set
;*************************************************************************
declare	   bc_custom_code_set(null) = null
subroutine bc_custom_code_set(null)
	call writeLog(build2("* START bc_custom_code_set *********************************"))
	select into "nl:"
	from
		code_value_set cvs
	plan cvs
		where cvs.definition = "PRINTTOPDF"
		and   cvs.code_set > 0.0
	order by
		 cvs.updt_dt_tm desc
		,cvs.code_set
	head report
		stat = 0
	head cvs.code_set
		bc_common->code_set = cvs.code_set
		call writeLog(build2("* -> Code Set=",trim(cnvtstring(bc_common->code_set))))
	with nocounter
 
	if (bc_common->code_set = 0.0)
		set reply->status_data.status = "F"
		call writeLog(build2("* ERROR: Custom Code Set Not Found"))
		go to exit_script
	endif
	call writeLog(build2("* END   bc_custom_code_set *********************************"))
end ;subroutine bc_custom_code_set(null)
 
;*************************************************************************
;* Setup the msgview log
;*************************************************************************
declare writeMlgMsg(msg = vc, lvl = i2) = null
subroutine writeMlgMsg(msg, lvl)
    declare sys_handle = i4 with noconstant(0),private
    declare sys_status = i4 with noconstant(0),private
 
    call uar_SysCreateHandle (sys_handle, sys_status)
 
    ; only log the message if we have a valid handle
    if (sys_handle > 0)
        call uar_Msgsetlevel(sys_handle, lvl)
        call uar_SysEvent(sys_handle, lvl, nullterm(program_log->curprog), nullterm(msg))
        call uar_SysDestroyHandle(sys_handle)
    endif
end ;end writeMlgMsg subroutine
 
;*************************************************************************
;* Setup the log subroutines
;*************************************************************************
subroutine startLog(str)			;subroutine to start a log file in cclscratch. must pass the filename to sub
	if (program_log->produce_log = 0)
		set frec->file_name = str		;set the filename to the string passed
		set frec->file_buf = "w"   		;case sensitive must be lowercase, opens a new file
		set stat = cclio("OPEN",frec)	;call CCLIO() to open the file in the frec record structure
		call echo2(build2("startLog(",str,")"))
	endif
end									;end startLog subroutine
 
subroutine writeLog(str)			;subroutine to silently add a line to log with the date and time and the string passed
									;line below builds a string to add to the log file
	set disp_line = build2("[",format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy hh:mm:ss;;q"),"]",trim(str,3),char(13),char(10))
	set disp_line = substring(1,131,disp_line)
	call echo2(disp_line)			;echo output to the command line
	if (program_log->produce_log = 0)
		set frec->file_buf = disp_line	;sends the string to the file buffer
		set stat = cclio("WRITE", frec)	;calls CCLIO to dump the buffer to the file
	endif
	if (program_log->msgview_log = 1)
		call echo2(build2("writeMlgMsg(",str,")"))
		call writeMlgMsg(str, 0)
	endif
end 								;end writeLog subroutine
 								;end writeLog subroutine
 
subroutine closeLog(str)   			;subroutine to close the log file, currently the passed in string does nothing
	if (program_log->produce_log = 0)
		set stat = cclio("CLOSE",frec)	;call CCLIO to close the file
		call echo2(build2("closeLog(",str,")"))
	endif
end
 
declare    echo2(str=vc) = null
subroutine echo2(str)
	if ((validate(debug_ind) = 1))
		if (debug_ind != 0)
			call echo(str)
		endif
	endif
end ;subroutine echo2(str)
 
declare    echorecord2(str=vc) = null
subroutine echorecord2(str)
	if ((validate(debug_ind) = 1) and (debug_ind != 0))
		set line = concat("call echorecord(",trim(str),")")
		call parser(line)
	endif
end ;subroutine echorecord2(str)
 
;*************************************************************************
;* Zip the log file for distribution
;*************************************************************************
declare	   zipLog(null) = null
subroutine zipLog(null)
	if (program_log->produce_log = 0)
		set program_log->files.filename_zip = replace(
												 program_log->files.filename_log
												,".log"
												,".zip"
												,0
												)
		call echo2(build2("program_log->files.filename_zip = ",program_log->files.filename_zip))
		set dclcom = build2("zip -j ",trim(program_log->files.filename_zip)," ",trim(program_log->files.filename_log))
		set dclstat = 0
		call echo2(build2("zip log file dclcom = ",dclcom))
		call dcl(dclcom, size(trim(dclcom)), dclstat)
		call echo2(build2("dclstat = ",dclstat))
	endif
end ;subroutine zipLog(null)
 
;*************************************************************************
;* clean up log file(s) for distribution
;*************************************************************************
declare	   cleanLog(null) = null
subroutine cleanLog(null)
	if (program_log->produce_log = 0)
		if (program_log->files.filename_zip > " " )
				set dclcom = build2("rm -f ",trim(program_log->files.filename_zip))
				set dclstat = 0
				call echo2(build2("remove log file dclcom = ",dclcom))
				call dcl(dclcom, size(trim(dclcom)), dclstat)
				call echo2(build2("dclstat = ",dclstat))
		endif
 
		if (program_log->files.filename_log > " ")
			set dclcom = build2("rm -f ",trim(program_log->files.filename_log))
			set dclstat = 0
			call echo2(build2("zip log file dclcom = ",dclcom))
			call dcl(dclcom, size(trim(dclcom)), dclstat)
			call echo2(build2("dclstat = ",dclstat))
		endif
	endif
end ;subroutine cleanLog(null)
 
;*************************************************************************
;* clean up log file(s) for distribution
;*************************************************************************
declare	   displayLog(null) = null
subroutine displayLog(null)
	if ((program_log->display_on_exit = 1) and (program_log->produce_log = 0))
		free define rtl2
		define rtl2 is value(program_log->files.filename_log)
 
		select into $OUTDEV
			r.line
		from
			rtl2t r
		plan r
		with nocounter,maxcol=32000,separator = " ",format
	endif
end ;subroutine displayLog(null)
 
;*************************************************************************
;* Setup the exit subroutines
;*************************************************************************
declare    exitScript(null) = null
subroutine exitScript(null)
	call closeLog(program_log->files.filename_log)
	call displayLog(null)
	;call zipLog(null)
	;call cleanLog(null)
	call echo2(build2("exiting script ",curprog))
end	;subroutine exitScript(null)
 
