/************************************************************************
 *                                                                      *
 *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
 *                              Technology, Inc.                        *
 *       Revision      (c) 1984-2001 Cerner Corporation                 *
 *                                                                      *
 *  Cerner (R) Proprietary Rights Notice:  All rights reserved.         *
 *  This material contains the valuable properties and trade secrets of *
 *  Cerner Corporation of Kansas City, Missouri, United States of       *
 *  America (Cerner), embodying substantial creative efforts and        *
 *  confidential information, ideas and expressions, no part of which   *
 *  may be reproduced or transmitted in any form or by any means, or    *
 *  retained in any storage or retrieval system without the express     *
 *  written permission of Cerner.                                       *
 *                                                                      *
 *  Cerner is a registered mark of Cerner Corporation.                  *
 *                                                                      *
 ************************************************************************
 
          Date Written:       08/01/2017
          Source file name:   phsa_cd_gen_lab_preprocessing
          Object name:        phsa_cd_gen_lab_preprocessing
          Request #:
 
          Product:            Order Management
          Product Team:       Edge Custom Development
          HNA Version:        V500
          CCL Version:
 
          Program purpose:    Populate the CC Provider 1 order detail correctly
 
          Tables read:        requisition
                              dist_req_r
                              distribution
                              line_item
                              object_identifier_index
                              dist_line_detail
                              mm_trans_line
 
          Tables updated:     None
 
          Executing from:     Reporting Portal
 
          Special Notes:      Records that have the updt_id as "Custom, NOLDAP, Supply Chain" will qualify
                              for the audit.
 
 ***************************************************************************************************************************
 *                  GENERATED MODIFICATION CONTROL LOG                                                                     *
 ***************************************************************************************************************************
 *                                                                                                                         *
 *Mod   Date        Engineer              Comment                                                                          *
 *---   --------    --------------------  ---------------------------------------------------------------------------------*
 *000   08/01/2017  Chris Grobbel         Initial Release                                                                  *
 *001   02/07/2022  Chris Grobbel         Do not populate the CC Provider order detail for BCW CARE Program encounters     *
 *002   09/28/2022  Chad Cummings		  Translated from object library, file in cust_script was outdated.  needs compare *
 * 										  with original include location.  B0783 domain version has many more changes.	   *
 *										  cust_script version saved as phsa_cd_gen_lab_preprocessing_nontrans.prg current  *
 * 										  version from:																	   *
 *										  Source=\\Client\C$\Users\cercjg\OneDrive - Cerner Corporation\chris\CST_CD\12776 *
 *003   09/28/2022  Chad Cummings		  Added original Order Id
 ***************************************************************************************************************************
 
 ******************  END OF ALL MODCONTROL BLOCKS  *************************************************************************/
DROP PROGRAM phsa_cd_gen_lab_preprocessing :dba GO
CREATE PROGRAM phsa_cd_gen_lab_preprocessing :dba
 CALL echoxml (request ,"request_pre.xml" )
 IF (NOT (validate (reply ,0 ) ) )
  RECORD reply (
    1 orderchangeflag = i2
    1 orderid = f8
    1 detaillist [* ]
      2 oefieldid = f8
      2 oefieldvalue = f8
      2 oefielddisplayvalue = vc
      2 oefielddttmvalue = dq8
      2 oefieldmeaningid = f8
      2 valuerequiredind = i2
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET modify = predeclare
 SET reply->status_data.status = "F"
 DECLARE cc_provider_oe_field_id = f8 WITH public ,noconstant (0.00 )
 DECLARE cc_provider2_oe_field_id = f8 WITH public ,noconstant (0.00 )
 DECLARE original_order_oe_field_id = f8 WITH public ,noconstant (0.00 )
 DECLARE num = i4 WITH public ,noconstant (0 )
 DECLARE idx = i4 WITH public ,noconstant (0 )
 DECLARE num2 = i4 WITH public ,noconstant (0 )
 DECLARE idx2 = i4 WITH public ,noconstant (0 )
 SELECT INTO "nl:"
  FROM (order_entry_fields o )
  WHERE (o.description = "CC Provider" )
  HEAD REPORT
   cc_provider_oe_field_id = o.oe_field_id
  WITH nocounter ,time = 30
 ;end select
 SELECT INTO "nl:"
  FROM (order_entry_fields o )
  WHERE (o.description = "CC Provider 2" )
  HEAD REPORT
   cc_provider2_oe_field_id = o.oe_field_id
  WITH nocounter ,time = 30
 ;end select
 SELECT INTO "nl:"
  FROM (order_entry_fields o )
  WHERE (o.description = "Original Order Id" )
  HEAD REPORT
   original_order_oe_field_id = o.oe_field_id
  WITH nocounter ,time = 30
 ;end select
 SET idx = 0
 SET idx = locateval (num ,1 ,size (request->detaillist ,5 ) ,cc_provider_oe_field_id ,request->
  detaillist[num ].oefieldid )
 IF ((idx > 0 ) )
  CALL echo (build ("idx = " ,idx ) )
  SET request->detaillist[idx ].oefieldvalue = 0.00
  SELECT INTO "nl:"
   FROM (encounter e )
   PLAN (e
    WHERE (e.encntr_id = request->encntrid )
    AND (e.encntr_id != 0.00 )
    AND (e.loc_facility_cd =
    (SELECT
     cv.code_value
     FROM (code_value cv )
     WHERE (cv.code_set = 220 )
     AND (cdf_meaning = "FACILITY" )
     AND (cv.display_key = "BCWCARE" )
     AND (cv.active_ind = 1 ) ) ) )
   WITH nocounter
  ;end select
  IF ((curqual > 0 ) )
   SET reply->orderchangeflag = 1
   SET reply->orderid = request->orderid
   SET stat = alterlist (reply->detaillist ,(size (reply->detaillist ,5 ) + 1 ) )
   SET reply->detaillist[size (reply->detaillist ,5 ) ].oefieldid = request->detaillist[idx ].
   oefieldid
   SET reply->detaillist[size (reply->detaillist ,5 ) ].oefieldvalue = 0.00
   SET reply->detaillist[size (reply->detaillist ,5 ) ].oefielddisplayvalue = ""
   SET reply->detaillist[size (reply->detaillist ,5 ) ].oefielddttmvalue = request->detaillist[idx ].
   oefielddttmvalue
   SET reply->detaillist[size (reply->detaillist ,5 ) ].oefieldmeaningid = request->detaillist[idx ].
   oefieldmeaningid
   SET reply->detaillist[size (reply->detaillist ,5 ) ].valuerequiredind = request->detaillist[idx ].
   valuerequiredind
  ELSE
   SELECT INTO "nl:"
    FROM (person_prsnl_reltn ppr ),
     (prsnl p )
    PLAN (ppr
     WHERE (ppr.person_id = request->personid )
     AND (ppr.person_prsnl_r_cd =
     (SELECT
      code_value
      FROM (code_value )
      WHERE (code_set = 331 )
      AND (display_key = "PRIMARYCAREPHYSICIAN" )
      AND (active_ind = 1 ) ) )
     AND (ppr.active_ind = 1 )
     AND (ppr.end_effective_dt_tm > sysdate ) )
     JOIN (p
     WHERE (p.person_id = ppr.prsnl_person_id ) )
    HEAD REPORT
     reply->orderchangeflag = 1 ,
     reply->orderid = request->orderid ,
     stat = alterlist (reply->detaillist ,(size (reply->detaillist ,5 ) + 1 ) ) ,
     reply->detaillist[size (reply->detaillist ,5 ) ].oefieldid = request->detaillist[idx ].oefieldid
      ,
     reply->detaillist[size (reply->detaillist ,5 ) ].oefieldvalue = p.person_id ,
     reply->detaillist[size (reply->detaillist ,5 ) ].oefielddisplayvalue = p.name_full_formatted ,
     reply->detaillist[size (reply->detaillist ,5 ) ].oefielddttmvalue = request->detaillist[idx ].
     oefielddttmvalue ,
     reply->detaillist[size (reply->detaillist ,5 ) ].oefieldmeaningid = request->detaillist[idx ].
     oefieldmeaningid ,
     reply->detaillist[size (reply->detaillist ,5 ) ].valuerequiredind = request->detaillist[idx ].
     valuerequiredind
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  SELECT INTO "nl:"
   FROM (encounter e )
   PLAN (e
    WHERE (e.encntr_id = request->encntrid )
    AND (e.encntr_id != 0.00 )
    AND (e.loc_facility_cd =
    (SELECT
     cv.code_value
     FROM (code_value cv )
     WHERE (cv.code_set = 220 )
     AND (cdf_meaning = "FACILITY" )
     AND (cv.display_key = "BCWCARE" )
     AND (cv.active_ind = 1 ) ) ) )
   WITH nocounter
  ;end select
  IF ((curqual > 0 ) )
   GO TO exit_script
  ELSE
   SELECT INTO "nl:"
    FROM (person_prsnl_reltn ppr ),
     (prsnl p )
    PLAN (ppr
     WHERE (ppr.person_id = request->personid )
     AND (ppr.person_prsnl_r_cd =
     (SELECT
      code_value
      FROM (code_value )
      WHERE (code_set = 331 )
      AND (display_key = "PRIMARYCAREPHYSICIAN" )
      AND (active_ind = 1 ) ) )
     AND (ppr.active_ind = 1 )
     AND (ppr.end_effective_dt_tm > sysdate ) )
     JOIN (p
     WHERE (p.person_id = ppr.prsnl_person_id ) )
    HEAD REPORT
     reply->orderchangeflag = 1 ,
     reply->orderid = request->orderid ,
     stat = alterlist (reply->detaillist ,(size (reply->detaillist ,5 ) + 1 ) ) ,
     reply->detaillist[size (reply->detaillist ,5 ) ].oefieldid = cc_provider_oe_field_id ,
     reply->detaillist[size (reply->detaillist ,5 ) ].oefieldvalue = p.person_id ,
     reply->detaillist[size (reply->detaillist ,5 ) ].oefielddisplayvalue = p.name_full_formatted
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET idx = 0
 SET idx = locateval (num ,1 ,size (request->detaillist ,5 ) ,cc_provider2_oe_field_id ,request->
  detaillist[num ].oefieldid )
 IF ((idx > 0 ) )
  CALL echo (build ("idx = " ,idx ) )
  SET request->detaillist[idx ].oefieldvalue = 0.00
  SELECT INTO "nl:"
   FROM (encounter e )
   PLAN (e
    WHERE (e.encntr_id = request->encntrid )
    AND (e.encntr_id != 0.00 )
    AND (e.loc_facility_cd =
    (SELECT
     cv.code_value
     FROM (code_value cv )
     WHERE (cv.code_set = 220 )
     AND (cdf_meaning = "FACILITY" )
     AND (cv.display_key = "BCWCARE" )
     AND (cv.active_ind = 1 ) ) ) )
   WITH nocounter
  ;end select
  IF ((curqual > 0 ) )
   SET reply->orderchangeflag = 1
   SET reply->orderid = request->orderid
   SET stat = alterlist (reply->detaillist ,(size (reply->detaillist ,5 ) + 1 ) )
   SET reply->detaillist[size (reply->detaillist ,5 ) ].oefieldid = request->detaillist[idx ].
   oefieldid
   SET reply->detaillist[size (reply->detaillist ,5 ) ].oefieldvalue = 0.00
   SET reply->detaillist[size (reply->detaillist ,5 ) ].oefielddisplayvalue = ""
   SET reply->detaillist[size (reply->detaillist ,5 ) ].oefielddttmvalue = request->detaillist[idx ].
   oefielddttmvalue
   SET reply->detaillist[size (reply->detaillist ,5 ) ].oefieldmeaningid = request->detaillist[idx ].
   oefieldmeaningid
   SET reply->detaillist[size (reply->detaillist ,5 ) ].valuerequiredind = request->detaillist[idx ].
   valuerequiredind
  ELSE
   SELECT INTO "nl:"
    FROM (code_value_outbound cvo ),
     (encounter e ),
     (prsnl p )
    PLAN (cvo
     WHERE (cvo.code_set = 220 )
     AND (cvo.contributor_source_cd = value (uar_get_code_by ("DISPLAY_KEY" ,73 ,"INSTENTITYINBOX" )
      ) ) )
     JOIN (e
     WHERE (e.loc_nurse_unit_cd = cvo.code_value )
     AND (e.encntr_id = request->encntrid ) )
     JOIN (p
     WHERE (p.person_id = cnvtreal (cvo.alias ) ) )
    HEAD REPORT
     reply->orderchangeflag = 1 ,
     reply->orderid = request->orderid ,
     stat = alterlist (reply->detaillist ,(size (reply->detaillist ,5 ) + 1 ) ) ,
     reply->detaillist[size (reply->detaillist ,5 ) ].oefieldid = request->detaillist[idx ].oefieldid
      ,
     reply->detaillist[size (reply->detaillist ,5 ) ].oefieldvalue = p.person_id ,
     reply->detaillist[size (reply->detaillist ,5 ) ].oefielddisplayvalue = p.name_full_formatted ,
     reply->detaillist[size (reply->detaillist ,5 ) ].oefielddttmvalue = request->detaillist[idx ].
     oefielddttmvalue ,
     reply->detaillist[size (reply->detaillist ,5 ) ].oefieldmeaningid = request->detaillist[idx ].
     oefieldmeaningid ,
     reply->detaillist[size (reply->detaillist ,5 ) ].valuerequiredind = request->detaillist[idx ].
     valuerequiredind
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  SELECT INTO "nl:"
   FROM (encounter e )
   PLAN (e
    WHERE (e.encntr_id = request->encntrid )
    AND (e.encntr_id != 0.00 )
    AND (e.loc_facility_cd =
    (SELECT
     cv.code_value
     FROM (code_value cv )
     WHERE (cv.code_set = 220 )
     AND (cdf_meaning = "FACILITY" )
     AND (cv.display_key = "BCWCARE" )
     AND (cv.active_ind = 1 ) ) ) )
   WITH nocounter
  ;end select
  IF ((curqual > 0 ) )
   GO TO exit_script
  ELSE
   SELECT INTO "nl:"
    FROM (code_value_outbound cvo ),
     (encounter e ),
     (prsnl p )
    PLAN (cvo
     WHERE (cvo.code_set = 220 )
     AND (cvo.contributor_source_cd = value (uar_get_code_by ("DISPLAY_KEY" ,73 ,"INSTENTITYINBOX" )
      ) ) )
     JOIN (e
     WHERE (e.loc_nurse_unit_cd = cvo.code_value )
     AND (e.encntr_id = request->encntrid ) )
     JOIN (p
     WHERE (p.person_id = cnvtreal (cvo.alias ) ) )
    HEAD REPORT
     reply->orderchangeflag = 1 ,
     reply->orderid = request->orderid ,
     stat = alterlist (reply->detaillist ,(size (reply->detaillist ,5 ) + 1 ) ) ,
     reply->detaillist[size (reply->detaillist ,5 ) ].oefieldid = cc_provider2_oe_field_id ,
     reply->detaillist[size (reply->detaillist ,5 ) ].oefieldvalue = p.person_id ,
     reply->detaillist[size (reply->detaillist ,5 ) ].oefielddisplayvalue = p.name_full_formatted
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET idx = 0
 SET idx = locateval (num ,1 ,size (request->detaillist ,5 ) ,original_order_oe_field_id ,request->
  detaillist[num ].oefieldid )
 IF ((idx > 0 ) )
  SET reply->orderchangeflag = 1
  SET reply->orderid = request->orderid
  SET stat = alterlist (reply->detaillist ,(size (reply->detaillist ,5 ) + 1 ) )
  SET reply->detaillist[size (reply->detaillist ,5 ) ].oefieldid = request->detaillist[idx ].
  oefieldid
  SET reply->detaillist[size (reply->detaillist ,5 ) ].oefieldvalue = request->orderid
  SET reply->detaillist[size (reply->detaillist ,5 ) ].oefielddisplayvalue = cnvtstring (request->
   orderid )
  SET reply->detaillist[size (reply->detaillist ,5 ) ].oefielddttmvalue = request->detaillist[idx ].
  oefielddttmvalue
  SET reply->detaillist[size (reply->detaillist ,5 ) ].oefieldmeaningid = request->detaillist[idx ].
  oefieldmeaningid
  SET reply->detaillist[size (reply->detaillist ,5 ) ].valuerequiredind = request->detaillist[idx ].
  valuerequiredind
 ELSE
  SET reply->orderchangeflag = 1
  SET reply->orderid = request->orderid
  SET stat = alterlist (reply->detaillist ,(size (reply->detaillist ,5 ) + 1 ) )
  SET reply->detaillist[size (reply->detaillist ,5 ) ].oefieldid = original_order_oe_field_id
  SET reply->detaillist[size (reply->detaillist ,5 ) ].oefieldvalue = request->orderid
  SET reply->detaillist[size (reply->detaillist ,5 ) ].oefielddisplayvalue = cnvtstring (request->
   orderid )
  SET reply->detaillist[size (reply->detaillist ,5 ) ].oefieldmeaningid = 1561
  SET reply->detaillist[size (reply->detaillist ,5 ) ].valuerequiredind = 1
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 SET modify = nopredeclare
 CALL echorecord (reply )
 CALL echoxml (reply ,"reply_pre.xml" )
END GO
