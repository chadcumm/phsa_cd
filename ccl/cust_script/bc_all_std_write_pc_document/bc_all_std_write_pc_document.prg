/***********************************************************************************************************************
  Program Name:       	bc_all_std_write_pc_document
  Source File Name:   	bc_all_std_write_pc_document.prg
  Program Written By: 	John Simpson
  Date:  			  	31-May-2021
  Program Purpose:   	Simple utility to write document to Powerchart
 
  Usage Instructions.
 
  call saveDocument(encntr_id, event_cd, content, mode)
 
  Valid values for mode are:
 
  0 - Update if encntr_id + event_cd combination found
  1 - Create new document every run
 
************************************************************************************************************************
												*MODIFICATION HISTORY*
************************************************************************************************************************
 
Rev  Date         Jira       Programmer             Comment
---  -----------  ---------  ---------------------  --------------------------------------------------------------------
000  26-May-2021  CST-96425  John Simpson           Created
***********************************************************************************************************************/
 
drop program bc_all_std_write_pc_document:dba go
create program bc_all_std_write_pc_document:dba
 
declare saveDocument(nEncntrId = f8, cDDTemplateDesc= vc, nEventCd = f8, cTitle = vc,
                        cContent = vc, nMode = i4) = null with copy, persist
 
; Assign required code values
declare cv8_Auth = f8 with noconstant(uar_get_code_by("MEANING", 8, "AUTH")), persist
declare cv8_Modified = f8 with noconstant(uar_get_code_by("MEANING", 8, "MODIFIED")), persist
declare cv8_InProgress = f8 with noconstant(uar_get_code_by("MEANING", 8, "IN PROGRESS")), persist
 
subroutine saveDocument(nEncntrId, cDDTemplateDesc, nEventCd, cTitle, cContent, nMode)
    declare nNewDocInd = i4 with noconstant(0)
 
    ; 969503 - Open Existing Document
    free record request
    record request (
        1 mdoc_event_id         = f8
        1 sessions [*]
            2 dd_session_id     = f8
        1 read_only_flag        = i4
        1 revise_flag           = i2
    )
 
 
    ; ----------------------------------------------------------------
    ; Perform a check to see if document exists and load it if it does
    ; ----------------------------------------------------------------
    if (nMode = 0 and nEncntrId > 0.0 and nEventCd > 0.0)
        ; 969503 - Open Existing Document
        free record reply
        record reply (
            1 document
                2 attribute
                    3 author_id = f8
                    3 doc_status_cd = f8
                    3 encounter_id = f8
                    3 event_cd = f8
                    3 mdoc_event_id = f8
                    3 person_id = f8
                    3 service_dt_tm = dq8
                    3 service_tz = i4
                    3 title_text = vc
                    3 workflow_id = f8
                    3 valid_from_dt_tm = dq8
                2 contributions [*]
                    3 attribute
                        4 author_id = f8
                        4 contribution_id = f8
                        4 contribution_status_cd = f8
                        4 dd_session_id = f8
                        4 event_cd = f8
                        4 doc_event_id = f8
                        4 session_user_id = f8
                        4 session_dt_tm = dq8
                        4 title_text = vc
                        4 updt_id = f8
                        4 uptd_dt_tm = dq8
                        4 sequence_val = vc
                    3 html_text = gvc
                2 signers [*]
                    3 attribute
                        4 id = f8
                        4 type_cd = f8
                        4 action_dt = dq8
                        4 action_tz = i4
                        4 provider_id = f8
                        4 status_cd = f8
                2 reviewers [*]
                    3 attribute
                        4 id = f8
                        4 type_cd = f8
                        4 action_dt = dq8
                        4 action_tz = i4
                        4 provider_id = f8
                        4 status_cd = f8
            1 status_data
                2 status = c1
                2 subeventstatus [*]
                    3 OperationName = c25
                    3 OperationStatus = c1
                    3 TargetObjectName = c50
                    3 TargetObjectValue = vc
        )
 
 
        ; Search for the document
        select into "nl:"
        from clinical_event     ce
        plan ce
            where ce.encntr_id = nEncntrId
            and ce.event_cd = nEventCd
            and ce.view_level = 1
            and ce.valid_until_dt_tm > sysdate
            and ce.result_status_cd in (cv8_Auth, cv8_Modified, cv8_InProgress)
        detail
            request->mdoc_event_id = ce.event_id
            request->revise_flag = 0
        with counter
 
        if (request->mdoc_event_id > 0.0)
            set stat = tdbExecute(600005, 3202004, 969503, "REC", request, "REC", reply, 0)
        endif
 
    endif
 
    ; ------------------------------------------------------------------------------------
    ; If no document found or new document requested with mode flag, initiate new document
    ; ------------------------------------------------------------------------------------
    if (request->mdoc_event_id = 0.0 and nEncntrId > 0.0)
        ; 969500 - Open New Document
        free record request
        record request (
            1 patient_id = f8
            1 encounter_id = f8
            1 dd_ref_template_id = f8
        )
 
        ; 969500 - Open New Document
        free record reply
        record reply (
            1 document
                2 attribute
                    3 author_id = f8
                    3 doc_status_cd = f8
                    3 encounter_id = f8
                    3 event_cd = f8
                    3 mdoc_event_id = f8
                    3 person_id = f8
                    3 service_dt_tm = dq8
                    3 service_tz = i4
                    3 title_text = vc
                    3 workflow_id = f8
                    3 valid_from_dt_tm = dq8
                2 contributions [*]
                    3 attribute
                        4 author_id = f8
                        4 contribution_id = f8
                        4 contribution_status_cd = f8
                        4 dd_session_id = f8
                        4 event_cd = f8
                        4 doc_event_id = f8
                        4 session_user_id = f8
                        4 session_dt_tm = dq8
                        4 title_text = vc
                        4 updt_id = f8
                        4 uptd_dt_tm = dq8
                        4 sequence_val = vc
                    3 html_text = gvc
                2 signers [*]
                    3 attribute
                        4 id = f8
                        4 type_cd = f8
                        4 action_dt = dq8
                        4 action_tz = i4
                        4 provider_id = f8
                        4 status_cd = f8
                2 reviewers [*]
                    3 attribute
                        4 id = f8
                        4 type_cd = f8
                        4 action_dt = dq8
                        4 action_tz = i4
                        4 provider_id = f8
                        4 status_cd = f8
            1 status_data
                2 status = c1
                2 subeventstatus [*]
                    3 OperationName = c25
                    3 OperationStatus = c1
                    3 TargetObjectName = c50
                    3 TargetObjectValue = vc
            1 tagged_entities [*]
                2 emr_type_cd = f8
                2 entity_ids [*]
                    3 id = f8
        )
 
        ; Collect the template Id
        select into "nl:"
        from    dd_ref_template     r
        plan r
            where r.description_txt = cDDTemplateDesc
            and r.active_ind = 1
        detail
            request->dd_ref_template_id = r.dd_ref_template_id
        with counter
 
        ; Populate the patient data
        select into "nl:"
        from    encounter   e
        plan e
            where e.encntr_id = nEncntrId
        detail
            request->encounter_id = e.encntr_id
            request->patient_id = e.person_id
        with counter
 
        if (request->dd_ref_template_id > 0.0)
            set stat = tdbExecute(600005, 3202004, 969500, "REC", request, "REC", reply, 0)
        endif
 
        ; Flag New document indicator
        if (reply->document->attribute->encounter_id > 0.0)
            set nNewDocInd = 1
        else
            set nNewDocInd = -1
        endif
    endif
 
    ; ------------------------------------------
    ; Perform the document write (new or update)
    ; ------------------------------------------
    if (nNewDocInd >= 0 and reply->document->attribute->encounter_id > 0.0)
        ; 969502 - Save Document
        free record request
        record request (
            1 action_tz = i4
            1 author_id = f8
            1 encounter_id = f8
            1 event_cd = f8
            1 patient_id = f8
            1 mdoc_event_id = f8
            1 current_doc_status_cd = f8
            1 service_dt_tm = dq8
            1 service_tz = i4
            1 title_text = vc
            1 unlock_flag = i4
            1 ppr_cd = i4
            1 wkf_workflow_id = f8
            1 contributions [*]
                2 author_id = f8
                2 dd_contribution_id = f8
                2 dd_session_id = f8
                2 doc_event_id = f8
                2 event_cd = f8
                2 html_text = gvc
                2 title_text = vc
                2 ensure_type = i4
            1 pat_prsnl_reltn_cd = f8
            1 excluded_extract_ids [*]
                2 extract_uuid = vc
                2 excluded_ids [*]
                    3 content_type_mean = vc
                    3 ids [*]
                        4 id = f8
            1 reference_dqr = vc
            1 signers [*]
                2 provider_id = f8
                2 cancel_ind = i2
                2 comment = vc
            1 reviewers [*]
                2 provider_id = f8
                2 cancel_ind = i2
                2 comment = vc
            1 structure_section_components [*]
                2 entry_mode_mean = c12
                2 activity_json = gvc
            1 user_id = f8
        )
 
        call echo("Initial reply")
        call echorecord(reply)
 
        ; Populate the request structure
        set request->action_tz = curtimezoneapp
        set request->author_id = reqinfo->updt_id
        set request->encounter_id = reply->document->attribute.encounter_id
        set request->patient_id = reply->document->attribute.person_id
        set request->service_dt_tm = cnvtdatetime(sysdate)
        set request->service_tz = curtimezoneapp
        set request->title_text = cTitle
        set request->unlock_flag = 1
 
        set stat = alterlist(request->contributions, 1)
 
        set request->contributions[1].author_id = reqinfo->updt_id
        set request->contributions[1].html_text = cContent
        set request->contributions[1].title_text = cTitle
        set request->contributions[1].ensure_type = 2   ; Set status of Auth (Verified)
 
        if (nNewDocInd = 1)
            call echo("New Document")
 
            set request->event_cd = nEventCd
            set request->contributions[1].dd_contribution_id = reply->document->contributions->attribute.contribution_id
            set request->contributions[1].dd_session_id = reply->document->contributions->attribute.dd_session_id
            set request->contributions[1].doc_event_id = reply->document->contributions->attribute.doc_event_id
            set request->contributions[1].event_cd = nEventCd
 
        else
            set request->event_cd = reply->document->attribute.event_cd
            set request->mdoc_event_id = reply->document->attribute.mdoc_event_id
            set request->current_doc_status_cd = reply->document->attribute.doc_status_cd
            set request->wkf_workflow_id = reply->document->attribute.workflow_id
            set request->contributions[1].dd_contribution_id = reply->document->contributions[1]->attribute.contribution_id
            set request->contributions[1].dd_session_id = reply->document->contributions[1]->attribute.dd_session_id
            set request->contributions[1].doc_event_id = reply->document->contributions[1]->attribute.doc_event_id
            set request->contributions[1].event_cd = reply->document->contributions[1]->attribute.event_cd
        endif
 
        ; 969502 - Save Document
        free record reply
        record reply (
            1 mdoc_event_id = f8
            1 doc_status_cd = f8
            1 contributions [*]
                2 dd_contribution_id = f8
                2 doc_event_id = f8
            1 components [*]
                2 concept = vc
                2 event_id = f8
                2 version = i4
                2 concept_cki = vc
            1 status_data
                2 status = c1
                2 subeventstatus [*]
                    3 OperationName = c25
                    3 OperationStatus = c1
                    3 TargetObjectName = c50
                    3 TargetObjectValue = vc
        )
 
        set stat = tdbExecute(600005, 3202004, 969502, "REC", request, "REC", reply, 0)
 
        call echorecord(reply)
    endif
 
end
 
end go
