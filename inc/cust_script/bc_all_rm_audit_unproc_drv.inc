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
;free record frec
record frec
	(
     1 file_desc = i4
     1 file_offset = i4
     1 file_dir = i4
     1 file_name = vc
     1 file_buf = vc
) with protect
 
 
;free record program_log
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
) with protect
 
;free record bc_common
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
) with protect
 
 
 
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
 
 
;free set req_request
record req_request (
			  1 person_id = f8
			  1 print_prsnl_id = f8
			  1 cnt = i2
			  1 order_qual[*]
			    2 order_id = f8
			    2 encntr_id = f8
			    2 conversation_id = f8
			    2 order_dttm = c11
			  1 printer_name = c50
			  1 pdf_name = c50
			  1 requisition_script = vc
			  1 execute_statement = vc
			  1 find_file_stat = i2
)
 
;free set temp_req_request
record temp_req_request
(
  1 person_id = f8
   1 print_prsnl_id = f8
   1 order_qual [* ]
     2 order_id = f8
     2 encntr_id = f8
     2 conversation_id = f8
   1 printer_name = c50
)
 
;free record mmf_store_reply
record mmf_store_reply
(
   1 identifier = vc ; unique identifier if successfully stored
%i cclsource:status_block.inc
)
;free set mmf_store_request
record mmf_store_request
(
   1 filename = vc
   1 contentType = vc
   1 mediaType = vc
   1 name = vc
   1 personId = f8
   1 encounterId = f8
)
 
;free set mmf_publish_ce_request
record mmf_publish_ce_request
(
   1 personId = f8
   1 encounterId = f8
   1 documentType_key = vc ;  code set 72 display_key
   1 title = vc
   1 service_dt_tm = dq8
   1 reference_nbr = c100
   1 normal_ref_range_txt = vc
   1 order_id = f8
   1 notetext = vc
   1 noteformat = vc ; code set 23 cdf_meaning
   1 personnel[*]
     2 id = f8
     2 action = vc     ; code set 21 cdf_meaning
     2 status = vc     ; code set 103 cdf_meanings
   1 mediaObjects[*]
     2 display = vc
     2 identifier = vc
   1 mediaObjectGroups[*]
     2 identifier = vc
   1 publishAsNote = i2
   1 debug = i2
)
 
;free set mmf_publish_ce_reply
record mmf_publish_ce_reply (
	1 parentEventId = f8
%i cclsource:status_block.inc
)
 
;free set 560300_request
record 560300_request
(
  1 person_id             = f8
  1 encntr_id             = f8
  1 stat_ind              = i2
  1 task_type_cd          = f8
  1 task_class_cd		  = f8
  1 task_dt_tm            = dq8
  1 task_activity_cd      = f8
  1 msg_text              = vc
  1 msg_subject_cd        = f8
  1 msg_subject           = vc
  1 confidential_ind      = i2
  1 read_ind              = i2
  1 delivery_ind          = i2
  1 task_status_cd        = f8
  1 reference_task_id     = f8
  1 event_id              = f8
  1 event_class_cd        = f8
  1 assign_prsnl_list[*]
    2 assign_prsnl_id     = f8
)
 
;free set 560300_reply
record 560300_reply
( 1 result
    2 task_status = c1
    2 task_id = f8
    2 assign_prsnl_list[*]
      3 assign_prsnl_id = f8
%i cclsource:status_block.inc
)
 
;free record ensure_request
;free record ensure_reply
 
record ensure_request (
   1 req                   [*]
      2 ensure_type           = i2
      2 version_dt_tm         = dq8
      2 version_dt_tm_ind     = i2
      2 event_prsnl
         3 event_prsnl_id        = f8
         3 person_id             = f8
         3 event_id              = f8
         3 action_type_cd        = f8
         3 request_dt_tm         = dq8
         3 request_dt_tm_ind     = i2
         3 request_prsnl_id      = f8
         3 request_prsnl_ft      = vc
         3 request_comment       = vc
         3 action_dt_tm          = dq8
         3 action_dt_tm_ind      = i2
         3 action_prsnl_id       = f8
         3 action_prsnl_ft       = vc
         3 proxy_prsnl_id        = f8
         3 proxy_prsnl_ft        = vc
         3 action_status_cd      = f8
         3 action_comment        = vc
         3 change_since_action_flag  = i2
         3 change_since_action_flag_ind  = i2
         3 action_prsnl_pin      = vc
         3 defeat_succn_ind      = i2
         3 ce_event_prsnl_id     = f8
         3 valid_from_dt_tm      = dq8
         3 valid_from_dt_tm_ind  = i2
         3 valid_until_dt_tm     = dq8
         3 valid_until_dt_tm_ind  = i2
         3 updt_dt_tm            = dq8
         3 updt_dt_tm_ind        = i2
         3 updt_task             = i4
         3 updt_task_ind         = i2
         3 updt_id               = f8
         3 updt_cnt              = i4
         3 updt_cnt_ind          = i2
         3 updt_applctx          = i4
         3 updt_applctx_ind      = i2
         3 long_text_id          = f8
         3 linked_event_id       = f8
         3 request_tz            = i4
         3 action_tz             = i4
         3 system_comment        = vc
         3 event_action_modifier_list  [*]
            4 ce_event_action_modifier_id  = f8
            4 event_action_modifier_id  = f8
            4 event_id              = f8
            4 event_prsnl_id        = f8
            4 action_type_modifier_cd  = f8
            4 valid_from_dt_tm      = dq8
            4 valid_from_dt_tm_ind  = i2
            4 valid_until_dt_tm     = dq8
            4 valid_until_dt_tm_ind  = i2
            4 updt_dt_tm            = dq8
            4 updt_dt_tm_ind        = i2
            4 updt_task             = i4
            4 updt_task_ind         = i2
            4 updt_id               = f8
            4 updt_cnt              = i4
            4 updt_cnt_ind          = i2
            4 updt_applctx          = i4
            4 updt_applctx_ind      = i2
         3 ensure_type           = i2
         3 digital_signature_ident  = vc
         3 action_prsnl_group_id  = f8
         3 request_prsnl_group_id  = f8
         3 receiving_person_id   = f8
         3 receiving_person_ft   = vc
      2 ensure_type2          = i2
      2 clinsig_updt_dt_tm_flag  = i2
      2 clinsig_updt_dt_tm    = dq8
      2 clinsig_updt_dt_tm_ind  = i2
   1 message_item
      2 message_text          = vc
      2 subject               = vc
      2 confidentiality       = i2
      2 priority              = i2
      2 due_date              = dq8
      2 sender_id             = f8
   1 user_id               = f8
)

;free record ensure_reply
record ensure_reply (
   1 rep                   [*]
      2 event_prsnl_id        = f8
      2 event_id              = f8
      2 action_prsnl_id       = f8
      2 action_type_cd        = f8
      2 sb
         3 severityCd            = i4
         3 statusCd              = i4
         3 statusText            = vc
         3 subStatusList         [*]
            4 subStatusCd           = i4
   1 sb
      2 severityCd            = i4
      2 statusCd              = i4
      2 statusText            = vc
      2 subStatusList         [*]
         3 subStatusCd           = i4
 
%i cclsource:status_block.inc
)
 
;free record dcp_request
record dcp_request
(
   1 task_list [*]
      2  task_id = f8
      2  person_id = f8
      2  catalog_type_cd = f8
      2  order_id = f8
      2  encntr_id = f8
      2  reference_task_id = f8
      2  task_type_cd = f8
      2  task_class_cd = f8
      2  task_status_cd = f8
      2 prev_task_status_cd = f8
      2 task_tz = i4
      2  task_dt_tm = dq8
      2  updt_cnt = i4
      2  event_id = f8
      2  task_activity_cd = f8
      2  catalog_cd = f8
      2  task_status_reason_cd = f8
      2  reschedule_ind = i2
      2  reschedule_reason_cd = f8
      2  med_order_type_cd = f8
      2  task_priority_cd = f8
      2  charted_by_agent_cd = f8
      2  charted_by_agent_identifier = vc
      2  charting_context_reference = vc
      2  scheduled_dt_tm = dq8
      2  result_set_id = f8
      2  msg_subject = vc
)

 SUBROUTINE  log_message (logmsg ,loglvl )
  SET icrslloglvloverrideind = 0
  SET scrsllogtext = ""
  SET scrsllogevent = ""
  SET scrsllogtext = concat ("{{Script::" ,value (log_program_name ) ,"}} " ,logmsg )
  IF ((log_override_ind = 0 ) )
   SET icrslholdloglevel = loglvl
  ELSE
   IF ((crsl_msg_level < loglvl ) )
    SET icrslholdloglevel = crsl_msg_level
    SET icrslloglvloverrideind = 1
   ELSE
    SET icrslholdloglevel = loglvl
   ENDIF
  ENDIF
  IF ((icrslloglvloverrideind = 1 ) )
   SET scrsllogevent = "Script_Override"
  ELSE
   CASE (icrslholdloglevel )
    OF log_level_error :
     SET scrsllogevent = "Script_Error"
    OF log_level_warning :
     SET scrsllogevent = "Script_Warning"
    OF log_level_audit :
     SET scrsllogevent = "Script_Audit"
    OF log_level_info :
     SET scrsllogevent = "Script_Info"
    OF log_level_debug :
     SET scrsllogevent = "Script_Debug"
   ENDCASE
  ENDIF
  SET lcrsluarmsgwritestat = uar_msgwrite (crsl_msg_default ,0 ,nullterm (scrsllogevent ) ,
   icrslholdloglevel ,nullterm (scrsllogtext ) )
  CALL echo (logmsg )
 END ;Subroutine
 DECLARE error_message ((logstatusblockind = i2 ) ) = i2
 SUBROUTINE  error_message (logstatusblockind )
  SET icrslerroroccured = 0
  SET ierrcode = error (serrmsg ,0 )
  WHILE ((ierrcode > 0 ) )
   SET icrslerroroccured = 1
   IF (validate (reply ) )
    SET reply->status_data.status = "F"
   ENDIF
   CALL log_message (serrmsg ,log_level_audit )
   IF ((logstatusblockind = 1 ) )
    IF (validate (reply ) )
     CALL populate_subeventstatus ("EXECUTE" ,"F" ,"CCL SCRIPT" ,serrmsg )
    ENDIF
   ENDIF
   SET ierrcode = error (serrmsg ,0 )
  ENDWHILE
  RETURN (icrslerroroccured )
 END ;Subroutine
 DECLARE error_and_zero_check_rec ((qualnum = i4 ) ,(opname = vc ) ,(logmsg = vc ) ,(errorforceexit
  = i2 ) ,(zeroforceexit = i2 ) ,(recorddata = vc (ref ) ) ) = i2
 SUBROUTINE  error_and_zero_check_rec (qualnum ,opname ,logmsg ,errorforceexit ,zeroforceexit ,
  recorddata )
  SET icrslerroroccured = 0
  SET ierrcode = error (serrmsg ,0 )
  WHILE ((ierrcode > 0 ) )
   SET icrslerroroccured = 1
   CALL log_message (serrmsg ,log_level_audit )
   CALL populate_subeventstatus_rec (opname ,"F" ,serrmsg ,logmsg ,recorddata )
   SET ierrcode = error (serrmsg ,0 )
  ENDWHILE
  IF ((icrslerroroccured = 1 )
  AND (errorforceexit = 1 ) )
   SET recorddata->status_data.status = "F"
   GO TO exit_script
  ENDIF
  IF ((qualnum = 0 )
  AND (zeroforceexit = 1 ) )
   SET recorddata->status_data.status = "Z"
   CALL populate_subeventstatus_rec (opname ,"Z" ,"No records qualified" ,logmsg ,recorddata )
   GO TO exit_script
  ENDIF
  RETURN (icrslerroroccured )
 END ;Subroutine
 DECLARE error_and_zero_check ((qualnum = i4 ) ,(opname = vc ) ,(logmsg = vc ) ,(errorforceexit = i2
  ) ,(zeroforceexit = i2 ) ) = i2
 SUBROUTINE  error_and_zero_check (qualnum ,opname ,logmsg ,errorforceexit ,zeroforceexit )
  RETURN (error_and_zero_check_rec (qualnum ,opname ,logmsg ,errorforceexit ,zeroforceexit ,reply ) )
 END ;Subroutine
 DECLARE populate_subeventstatus_rec ((operationname = vc (value ) ) ,(operationstatus = vc (value )
  ) ,(targetobjectname = vc (value ) ) ,(targetobjectvalue = vc (value ) ) ,(recorddata = vc (ref )
  ) ) = i2
 SUBROUTINE  populate_subeventstatus_rec (operationname ,operationstatus ,targetobjectname ,
  targetobjectvalue ,recorddata )
  IF ((validate (recorddata->status_data.status ,"-1" ) != "-1" ) )
   SET lcrslsubeventcnt = size (recorddata->status_data.subeventstatus ,5 )
   SET lcrslsubeventsize = size (trim (recorddata->status_data.subeventstatus[lcrslsubeventcnt ].
     operationname ) )
   SET lcrslsubeventsize = (lcrslsubeventsize + size (trim (recorddata->status_data.subeventstatus[
     lcrslsubeventcnt ].operationstatus ) ) )
   SET lcrslsubeventsize = (lcrslsubeventsize + size (trim (recorddata->status_data.subeventstatus[
     lcrslsubeventcnt ].targetobjectname ) ) )
   SET lcrslsubeventsize = (lcrslsubeventsize + size (trim (recorddata->status_data.subeventstatus[
     lcrslsubeventcnt ].targetobjectvalue ) ) )
   IF ((lcrslsubeventsize > 0 ) )
    SET lcrslsubeventcnt = (lcrslsubeventcnt + 1 )
    SET icrslloggingstat = alter (recorddata->status_data.subeventstatus ,lcrslsubeventcnt )
   ENDIF
   SET recorddata->status_data.subeventstatus[lcrslsubeventcnt ].operationname = substring (1 ,25 ,
    operationname )
   SET recorddata->status_data.subeventstatus[lcrslsubeventcnt ].operationstatus = substring (1 ,1 ,
    operationstatus )
   SET recorddata->status_data.subeventstatus[lcrslsubeventcnt ].targetobjectname = substring (1 ,25
    ,targetobjectname )
   SET recorddata->status_data.subeventstatus[lcrslsubeventcnt ].targetobjectvalue =
   targetobjectvalue
  ENDIF
 END ;Subroutine
 DECLARE populate_subeventstatus ((operationname = vc (value ) ) ,(operationstatus = vc (value ) ) ,(
  targetobjectname = vc (value ) ) ,(targetobjectvalue = vc (value ) ) ) = i2
 SUBROUTINE  populate_subeventstatus (operationname ,operationstatus ,targetobjectname ,
  targetobjectvalue )
  CALL populate_subeventstatus_rec (operationname ,operationstatus ,targetobjectname ,
   targetobjectvalue ,reply )
 END ;Subroutine
 DECLARE populate_subeventstatus_msg ((operationname = vc (value ) ) ,(operationstatus = vc (value )
  ) ,(targetobjectname = vc (value ) ) ,(targetobjectvalue = vc (value ) ) ,(loglevel = i2 (value )
  ) ) = i2
 SUBROUTINE  populate_subeventstatus_msg (operationname ,operationstatus ,targetobjectname ,
  targetobjectvalue ,loglevel )
  CALL populate_subeventstatus (operationname ,operationstatus ,targetobjectname ,targetobjectvalue
   )
  CALL log_message (targetobjectvalue ,loglevel )
 END ;Subroutine
 DECLARE check_log_level ((arg_log_level = i4 ) ) = i2
 SUBROUTINE  check_log_level (arg_log_level )
  IF ((((crsl_msg_level >= arg_log_level ) ) OR ((log_override_ind = 1 ) )) )
   RETURN (1 )
  ELSE
   RETURN (0 )
  ENDIF
 END ;Subroutine
 
  SUBROUTINE  getencntrreltn (dencntr_id ,dreltn_cd ,dprov_id )
  FREE RECORD epr_qual
  RECORD epr_qual (
    1 epr_cnt = i4
    1 res_chk = i2
    1 mpage_ind = i2
    1 qual [* ]
      2 epr_id = f8
      2 prsnl_person_id = f8
  ) WITH persistscript
  SELECT INTO "nl:"
   FROM (encntr_prsnl_reltn epr )
   PLAN (epr
    WHERE (epr.encntr_id = dencntr_id )
    AND (epr.encntr_prsnl_r_cd = dreltn_cd )
    AND (epr.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (epr.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
    AND (epr.active_ind = 1 ) )
   DETAIL
    epr_qual->epr_cnt = (epr_qual->epr_cnt + 1 ) ,
    stat = alterlist (epr_qual->qual ,epr_qual->epr_cnt ) ,
    epr_qual->qual[epr_qual->epr_cnt ].epr_id = epr.encntr_prsnl_reltn_id ,
    epr_qual->qual[epr_qual->epr_cnt ].prsnl_person_id = epr.prsnl_person_id ,
    IF ((dprov_id = epr.prsnl_person_id ) ) epr_qual->res_chk = true
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (encntr_prsnl_reltn epr )
   PLAN (epr
    WHERE (epr.encntr_id = dencntr_id )
    AND (epr.encntr_prsnl_r_cd = dreltn_cd )
    AND (epr.active_status_cd IN (48_active ,
    48_inactive ) )
    AND (epr.contributor_system_cd = 89_powerchart ) )
   DETAIL
    epr_qual->mpage_ind = true
   WITH nocounter
  ;end select
  RETURN
 END ;Subroutine
 SUBROUTINE  validatefxreltn (dencntr_id ,dprov_id )
  DECLARE ep_mufx_id = f8 WITH noconstant (0.0 )
  SELECT INTO "nl:"
   FROM (lh_mu_fx_metrics mufx ),
    (lh_mu_ep_metrics_reltn epm ),
    (br_eligible_provider bep )
   PLAN (mufx
    WHERE (mufx.encntr_id = dencntr_id ) )
    JOIN (epm
    WHERE (epm.lh_mu_fx_metrics_id = mufx.lh_mu_fx_metrics_id ) )
    JOIN (bep
    WHERE (bep.br_eligible_provider_id = epm.br_eligible_provider_id )
    AND (bep.provider_id = dprov_id ) )
   DETAIL
    ep_mufx_id = epm.lh_mu_ep_metrics_reltn_id
   WITH nocounter
  ;end select
  RETURN (ep_mufx_id )
 END ;Subroutine
 SUBROUTINE  validatefx2reltn (dencntr_id ,dprov_id )
  DECLARE ep_mufx2_id = f8 WITH noconstant (0.0 )
  SELECT INTO "nl:"
   FROM (lh_mu_fx_2_metrics mufx2 ),
    (lh_mu_fx_2_ep_reltn epm2 ),
    (br_eligible_provider bep )
   PLAN (mufx2
    WHERE (mufx2.encntr_id = dencntr_id )
    AND (mufx2.parent_entity_name = "ENCOUNTER" )
    AND (mufx2.lh_mu_fx_2_metrics_id != 0 ) )
    JOIN (epm2
    WHERE (epm2.lh_mu_fx_2_metrics_id = mufx2.lh_mu_fx_2_metrics_id ) )
    JOIN (bep
    WHERE (bep.br_eligible_provider_id = epm2.br_eligible_provider_id )
    AND (bep.provider_id = dprov_id ) )
   DETAIL
    ep_mufx2_id = epm2.lh_mu_fx_2_ep_reltn_id
   WITH nocounter
  ;end select
  RETURN (ep_mufx2_id )
 END ;Subroutine
 SUBROUTINE  validatecustomsettings (codeset ,encntrid ,cve_fieldparse )
  DECLARE validateoutcome = vc
  SET cveparser = concat ("cnvtupper(cve.field_name)= cnvtupper('" ,trim (cve_fieldparse ) ,"')" )
  SELECT INTO "nl:"
   cv_type = evaluate2 (
    IF ((cnvtupper (cv.cdf_meaning ) = "LOG_DOMAIN" ) ) 1
    ELSEIF ((cnvtupper (cv.cdf_meaning ) = "ORG" ) ) 2
    ELSEIF ((cnvtupper (cv.cdf_meaning ) = "LOC" ) ) 3
    ENDIF
    )
   FROM (encounter e ),
    (code_value cv ),
    (code_value_extension cve )
   PLAN (e
    WHERE (e.encntr_id = encntrid ) )
    JOIN (cv
    WHERE (cv.code_set = codeset )
    AND (cv.active_ind = 1 )
    AND (cv.cdf_meaning IN ("LOC" ,
    "ORG" ,
    "LOG_DOMAIN" ) )
    AND (((cnvtreal (cv.definition ) = e.organization_id ) ) OR ((((cnvtreal (cv.definition ) = e
    .loc_nurse_unit_cd ) ) OR ((cnvtreal (cv.definition ) =
    (SELECT
     org.logical_domain_id
     FROM (organization org )
     WHERE (org.organization_id = e.organization_id ) ) ) )) )) )
    JOIN (cve
    WHERE (cve.code_value = cv.code_value )
    AND parser (cveparser ) )
   ORDER BY cv_type
   HEAD cv_type
    null
   DETAIL
    IF ((isnumeric (cve.field_value ) = 1 ) ) validateoutcome = trim (cnvtstring (cve.field_value )
      )
    ELSE validateoutcome = trim (cve.field_value )
    ENDIF
   WITH nocounter
  ;end select
  RETURN (validateoutcome )
 END ;Subroutine
  SUBROUTINE  gathercomponentsettings (parentid )
  CALL log_message ("In gatherComponentSettings()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  SET position_bedrock_settings = 0
  SELECT INTO "nl:"
   FROM (br_datamart_category bdc ),
    (br_datamart_report br ),
    (br_datamart_report_filter_r bfr ),
    (br_datamart_filter bf ),
    (br_datamart_value bv ),
    (br_datamart_flex bx )
   PLAN (bdc
    WHERE (bdc.category_mean = "MP_CUSTOM_AMB_VIEW" ) )
    JOIN (br
    WHERE (br.br_datamart_category_id = bdc.br_datamart_category_id )
    AND (br.report_mean IN ("MP_CUSTOM_AMB_VIEW_TASKS" ,
    "MP_CUSTOM_AMB_VIEW_PAGE" ) ) )
    JOIN (bfr
    WHERE (bfr.br_datamart_report_id = br.br_datamart_report_id ) )
    JOIN (bf
    WHERE (bf.br_datamart_filter_id = bfr.br_datamart_filter_id ) )
    JOIN (bv
    WHERE (bv.br_datamart_category_id = bf.br_datamart_category_id )
    AND (bv.br_datamart_filter_id = bf.br_datamart_filter_id ) )
    JOIN (bx
    WHERE (bx.br_datamart_flex_id = bv.br_datamart_flex_id )
    AND (bx.parent_entity_id = parentid ) )
   ORDER BY bf.filter_mean ,
    bv.value_seq ,
    bv.br_datamart_value_id
   HEAD REPORT
    a_status = 0 ,
    form_cnt = 0
   DETAIL
    CASE (bf.filter_mean )
     OF "AMB_VIEW_TASK_ACTIVE_TYPES" :
      a_status = (a_status + 1 ) ,
      stat = alterlist (task_stat->slist ,a_status ) ,
      task_stat->slist[a_status ].status_cd = bv.parent_entity_id ,
      task_stat->slist[a_status ].status = "Active"
     OF "AMB_VIEW_TASK_ADHOC_DISP" :
      record_data->form_ind = cnvtint (bv.freetext_desc )
     OF "AMB_VIEW_TASK_ADHOC_FORMS" :
      form_cnt = (form_cnt + 1 ) ,
      stat = alterlist (record_data->formslist ,form_cnt ) ,
      record_data->formslist[form_cnt ].form_id = bv.parent_entity_id
     OF "AMB_VIEW_TASK_CANCEL_TYPES" :
      a_status = (a_status + 1 ) ,
      stat = alterlist (task_stat->slist ,a_status ) ,
      task_stat->slist[a_status ].status_cd = bv.parent_entity_id ,
      task_stat->slist[a_status ].status = "Discontinued"
     OF "AMB_VIEW_TASK_COMPL_TYPES" :
      a_status = (a_status + 1 ) ,
      stat = alterlist (task_stat->slist ,a_status ) ,
      task_stat->slist[a_status ].status_cd = bv.parent_entity_id ,
      task_stat->slist[a_status ].status = "Complete"
     OF "AMB_VIEW_TASK_ENC_TYPES" :
      IF ((encntr_type_parser = "1=1" ) ) encntr_type_parser = concat (trim (cnvtstring (bv
          .parent_entity_id ) ,3 ) ,".00" )
      ELSE encntr_type_parser = concat (encntr_type_parser ,"," ,trim (cnvtstring (bv
          .parent_entity_id ) ,3 ) ,".00" )
      ENDIF
     OF "AMB_VIEW_TASK_INFO" :
      record_data->task_info_text = trim (bv.freetext_desc )
     OF "AMB_VIEW_TASK_TASK_TYPES" :
      IF ((task_type_parser = "1=1" ) ) task_type_parser = concat (trim (cnvtstring (bv
          .parent_entity_id ) ,3 ) ,".00" )
      ELSE task_type_parser = concat (task_type_parser ,"," ,trim (cnvtstring (bv.parent_entity_id )
         ,3 ) ,".00" )
      ENDIF
     OF "AMB_VIEW_TASK_REQPRINT_DISP" :
      record_data->allow_req_print = cnvtint (bv.freetext_desc )
     OF "AMB_VIEW_TASK_AUTOSPEC_LOGIN" :
      record_data->autolog_spec_ind = cnvtint (bv.freetext_desc )
     OF "AMB_VIEW_TASK_MPTL_DEPART" :
      record_data->allow_depart = cnvtint (bv.freetext_desc )
     OF "AMB_VIEW_TASK_DEPART_LABEL" :
      record_data->depart_label = trim (bv.freetext_desc )
     OF "AMB_VIEW_ADV_PRINT" :
      record_data->adv_print_ind = cnvtint (trim (bv.freetext_desc ) )
     OF "AMB_VIEW_ADV_PRINT_CSET" :
      record_data->adv_print_codeset = cnvtreal (trim (bv.freetext_desc ) )
    ENDCASE
   WITH nocounter
  ;end select
  IF ((cnvtint (curqual ) > 0 ) )
   SET position_bedrock_settings = 1
  ENDIF
  CALL error_and_zero_check_rec (curqual ,"AMB_CUST_MP_TASK_GET" ,"gatherComponentSettings" ,1 ,0 ,
   record_data )
  CALL log_message (build ("Exit gatherComponentSettings(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  gatherpagecomponentsettings (parentid )
  CALL log_message ("In gatherPageComponentSettings()" ,log_level_debug )
  DECLARE begin_date_time = q8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  SET position_bedrock_settings = 0
  SELECT INTO "nl:"
   FROM (br_datamart_category bdc ),
    (br_datamart_report br ),
    (br_datamart_report_filter_r bfr ),
    (br_datamart_filter bf ),
    (br_datamart_value bv ),
    (br_datamart_flex bx )
   PLAN (bdc
    WHERE (bdc.category_mean = "MP_CUSTOM_AMB_VIEW" ) )
    JOIN (br
    WHERE (br.br_datamart_category_id = bdc.br_datamart_category_id )
    AND (br.report_mean = "MP_CUSTOM_AMB_VIEW_PAGE" ) )
    JOIN (bfr
    WHERE (bfr.br_datamart_report_id = br.br_datamart_report_id ) )
    JOIN (bf
    WHERE (bf.br_datamart_filter_id = bfr.br_datamart_filter_id ) )
    JOIN (bv
    WHERE (bv.br_datamart_category_id = bf.br_datamart_category_id )
    AND (bv.br_datamart_filter_id = bf.br_datamart_filter_id ) )
    JOIN (bx
    WHERE (bx.br_datamart_flex_id = bv.br_datamart_flex_id )
    AND (bx.parent_entity_id = parentid ) )
   ORDER BY bf.filter_mean ,
    bv.value_seq ,
    bv.br_datamart_value_id
   DETAIL
    CASE (bf.filter_mean )
     OF "AMB_VIEW_ORDER_REQ_PRINT" :
      record_data->labreq_prg = trim (bv.freetext_desc )
     OF "AMB_VIEW_ADV_PRINT" :
      record_data->adv_print_ind = cnvtint (trim (bv.freetext_desc ) )
     OF "AMB_VIEW_ADV_PRINT_CSET" :
      record_data->adv_print_codeset = cnvtreal (trim (bv.freetext_desc ) )
    ENDCASE
   WITH nocounter
  ;end select
  IF ((cnvtint (curqual ) > 0 ) )
   SET position_bedrock_settings = 1
  ENDIF
  CALL log_message (build ("Exit gatherPageComponentSettings(), Elapsed time in seconds:" ,
    datetimediff (cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 
 
 
 
 
  SUBROUTINE  gathertasktypes (dummy )
  CALL log_message ("In GatherTaskTypes1()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  /*
  SELECT INTO "nl:"
   type_name = trim (replace (cv.display ,"* " ,"" ,0 ) )
   FROM (code_value cv )
   WHERE (cv.code_set = 6026 )
   AND (cv.active_ind = 1 )
   AND (cv.cdf_meaning IN ("CLINPHARM" ,
   "INFUSEBILL" ,
   "MEDRECON" ,
   "NURSECOL" ,
   "RESPONSE" ,
   "PERSONAL" ,
   "SURGERY" ,
   "ASSESS" ,
   "PATCARE" ,
   "IV" ,
   "MED" ,
   "RAD" ,
   "LAB" ,
   "ANCILLARY" ) )
   AND parser (task_type_cv_parser )
   ORDER BY type_name
   HEAD REPORT
    tycnt = 0
   DETAIL
    tycnt = (tycnt + 1 ) ,
    stat = alterlist (record_data->type_list ,tycnt ) ,
    record_data->type_list[tycnt ].type = type_name ,
    record_data->type_list[tycnt ].selected = 0
   WITH nocounter
  ;end select
  */
 
 	select distinct into "nl:"
		cv1.display
	from
		code_value cv1
	plan cv1
		where cv1.code_set = 103507
		and   cv1.cdf_meaning = "REQUISITION"
		and	  cv1.active_ind = 1
	order by
		cv1.display
	head report
		tycnt = size(record_data->type_list,5)
	head cv1.display
		tycnt = (tycnt + 1 ) ,
    	stat = alterlist (record_data->type_list ,tycnt ) ,
    	record_data->type_list[tycnt ].type =trim(cv1.display) ,
    	record_data->type_list[tycnt ].type = replace(record_data->type_list[tycnt ].type,"Requisition","") , ;004
    	record_data->type_list[tycnt ].type = replace(record_data->type_list[tycnt ].type,"Diagnostic","") , ;004
    	call echo(build("->adding requisition type=",trim(cv1.display)))
	with nocounter
 
free record type_temp
record type_temp
(
	1 cnt = i2
	1 qual[*]
	 2 display = vc
	 2 grouping = vc
)
 
select distinct into "nl:"
	cv1.display
	,cve1.field_value
	,activity_type = uar_get_code_display(oc.activity_type_cd)
	,activity_subtype = uar_get_code_display(oc.activity_subtype_cd)
from
	 order_catalog oc
	,code_value cv1
	,code_value cv2
	,code_value_extension cve1
plan cv1
	where cv1.code_set = 103507
	and   cv1.cdf_meaning = "REQUISITION"
	and   cv1.active_ind = 1
join cv2
	where cv2.code_set = 6002
	and   cv2.active_ind = 1
	and   cv2.cdf_meaning = cv1.description
join cve1
	where   cve1.code_set = cv1.code_set
	and     cve1.code_value = cv1.code_value
	and     cve1.field_name = "SUBTYPE_PROCESSING"
join oc
	where oc.requisition_format_cd = cv2.code_value
	and   oc.active_ind = 1
order by
	cv1.display
	,cve1.field_value
	,activity_type
	,activity_subtype
head report
	null
head cv1.display
	null
detail
 
	if (cve1.field_value = "activity_type_cd")
		if (activity_type > " ")
			type_temp->cnt = (type_temp->cnt + 1)
			stat = alterlist(type_temp->qual,type_temp->cnt)
			type_temp->qual[type_temp->cnt].grouping = trim(replace(cv1.display,"Requisition",""))
			type_temp->qual[type_temp->cnt].display  = trim(uar_get_code_display(oc.activity_type_cd))
		endif
	elseif (cve1.field_value = "activity_subtype_cd")
		if (activity_subtype > " ")
			type_temp->cnt = (type_temp->cnt + 1)
			stat = alterlist(type_temp->qual,type_temp->cnt)
			type_temp->qual[type_temp->cnt].grouping = trim(replace(cv1.display,"Requisition",""))
			type_temp->qual[type_temp->cnt].display  = trim(uar_get_code_display(oc.activity_subtype_cd))
		endif
	else
		type_temp->cnt = (type_temp->cnt + 1)
		stat = alterlist(type_temp->qual,type_temp->cnt)
		type_temp->qual[type_temp->cnt].grouping = trim(replace(cv1.display,"Requisition",""))
		type_temp->qual[type_temp->cnt].display = trim(cve1.field_value)
	endif
with nocounter
 
 
 
/*
select distinct into "nl:"
from
	 order_catalog oc
	,code_value cv1
plan cv1
	where cv1.code_set = 6000
	and   cv1.cdf_meaning in("CARDIOLOGY","AMB REFERRAL","RADIOLOGY","GENERAL LAB")
	and   cv1.active_ind = 1
join oc
	where oc.catalog_type_cd = cv1.code_value
	and   oc.active_ind = 1
order by
	 oc.catalog_type_cd
	,oc.activity_type_cd
	,oc.activity_subtype_cd
head report
	type_temp->cnt = (type_temp->cnt + 1)
	stat = alterlist(type_temp->qual,type_temp->cnt)
	type_temp->qual[type_temp->cnt].display = "Group and Screen"
	type_temp->qual[type_temp->cnt].grouping = "Laboratory"
	type_temp->cnt = (type_temp->cnt + 1)
	stat = alterlist(type_temp->qual,type_temp->cnt)
	type_temp->qual[type_temp->cnt].display = "Bone Marrow Biopsy/ Aspirate"
	type_temp->qual[type_temp->cnt].grouping = "Laboratory"
head oc.catalog_type_cd
	if (cv1.cdf_meaning in("GENERAL LAB"))
		type_temp->cnt = (type_temp->cnt + 1)
		stat = alterlist(type_temp->qual,type_temp->cnt)
		type_temp->qual[type_temp->cnt].display = "Outpatient Lab(s)"
		type_temp->qual[type_temp->cnt].grouping = "Laboratory"
	endif
head oc.activity_type_cd
	if (cv1.cdf_meaning in("CARDIOLOGY","AMB REFERRAL"))
		type_temp->cnt = (type_temp->cnt + 1)
		stat = alterlist(type_temp->qual,type_temp->cnt)
		type_temp->qual[type_temp->cnt].display = uar_get_code_display(oc.activity_type_cd)
		if (cv1.cdf_meaning = "CARDIOLOGY")
			type_temp->qual[type_temp->cnt].grouping = "Cardiology"
		elseif (cv1.cdf_meaning = "AMB REFERRAL")
			type_temp->qual[type_temp->cnt].grouping = "Referral"
		endif
	endif
head oc.activity_subtype_cd
	if (cv1.cdf_meaning in("RADIOLOGY"))
		type_temp->cnt = (type_temp->cnt + 1)
		stat = alterlist(type_temp->qual,type_temp->cnt)
		type_temp->qual[type_temp->cnt].display = uar_get_code_display(oc.activity_subtype_cd)
		type_temp->qual[type_temp->cnt].grouping = "Medical Imaging"
	endif
with nocounter
*/
 
call echorecord(type_temp)
 
select into "nl:"
	display = substring(1,100,type_temp->qual[d1.seq].display)
from
	(dummyt d1 with seq=type_temp->cnt)
plan d1
	where type_temp->qual[d1.seq].display > " "
order by
	display
head report
	tycnt = size(record_data->subtype_list,5)
head display
		tycnt = (tycnt + 1 ) ,
    	stat = alterlist (record_data->subtype_list ,tycnt ) ,
    	record_data->subtype_list[tycnt ].type =trim(display) ,
    	call echo(build("->adding subtype type=",trim(display)))
with nocounter
 
select into "nl:"
	 grouping = substring(1,100,type_temp->qual[d1.seq].grouping)
	,display = substring(1,100,type_temp->qual[d1.seq].display)
from
	(dummyt d1 with seq=type_temp->cnt)
plan d1
	where type_temp->qual[d1.seq].display > " "
order by
	 grouping
	,display
head report
	tycnt = size(record_data->gsubtype_list,5)
	gpcnt = 0
head grouping
	tycnt = (tycnt + 1 )
	gpcnt = 0
	stat = alterlist (record_data->gsubtype_list ,tycnt)
	record_data->gsubtype_list[tycnt ].group_name = grouping
head display
	gpcnt = (gpcnt + 1 ) ,
    stat = alterlist (record_data->gsubtype_list[tycnt ].group ,gpcnt ) ,
    record_data->gsubtype_list[tycnt ].group[gpcnt].type =trim(display)
with nocounter
/*
	select distinct into "nl:"
		cv1.display
	from
		code_value cv1
	plan cv1
	where cv1.code_set = 5801
	and   cv1.definition in("RADIOLOGY","CARDIOVASCUL")
	and	  cv1.active_ind = 1
	order by
		cv1.display
	head report
		tycnt = size(record_data->subtype_list,5)
	head cv1.display
		tycnt = (tycnt + 1 ) ,
    	stat = alterlist (record_data->subtype_list ,tycnt ) ,
    	record_data->subtype_list[tycnt ].type =trim(cv1.display) ,
    	record_data->subtype_list[tycnt ].type = replace(record_data->subtype_list[tycnt ].type,"Requisition","") , ;004
    	record_data->subtype_list[tycnt ].type = replace(record_data->subtype_list[tycnt ].type,"Diagnostic","") , ;004
    	call echo(build("->adding subtype type=",trim(cv1.display)))
	with nocounter
*/
 
	call echo("starting priority_list")
	select distinct into "nl:"
		group_sort = cnvtreal(cve1.field_value)
	from
		 code_value cv1
		,code_value_extension cve1
		,code_value_extension cve2
		,code_value_extension cve3
		,code_value cv2
		,order_catalog oc
		,oe_format_fields off
		,order_entry_fields oef
		,oe_field_meaning ofm
		,code_value cv3
	plan cv1
		where cv1.code_set = 103507
		and   cv1.cdf_meaning = "REQUISITION"
		and	  cv1.active_ind = 1
	join cve1
		where cve1.code_value = cv1.code_value
		and cve1.field_name = "RM_PRIORITY_GROUP"
	join cve2
		where cve2.code_value = cv1.code_value
		and cve2.field_name = "RM_PRIORITY_OEM"
	join cve3
		where cve3.code_value = cv1.code_value
		and cve3.field_name = "RM_TYPE_DISPLAY"
	join cv2
		where cv2.code_set = 6002
		and   cv2.cdf_meaning = cv1.description
		and   cv2.active_ind = 1
	join oc
		where oc.requisition_format_cd = cv2.code_value
		and   oc.active_ind = 1
		and   oc.primary_mnemonic not in("Cardiopulmonary Exercise Stress Test (MVO2)")
	join off
		where off.oe_format_id = oc.oe_format_id
		and   off.label_text = cve2.field_value
	join oef
		where oef.oe_field_id = off.oe_field_id
		and oef.oe_field_id in(      12613.00
, 2550935691.00
 ,     12657.00)
	join ofm
		where ofm.oe_field_meaning_id = oef.oe_field_meaning_id
	join cv3
		where cv3.code_set = oef.codeset
		and   cv3.active_ind = 1
		and   cv3.display not in("Add On")
	order by
     group_sort
	,cve3.field_value
	,cv3.collation_seq
	,cv3.display
	,cve1.field_value
head report
		tycnt = size(record_data->priority_list,5)
		gpcnt = 0
		pos = 0
	head group_sort
		null
	head cve3.field_value
		tycnt = (tycnt + 1 ) ,
    	stat = alterlist (record_data->priority_list ,tycnt ) ,
    	record_data->priority_list[tycnt ].group_name =trim(cve3.field_value)
    	;call echo(build("->adding priority_list group_name=",trim(cv1.display)))
    	call echo(build("->adding priority_list group_name=",trim(record_data->priority_list[tycnt ].group_name)))
    	gpcnt = 0
    	pos = 0
    head cv3.display
    	pos = locateval(i,1,size(record_data->priority_list[tycnt].group,5),cv3.display,record_data->priority_list[tycnt].group[i].
    	priority)
    	if (pos = 0)
    		gpcnt = (gpcnt + 1)
    		stat = alterlist(record_data->priority_list[tycnt].group,gpcnt)
    		record_data->priority_list[tycnt].group[gpcnt].priority = cv3.display
    		call echo(build("-->adding priority_list priority=",trim(record_data->priority_list[tycnt ].group[gpcnt].priority),"<>"))
    	endif
 	with nocounter
	CALL error_and_zero_check_rec (curqual ,"AMB_CUST_MP_TASK_LOC_DT" ,"GatherTaskTypes" ,1 ,0 ,record_data )
 	 CALL log_message (build ("Exit GatherTaskTypes(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 
 END ;Subroutine
 
  SUBROUTINE  gatheruserprefs (prsnl_id ,pref_id )
  CALL log_message ("In GatherUserPrefs()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  SET user_pref_string = ""
  SET user_pref_found = 0
  SELECT INTO "nl:"
   FROM (app_prefs a ),
    (name_value_prefs n )
   PLAN (a
    WHERE (a.prsnl_id = prsnl_id ) )
    JOIN (n
    WHERE (n.parent_entity_id = a.app_prefs_id )
    AND (n.parent_entity_name = "APP_PREFS" )
    AND (n.pvc_name = pref_id ) )
   ORDER BY n.sequence
   DETAIL
    user_pref_found = 1 ,
    user_pref_string = concat (user_pref_string ,trim (n.pvc_value ) )
   WITH nocounter
  ;end select
  CALL error_and_zero_check_rec (curqual ,"AMB_CUST_MP_TASK_LOC_DT" ,"GatherUserPrefs" ,1 ,0 , record_data )
  CALL log_message (build ("Exit GatherUserPrefs(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  gatherpowerformname (dummy )
  CALL log_message ("In GatherPowerFormName()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  SELECT INTO "nl:"
   FROM (dcp_forms_ref dfr ),
    (dummyt d WITH seq = size (record_data->formslist ,5 ) )
   PLAN (d )
    JOIN (dfr
    WHERE (dfr.dcp_forms_ref_id = record_data->formslist[d.seq ].form_id )
    AND (dfr.active_ind = 1 ) )
   DETAIL
    record_data->formslist[d.seq ].form_name = trim (dfr.definition )
   WITH nocounter
  ;end select
  CALL error_and_zero_check_rec (curqual ,"AMB_CUST_MP_TASK_LOC_DT" ,"GatherPowerFormName" ,1 ,0 ,
   record_data )
  CALL log_message (build ("Exit GatherPowerFormName(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 
 
 SUBROUTINE  gathernotdonereason (resultid )
  CALL log_message ("In GatherNotDoneReason()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  SET not_done_reason = ""
  SET not_done_reason_comm = ""
  SELECT INTO "nl:"
   blob_contents = l.long_blob
   FROM (ce_result_set_link cr ),
    (clinical_event ce ),
    (left
    JOIN ce_event_note c ON (c.event_id = ce.event_id ) ),
    (left
    JOIN long_blob l ON (l.parent_entity_id = c.ce_event_note_id )
    AND (l.parent_entity_name = "CE_EVENT_NOTE" ) )
   PLAN (cr
    WHERE (cr.result_set_id = resultid ) )
    JOIN (ce
    WHERE (cr.event_id = ce.event_id )
    AND (ce.result_status_cd != inerror )
    AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (ce.event_title_text != "Date\Time correction" )
    AND (ce.view_level = 1 )
    AND (ce.publish_flag = 1 ) )
    JOIN (c )
    JOIN (l )
   ORDER BY ce.event_end_dt_tm DESC
   HEAD REPORT
    goodblob = fillstring (1000 ," " ) ,
    xlen = 0
   DETAIL
    not_done_reason = trim (ce.result_val ) ,
    IF ((l.long_blob_id > 0 ) )
     IF ((c.compression_cd = ocfcomp_cd ) ) blob_out = fillstring (1000 ," " ) ,blob_out2 =
      fillstring (1000 ," " ) ,blob_ret_len = 0 ,
      CALL uar_ocf_uncompress (blob_contents ,1000 ,blob_out ,1000 ,blob_ret_len ) ,
      CALL uar_rtf (blob_out ,textlen (blob_out ) ,blob_out2 ,32000 ,32000 ,0 ) ,xlen = (findstring (
       "ocf_blob" ,blob_out2 ,1 ) - 1 ) ,
      IF ((xlen > 0 ) ) goodblob = notrim (substring (1 ,xlen ,blob_out2 ) ) ,not_done_reason_comm =
       goodblob
      ELSE not_done_reason_comm = blob_out2
      ENDIF
     ELSE blob_out2 = fillstring (32000 ," " ) ,
      CALL uar_rtf (blob_contents ,textlen (blob_contents ) ,blob_out2 ,32000 ,32000 ,0 ) ,xlen = (
      findstring ("ocf_blob" ,blob_out2 ,1 ) - 1 ) ,
      IF ((xlen > 0 ) ) goodblob = notrim (substring (1 ,xlen ,blob_out2 ) ) ,not_done_reason_comm =
       goodblob
      ELSE not_done_reason_comm = blob_out2
      ENDIF
      ,not_done_reason_comm = goodblob
     ENDIF
    ENDIF
   WITH nocounter ,maxrec = 1
  ;end select
  CALL log_message (build ("ExitGatherNotDoneReason(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  gatherchartedforms (eventid )
  CALL log_message ("In GatherChartedForms()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  SET charted_form_id = 0.0
  SELECT INTO "nl:"
   FROM (clinical_event ce ),
    (dcp_forms_activity_comp dfac )
   PLAN (ce
    WHERE (ce.event_id = eventid )
    AND (ce.result_status_cd != inerror )
    AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (ce.event_title_text != "Date\Time correction" )
    AND (ce.view_level = 1 )
    AND (ce.publish_flag = 1 ) )
    JOIN (dfac
    WHERE (dfac.parent_entity_id = ce.parent_event_id )
    AND (dfac.parent_entity_name = "CLINICAL_EVENT" ) )
   DETAIL
    charted_form_id = dfac.dcp_forms_activity_id
   WITH nocounter ,maxrec = 1
  ;end select
  CALL log_message (build ("Exit GatherChartedForms(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 
 
   SUBROUTINE  gatherclericalstatus (dummy )
  CALL log_message ("In GatherClericalStatus()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
 
 
 	select distinct into "nl:"
		cv1.display
	from
		code_value cv2
		,code_value_group cvg1
		,code_value cv1
	plan cv2
		where cv2.code_set = 103507
		and   cv2.cdf_meaning = "CLER_STATUS"
		and	  cv2.active_ind = 1
	join cvg1
		where cvg1.parent_code_value = cv2.code_value
		and   cvg1.code_set = 103507
	join cv1
		where cv1.code_value = cvg1.child_code_value
	order by
		cvg1.collation_seq
		,cv1.display
	head report
		tycnt = size(record_data->cler_status_list,5)
	head cv1.display
		tycnt = (tycnt + 1 ) ,
    	stat = alterlist (record_data->cler_status_list ,tycnt ) ,
    	record_data->cler_status_list[tycnt ].status =trim(cv1.display)
    	call echo(build("->adding status=",trim(cv1.display)))
	with nocounter
	CALL error_and_zero_check_rec (curqual ,"AMB_CUST_MP_TASK_LOC_DT" ,"GatherClericalStatus" ,1 ,0 ,record_data )
 	 CALL log_message (build ("Exit GatherClericalStatus(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 
 END ;Subroutine
 
 SUBROUTINE  gatherlocations (persid )
  CALL log_message ("In GatherLocations()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
 
  SELECT DISTINCT into "nl:"
   location_cd = l3.location_cd ,
   ;location = trim (uar_get_code_description (l3.location_cd ) ),
   location = trim (uar_get_code_display (l3.location_cd ) ),
   facility = trim (uar_get_code_description (l.location_cd ) )
   FROM (prsnl_org_reltn por ),
    (organization org ),
    (location l ),
    (location_group lg ),
    (location l2 ),
    (location_group lg2 ),
    (location l3 ),
    (code_value cv1),
    (code_value cv2),
    (code_value cv3)
   PLAN (por
    WHERE (por.person_id = persid )
    AND (por.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
    AND (por.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
    AND (por.active_ind = 1 ) )
    JOIN (org
    WHERE (org.organization_id = por.organization_id )
    AND (org.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
    AND (org.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
    AND (org.active_ind = 1 ) )
    JOIN (l
    WHERE (l.organization_id = org.organization_id )
    AND (l.location_type_cd = value(uar_get_code_by_cki ("CKI.CODEVALUE!2844" ) ))
    AND (l.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
    AND (l.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
    AND (l.active_ind = 1 ) )
 
    join (cv1
    where (cv1.code_value = l.location_cd)
    ;and   (cv1.display in("BCC*","SPH St Pauls"))
    )
 
    JOIN (lg
    WHERE (lg.parent_loc_cd = l.location_cd )
    AND (lg.root_loc_cd = 0 )
    AND (lg.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
    AND (lg.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
    AND (lg.active_ind = 1 ) )
    JOIN (l2
    WHERE (l2.location_cd = lg.child_loc_cd )
    AND (l2.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
    AND (l2.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
    AND (l2.active_ind = 1 ) )
    JOIN (lg2
    WHERE (lg.child_loc_cd = lg2.parent_loc_cd )
    AND (lg2.root_loc_cd = 0 )
    AND (lg2.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
    AND (lg2.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
    AND (lg2.active_ind = 1 ) )
    JOIN (l3
    WHERE (l3.location_cd = lg2.child_loc_cd )
    AND (l3.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
    AND (l3.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
    AND (l3.active_ind = 1 )
    ;and (uar_get_code_display(l3.location_cd) not in("SPH ED","SPH Morgue"))
    ;and l3.location_cd = 2561582141 ;REMOVE location specific
    AND (l3.location_type_cd IN ((	SELECT
								     cv.code_value
								     FROM (code_value cv )
								     ;WHERE (cv.cdf_meaning IN ("AMBULATORY" , "NURSEUNIT"  ) )
								     WHERE (cv.cdf_meaning IN ("AMBULATORY"   ) )
								     ) )
			) )
	join (cv2
    where (cv2.code_value = l3.location_cd)
    and   (cv2.display not in("SPH ED","SPH Morgue"))
    join (cv3
    where (cv3.code_set = 103507)
    and   (cv3.cdf_meaning = "LOCATION")
    and   (cv3.active_ind = 1)
    and   (cv3.display = cv2.display)))
   ORDER BY
   	facility ,
   	location,
   	l.location_cd,
    l3.location_cd
   HEAD REPORT
    org_cnt = 0 ,
    unit_cnt = 0,
    temp_string = ""
   ;HEAD l3.location_cd
   ;head l.location_cd
   head facility
	call echo(build2("l.location_cd=",l.location_cd))
	call echo(build2("facility=",facility))
 
    unit_cnt = 0,
    temp_string = ""
    org_cnt = (org_cnt + 1 ) ,
    IF ((mod (org_cnt ,10 ) = 1 ) )
    	stat = alterlist (record_data->loc_list ,(org_cnt + 9 ) )
    ENDIF
    temp_string = replace (facility ,char (10 ) ," " )
    record_data->loc_list[org_cnt ].org_name = replace (temp_string ,char (13 ) ," " )
    record_data->loc_list[org_cnt ].org_id = l.location_cd
   ;head l3.location_cd
   head location
   	call echo(build2("l3.location_cd=",l3.location_cd))
   	call echo(build2("location=",location))
   	unit_cnt = (unit_cnt + 1)
   	stat = alterlist (record_data->loc_list[org_cnt].unit,unit_cnt )
   	temp_string = replace (location ,char (10 ) ," " )
   	record_data->loc_list[org_cnt ].unit[unit_cnt].unit_name = replace (temp_string ,char (13 ) ," " )
   	record_data->loc_list[org_cnt ].unit[unit_cnt].unit_id = l3.location_cd
   FOOT REPORT
    stat = alterlist (record_data->loc_list ,org_cnt )
   WITH nocounter
  ;end select
  CALL error_and_zero_check_rec (curqual ,"PWX_MP_TASK_ORG_DRIVER" ,"GatherLocations" ,1 ,0 ,
   record_data )
  CALL log_message (build ("Exit GatherLocations(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
END ;Subroutine
