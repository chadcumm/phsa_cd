DROP PROGRAM phsa_add_violence_alert GO
CREATE PROGRAM phsa_add_violence_alert
 EXECUTE phsa_lib_logging
 CALL enabledblogging (curprog )
 CALL enableecho (null )
 CALL settracelevel ("LOW" )
 CALL loginfomsg (build (curprog ," executed!" ) )
 CALL echorec (eksdata )
 CALL echorec (reqinfo )
 DECLARE i = i4 WITH protect
 DECLARE templatepos = i4 WITH protect
 SET retval = 100
 SET templatepos = locateval (i ,1 ,size (eksdata->tqual[3 ].qual ,5 ) ,
  "EKS_CE_RESULTA_INCOMING_REQ_L" ,trim (eksdata->tqual[3 ].qual[i ].template_name ,3 ) )
 IF ((((templatepos <= 0.0 ) ) OR ((((eksdata->tqual[3 ].qual[templatepos ].person_id = 0.0 ) ) OR ((
 eksdata->tqual[3 ].qual[templatepos ].task_assay_cd = 0.0 ) )) )) )
  CALL logerrormsg ("eksdata record is missing data!" )
  SET retval = - (1 )
  GO TO exit_script
 ENDIF
 CALL logdebugmsg (build2 ("person_id=" ,eksdata->tqual[3 ].qual[templatepos ].person_id ) )
 CALL logdebugmsg (build2 ("TASK_ASSAY_CD=" ,eksdata->tqual[3 ].qual[templatepos ].task_assay_cd ) )
 DECLARE process_cd = f8 WITH constant (maptaskassaycdtoprocesscd (eksdata->tqual[3 ].qual[
   templatepos ].task_assay_cd ) )
 IF ((process_cd < 0.0 ) )
  CALL logerrormsg ("No process alert was mappable from the task assay cd." )
  SET retval = - (1 )
  GO TO exit_script
 ENDIF
 FREE SET libreq
 RECORD libreq (
   1 person_id = f8
   1 encntr_id = f8
   1 clinic_flag [* ]
     2 flag_cd = f8
     2 remove_ind = i1
   1 process_flag [* ]
     2 flag_cd = f8
     2 remove_ind = i1
   1 disease_flag [* ]
     2 flag_cd = f8
     2 remove_ind = i1
   1 isolation_flag
     2 flag_cd = f8
     2 remove_ind = i1
   1 adts [* ]
     2 trigger = vc
 )
 FREE SET librep
 RECORD librep (
   1 status_ind = i2
   1 event = vc
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET libreq->person_id = eksdata->tqual[3 ].qual[templatepos ].person_id
 CALL alterlist (libreq->process_flag ,1 )
 SET libreq->process_flag[1 ].flag_cd = process_cd
 CALL alterlist (libreq->adts ,1 )
 SET libreq->adts[1 ].trigger = "A31"
 EXECUTE phsa_upt_person_flag WITH replace ("REQUEST" ,libreq ) ,
 replace ("REPLY" ,librep )
 CALL echorec (librep )
 IF ((librep->status_data[1 ].status = "S" ) )
  SET retval = 100
  CALL loginfomsg ("Execution completed with changes committed." )
 ELSEIF ((librep->status_data[1 ].status = "Z" ) )
  SET retval = 0
  CALL loginfomsg ("Execution completed with no changes required." )
 ELSE
  SET retval = - (1 )
  CALL logerrormsg ("ERROR OCCURRED" )
  CALL echorec (librep )
 ENDIF
 SUBROUTINE  (maptaskassaycdtoprocesscd (task_assay_cd =f8 ) =f8 )
  FREE SET process_alert_mapping
  RECORD process_alert_mapping (
    1 qual [* ]
      2 map_from_task_assay_cd = f8
      2 map_to_process_alert_cd = f8
  ) WITH protect
  DECLARE process_alert_cs = i4 WITH constant (19350 ) ,protect
  DECLARE mapping_cnt = i4 WITH constant (1 ) ,protect
  CALL alterlist (process_alert_mapping->qual ,mapping_cnt )
  SET process_alert_mapping->qual[1 ].map_from_task_assay_cd = uar_get_code_by ("DISPLAY_KEY" ,14003
   ,"VIOLENCERISKSCREENACTION" )
  SET process_alert_mapping->qual[1 ].map_to_process_alert_cd = uar_get_code_by ("DISPLAY_KEY" ,
   process_alert_cs ,"VIOLENCERISK" )
  FOR (i = 1 TO mapping_cnt )
   IF ((((process_alert_mapping->qual[i ].map_from_task_assay_cd < 1 ) ) OR ((process_alert_mapping->
   qual[i ].map_to_process_alert_cd < 1 ) )) )
    CALL logerrormsg ("Code value look up failed! Table to follow..." )
    CALL echorec (process_alert_mapping )
    RETURN (- (1 ) )
   ENDIF
  ENDFOR
  DECLARE pos = i4 WITH noconstant (locateval (i ,1 ,mapping_cnt ,task_assay_cd ,
    process_alert_mapping->qual[i ].map_from_task_assay_cd ) ) ,protect
  IF (pos )
   CALL loginfomsg (concat ("The task_assay_cd maps to process_cd " ,build (process_alert_mapping->
      qual[pos ].map_to_process_alert_cd ) ,". Display: " ,uar_get_code_display (
      process_alert_mapping->qual[pos ].map_to_process_alert_cd ) ) )
   RETURN (process_alert_mapping->qual[pos ].map_to_process_alert_cd )
  ELSE
   CALL logerrormsg (concat ("The task_assay_cd " ,build2 (task_assay_cd ) ,
     " was not found in the mapping table" ) )
   RETURN (- (1 ) )
  ENDIF
 END ;Subroutine
#exit_script
 CALL closelog (null )
 IF ((retval = - (1 ) ) )
  EXECUTE pf_adhoc_email "ERROR OCCURRED" ,
  "Please investigate"
 ENDIF
END GO
