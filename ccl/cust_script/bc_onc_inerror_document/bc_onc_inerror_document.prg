/***********************************************************************************************************************
  Program Name:       	bc_onc_inerror_document
  Source File Name:   	bc_onc_inerror_document.prg
  Program Written By: 	Chad Cummings
  Date:  			  	10-Sep-2020
  Program Purpose:      Adapted from him_inerror_docment
************************************************************************************************************************
												*MODIFICATION HISTORY*
************************************************************************************************************************
 
Rev  Date         Jira       Programmer             Comment
---  -----------  ---------  ---------------------  --------------------------------------------------------------------
000  10-Sep-2020  CST-96425  Chad Cummings          Initial Release
 
***********************************************************************************************************************/
drop program bc_onc_inerror_document:dba go
create program bc_onc_inerror_document:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "EVENT_ID" = 0
 
with OUTDEV, EVENT_ID
 
 
 
if (validate(GEN_NBR_ERROR,-1) != 3)
   declare GEN_NBR_ERROR = i2 with protect, noconstant(3)
endif
if (validate(INSERT_ERROR,-1) != 4)
   declare INSERT_ERROR = i2 with protect, noconstant(4)
endif
if (validate(UPDATE_ERROR,-1) != 5)
   declare UPDATE_ERROR = i2 with protect, noconstant(5)
endif
if (validate(REPLACE_ERROR,-1) != 6)
   declare REPLACE_ERROR = i2 with protect, noconstant(6)
endif
if (validate(DELETE_ERROR,-1) != 7)
   declare DELETE_ERROR = i2 with protect, noconstant(7)
endif
if (validate(UNDELETE_ERROR,-1) != 8)
   declare UNDELETE_ERROR = i2 with protect, noconstant(8)
endif
if (validate(REMOVE_ERROR,-1) != 9)
   declare REMOVE_ERROR = i2 with protect, noconstant(9)
endif
if (validate(ATTRIBUTE_ERROR,-1) != 10)
   declare ATTRIBUTE_ERROR = i2 with protect, noconstant(10)
endif
if (validate(LOCK_ERROR,-1) != 11)
   declare LOCK_ERROR = i2 with protect, noconstant(11)
endif
if (validate(NONE_FOUND,-1) != 12)
   declare NONE_FOUND = i2 with protect, noconstant(12)
endif
if (validate(SELECT_ERROR,-1) != 13)
   declare SELECT_ERROR = i2 with protect, noconstant(13)
endif
if (validate(INSERT_DUPLICATE,-1) != 14)
   declare VERSION_INSERT_ERROR = i2 with protect, noconstant(16)
endif
if (validate(UAR_ERROR,-1) != 20)
   declare UAR_ERROR = i2 with protect, noconstant(20)
endif
if (validate(failed,-1) != 0)
   declare failed  = i2 with protect, noconstant(FALSE)
endif
if (validate(table_name,"ZZZ") = "ZZZ")
   declare table_name = vc with protect, noconstant(" ")
else
   set table_name = fillstring(50," ")
endif
if (validate(Error_Value,"ZZZ") = "ZZZ")
   declare Error_Value = vc with protect, noconstant(fillstring(150," "))
endif
 
if (validate(reply->status_data) = 0)
  record reply
  (
%i cclsource:status_block.inc
  )
endif
 
set reply->status_data->status = "F"
set table_name = "CLINICAL_EVENT"
 
declare mf_INERROR_RESULT_STATUS_CD = f8 with protect, constant(uar_get_code_by("MEANING", 8, "INERROR"))
declare mf_INERRNOMUT_RESULT_STATUS_CD = f8 with protect, constant(uar_get_code_by("MEANING", 8, "INERRNOMUT"))
declare mf_INERRNOVIEW_RESULT_STATUS_CD = f8 with protect, constant(uar_get_code_by("MEANING", 8, "INERRNOVIEW"))
declare mf_INERROR_ACTION_CD = f8 with protect, constant(uar_get_code_by("MEANING", 103, "INERROR"))
declare mf_DELETED_STATUS_CD = f8 with protect, constant(uar_get_code_by("MEANING", 48, "DELETED"))
 
declare ml_appNum = i4 with protect, constant(1000012)
declare ml_taskNum = i4 with protect, constant(1000012)
declare ml_reqNum = i4 with protect, constant(1000012)
declare mi_crmStatus = i2 with protect, noconstant(0)
declare ml_hApp = i4 with protect, noconstant(0)
declare ml_hTask = i4 with protect, noconstant(0)
declare ml_hStep = i4 with protect, noconstant(0)
declare ml_hReq = i4 with protect, noconstant(0)
declare ml_hReply = i4 with protect, noconstant(0)
declare ml_hParentEventStruct = i4 with protect, noconstant(0)
declare ml_hEventStruct = i4 with protect, noconstant(0)
declare ml_hEventPrsnlItem = i4 with protect, noconstant(0)
declare ml_hCE_Type = i4 with protect, noconstant(0)
declare ml_hCE_Struct = i4 with protect, noconstant(0)
 
declare mi_EVENT_ENSURE_ADD = i2 with protect, constant(1)
declare mi_EVENT_ENSURE_UPT = i2 with protect, constant(2)
 
select into "nl:"
from
  clinical_event ce
where
  ce.event_id = $EVENT_ID
and ce.event_id > 0.0
    and not ce.result_status_cd in (mf_INERROR_RESULT_STATUS_CD, mf_INERRNOMUT_RESULT_STATUS_CD, mf_INERRNOVIEW_RESULT_STATUS_CD)
    and ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
with nocounter
 
if (curqual <= 0)
  set reply->status_data->status = "Z"
  go to exit_script
endif
 
set mi_crmStatus = uar_CrmBeginApp(ml_appNum, ml_hApp)
if ((mi_crmStatus != 0) or (ml_hApp = 0))
  set reply->status_data->subeventstatus[1]->operationstatus = "F"
  set reply->status_data->subeventstatus[1]->targetobjectname
    = concat("Begin App 1000012 err=", cnvtstring(mi_crmStatus))
  set reply->status_data->subeventstatus[1]->targetobjectvalue = "srvInErrorEvent"
  set reqinfo->commit_ind = FALSE
  go to exit_script
endif
 
set mi_crmStatus = uar_CrmBeginTask(ml_hApp, ml_taskNum, ml_hTask)
if ((mi_crmStatus != 0) or (ml_hTask = 0))
 set reply->status_data->subeventstatus[1]->operationstatus = "F"
  set reply->status_data->subeventstatus[1]->targetobjectname
    = concat("Begin Task 1000012 err=", cnvtstring(mi_crmStatus))
  set reply->status_data->subeventstatus[1]->targetobjectvalue = "srvInErrorEvent"
  set reqinfo->commit_ind = FALSE
  go to exit_script
endif
 
set mi_crmStatus = uar_CrmBeginReq(ml_hTask, "", ml_reqNum, ml_hStep)
if ((mi_crmStatus != 0) or (ml_hStep = 0))
  set reply->status_data->subeventstatus[1]->operationstatus = "F"
  set reply->status_data->subeventstatus[1]->targetobjectname
    = concat("Begin Req 1000012 err=", cnvtstring(mi_crmStatus))
  set reply->status_data->subeventstatus[1]->targetobjectvalue = "srvInErrorEvent"
  set reqinfo->commit_ind = FALSE
  go to exit_script
endif
 
set ml_hReq = uar_CrmGetRequest(ml_hStep)
if (ml_hReq = 0)
  set reply->status_data->subeventstatus[1]->operationstatus = "F"
  set reply->status_data->subeventstatus[1]->targetobjectname = "Failed to get request handle"
  set reply->status_data->subeventstatus[1]->targetobjectvalue = "srvInErrorEvent"
  set reqinfo->commit_ind = FALSE
  go to exit_script
endif
 
set stat = uar_SrvSetShort(ml_hReq, "ensure_type", mi_EVENT_ENSURE_UPT) ;Update
set ml_hParentEventStruct = uar_SrvGetStruct(ml_hReq, "clin_event")
set ml_hCE_Type = uar_SrvCreateTypeFrom(ml_hReq, "clin_event")
set ml_hCE_Struct = uar_SrvGetStruct(ml_hReq, "clin_event")
set stat = uar_SrvBindItemType(ml_hCE_Struct, "child_event_list", ml_hCE_Type)
 
select into "nl:"
from
  clinical_event ce,
  ce_event_prsnl cep
plan ce where
  ce.parent_event_id = $EVENT_ID
    and not ce.result_status_cd
      in (mf_INERROR_RESULT_STATUS_CD, mf_INERRNOMUT_RESULT_STATUS_CD, mf_INERRNOVIEW_RESULT_STATUS_CD)
    and ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
join cep where
  cep.event_id = outerjoin(ce.event_id)
    and cep.valid_until_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
order by ce.event_id
head ce.event_id
  if ((ce.event_id = ce.parent_event_id) or (ce.parent_event_id = 0.0))
    ml_hEventStruct = ml_hParentEventStruct
  else
    ml_hEventStruct = uar_SrvAddItem(ml_hParentEventStruct, "child_event_list")
  endif
 
  stat = uar_SrvSetDouble(ml_hEventStruct, "clinical_event_id", ce.clinical_event_id)
  stat = uar_SrvSetDouble(ml_hEventStruct, "event_id", ce.event_id)
  stat = uar_SrvSetDouble(ml_hEventStruct, "parent_event_id", ce.parent_event_id)
  stat = uar_SrvSetDouble(ml_hEventStruct, "person_id", ce.person_id)
  stat = uar_SrvSetDouble(ml_hEventStruct, "encntr_id", ce.encntr_id)
  stat = uar_SrvSetDouble(ml_hEventStruct, "event_cd", ce.event_cd)
  stat = uar_SrvSetDouble(ml_hEventStruct, "event_class_cd", ce.event_class_cd)
  stat = uar_SrvSetDouble(ml_hEventStruct, "event_reltn_cd", ce.event_reltn_cd)
  stat = uar_SrvSetDouble(ml_hEventStruct, "record_status_cd", mf_DELETED_STATUS_CD)
  stat = uar_SrvSetDouble(ml_hEventStruct, "result_status_cd", mf_INERRNOVIEW_RESULT_STATUS_CD) ;INERROR
  stat = uar_SrvSetDouble(ml_hEventStruct, "contributor_system_cd", ce.contributor_system_cd)
  stat = uar_SrvSetLong(ml_hEventStruct, "view_level", 0)
  stat = uar_SrvSetLong(ml_hEventStruct, "subtable_bit_map", ce.subtable_bit_map)
  stat = uar_SrvSetShort(ml_hEventStruct, "authentic_flag", ce.authentic_flag)
  stat = uar_SrvSetShort(ml_hEventStruct, "publish_flag", ce.publish_flag)
  stat = uar_SrvSetLong(ml_hEventStruct, "updt_cnt", ce.updt_cnt)
  stat = uar_SrvSetDate(ml_hEventStruct, "event_start_dt_tm", ce.event_start_dt_tm)
  stat = uar_SrvSetDate(ml_hEventStruct, "event_end_dt_tm", ce.event_end_dt_tm)
  stat = uar_SrvSetDate(ml_hEventStruct, "valid_until_dt_tm", cnvtdatetime(curdate,curtime3))
  stat = uar_SrvSetDate(ml_hEventStruct, "verified_dt_tm", ce.verified_dt_tm)
  stat = uar_SrvSetShort(ml_hEventStruct, "verified_dt_tm_ind", 0)
  stat = uar_SrvSetDouble(ml_hEventStruct, "verified_prsnl_id", ce.verified_prsnl_id)
  stat = uar_SrvSetDate(ml_hEventStruct, "performed_dt_tm", ce.performed_dt_tm)
  stat = uar_SrvSetShort(ml_hEventStruct, "performed_dt_tm_ind", 0)
  stat = uar_SrvSetDouble(ml_hEventStruct, "performed_prsnl_id", ce.performed_prsnl_id)
detail
  if (cep.ce_event_prsnl_id > 0.0)
    ml_hEventPrsnlItem = uar_SrvAddItem(ml_hEventStruct, "event_prsnl_list")
 
    stat = uar_SrvSetDouble(ml_hEventPrsnlItem, "ce_event_prsnl_id", cep.ce_event_prsnl_id)
    stat = uar_SrvSetDouble(ml_hEventPrsnlItem, "event_prsnl_id", cep.event_prsnl_id)
    stat = uar_SrvSetDouble(ml_hEventPrsnlItem, "event_id", cep.event_id)
    stat = uar_SrvSetDouble(ml_hEventPrsnlItem, "person_id", cep.person_id)
    stat = uar_SrvSetDouble(ml_hEventPrsnlItem, "action_prsnl_id", cep.action_prsnl_id)
    stat = uar_SrvSetDouble(ml_hEventPrsnlItem, "proxy_prsnl_id", cep.proxy_prsnl_id)
    stat = uar_SrvSetDouble(ml_hEventPrsnlItem, "request_prsnl_id", cep.request_prsnl_id)
    stat = uar_SrvSetDouble(ml_hEventPrsnlItem, "action_type_cd", cep.action_type_cd)
    stat = uar_SrvSetDouble(ml_hEventPrsnlItem, "action_status_cd", mf_INERROR_ACTION_CD) ;INERROR
    stat = uar_SrvSetShort(ml_hEventPrsnlItem, "change_since_action_flag_ind", 0)
    stat = uar_SrvSetShort(ml_hEventPrsnlItem, "change_since_action_flag", cep.change_since_action_flag)
    stat = uar_SrvSetShort(ml_hEventPrsnlItem, "updt_task_ind", 1)
    stat = uar_SrvSetShort(ml_hEventPrsnlItem, "updt_cnt_ind", 0)
    stat = uar_SrvSetLong(ml_hEventPrsnlItem, "updt_cnt", cep.updt_cnt)
    stat = uar_SrvSetShort(ml_hEventPrsnlItem, "updt_applctx_ind", 1)
    stat = uar_SrvSetShort(ml_hEventPrsnlItem, "valid_from_dt_tm_ind", 0)
    stat = uar_SrvSetDate(ml_hEventPrsnlItem, "valid_from_dt_tm", cep.valid_from_dt_tm)
    stat = uar_SrvSetShort(ml_hEventPrsnlItem, "valid_until_dt_tm_ind", 0)
    stat = uar_SrvSetDate(ml_hEventPrsnlItem, "valid_until_dt_tm", cnvtdatetime(curdate,curtime3))
    stat = uar_SrvSetShort(ml_hEventPrsnlItem, "request_dt_tm_ind", 0)
    stat = uar_SrvSetDate(ml_hEventPrsnlItem, "request_dt_tm", cep.request_dt_tm)
    stat = uar_SrvSetShort(ml_hEventPrsnlItem, "action_dt_tm_ind", 0)
    stat = uar_SrvSetDate(ml_hEventPrsnlItem, "action_dt_tm", cep.action_dt_tm)
    stat = uar_SrvSetShort(ml_hEventPrsnlItem, "updt_dt_tm_ind", 0)
    stat = uar_SrvSetDate(ml_hEventPrsnlItem, "updt_dt_tm", cep.updt_dt_tm)
  endif
with nocounter
 
set mi_crmStatus = uar_CrmPerformAs(ml_hStep, "event")
 
if (mi_crmStatus != 0)
  set reply->status_data->subeventstatus[1]->operationstatus = "F"
  set reply->status_data->subeventstatus[1]->targetobjectname
    = concat("CrmPerform err status=", cnvtstring(mi_crmStatus))
  set reply->status_data->subeventstatus[1]->targetobjectvalue = "srvInErrorEvent"
  set reqinfo->commit_ind = FALSE
  go to exit_script
endif
 
set reqinfo->commit_ind = TRUE
set reply->status_data->status = "S"
 
#exit_script
if (ml_hStep > 0)
  call uar_CrmEndReq(ml_hStep)
  set ml_hStep = 0
endif
if (ml_hTask > 0)
  call uar_CrmEndTask(ml_hTask)
  set ml_hTask = 0
endif
if (ml_hApp > 0)
  call uar_CrmEndApp(ml_hApp)
  set ml_hApp = 0
endif
 
end
go
 