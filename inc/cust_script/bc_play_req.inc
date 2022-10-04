 
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
 
 
free set req_request
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
 
free set temp_req_request
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
 
free record mmf_store_reply
record mmf_store_reply
(
   1 identifier = vc ; unique identifier if successfully stored
%i cclsource:status_block.inc
)
free set mmf_store_request
record mmf_store_request
(
   1 filename = vc
   1 contentType = vc
   1 mediaType = vc
   1 name = vc
   1 personId = f8
   1 encounterId = f8
)
 
free set mmf_publish_ce_request
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
 
free set mmf_publish_ce_reply
record mmf_publish_ce_reply (
	1 parentEventId = f8
%i cclsource:status_block.inc
)
 
free set 560300_request
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
 
free set 560300_reply
record 560300_reply
( 1 result
    2 task_status = c1
    2 task_id = f8
    2 assign_prsnl_list[*]
      3 assign_prsnl_id = f8
%i cclsource:status_block.inc
)
 
free record ensure_request
free record ensure_reply
 
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
free record ensure_reply
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
 
free record dcp_request
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
