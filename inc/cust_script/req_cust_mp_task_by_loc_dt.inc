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
 
select distinct
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
 
 
 	select distinct
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
 
  SELECT DISTINCT
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
