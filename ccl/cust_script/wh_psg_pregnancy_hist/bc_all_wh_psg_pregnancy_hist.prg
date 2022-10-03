/***********************************************************************************************************************
  Program Name:			wh_psg_pregnancy_hist
  Source File Name:		bc_all_wh_psg_pregnancy_hist.prg
  Layout File Name:		N/A
  Program Written By:	
  Date:					
  Program Purpose:		
 
************************************************************************************************************************
												*MODIFICATION HISTORY*
************************************************************************************************************************
 
Rev	Date		Jira		Programmer				Comment
---	-----------	----------	---------------------	----------------------------------------------------------
000 05-JUL-2022 CST-162564	Chad Cummings			Copied from wh_psg_pregnancy_hist and updated	 
***********************************************************************************************************************/

DROP PROGRAM wh_psg_pregnancy_hist :dba GO
CREATE PROGRAM wh_psg_pregnancy_hist :dba
 IF (NOT (validate (rhead ,0 ) ) )
  SET rhead = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}"
  SET rhead_colors1 = "{\colortbl;\red0\green0\blue0;\red255\green255\blue255;"
  SET rhead_colors2 = "\red99\green99\blue99;\red22\green107\blue178;"
  SET rhead_colors3 = "\red0\green0\blue255;\red123\green193\blue67;\red255\green0\blue0;}"
  SET reol = "\par "
  SET rtab = "\tab "
  SET wr = "\plain \f0 \fs16 \cb2 "
  SET wr11 = "\plain \f0 \fs11 \cb2 "
  SET wr18 = "\plain \f0 \fs18 \cb2 "
  SET wr20 = "\plain \f0 \fs20 \cb2 "
  SET wu = "\plain \f0 \fs16 \ul \cb2 "
  SET wb = "\plain \f0 \fs16 \b \cb2 "
  SET wbu = "\plain \f0 \fs16 \b \ul \cb2 "
  SET wi = "\plain \f0 \fs16 \i \cb2 "
  SET ws = "\plain \f0 \fs16 \strike \cb2"
  SET wb2 = "\plain \f0 \fs18 \b \cb2 "
  SET wb18 = "\plain \f0 \fs18 \b \cb2 "
  SET wb20 = "\plain \f0 \fs20 \b \cb2 "
  SET rsechead = "\plain \f0 \fs28 \b \ul \cb2 "
  SET rsubsechead = "\plain \f0 \fs22 \b \cb2 "
  SET rsecline = "\plain \f0 \fs20 \b \cb2 "
  SET hi = "\pard\fi-2340\li2340 "
  SET rtfeof = "}"
  SET wbuf26 = "\plain \f0 \fs26 \b \ul \cb2 "
  SET wbuf30 = "\plain \f0 \fs30 \b \ul \cb2 "
  SET rpard = "\pard "
  SET rtitle = "\plain \f0 \fs36 \b \cb2 "
  SET rpatname = "\plain \f0 \fs38 \b \cb2 "
  SET rtabstop1 = "\tx300"
  SET rtabstopnd = "\tx400"
  SET wsd = "\plain \f0 \fs13 \cb2 "
  SET wsb = "\plain \f0 \fs13 \b \cb2 "
  SET wrs = "\plain \f0 \fs14 \cb2 "
  SET wbs = "\plain \f0 \fs14 \b \cb2 "
  DECLARE snot_documented = vc WITH public ,constant ("--" )
  SET color0 = "\cf0 "
  SET colorgrey = "\cf3 "
  SET colornavy = "\cf4 "
  SET colorblue = "\cf5 "
  SET colorgreen = "\cf6 "
  SET colorred = "\cf7 "
  SET row_start = "\trowd"
  SET row_end = "\row"
  SET cell_start = "\intbl "
  SET cell_end = "\cell"
  SET cell_text_center = "\qc "
  SET cell_text_left = "\ql "
  SET cell_border_top = "\clbrdrt\brdrt\brdrw1"
  SET cell_border_left = "\clbrdrl\brdrl\brdrw1"
  SET cell_border_bottom = "\clbrdrb\brdrb\brdrw1"
  SET cell_border_right = "\clbrdrr\brdrr\brdrw1"
  SET cell_border_top_left = "\clbrdrt\brdrt\brdrw1\clbrdrl\brdrl\brdrw1"
  SET block_start = "{"
  SET block_end = "}"
 ENDIF
 IF ((validate (i18nuar_def ,999 ) = 999 ) )
  CALL echo ("Declaring i18nuar_def" )
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit ((p1 = i4 ) ,(p2 = vc ) ,(p3 = vc ) ,(p4 = f8 ) ) = i4 WITH
  persist
  DECLARE uar_i18ngetmessage ((p1 = i4 ) ,(p2 = vc ) ,(p3 = vc ) ) = vc WITH persist
  DECLARE uar_i18nbuildmessage () = vc WITH persist
  DECLARE uar_i18ngethijridate ((imonth = i2 (val ) ) ,(iday = i2 (val ) ) ,(iyear = i2 (val ) ) ,(
   sdateformattype = vc (ref ) ) ) = c50 WITH image_axp = "shri18nuar" ,image_aix =
  "libi18n_locale.a(libi18n_locale.o)" ,uar = "uar_i18nGetHijriDate" ,persist
  DECLARE uar_i18nbuildfullformatname ((sfirst = vc (ref ) ) ,(slast = vc (ref ) ) ,(smiddle = vc (
    ref ) ) ,(sdegree = vc (ref ) ) ,(stitle = vc (ref ) ) ,(sprefix = vc (ref ) ) ,(ssuffix = vc (
    ref ) ) ,(sinitials = vc (ref ) ) ,(soriginal = vc (ref ) ) ) = c250 WITH image_axp =
  "shri18nuar" ,image_aix = "libi18n_locale.a(libi18n_locale.o)" ,uar = "i18nBuildFullFormatName" ,
  persist
  DECLARE uar_i18ngetarabictime ((ctime = vc (ref ) ) ) = c20 WITH image_axp = "shri18nuar" ,
  image_aix = "libi18n_locale.a(libi18n_locale.o)" ,uar = "i18n_GetArabicTime" ,persist
 ENDIF
 IF (NOT (validate (i18nhandle ) ) )
  DECLARE i18nhandle = i4 WITH protect ,noconstant (0 )
 ENDIF
 SET stat = uar_i18nlocalizationinit (i18nhandle ,curprog ,"" ,curcclrev )
 DECLARE stand_alone_ind = i4 WITH protect ,noconstant (0 )
 IF (NOT (validate (request->person[1 ].pregnancy_list ) ) )
  SET stand_alone_ind = 1
 ENDIF
 DECLARE whorgsecpref = i2 WITH protect ,noconstant (0 )
 DECLARE prsnl_override_flag = i2 WITH protect ,noconstant (0 )
 IF (NOT (validate (preg_org_sec_ind ) ) )
  DECLARE preg_org_sec_ind = i4 WITH noconstant (0 ) ,public
 ENDIF
 DECLARE os_idx = i4 WITH noconstant (0 )
 IF (NOT (validate (encntr_list ) ) )
  FREE RECORD encntr_list
  RECORD encntr_list (
    1 cnt = i4
    1 qual [* ]
      2 value = f8
  )
 ENDIF
 DECLARE en_idx = i4 WITH public ,noconstant (0 )
 IF ((validate (antepartum_run_ind ) = 0 ) )
  DECLARE antepartum_run_ind = i4 WITH public ,noconstant (0 )
 ENDIF
 IF (NOT (validate (whsecuritydisclaim ) ) )
  DECLARE whsecuritydisclaim = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap99" ,
    "(Report contains only data from encounters at associated organizations)" ) )
 ENDIF
 IF (NOT (validate (whcaosecuritydisclaim ) ) )
  DECLARE whcaosecuritydisclaim = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap199"
    ,"(Report contains only data from encounters at associated organizations and care units)" ) )
 ENDIF
 IF (NOT (validate (preg_sec_orgs ) ) )
  FREE RECORD preg_sec_orgs
  RECORD preg_sec_orgs (
    1 qual [* ]
      2 org_id = f8
      2 confid_level = i4
  )
 ENDIF
 DECLARE getpersonneloverride ((person_id = f8 (val ) ) ,(prsnl_id = f8 (val ) ) ) = i2 WITH protect
 DECLARE getpreferences () = i2 WITH protect
 DECLARE getorgsecurity () = null WITH protect
 DECLARE loadorganizationsecuritylist () = null
 DECLARE loadencounterlistforcao ((person_id = f8 (val ) ) ,(cao_flag = i2 (ref ) ) ) = null
 IF ((((validate (honor_org_security_flag ) = 0 ) ) OR ((validate (chart_access_flag ) = 0 ) )) )
  DECLARE honor_org_security_flag = i2 WITH public ,noconstant (0 )
  DECLARE chart_access_flag = i2 WITH public ,noconstant (0 )
  SET whorgsecpref = getpreferences (null )
  CALL getorgsecurity (null )
  SET prsnl_override_flag = getpersonneloverride (request->person[1 ].person_id ,reqinfo->updt_id )
  IF ((preg_org_sec_ind = 1 )
  AND (whorgsecpref = 1 ) )
   CALL loadencounterlistforcao (request->person[1 ].person_id ,chart_access_flag )
   IF ((((chart_access_flag = 1 ) ) OR ((prsnl_override_flag = 0 ) )) )
    SET honor_org_security_flag = 1
   ENDIF
  ENDIF
 ELSEIF ((encntr_list->cnt = 0 ) )
  CALL loadencounterlistforcao (request->person[1 ].person_id ,chart_access_flag )
 ENDIF
 SUBROUTINE  getpersonneloverride (person_id ,prsnl_id )
  CALL echo (build ("person_id=" ,person_id ) )
  CALL echo (build ("prsnl_id=" ,prsnl_id ) )
  DECLARE override_ind = i2 WITH protect ,noconstant (0 )
  IF ((((person_id <= 0.0 ) ) OR ((prsnl_id <= 0.0 ) )) )
   RETURN (0 )
  ENDIF
  SELECT INTO "nl:"
   FROM (person_prsnl_reltn ppr ),
    (code_value_extension cve )
   PLAN (ppr
    WHERE (ppr.prsnl_person_id = prsnl_id )
    AND (ppr.active_ind = 1 )
    AND ((ppr.person_id + 0 ) = person_id )
    AND (ppr.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (ppr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
    JOIN (cve
    WHERE (cve.code_value = ppr.person_prsnl_r_cd )
    AND (cve.code_set = 331 )
    AND (((cve.field_value = "1" ) ) OR ((cve.field_value = "2" ) ))
    AND (cve.field_name = "Override" ) )
   DETAIL
    override_ind = 1
   WITH nocounter
  ;end select
  RETURN (override_ind )
 END ;Subroutine
 SUBROUTINE  getpreferences (null )
  DECLARE powerchart_app_number = i4 WITH protect ,constant (600005 )
  DECLARE spreferencename = vc WITH protect ,constant ("PREGNANCY_SMART_TMPLT_ORG_SEC" )
  DECLARE prefvalue = vc WITH noconstant ("0" ) ,protect
  SELECT INTO "nl:"
   FROM (app_prefs ap ),
    (name_value_prefs nvp )
   PLAN (ap
    WHERE (ap.prsnl_id = 0.0 )
    AND (ap.position_cd = 0.0 )
    AND (ap.application_number = powerchart_app_number ) )
    JOIN (nvp
    WHERE (nvp.parent_entity_name = "APP_PREFS" )
    AND (nvp.parent_entity_id = ap.app_prefs_id )
    AND (trim (nvp.pvc_name ,3 ) = cnvtupper (spreferencename ) ) )
   DETAIL
    prefvalue = nvp.pvc_value
   WITH nocounter
  ;end select
  RETURN (cnvtint (prefvalue ) )
 END ;Subroutine
 SUBROUTINE  getorgsecurity (null )
  SELECT INTO "nl:"
   FROM (dm_info d1 )
   WHERE (d1.info_domain = "SECURITY" )
   AND (d1.info_name = "SEC_ORG_RELTN" )
   AND (d1.info_number = 1 )
   DETAIL
    preg_org_sec_ind = 1
   WITH nocounter
  ;end select
  CALL echo (build ("org_sec_ind=" ,preg_org_sec_ind ) )
  IF ((preg_org_sec_ind = 1 ) )
   CALL loadorganizationsecuritylist (null )
  ENDIF
 END ;Subroutine
 SUBROUTINE  loadorganizationsecuritylist (null )
  DECLARE org_cnt = i2 WITH noconstant (0 )
  DECLARE stat = i2 WITH protect ,noconstant (0 )
  IF ((validate (sac_org ) = 1 ) )
   FREE RECORD sac_org
  ENDIF
  IF ((validate (_sacrtl_org_inc_ ,99999 ) = 99999 ) )
   DECLARE _sacrtl_org_inc_ = i2 WITH constant (1 )
   RECORD sac_org (
     1 organizations [* ]
       2 organization_id = f8
       2 confid_cd = f8
       2 confid_level = i4
   )
   EXECUTE secrtl
   EXECUTE sacrtl
   DECLARE orgcnt = i4 WITH protected ,noconstant (0 )
   DECLARE secstat = i2
   DECLARE logontype = i4 WITH protect ,noconstant (- (1 ) )
   DECLARE dynamic_org_ind = i4 WITH protect ,noconstant (- (1 ) )
   DECLARE dcur_trustid = f8 WITH protect ,noconstant (0.0 )
   DECLARE dynorg_enabled = i4 WITH constant (1 )
   DECLARE dynorg_disabled = i4 WITH constant (0 )
   DECLARE logontype_nhs = i4 WITH constant (1 )
   DECLARE logontype_legacy = i4 WITH constant (0 )
   DECLARE confid_cnt = i4 WITH protected ,noconstant (0 )
   RECORD confid_codes (
     1 list [* ]
       2 code_value = f8
       2 coll_seq = f8
   )
   CALL uar_secgetclientlogontype (logontype )
   CALL echo (build ("logontype:" ,logontype ) )
   IF ((logontype != logontype_nhs ) )
    SET dynamic_org_ind = dynorg_disabled
   ENDIF
   IF ((logontype = logontype_nhs ) )
    DECLARE getdynamicorgpref ((dtrustid = f8 ) ) = i4
    SUBROUTINE  getdynamicorgpref (dtrustid )
     DECLARE scur_trust = vc
     DECLARE pref_val = vc
     DECLARE is_enabled = i4 WITH constant (1 )
     DECLARE is_disabled = i4 WITH constant (0 )
     SET scur_trust = cnvtstring (dtrustid )
     SET scur_trust = concat (scur_trust ,".00" )
     IF (NOT (validate (pref_req ,0 ) ) )
      RECORD pref_req (
        1 write_ind = i2
        1 delete_ind = i2
        1 pref [* ]
          2 contexts [* ]
            3 context = vc
            3 context_id = vc
          2 section = vc
          2 section_id = vc
          2 subgroup = vc
          2 entries [* ]
            3 entry = vc
            3 values [* ]
              4 value = vc
      )
     ENDIF
     IF (NOT (validate (pref_rep ,0 ) ) )
      RECORD pref_rep (
        1 pref [* ]
          2 section = vc
          2 section_id = vc
          2 subgroup = vc
          2 entries [* ]
            3 pref_exists_ind = i2
            3 entry = vc
            3 values [* ]
              4 value = vc
        1 status_data
          2 status = c1
          2 subeventstatus [1 ]
            3 operationname = c25
            3 operationstatus = c1
            3 targetobjectname = c25
            3 targetobjectvalue = vc
      )
     ENDIF
     SET stat = alterlist (pref_req->pref ,1 )
     SET stat = alterlist (pref_req->pref[1 ].contexts ,2 )
     SET stat = alterlist (pref_req->pref[1 ].entries ,1 )
     SET pref_req->pref[1 ].contexts[1 ].context = "organization"
     SET pref_req->pref[1 ].contexts[1 ].context_id = scur_trust
     SET pref_req->pref[1 ].contexts[2 ].context = "default"
     SET pref_req->pref[1 ].contexts[2 ].context_id = "system"
     SET pref_req->pref[1 ].section = "workflow"
     SET pref_req->pref[1 ].section_id = "UK Trust Security"
     SET pref_req->pref[1 ].entries[1 ].entry = "dynamic organizations"
     EXECUTE ppr_preferences WITH replace ("REQUEST" ,"PREF_REQ" ) ,
     replace ("REPLY" ,"PREF_REP" )
     IF ((cnvtupper (pref_rep->pref[1 ].entries[1 ].values[1 ].value ) = "ENABLED" ) )
      RETURN (is_enabled )
     ELSE
      RETURN (is_disabled )
     ENDIF
    END ;Subroutine
    DECLARE hprop = i4 WITH protect ,noconstant (0 )
    DECLARE tmpstat = i2
    DECLARE spropname = vc
    DECLARE sroleprofile = vc
    SET hprop = uar_srvcreateproperty ()
    SET tmpstat = uar_secgetclientattributesext (5 ,hprop )
    SET spropname = uar_srvfirstproperty (hprop )
    SET sroleprofile = uar_srvgetpropertyptr (hprop ,nullterm (spropname ) )
    SELECT INTO "nl:"
     FROM (prsnl_org_reltn_type prt ),
      (prsnl_org_reltn por )
     PLAN (prt
      WHERE (prt.role_profile = sroleprofile )
      AND (prt.active_ind = 1 )
      AND (prt.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
      AND (prt.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
      JOIN (por
      WHERE (outerjoin (prt.organization_id ) = por.organization_id )
      AND (por.person_id = outerjoin (prt.prsnl_id ) )
      AND (por.active_ind = outerjoin (1 ) )
      AND (por.beg_effective_dt_tm <= outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
      AND (por.end_effective_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) ) )
     ORDER BY por.prsnl_org_reltn_id
     DETAIL
      orgcnt = 1 ,
      secstat = alterlist (sac_org->organizations ,1 ) ,
      user_person_id = prt.prsnl_id ,
      sac_org->organizations[1 ].organization_id = prt.organization_id ,
      sac_org->organizations[1 ].confid_cd = por.confid_level_cd ,
      confid_cd = uar_get_collation_seq (por.confid_level_cd ) ,
      sac_org->organizations[1 ].confid_level =
      IF ((confid_cd > 0 ) ) confid_cd
      ELSE 0
      ENDIF
     WITH maxrec = 1
    ;end select
    SET dcur_trustid = sac_org->organizations[1 ].organization_id
    SET dynamic_org_ind = getdynamicorgpref (dcur_trustid )
    CALL uar_srvdestroyhandle (hprop )
   ENDIF
   IF ((dynamic_org_ind = dynorg_disabled ) )
    SET confid_cnt = 0
    SELECT INTO "NL:"
     c.code_value ,
     c.collation_seq
     FROM (code_value c )
     WHERE (c.code_set = 87 )
     DETAIL
      confid_cnt = (confid_cnt + 1 ) ,
      IF ((mod (confid_cnt ,10 ) = 1 ) ) secstat = alterlist (confid_codes->list ,(confid_cnt + 9 )
        )
      ENDIF
      ,confid_codes->list[confid_cnt ].code_value = c.code_value ,
      confid_codes->list[confid_cnt ].coll_seq = c.collation_seq
     WITH nocounter
    ;end select
    SET secstat = alterlist (confid_codes->list ,confid_cnt )
    SELECT DISTINCT INTO "nl:"
     FROM (prsnl_org_reltn por )
     WHERE (por.person_id = reqinfo->updt_id )
     AND (por.active_ind = 1 )
     AND (por.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
     AND (por.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
     HEAD REPORT
      IF ((orgcnt > 0 ) ) secstat = alterlist (sac_org->organizations ,100 )
      ENDIF
     DETAIL
      orgcnt = (orgcnt + 1 ) ,
      IF ((mod (orgcnt ,100 ) = 1 ) ) secstat = alterlist (sac_org->organizations ,(orgcnt + 99 ) )
      ENDIF
      ,sac_org->organizations[orgcnt ].organization_id = por.organization_id ,
      sac_org->organizations[orgcnt ].confid_cd = por.confid_level_cd
     FOOT REPORT
      secstat = alterlist (sac_org->organizations ,orgcnt )
     WITH nocounter
    ;end select
    SELECT INTO "NL:"
     FROM (dummyt d1 WITH seq = value (orgcnt ) ),
      (dummyt d2 WITH seq = value (confid_cnt ) )
     PLAN (d1 )
      JOIN (d2
      WHERE (sac_org->organizations[d1.seq ].confid_cd = confid_codes->list[d2.seq ].code_value ) )
     DETAIL
      sac_org->organizations[d1.seq ].confid_level = confid_codes->list[d2.seq ].coll_seq
     WITH nocounter
    ;end select
   ELSEIF ((dynamic_org_ind = dynorg_enabled ) )
    DECLARE nhstrustchild_org_org_reltn_cd = f8
    SET nhstrustchild_org_org_reltn_cd = uar_get_code_by ("MEANING" ,369 ,"NHSTRUSTCHLD" )
    SELECT INTO "nl:"
     FROM (org_org_reltn oor )
     PLAN (oor
      WHERE (oor.organization_id = dcur_trustid )
      AND (oor.active_ind = 1 )
      AND (oor.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
      AND (oor.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
      AND (oor.org_org_reltn_cd = nhstrustchild_org_org_reltn_cd ) )
     HEAD REPORT
      IF ((orgcnt > 0 ) ) secstat = alterlist (sac_org->organizations ,10 )
      ENDIF
     DETAIL
      IF ((oor.related_org_id > 0 ) ) orgcnt = (orgcnt + 1 ) ,
       IF ((mod (orgcnt ,10 ) = 1 ) ) secstat = alterlist (sac_org->organizations ,(orgcnt + 9 ) )
       ENDIF
       ,sac_org->organizations[orgcnt ].organization_id = oor.related_org_id
      ENDIF
     FOOT REPORT
      secstat = alterlist (sac_org->organizations ,orgcnt )
     WITH nocounter
    ;end select
   ELSE
    CALL echo (build ("Unexpected login type: " ,dynamimc_org_ind ) )
   ENDIF
  ENDIF
  SET org_cnt = size (sac_org->organizations ,5 )
  CALL echo (build ("org_cnt: " ,org_cnt ) )
  SET stat = alterlist (preg_sec_orgs->qual ,(org_cnt + 1 ) )
  FOR (count = 1 TO org_cnt )
   SET preg_sec_orgs->qual[count ].org_id = sac_org->organizations[count ].organization_id
   SET preg_sec_orgs->qual[count ].confid_level = sac_org->organizations[count ].confid_level
  ENDFOR
  SET preg_sec_orgs->qual[(org_cnt + 1 ) ].org_id = 0.00
  SET preg_sec_orgs->qual[(org_cnt + 1 ) ].confid_level = 0
  CALL echorecord (preg_sec_orgs )
 END ;Subroutine
 SUBROUTINE  loadencounterlistforcao (person_id ,cao_flag )
  DECLARE log_program_name = vc WITH protect ,noconstant ("" )
  DECLARE log_override_ind = i2 WITH protect ,noconstant (0 )
  SET log_program_name = curprog
  SET log_override_ind = 0
  DECLARE log_level_error = i2 WITH protect ,noconstant (0 )
  DECLARE log_level_warning = i2 WITH protect ,noconstant (1 )
  DECLARE log_level_audit = i2 WITH protect ,noconstant (2 )
  DECLARE log_level_info = i2 WITH protect ,noconstant (3 )
  DECLARE log_level_debug = i2 WITH protect ,noconstant (4 )
  DECLARE hsys = i4 WITH protect ,noconstant (0 )
  DECLARE sysstat = i4 WITH protect ,noconstant (0 )
  DECLARE serrmsg = c132 WITH protect ,noconstant (" " )
  DECLARE ierrcode = i4 WITH protect ,noconstant (error (serrmsg ,1 ) )
  DECLARE crsl_msg_default = i4 WITH protect ,noconstant (0 )
  DECLARE crsl_msg_level = i4 WITH protect ,noconstant (0 )
  EXECUTE msgrtl
  SET crsl_msg_default = uar_msgdefhandle ()
  SET crsl_msg_level = uar_msggetlevel (crsl_msg_default )
  DECLARE lcrslsubeventcnt = i4 WITH protect ,noconstant (0 )
  DECLARE icrslloggingstat = i2 WITH protect ,noconstant (0 )
  DECLARE lcrslsubeventsize = i4 WITH protect ,noconstant (0 )
  DECLARE icrslloglvloverrideind = i2 WITH protect ,noconstant (0 )
  DECLARE scrsllogtext = vc WITH protect ,noconstant ("" )
  DECLARE scrsllogevent = vc WITH protect ,noconstant ("" )
  DECLARE icrslholdloglevel = i2 WITH protect ,noconstant (0 )
  DECLARE icrslerroroccured = i2 WITH protect ,noconstant (0 )
  DECLARE lcrsluarmsgwritestat = i4 WITH protect ,noconstant (0 )
  DECLARE crsl_info_domain = vc WITH protect ,constant ("DISCERNABU SCRIPT LOGGING" )
  DECLARE crsl_logging_on = c1 WITH protect ,constant ("L" )
  IF ((((logical ("MP_LOGGING_ALL" ) > " " ) ) OR ((logical (concat ("MP_LOGGING_" ,log_program_name
    ) ) > " " ) )) )
   SET log_override_ind = 1
  ENDIF
  DECLARE log_message ((logmsg = vc ) ,(loglvl = i4 ) ) = null
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
  DECLARE error_and_zero_check ((qualnum = i4 ) ,(opname = vc ) ,(logmsg = vc ) ,(errorforceexit =
   i2 ) ,(zeroforceexit = i2 ) ) = i2
  SUBROUTINE  error_and_zero_check (qualnum ,opname ,logmsg ,errorforceexit ,zeroforceexit )
   RETURN (error_and_zero_check_rec (qualnum ,opname ,logmsg ,errorforceexit ,zeroforceexit ,reply )
   )
  END ;Subroutine
  DECLARE populate_subeventstatus_rec ((operationname = vc (value ) ) ,(operationstatus = vc (value
    ) ) ,(targetobjectname = vc (value ) ) ,(targetobjectvalue = vc (value ) ) ,(recorddata = vc (
    ref ) ) ) = i2
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
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt ].targetobjectname = substring (1 ,
     25 ,targetobjectname )
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt ].targetobjectvalue =
    targetobjectvalue
   ENDIF
  END ;Subroutine
  DECLARE populate_subeventstatus ((operationname = vc (value ) ) ,(operationstatus = vc (value ) ) ,
   (targetobjectname = vc (value ) ) ,(targetobjectvalue = vc (value ) ) ) = i2
  SUBROUTINE  populate_subeventstatus (operationname ,operationstatus ,targetobjectname ,
   targetobjectvalue )
   CALL populate_subeventstatus_rec (operationname ,operationstatus ,targetobjectname ,
    targetobjectvalue ,reply )
  END ;Subroutine
  DECLARE populate_subeventstatus_msg ((operationname = vc (value ) ) ,(operationstatus = vc (value
    ) ) ,(targetobjectname = vc (value ) ) ,(targetobjectvalue = vc (value ) ) ,(loglevel = i2 (
    value ) ) ) = i2
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
  DECLARE loadpregnancyorganizationsecuritylist () = null
  IF ((validate (preg_org_sec_ind ) = 0 ) )
   DECLARE preg_org_sec_ind = i4 WITH noconstant (0 )
   SELECT INTO "nl:"
    FROM (dm_info d1 ),
     (dm_info d2 )
    WHERE (d1.info_domain = "SECURITY" )
    AND (d1.info_name = "SEC_ORG_RELTN" )
    AND (d1.info_number = 1 )
    AND (d2.info_domain = "SECURITY" )
    AND (d2.info_name = "SEC_PREG_ORG_RELTN" )
    AND (d2.info_number = 1 )
    DETAIL
     preg_org_sec_ind = 1
    WITH nocounter
   ;end select
   CALL echo (build ("preg_org_sec_ind=" ,preg_org_sec_ind ) )
   IF ((preg_org_sec_ind = 1 ) )
    FREE RECORD preg_sec_orgs
    RECORD preg_sec_orgs (
      1 qual [* ]
        2 org_id = f8
        2 confid_level = i4
    )
    CALL loadpregnancyorganizationsecuritylist (null )
   ENDIF
  ENDIF
  SUBROUTINE  loadpregnancyorganizationsecuritylist (null )
   DECLARE org_cnt = i2 WITH noconstant (0 )
   DECLARE stat = i2 WITH protect ,noconstant (0 )
   IF ((validate (sac_org ) = 1 ) )
    FREE RECORD sac_org
   ENDIF
   IF ((validate (_sacrtl_org_inc_ ,99999 ) = 99999 ) )
    DECLARE _sacrtl_org_inc_ = i2 WITH constant (1 )
    RECORD sac_org (
      1 organizations [* ]
        2 organization_id = f8
        2 confid_cd = f8
        2 confid_level = i4
    )
    EXECUTE secrtl
    EXECUTE sacrtl
    DECLARE orgcnt = i4 WITH protected ,noconstant (0 )
    DECLARE secstat = i2
    DECLARE logontype = i4 WITH protect ,noconstant (- (1 ) )
    DECLARE dynamic_org_ind = i4 WITH protect ,noconstant (- (1 ) )
    DECLARE dcur_trustid = f8 WITH protect ,noconstant (0.0 )
    DECLARE dynorg_enabled = i4 WITH constant (1 )
    DECLARE dynorg_disabled = i4 WITH constant (0 )
    DECLARE logontype_nhs = i4 WITH constant (1 )
    DECLARE logontype_legacy = i4 WITH constant (0 )
    DECLARE confid_cnt = i4 WITH protected ,noconstant (0 )
    RECORD confid_codes (
      1 list [* ]
        2 code_value = f8
        2 coll_seq = f8
    )
    CALL uar_secgetclientlogontype (logontype )
    CALL echo (build ("logontype:" ,logontype ) )
    IF ((logontype != logontype_nhs ) )
     SET dynamic_org_ind = dynorg_disabled
    ENDIF
    IF ((logontype = logontype_nhs ) )
     DECLARE getdynamicorgpref ((dtrustid = f8 ) ) = i4
     SUBROUTINE  getdynamicorgpref (dtrustid )
      DECLARE scur_trust = vc
      DECLARE pref_val = vc
      DECLARE is_enabled = i4 WITH constant (1 )
      DECLARE is_disabled = i4 WITH constant (0 )
      SET scur_trust = cnvtstring (dtrustid )
      SET scur_trust = concat (scur_trust ,".00" )
      IF (NOT (validate (pref_req ,0 ) ) )
       RECORD pref_req (
         1 write_ind = i2
         1 delete_ind = i2
         1 pref [* ]
           2 contexts [* ]
             3 context = vc
             3 context_id = vc
           2 section = vc
           2 section_id = vc
           2 subgroup = vc
           2 entries [* ]
             3 entry = vc
             3 values [* ]
               4 value = vc
       )
      ENDIF
      IF (NOT (validate (pref_rep ,0 ) ) )
       RECORD pref_rep (
         1 pref [* ]
           2 section = vc
           2 section_id = vc
           2 subgroup = vc
           2 entries [* ]
             3 pref_exists_ind = i2
             3 entry = vc
             3 values [* ]
               4 value = vc
         1 status_data
           2 status = c1
           2 subeventstatus [1 ]
             3 operationname = c25
             3 operationstatus = c1
             3 targetobjectname = c25
             3 targetobjectvalue = vc
       )
      ENDIF
      SET stat = alterlist (pref_req->pref ,1 )
      SET stat = alterlist (pref_req->pref[1 ].contexts ,2 )
      SET stat = alterlist (pref_req->pref[1 ].entries ,1 )
      SET pref_req->pref[1 ].contexts[1 ].context = "organization"
      SET pref_req->pref[1 ].contexts[1 ].context_id = scur_trust
      SET pref_req->pref[1 ].contexts[2 ].context = "default"
      SET pref_req->pref[1 ].contexts[2 ].context_id = "system"
      SET pref_req->pref[1 ].section = "workflow"
      SET pref_req->pref[1 ].section_id = "UK Trust Security"
      SET pref_req->pref[1 ].entries[1 ].entry = "dynamic organizations"
      EXECUTE ppr_preferences WITH replace ("REQUEST" ,"PREF_REQ" ) ,
      replace ("REPLY" ,"PREF_REP" )
      IF ((cnvtupper (pref_rep->pref[1 ].entries[1 ].values[1 ].value ) = "ENABLED" ) )
       RETURN (is_enabled )
      ELSE
       RETURN (is_disabled )
      ENDIF
     END ;Subroutine
     DECLARE hprop = i4 WITH protect ,noconstant (0 )
     DECLARE tmpstat = i2
     DECLARE spropname = vc
     DECLARE sroleprofile = vc
     SET hprop = uar_srvcreateproperty ()
     SET tmpstat = uar_secgetclientattributesext (5 ,hprop )
     SET spropname = uar_srvfirstproperty (hprop )
     SET sroleprofile = uar_srvgetpropertyptr (hprop ,nullterm (spropname ) )
     SELECT INTO "nl:"
      FROM (prsnl_org_reltn_type prt ),
       (prsnl_org_reltn por )
      PLAN (prt
       WHERE (prt.role_profile = sroleprofile )
       AND (prt.active_ind = 1 )
       AND (prt.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
       AND (prt.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
       JOIN (por
       WHERE (outerjoin (prt.organization_id ) = por.organization_id )
       AND (por.person_id = outerjoin (prt.prsnl_id ) )
       AND (por.active_ind = outerjoin (1 ) )
       AND (por.beg_effective_dt_tm <= outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
       AND (por.end_effective_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) ) )
      ORDER BY por.prsnl_org_reltn_id
      DETAIL
       orgcnt = 1 ,
       secstat = alterlist (sac_org->organizations ,1 ) ,
       user_person_id = prt.prsnl_id ,
       sac_org->organizations[1 ].organization_id = prt.organization_id ,
       sac_org->organizations[1 ].confid_cd = por.confid_level_cd ,
       confid_cd = uar_get_collation_seq (por.confid_level_cd ) ,
       sac_org->organizations[1 ].confid_level =
       IF ((confid_cd > 0 ) ) confid_cd
       ELSE 0
       ENDIF
      WITH maxrec = 1
     ;end select
     SET dcur_trustid = sac_org->organizations[1 ].organization_id
     SET dynamic_org_ind = getdynamicorgpref (dcur_trustid )
     CALL uar_srvdestroyhandle (hprop )
    ENDIF
    IF ((dynamic_org_ind = dynorg_disabled ) )
     SET confid_cnt = 0
     SELECT INTO "NL:"
      c.code_value ,
      c.collation_seq
      FROM (code_value c )
      WHERE (c.code_set = 87 )
      DETAIL
       confid_cnt = (confid_cnt + 1 ) ,
       IF ((mod (confid_cnt ,10 ) = 1 ) ) secstat = alterlist (confid_codes->list ,(confid_cnt + 9 )
         )
       ENDIF
       ,confid_codes->list[confid_cnt ].code_value = c.code_value ,
       confid_codes->list[confid_cnt ].coll_seq = c.collation_seq
      WITH nocounter
     ;end select
     SET secstat = alterlist (confid_codes->list ,confid_cnt )
     SELECT DISTINCT INTO "nl:"
      FROM (prsnl_org_reltn por )
      WHERE (por.person_id = reqinfo->updt_id )
      AND (por.active_ind = 1 )
      AND (por.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
      AND (por.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
      HEAD REPORT
       IF ((orgcnt > 0 ) ) secstat = alterlist (sac_org->organizations ,100 )
       ENDIF
      DETAIL
       orgcnt = (orgcnt + 1 ) ,
       IF ((mod (orgcnt ,100 ) = 1 ) ) secstat = alterlist (sac_org->organizations ,(orgcnt + 99 ) )
       ENDIF
       ,sac_org->organizations[orgcnt ].organization_id = por.organization_id ,
       sac_org->organizations[orgcnt ].confid_cd = por.confid_level_cd
      FOOT REPORT
       secstat = alterlist (sac_org->organizations ,orgcnt )
      WITH nocounter
     ;end select
     SELECT INTO "NL:"
      FROM (dummyt d1 WITH seq = value (orgcnt ) ),
       (dummyt d2 WITH seq = value (confid_cnt ) )
      PLAN (d1 )
       JOIN (d2
       WHERE (sac_org->organizations[d1.seq ].confid_cd = confid_codes->list[d2.seq ].code_value ) )
      DETAIL
       sac_org->organizations[d1.seq ].confid_level = confid_codes->list[d2.seq ].coll_seq
      WITH nocounter
     ;end select
    ELSEIF ((dynamic_org_ind = dynorg_enabled ) )
     DECLARE nhstrustchild_org_org_reltn_cd = f8
     SET nhstrustchild_org_org_reltn_cd = uar_get_code_by ("MEANING" ,369 ,"NHSTRUSTCHLD" )
     SELECT INTO "nl:"
      FROM (org_org_reltn oor )
      PLAN (oor
       WHERE (oor.organization_id = dcur_trustid )
       AND (oor.active_ind = 1 )
       AND (oor.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
       AND (oor.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
       AND (oor.org_org_reltn_cd = nhstrustchild_org_org_reltn_cd ) )
      HEAD REPORT
       IF ((orgcnt > 0 ) ) secstat = alterlist (sac_org->organizations ,10 )
       ENDIF
      DETAIL
       IF ((oor.related_org_id > 0 ) ) orgcnt = (orgcnt + 1 ) ,
        IF ((mod (orgcnt ,10 ) = 1 ) ) secstat = alterlist (sac_org->organizations ,(orgcnt + 9 ) )
        ENDIF
        ,sac_org->organizations[orgcnt ].organization_id = oor.related_org_id
       ENDIF
      FOOT REPORT
       secstat = alterlist (sac_org->organizations ,orgcnt )
      WITH nocounter
     ;end select
    ELSE
     CALL echo (build ("Unexpected login type: " ,dynamimc_org_ind ) )
    ENDIF
   ENDIF
   SET org_cnt = size (sac_org->organizations ,5 )
   CALL echo (build ("org_cnt: " ,org_cnt ) )
   SET stat = alterlist (preg_sec_orgs->qual ,(org_cnt + 1 ) )
   FOR (count = 1 TO org_cnt )
    SET preg_sec_orgs->qual[count ].org_id = sac_org->organizations[count ].organization_id
    SET preg_sec_orgs->qual[count ].confid_level = sac_org->organizations[count ].confid_level
   ENDFOR
   SET preg_sec_orgs->qual[(org_cnt + 1 ) ].org_id = 0.00
   SET preg_sec_orgs->qual[(org_cnt + 1 ) ].confid_level = 0
  END ;Subroutine
  DECLARE getallpregencounters ((p1 = f8 (val ) ) ,(p3 = vc (ref ) ) ) = null WITH protect
  DECLARE getpregpreferences ((p1 = vc (val ) ) ) = vc WITH protect
  RECORD encounters (
    1 encounter_ids [* ]
      2 encounter_id = f8
  )
  SUBROUTINE  getallpregencounters (person_id ,encounters )
   CALL log_message ("In GetAllPregEncounters()" ,log_level_debug )
   DECLARE lcnt = i4 WITH protect ,noconstant (0 )
   DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
   IF ((preg_org_sec_ind = 0 ) )
    SELECT INTO "nl:"
     FROM (encounter e )
     WHERE (e.person_id = person_id )
     AND (e.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
     AND ((e.end_effective_dt_tm + 0 ) > cnvtdatetime (curdate ,curtime3 ) )
     AND ((e.active_ind + 0 ) = 1 )
     AND ((e.organization_id + 0 ) > 0.0 )
     DETAIL
      lcnt = (lcnt + 1 ) ,
      IF ((mod (lcnt ,10 ) = 1 ) ) lstat = alterlist (encounters->encounter_ids ,(lcnt + 9 ) )
      ENDIF
      ,encounters->encounter_ids[lcnt ].encounter_id = e.encntr_id
     WITH nocounter
    ;end select
    SET stat = alterlist (encounters->encounter_ids ,lcnt )
   ENDIF
   CALL log_message (build ("Exit GetAllPregEncounters(), Elapsed time in seconds:" ,datetimediff (
      cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
  END ;Subroutine
  SUBROUTINE  getpregpreferences (preferencename )
   CALL log_message ("In GetPregPreferences()" ,log_level_debug )
   DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
   DECLARE preferencevalue = vc WITH noconstant ("" ) ,protect
   RECORD pregnancy_event_sets (
     1 qual [* ]
       2 pref_entry_name = vc
       2 event_set_name = vc
   )
   DECLARE stat = i2 WITH protect ,noconstant (0 )
   DECLARE hpref = i4 WITH private ,noconstant (0 )
   DECLARE hgroup = i4 WITH private ,noconstant (0 )
   DECLARE hrepgroup = i4 WITH private ,noconstant (0 )
   DECLARE hsection = i4 WITH private ,noconstant (0 )
   DECLARE hattr = i4 WITH private ,noconstant (0 )
   DECLARE hentry = i4 WITH private ,noconstant (0 )
   DECLARE lentrycnt = i4 WITH private ,noconstant (0 )
   DECLARE lentryidx = i4 WITH private ,noconstant (0 )
   DECLARE ilen = i4 WITH private ,noconstant (255 )
   DECLARE lattrcnt = i4 WITH private ,noconstant (0 )
   DECLARE lattridx = i4 WITH private ,noconstant (0 )
   DECLARE lvalcnt = i4 WITH private ,noconstant (0 )
   DECLARE sentryname = c255 WITH private ,noconstant ("" )
   DECLARE sattrname = c255 WITH private ,noconstant ("" )
   DECLARE sval = c255 WITH private ,noconstant ("" )
   DECLARE sentryval = c255 WITH private ,noconstant ("" )
   DECLARE tempdeldate = dq8 WITH private ,noconstant (0 )
   DECLARE deldate = dq8 WITH private ,noconstant (0 )
   CALL echo ("Entering GetPregPreferences subroutine" )
   EXECUTE prefrtl
   SET hpref = uar_prefcreateinstance (0 )
   SET stat = uar_prefaddcontext (hpref ,nullterm ("default" ) ,nullterm ("system" ) )
   SET stat = uar_prefsetsection (hpref ,nullterm ("component" ) )
   SET hgroup = uar_prefcreategroup ()
   SET stat = uar_prefsetgroupname (hgroup ,nullterm ("Pregnancy" ) )
   SET stat = uar_prefaddgroup (hpref ,hgroup )
   SET stat = uar_prefperform (hpref )
   SET hsection = uar_prefgetsectionbyname (hpref ,nullterm ("component" ) )
   SET hrepgroup = uar_prefgetgroupbyname (hsection ,nullterm ("Pregnancy" ) )
   SET stat = uar_prefgetgroupentrycount (hrepgroup ,lentrycnt )
   FOR (lentryidx = 0 TO (lentrycnt - 1 ) )
    SET hentry = uar_prefgetgroupentry (hrepgroup ,lentryidx )
    SET ilen = 255
    SET sentryname = ""
    SET sentryval = ""
    SET stat = uar_prefgetentryname (hentry ,sentryname ,ilen )
    IF ((sentryname = preferencename ) )
     SET lattrcnt = 0
     SET stat = uar_prefgetentryattrcount (hentry ,lattrcnt )
     FOR (lattridx = 0 TO (lattrcnt - 1 ) )
      SET hattr = uar_prefgetentryattr (hentry ,lattridx )
      SET ilen = 255
      SET sattrname = ""
      SET stat = uar_prefgetattrname (hattr ,sattrname ,ilen )
      IF ((sattrname = "prefvalue" ) )
       SET lvalcnt = 0
       SET stat = uar_prefgetattrvalcount (hattr ,lvalcnt )
       IF ((lvalcnt > 0 ) )
        SET sval = ""
        SET ilen = 255
        SET stat = uar_prefgetattrval (hattr ,sval ,ilen ,0 )
        SET preferencevalue = trim (sval )
       ENDIF
       SET lattridx = lattrcnt
      ENDIF
     ENDFOR
    ENDIF
   ENDFOR
   CALL uar_prefdestroysection (hsection )
   CALL uar_prefdestroygroup (hgroup )
   CALL uar_prefdestroyinstance (hpref )
   CALL log_message (build ("Exit GetPregPreferences(), Elapsed time in seconds:" ,datetimediff (
      cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
   RETURN (preferencevalue )
  END ;Subroutine
  RECORD accessible_encntr_person_ids (
    1 person_ids [* ]
      2 person_id = f8
  ) WITH public
  RECORD accessible_encntr_ids (
    1 accessible_encntrs_cnt = i4
    1 accessible_encntrs [* ]
      2 accessible_encntr_id = f8
  ) WITH public
  RECORD accessible_encntr_ids_maps (
    1 persons_cnt = i4
    1 persons [* ]
      2 person_id = f8
      2 accessible_encntrs_cnt = i4
      2 accessible_encntrs [* ]
        3 accessible_encntr_id = f8
  ) WITH public
  DECLARE getaccessibleencntrerrormsg = vc WITH protect
  DECLARE getaccessibleencntrtoggleerrormsg = vc WITH protect
  DECLARE h3202611srvmsg = i4 WITH noconstant (0 ) ,protect
  DECLARE h3202611srvreq = i4 WITH noconstant (0 ) ,protect
  DECLARE h3202611srvrep = i4 WITH noconstant (0 ) ,protect
  DECLARE hsys = i4 WITH noconstant (0 ) ,protect
  DECLARE sysstat = i4 WITH noconstant (0 ) ,protect
  DECLARE slogtext = vc WITH noconstant ("" ) ,protect
  DECLARE access_encntr_req_number = i4 WITH constant (3202611 ) ,protect
  DECLARE get_accessible_encntr_ids_by_person_id ((person_id = f8 ) ,(concept = vc ) ,(
   disable_access_security_ind = i2 (value ,0 ) ) ) = i4
  DECLARE get_accessible_encntr_ids_by_person_ids ((accessible_encntr_person_ids = vc (ref ) ) ,(
   concept = vc ) ,(disable_access_security_ind = i2 (value ,0 ) ) ) = i4
  DECLARE get_accessible_encntr_ids_by_person_ids_map ((accessible_encntr_person_ids = vc (ref ) ) ,(
   concept = vc ) ,(disable_access_security_ind = i2 (value ,0 ) ) ) = i4
  DECLARE get_accessible_encntr_toggle ((result = i4 (ref ) ) ) = i4
  DECLARE isfeaturetoggleon ((togglename = vc ) ,(systemidentifier = vc ) ,(featuretoggleflag = i2 (
    ref ) ) ) = i4
  DECLARE ischartaccesson ((concept = vc ) ,(chartaccessflag = i2 (ref ) ) ) = i4
  SUBROUTINE  get_accessible_encntr_ids_by_person_id (person_id ,concept ,
   disable_access_security_ind )
   SET h3202611srvmsg = uar_srvselectmessage (access_encntr_req_number )
   IF ((h3202611srvmsg = 0 ) )
    SET getaccessibleencntrerrormsg = build2 ("*** Failed to select message " ,build (
      access_encntr_req_number ) )
    RETURN (1 )
   ENDIF
   SET h3202611srvreq = uar_srvcreaterequest (h3202611srvmsg )
   IF ((h3202611srvreq = 0 ) )
    SET getaccessibleencntrerrormsg = build2 ("*** Failed to create request " ,build (
      access_encntr_req_number ) )
    RETURN (1 )
   ENDIF
   SET h3202611srvrep = uar_srvcreatereply (h3202611srvmsg )
   IF ((h3202611srvrep = 0 ) )
    SET getaccessibleencntrerrormsg = build2 ("*** Failed to create reply " ,build (
      access_encntr_req_number ) )
    RETURN (1 )
   ENDIF
   DECLARE e_count = i4 WITH noconstant (0 ) ,protect
   DECLARE encounter_count = i4 WITH noconstant (0 ) ,protect
   DECLARE htransactionstatus = i4 WITH noconstant (0 ) ,protect
   DECLARE hencounter = i4 WITH noconstant (0 ) ,protect
   SET stat = uar_srvsetdouble (h3202611srvreq ,"patientId" ,person_id )
   SET stat = uar_srvsetstring (h3202611srvreq ,"concept" ,nullterm (concept ) )
   SET stat = uar_srvsetshort (h3202611srvreq ,"disableAccessSecurityInd" ,
    disable_access_security_ind )
   SET stat = uar_srvexecute (h3202611srvmsg ,h3202611srvreq ,h3202611srvrep )
   IF ((stat = 0 ) )
    SET htransactionstatus = uar_srvgetstruct (h3202611srvrep ,"transactionStatus" )
    IF ((htransactionstatus = 0 ) )
     SET getaccessibleencntrerrormsg = build2 ("Failed to get transaction status from reply of " ,
      build (access_encntr_req_number ) )
     RETURN (1 )
    ELSE
     IF ((uar_srvgetshort (htransactionstatus ,"successIndicator" ) != 1 ) )
      SET getaccessibleencntrerrormsg = build2 ("Failure for call to " ,build (
        access_encntr_req_number ) ,". Debug Msg =" ,uar_srvgetstringptr (htransactionstatus ,
        "debugErrorMessage" ) )
      RETURN (1 )
     ELSE
      SET encounter_count = uar_srvgetitemcount (h3202611srvrep ,"encounterIds" )
      SET stat = alterlist (accessible_encntr_ids->accessible_encntrs ,encounter_count )
      SET accessible_encntr_ids->accessible_encntrs_cnt = encounter_count
      FOR (e_count = 1 TO encounter_count )
       SET hencounter = uar_srvgetitem (h3202611srvrep ,"encounterIds" ,(e_count - 1 ) )
       SET accessible_encntr_ids->accessible_encntrs[e_count ].accessible_encntr_id =
       uar_srvgetdouble (hencounter ,"encounterId" )
      ENDFOR
     ENDIF
    ENDIF
    RETURN (0 )
   ELSE
    SET getaccessibleencntrerrormsg = build2 ("Failure for call to " ,build (
      access_encntr_req_number ) )
    RETURN (1 )
   ENDIF
  END ;Subroutine
  SUBROUTINE  get_accessible_encntr_ids_by_person_ids (accessible_encntr_person_ids ,concept ,
   disable_access_security_ind )
   SET h3202611srvmsg = uar_srvselectmessage (access_encntr_req_number )
   IF ((h3202611srvmsg = 0 ) )
    SET getaccessibleencntrerrormsg = build2 ("*** Failed to select message " ,build (
      access_encntr_req_number ) )
    RETURN (1 )
   ENDIF
   SET h3202611srvreq = uar_srvcreaterequest (h3202611srvmsg )
   IF ((h3202611srvreq = 0 ) )
    SET getaccessibleencntrerrormsg = build2 ("*** Failed to create request " ,build (
      access_encntr_req_number ) )
    RETURN (1 )
   ENDIF
   SET h3202611srvrep = uar_srvcreatereply (h3202611srvmsg )
   IF ((h3202611srvrep = 0 ) )
    SET getaccessibleencntrerrormsg = build2 ("*** Failed to create reply " ,build (
      access_encntr_req_number ) )
    RETURN (1 )
   ENDIF
   DECLARE p_count = i4 WITH noconstant (0 ) ,protect
   DECLARE person_count = i4 WITH noconstant (0 ) ,protect
   DECLARE e_count = i4 WITH noconstant (0 ) ,protect
   DECLARE encounter_count = i4 WITH noconstant (0 ) ,protect
   DECLARE htransactionstatus = i4 WITH noconstant (0 ) ,protect
   DECLARE hencounter = i4 WITH noconstant (0 ) ,protect
   DECLARE curr_encntr_cnt = i4 WITH noconstant (0 ) ,protect
   DECLARE prev_encntr_cnt = i4 WITH noconstant (0 ) ,protect
   SET person_count = size (accessible_encntr_person_ids->person_ids ,5 )
   FOR (p_count = 1 TO person_count )
    SET stat = uar_srvsetdouble (h3202611srvreq ,"patientId" ,accessible_encntr_person_ids->
     person_ids[p_count ].person_id )
    SET stat = uar_srvsetstring (h3202611srvreq ,"concept" ,nullterm (concept ) )
    SET stat = uar_srvsetshort (h3202611srvreq ,"disableAccessSecurityInd" ,
     disable_access_security_ind )
    SET stat = uar_srvexecute (h3202611srvmsg ,h3202611srvreq ,h3202611srvrep )
    IF ((stat = 0 ) )
     SET htransactionstatus = uar_srvgetstruct (h3202611srvrep ,"transactionStatus" )
     IF ((htransactionstatus = 0 ) )
      SET getaccessibleencntrerrormsg = build2 ("Failed to get transaction status from reply of " ,
       build (access_encntr_req_number ) )
      RETURN (1 )
     ELSE
      IF ((uar_srvgetshort (htransactionstatus ,"successIndicator" ) != 1 ) )
       SET getaccessibleencntrerrormsg = build2 ("Failure for call to " ,build (
         access_encntr_req_number ) ,". Debug Msg =" ,uar_srvgetstringptr (htransactionstatus ,
         "debugErrorMessage" ) )
       RETURN (1 )
      ELSE
       SET encounter_count = uar_srvgetitemcount (h3202611srvrep ,"encounterIds" )
       SET prev_encntr_cnt = curr_encntr_cnt
       SET curr_encntr_cnt = (curr_encntr_cnt + encounter_count )
       SET stat = alterlist (accessible_encntr_ids->accessible_encntrs ,curr_encntr_cnt )
       SET accessible_encntr_ids->accessible_encntrs_cnt = curr_encntr_cnt
       FOR (e_count = 1 TO encounter_count )
        SET hencounter = uar_srvgetitem (h3202611srvrep ,"encounterIds" ,(e_count - 1 ) )
        SET accessible_encntr_ids->accessible_encntrs[(e_count + prev_encntr_cnt ) ].
        accessible_encntr_id = uar_srvgetdouble (hencounter ,"encounterId" )
       ENDFOR
      ENDIF
     ENDIF
    ELSE
     SET getaccessibleencntrerrormsg = build2 ("Failure for call to " ,build (
       access_encntr_req_number ) )
     RETURN (1 )
    ENDIF
   ENDFOR
   RETURN (0 )
  END ;Subroutine
  SUBROUTINE  get_accessible_encntr_ids_by_person_ids_map (accessible_encntr_person_ids ,concept ,
   disable_access_security_ind )
   SET h3202611srvmsg = uar_srvselectmessage (access_encntr_req_number )
   IF ((h3202611srvmsg = 0 ) )
    SET getaccessibleencntrerrormsg = build2 ("*** Failed to select message " ,build (
      access_encntr_req_number ) )
    RETURN (1 )
   ENDIF
   SET h3202611srvreq = uar_srvcreaterequest (h3202611srvmsg )
   IF ((h3202611srvreq = 0 ) )
    SET getaccessibleencntrerrormsg = build2 ("*** Failed to create request " ,build (
      access_encntr_req_number ) )
    RETURN (1 )
   ENDIF
   SET h3202611srvrep = uar_srvcreatereply (h3202611srvmsg )
   IF ((h3202611srvrep = 0 ) )
    SET getaccessibleencntrerrormsg = build2 ("*** Failed to create reply " ,build (
      access_encntr_req_number ) )
    RETURN (1 )
   ENDIF
   DECLARE p_count = i4 WITH noconstant (0 ) ,protect
   DECLARE person_count = i4 WITH noconstant (0 ) ,protect
   DECLARE e_count = i4 WITH noconstant (0 ) ,protect
   DECLARE encounter_count = i4 WITH noconstant (0 ) ,protect
   DECLARE htransactionstatus = i4 WITH noconstant (0 ) ,protect
   DECLARE hencounter = i4 WITH noconstant (0 ) ,protect
   SET person_count = size (accessible_encntr_person_ids->person_ids ,5 )
   SET accessible_encntr_ids_maps->persons_cnt = person_count
   FOR (p_count = 1 TO person_count )
    SET stat = uar_srvsetdouble (h3202611srvreq ,"patientId" ,accessible_encntr_person_ids->
     person_ids[p_count ].person_id )
    SET stat = uar_srvsetstring (h3202611srvreq ,"concept" ,nullterm (concept ) )
    SET stat = uar_srvsetshort (h3202611srvreq ,"disableAccessSecurityInd" ,
     disable_access_security_ind )
    SET accessible_encntr_ids_maps->persons[p_count ].person_id = accessible_encntr_person_ids->
    person_ids[p_count ].person_id
    SET stat = uar_srvexecute (h3202611srvmsg ,h3202611srvreq ,h3202611srvrep )
    IF ((stat = 0 ) )
     SET htransactionstatus = uar_srvgetstruct (h3202611srvrep ,"transactionStatus" )
     IF ((htransactionstatus = 0 ) )
      SET getaccessibleencntrerrormsg = build2 ("Failed to get transaction status from reply of " ,
       build (access_encntr_req_number ) )
      RETURN (1 )
     ELSE
      IF ((uar_srvgetshort (htransactionstatus ,"successIndicator" ) != 1 ) )
       SET getaccessibleencntrerrormsg = build2 ("Failure for call to " ,build (
         access_encntr_req_number ) ,". Debug Msg =" ,uar_srvgetstringptr (htransactionstatus ,
         "debugErrorMessage" ) )
       RETURN (1 )
      ELSE
       SET encounter_count = uar_srvgetitemcount (h3202611srvrep ,"encounterIds" )
       SET stat = alterlist (accessible_encntr_ids_maps->persons[p_count ].accessible_encntrs ,
        encounter_count )
       SET accessible_encntr_ids_maps->persons[p_count ].accessible_encntrs_cnt = encounter_count
       FOR (e_count = 1 TO encounter_count )
        SET hencounter = uar_srvgetitem (h3202611srvrep ,"encounterIds" ,(e_count - 1 ) )
        SET accessible_encntr_ids_maps->persons[p_count ].accessible_encntrs[e_count ].
        accessible_encntr_id = uar_srvgetdouble (hencounter ,"encounterId" )
       ENDFOR
      ENDIF
     ENDIF
    ELSE
     SET getaccessibleencntrerrormsg = build2 ("Failure for call to " ,build (
       access_encntr_req_number ) )
     RETURN (1 )
    ENDIF
   ENDFOR
   RETURN (0 )
  END ;Subroutine
  SUBROUTINE  get_accessible_encntr_toggle (result )
   DECLARE concept_policies_req_concept = vc WITH constant ("PowerChart_Framework" ) ,protect
   DECLARE featuretoggleflag = i2 WITH noconstant (false ) ,protect
   DECLARE chartaccessflag = i2 WITH noconstant (false ) ,protect
   DECLARE featuretogglestat = i2 WITH noconstant (0 ) ,protect
   DECLARE chartaccessstat = i2 WITH noconstant (0 ) ,protect
   SET featuretogglestat = isfeaturetoggleon (
    "urn:cerner:millennium:accessible-encounters-by-concept" ,"urn:cerner:millennium" ,
    featuretoggleflag )
   CALL uar_syscreatehandle (hsys ,sysstat )
   IF ((hsys > 0 ) )
    SET slogtext = build2 ("get_accessible_encntr_toggle - featureToggleStat is " ,build (
      featuretogglestat ) )
    CALL uar_sysevent (hsys ,4 ,"pm_get_access_encntr_by_person" ,nullterm (slogtext ) )
    SET slogtext = build2 ("get_accessible_encntr_toggle - featureToggleFlag is " ,build (
      featuretoggleflag ) )
    CALL uar_sysevent (hsys ,4 ,"pm_get_access_encntr_by_person" ,nullterm (slogtext ) )
    CALL uar_sysdestroyhandle (hsys )
   ENDIF
   IF ((featuretogglestat = 0 )
   AND (featuretoggleflag = true ) )
    SET result = 1
    RETURN (0 )
   ENDIF
   IF ((featuretogglestat != 0 ) )
    CALL uar_syscreatehandle (hsys ,sysstat )
    IF ((hsys > 0 ) )
     SET slogtext = build ("Feature toggle service returned failure status." )
     CALL uar_sysevent (hsys ,1 ,"pm_get_access_encntr_by_person" ,nullterm (slogtext ) )
     CALL uar_sysdestroyhandle (hsys )
    ENDIF
   ENDIF
   SET chartaccessstat = ischartaccesson (concept_policies_req_concept ,chartaccessflag )
   CALL uar_syscreatehandle (hsys ,sysstat )
   IF ((hsys > 0 ) )
    SET slogtext = build2 ("get_accessible_encntr_toggle - chartAccessStat is " ,build (
      chartaccessstat ) )
    CALL uar_sysevent (hsys ,4 ,"pm_get_access_encntr_by_person" ,nullterm (slogtext ) )
    SET slogtext = build2 ("get_accessible_encntr_toggle - chartAccessFlag is " ,build (
      chartaccessflag ) )
    CALL uar_sysevent (hsys ,4 ,"pm_get_access_encntr_by_person" ,nullterm (slogtext ) )
    CALL uar_sysdestroyhandle (hsys )
   ENDIF
   IF ((chartaccessstat != 0 ) )
    RETURN (1 )
   ENDIF
   IF ((chartaccessflag = true ) )
    SET result = 1
   ENDIF
   RETURN (0 )
  END ;Subroutine
  SUBROUTINE  isfeaturetoggleon (togglename ,systemidentifier ,featuretoggleflag )
   DECLARE feature_toggle_req_number = i4 WITH constant (2030001 ) ,protect
   DECLARE toggle = vc WITH noconstant ("" ) ,protect
   DECLARE htransactionstatus = i4 WITH noconstant (0 ) ,protect
   DECLARE hfeatureflagmsg = i4 WITH noconstant (0 ) ,protect
   DECLARE hfeatureflagreq = i4 WITH noconstant (0 ) ,protect
   DECLARE hfeatureflagrep = i4 WITH noconstant (0 ) ,protect
   DECLARE rep2030001count = i4 WITH noconstant (0 ) ,protect
   DECLARE rep2030001successind = i2 WITH noconstant (0 ) ,protect
   SET hfeatureflagmsg = uar_srvselectmessage (feature_toggle_req_number )
   IF ((hfeatureflagmsg = 0 ) )
    RETURN (0 )
   ENDIF
   SET hfeatureflagreq = uar_srvcreaterequest (hfeatureflagmsg )
   IF ((hfeatureflagreq = 0 ) )
    RETURN (0 )
   ENDIF
   SET hfeatureflagrep = uar_srvcreatereply (hfeatureflagmsg )
   IF ((hfeatureflagrep = 0 ) )
    RETURN (0 )
   ENDIF
   SET stat = uar_srvsetstring (hfeatureflagreq ,"system_identifier" ,nullterm (systemidentifier ) )
   SET stat = uar_srvsetshort (hfeatureflagreq ,"ignore_overrides_ind" ,1 )
   IF ((uar_srvexecute (hfeatureflagmsg ,hfeatureflagreq ,hfeatureflagrep ) = 0 ) )
    SET htransactionstatus = uar_srvgetstruct (hfeatureflagrep ,"transaction_status" )
    IF ((htransactionstatus != 0 ) )
     SET rep2030001successind = uar_srvgetshort (htransactionstatus ,"success_ind" )
    ELSE
     SET getaccessibleencntrtoggleerrormsg = build2 (
      "Failed to get transaction status from reply of " ,build (feature_toggle_req_number ) )
     RETURN (1 )
    ENDIF
    IF ((rep2030001successind = 1 ) )
     IF ((uar_srvgetitem (hfeatureflagrep ,"feature_toggle_keys" ,0 ) > 0 ) )
      SET rep2030001count = uar_srvgetitemcount (hfeatureflagrep ,"feature_toggle_keys" )
      FOR (loop = 0 TO (rep2030001count - 1 ) )
       SET toggle = uar_srvgetstringptr (uar_srvgetitem (hfeatureflagrep ,"feature_toggle_keys" ,
         loop ) ,"key" )
       IF ((togglename = toggle ) )
        SET featuretoggleflag = true
        RETURN (0 )
       ENDIF
      ENDFOR
     ENDIF
    ELSE
     SET getaccessibleencntrtoggleerrormsg = build2 ("Failure for call to " ,build (
       feature_toggle_req_number ) ,". Debug Msg =" ,uar_srvgetstringptr (htransactionstatus ,
       "debug_error_message" ) )
     RETURN (1 )
    ENDIF
   ELSE
    SET getaccessibleencntrtoggleerrormsg = build2 ("Failure for call to " ,build (
      feature_toggle_req_number ) )
    RETURN (1 )
   ENDIF
   RETURN (0 )
  END ;Subroutine
  SUBROUTINE  ischartaccesson (concept ,chartaccessflag )
   DECLARE concept_policies_req_number = i4 WITH constant (3202590 ) ,protect
   DECLARE htransactionstatus = i4 WITH noconstant (0 ) ,protect
   DECLARE hconceptpoliciesreqstruct = i4 WITH noconstant (0 ) ,protect
   DECLARE hconceptpoliciesmsg = i4 WITH noconstant (0 ) ,protect
   DECLARE hconceptpoliciesreq = i4 WITH noconstant (0 ) ,protect
   DECLARE hconceptpoliciesrep = i4 WITH noconstant (0 ) ,protect
   DECLARE hconceptpoliciesstruct = i4 WITH noconstant (0 ) ,protect
   DECLARE rep3202590count = i4 WITH noconstant (0 ) ,protect
   DECLARE rep3202590successind = i2 WITH noconstant (0 ) ,protect
   SET hconceptpoliciesmsg = uar_srvselectmessage (concept_policies_req_number )
   IF ((hconceptpoliciesmsg = 0 ) )
    RETURN (0 )
   ENDIF
   SET hconceptpoliciesreq = uar_srvcreaterequest (hconceptpoliciesmsg )
   IF ((hconceptpoliciesreq = 0 ) )
    RETURN (0 )
   ENDIF
   SET hconceptpoliciesrep = uar_srvcreatereply (hconceptpoliciesmsg )
   IF ((hconceptpoliciesrep = 0 ) )
    RETURN (0 )
   ENDIF
   SET hconceptpoliciesreqstruct = uar_srvadditem (hconceptpoliciesreq ,"concepts" )
   IF ((hconceptpoliciesreqstruct > 0 ) )
    SET stat = uar_srvsetstring (hconceptpoliciesreqstruct ,"concept" ,nullterm (concept ) )
    IF ((uar_srvexecute (hconceptpoliciesmsg ,hconceptpoliciesreq ,hconceptpoliciesrep ) = 0 ) )
     SET htransactionstatus = uar_srvgetstruct (hconceptpoliciesrep ,"transaction_status" )
     IF ((htransactionstatus != 0 ) )
      SET rep3202590successind = uar_srvgetshort (htransactionstatus ,"success_ind" )
     ELSE
      SET getaccessibleencntrtoggleerrormsg = build2 (
       "Failed to get transaction status from reply of " ,build (concept_policies_req_number ) )
      RETURN (1 )
     ENDIF
     IF ((rep3202590successind = 1 ) )
      IF ((uar_srvgetitem (hconceptpoliciesrep ,"concept_policies_batch" ,0 ) > 0 ) )
       SET rep3202590count = uar_srvgetitemcount (hconceptpoliciesrep ,"concept_policies_batch" )
       FOR (loop = 0 TO (rep3202590count - 1 ) )
        SET hconceptpoliciesstruct = uar_srvgetstruct (uar_srvgetitem (hconceptpoliciesrep ,
          "concept_policies_batch" ,loop ) ,"policies" )
        IF ((hconceptpoliciesstruct > 0 ) )
         IF ((uar_srvgetshort (hconceptpoliciesstruct ,"chart_access_group_security_ind" ) = 1 ) )
          SET chartaccessflag = true
          RETURN (0 )
         ENDIF
        ELSE
         SET getaccessibleencntrtoggleerrormsg = build2 ("Failure for call to " ,build (
           concept_policies_req_number ) ,build ("Found an invalid hConceptPoliciesStruct : " ,
           hconceptpoliciesstruct ) )
         RETURN (1 )
        ENDIF
       ENDFOR
      ENDIF
     ELSE
      SET getaccessibleencntrtoggleerrormsg = build2 ("Failure for call to " ,build (
        concept_policies_req_number ) ,". Debug Msg =" ,uar_srvgetstringptr (htransactionstatus ,
        "debug_error_message" ) )
      RETURN (1 )
     ENDIF
    ELSE
     SET getaccessibleencntrtoggleerrormsg = build2 ("Failure for call to " ,build (
       concept_policies_req_number ) )
     RETURN (1 )
    ENDIF
   ELSE
    SET getaccessibleencntrtoggleerrormsg = build2 ("Failure for call to " ,build (
      concept_policies_req_number ) ,build ("Found an invalid hConceptPoliciesReqStruct : " ,
      hconceptpoliciesreqstruct ) )
    RETURN (1 )
   ENDIF
   RETURN (0 )
  END ;Subroutine
  RECORD encounters (
    1 encounter_ids [* ]
      2 encounter_id = f8
  )
  DECLARE pregnancy_concept = vc WITH constant ("PREGNANCY" ) ,protect
  DECLARE womens_health_concept = vc WITH constant ("WOMENS_HEALTH" ) ,protect
  DECLARE getaccessibleencounters ((encntrsrec = vc (ref ) ) ,(personid = f8 (val ) ) ,(ispregcomp =
   i2 (val ,0 ) ) ) = i4
  DECLARE getallencounters ((encntrsrec = vc (ref ) ) ,(personid = f8 (val ) ) ) = i4
  DECLARE getaccessibleencounterbypersonids ((personids = vc (ref ) ) ,(encntrsrec = vc (ref ) ) ,(
   patientcount = i4 (val ,0 ) ) ) = i4
  DECLARE ischartaccessenabled ((chartaccessflag = i2 (ref ) ) ,(ispregcomp = i2 (val ,0 ) ) ) = i4
  SUBROUTINE  ischartaccessenabled (chartaccessflag ,ispregcomp )
   CALL log_message ("In IsChartAccessEnabled()" ,log_level_debug )
   DECLARE begin_date_time = dq8 WITH constant (curtime3 ) ,private
   DECLARE concept_policies_req_num = i4 WITH constant (3202590 ) ,protect
   DECLARE htransactionstatus = i4 WITH noconstant (0 ) ,protect
   DECLARE hconceptpoliciesreqstruct = i4 WITH noconstant (0 ) ,protect
   DECLARE hconceptpoliciesmsg = i4 WITH noconstant (0 ) ,protect
   DECLARE hconceptpoliciesreq = i4 WITH noconstant (0 ) ,protect
   DECLARE hconceptpoliciesrep = i4 WITH noconstant (0 ) ,protect
   DECLARE hconceptpoliciesstruct = i4 WITH noconstant (0 ) ,protect
   DECLARE rep3202590count = i4 WITH noconstant (0 ) ,protect
   DECLARE rep3202590successind = i2 WITH noconstant (0 ) ,protect
   DECLARE rep3202590debugerrormsg = vc WITH noconstant ("" ) ,protect
   DECLARE concept = vc WITH noconstant (womens_health_concept ) ,private
   IF ((ispregcomp = 1 ) )
    SET concept = pregnancy_concept
   ENDIF
   SET hconceptpoliciesmsg = uar_srvselectmessage (concept_policies_req_num )
   IF ((hconceptpoliciesmsg = 0 ) )
    RETURN (0 )
   ENDIF
   SET hconceptpoliciesreq = uar_srvcreaterequest (hconceptpoliciesmsg )
   IF ((hconceptpoliciesreq = 0 ) )
    RETURN (0 )
   ENDIF
   SET hconceptpoliciesrep = uar_srvcreatereply (hconceptpoliciesmsg )
   IF ((hconceptpoliciesrep = 0 ) )
    RETURN (0 )
   ENDIF
   SET hconceptpoliciesreqstruct = uar_srvadditem (hconceptpoliciesreq ,"concepts" )
   IF ((hconceptpoliciesreqstruct > 0 ) )
    SET stat = uar_srvsetstring (hconceptpoliciesreqstruct ,"concept" ,nullterm (concept ) )
    IF ((uar_srvexecute (hconceptpoliciesmsg ,hconceptpoliciesreq ,hconceptpoliciesrep ) = 0 ) )
     SET htransactionstatus = uar_srvgetstruct (hconceptpoliciesrep ,"transaction_status" )
     IF ((htransactionstatus != 0 ) )
      SET rep3202590successind = uar_srvgetshort (htransactionstatus ,"success_ind" )
      SET rep3202590debugerrormsg = uar_srvgetstringptr (htransactionstatus ,"debug_error_message" )
     ELSE
      IF ((validate (debug_ind ,0 ) = 1 ) )
       CALL echo (build2 ("Failed to get transaction status from reply of " ,build (
          concept_policies_req_num ) ) )
      ENDIF
      CALL log_message (build ("Exit IsChartAccessEnabled(), Elapsed time in seconds:" ,((curtime3 -
        begin_date_time ) / 100.0 ) ) ,log_level_debug )
      RETURN (1 )
     ENDIF
     IF ((rep3202590successind = 1 ) )
      IF ((uar_srvgetitem (hconceptpoliciesrep ,"concept_policies_batch" ,0 ) > 0 ) )
       SET rep3202590count = uar_srvgetitemcount (hconceptpoliciesrep ,"concept_policies_batch" )
       FOR (loop = 0 TO (rep3202590count - 1 ) )
        SET hconceptpoliciesstruct = uar_srvgetstruct (uar_srvgetitem (hconceptpoliciesrep ,
          "concept_policies_batch" ,loop ) ,"policies" )
        IF ((hconceptpoliciesstruct > 0 ) )
         IF ((uar_srvgetshort (hconceptpoliciesstruct ,"chart_access_group_security_ind" ) = 1 ) )
          SET chartaccessflag = true
          CALL log_message (build ("Exit IsChartAccessEnabled(), Elapsed time in seconds:" ,((
            curtime3 - begin_date_time ) / 100.0 ) ) ,log_level_debug )
          RETURN (0 )
         ENDIF
        ELSE
         IF ((validate (debug_ind ,0 ) = 1 ) )
          CALL echo (build2 ("Failure for call to " ,build (concept_policies_req_num ) ,build (
             "Found an invalid hConceptPoliciesStruct : " ,hconceptpoliciesstruct ) ) )
         ENDIF
         CALL log_message (build ("Exit IsChartAccessEnabled(), Elapsed time in seconds:" ,((
           curtime3 - begin_date_time ) / 100.0 ) ) ,log_level_debug )
         RETURN (1 )
        ENDIF
       ENDFOR
      ENDIF
     ELSE
      IF ((validate (debug_ind ,0 ) = 1 ) )
       CALL echo (build2 ("Failure for call to " ,build (concept_policies_req_num ) ,". Debug Msg ="
         ,uar_srvgetstringptr (htransactionstatus ,"debug_error_message" ) ) )
      ENDIF
      CALL log_message (build ("Exit IsChartAccessEnabled(), Elapsed time in seconds:" ,((curtime3 -
        begin_date_time ) / 100.0 ) ) ,log_level_debug )
      RETURN (1 )
     ENDIF
    ELSE
     IF ((validate (debug_ind ,0 ) = 1 ) )
      CALL echo (build2 ("Failure for call to " ,build (concept_policies_req_num ) ) )
     ENDIF
     CALL log_message (build ("Exit IsChartAccessEnabled(), Elapsed time in seconds:" ,((curtime3 -
       begin_date_time ) / 100.0 ) ) ,log_level_debug )
     RETURN (1 )
    ENDIF
   ELSE
    IF ((validate (debug_ind ,0 ) = 1 ) )
     CALL echo (build2 ("Failure for call to " ,build (concept_policies_req_num ) ,build (
        "Found an invalid hConceptPoliciesReqStruct : " ,hconceptpoliciesreqstruct ) ) )
    ENDIF
    CALL log_message (build ("Exit IsChartAccessEnabled(), Elapsed time in seconds:" ,((curtime3 -
      begin_date_time ) / 100.0 ) ) ,log_level_debug )
    RETURN (1 )
   ENDIF
   CALL log_message (build ("Exit IsChartAccessEnabled(), Elapsed time in seconds:" ,((curtime3 -
     begin_date_time ) / 100.0 ) ) ,log_level_debug )
   RETURN (0 )
  END ;Subroutine
  SUBROUTINE  getallencounters (encntrsrec ,personid )
   CALL log_message ("In GetAllEncounters()" ,log_level_debug )
   DECLARE begin_date_time = dq8 WITH constant (curtime3 ) ,private
   IF ((preg_org_sec_ind = 0 ) )
    CALL getallpregencounters (personid ,encounters )
    SET stat = alterlist (encntrsrec->qual ,0 )
    SET stat = moverec (encounters->encounter_ids ,encntrsrec->qual )
   ENDIF
   CALL log_message (build ("Exit GetAllEncounters(), Elapsed time in seconds:" ,((curtime3 -
     begin_date_time ) / 100.0 ) ) ,log_level_debug )
  END ;Subroutine
  SUBROUTINE  getaccessibleencounters (encntrsrec ,personid ,ispregcomp )
   CALL log_message ("In GetAccessibleEncounters()" ,log_level_debug )
   DECLARE begin_date_time = dq8 WITH constant (curtime3 ) ,private
   DECLARE result = i4 WITH protect ,noconstant (0 )
   DECLARE concept = vc WITH noconstant (womens_health_concept ) ,private
   IF ((ispregcomp = 1 ) )
    SET concept = pregnancy_concept
   ENDIF
   CALL get_accessible_encntr_toggle (result )
   IF ((result = 1 ) )
    SET stat = get_accessible_encntr_ids_by_person_id (personid ,concept ,0 )
    IF ((stat = 0 ) )
     SET stat = alterlist (encntrsrec->qual ,0 )
     SET stat = moverec (accessible_encntr_ids->accessible_encntrs ,encntrsrec->qual )
     SET encntrsrec->cnt = accessible_encntr_ids->accessible_encntrs_cnt
    ENDIF
   ELSEIF ((ispregcomp = 1 ) )
    CALL getallencounters (encntrsrec ,personid )
   ENDIF
   CALL log_message (build ("Exit GetAccessibleEncounters(), Elapsed time in seconds:" ,((curtime3 -
     begin_date_time ) / 100.0 ) ) ,log_level_debug )
  END ;Subroutine
  SUBROUTINE  getaccessibleencounterbypersonids (patientids ,encntrsrec ,patientcount )
   CALL log_message ("In GetAccessibleEncounterByPersonIds()" ,log_level_debug )
   DECLARE begin_date_time = dq8 WITH constant (curtime3 ) ,private
   DECLARE pcount = i4 WITH noconstant (0 ) ,protect
   DECLARE encntrcount = i4 WITH protect ,noconstant (0 )
   DECLARE prevencntrcount = i4 WITH protect ,noconstant (0 )
   DECLARE currencntrcount = i4 WITH protect ,noconstant (0 )
   DECLARE result = i4 WITH protect ,noconstant (0 )
   IF ((patientcount = 0 ) )
    SET patientcount = size (patientids->patient_list ,5 )
   ENDIF
   CALL get_accessible_encntr_toggle (result )
   IF ((result = 1 ) )
    FOR (pcount = 1 TO patientcount )
     SET stat = get_accessible_encntr_ids_by_person_id (patientids->patient_list[pcount ].patient_id
      ,pregnancy_concept ,0 )
     IF ((stat = 0 ) )
      SET encntrcount = accessible_encntr_ids->accessible_encntrs_cnt
      SET prevencntrcount = currencntrcount
      SET currencntrcount = (currencntrcount + encntrcount )
      SET stat = alterlist (encntrsrec->qual ,currencntrcount )
      SET encntrsrec->cnt = currencntrcount
      FOR (ecount = 1 TO encntrcount )
       SET encntrsrec->qual[(ecount + prevencntrcount ) ].value = accessible_encntr_ids->
       accessible_encntrs[ecount ].accessible_encntr_id
      ENDFOR
     ENDIF
    ENDFOR
   ENDIF
   CALL log_message (build ("Exit GetAccessibleEncounterByPersonIds(), Elapsed time in seconds:" ,((
     curtime3 - begin_date_time ) / 100.0 ) ) ,log_level_debug )
  END ;Subroutine
  CALL ischartaccessenabled (cao_flag )
  IF ((cao_flag = 1 ) )
   CALL getaccessibleencounters (encntr_list ,person_id )
  ENDIF
 END ;Subroutine
 IF ((validate (debug_ind ,0 ) = 1 ) )
  CALL echo (build ("stand_alone_ind:" ,stand_alone_ind ) )
 ENDIF
 FREE SET g_info
 RECORD g_info (
   1 gravida = vc
   1 para_details = vc
   1 para_full_term = vc
   1 para_premature = vc
   1 para_abortions = vc
   1 para = vc
   1 mod_ind = vc
 )
 FREE SET preghist
 RECORD preghist (
   1 preg_cnt = i4
   1 preg [* ]
     2 label = vc
     2 sensitive_ind = i4
     2 child_cnt = i4
     2 child [* ]
       3 delivery_date_qualifier_flag = i2
       3 delivery_date_qualifier = vc
       3 dlv_date = c10
       3 gest_at_birth = c21
       3 child_gender = vc
       3 length_labor = vc
       3 infant_wt = vc
       3 neonate_outcome = vc
       3 preg_outcome = vc
       3 dlv_hosp = vc
       3 child_name = vc
       3 father_name = vc
       3 preterm_labor = vc
       3 preterm_labor_ind = i4
       3 preterm_labor_wrap [* ]
         4 wrap_text = vc
       3 anesth_type = vc
       3 anesth_type_ind = i4
       3 anesth_type_wrap [* ]
         4 wrap_text = vc
       3 fetal_complic = vc
       3 fetal_complic_ind = i4
       3 fetal_comp_wrap [* ]
         4 wrap_text = vc
       3 neonate_complic = vc
       3 neonate_complic_ind = i4
       3 neonate_comp_wrap [* ]
         4 wrap_text = vc
       3 maternal_complic = vc
       3 maternal_complic_ind = i4
       3 maternal_comp_wrap [* ]
         4 wrap_text = vc
       3 preg_comments = vc
       3 child_comment_id = f8
       3 comment_wrapped [* ]
         4 wrap_text = vc
 )
 DECLARE auth = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,8 ,"AUTH" ) )
 DECLARE altered = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,8 ,"ALTERED" ) )
 DECLARE modified = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,8 ,"MODIFIED" ) )
 DECLARE gravida = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!6299" ) )
 DECLARE para_details = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!6300" ) )
 DECLARE para_full_term = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10099" ) )
 DECLARE para_premature = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10100" ) )
 DECLARE para_abortions = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10101" ) )
 DECLARE para_living = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10024" ) )
 DECLARE lb_cd = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2746" ) )
 DECLARE kg_cd = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2751" ) )
 DECLARE gm_cd = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!6123" ) )
 DECLARE fetus_comp = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!12805960" ) )
 DECLARE mother_comp = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!12805954" ) )
 DECLARE newborn_comp = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!12805961" ) )
 DECLARE anesth_comp = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!12610546" ) )
 DECLARE preterm_comp = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!12610547" ) )
 DECLARE nodatacaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap1" ,
   "No previous pregnancies history have been recorded" ) )
 DECLARE preghistorycaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap2" ,
   "Pregnancy History" ) )
 DECLARE outcomecaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap3" ,
   "Outcome Date:" ) )
 DECLARE gestagecaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap4" ,
   "Gest Age:" ) )
 DECLARE lenlaborcaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap5" ,
   "Len Labor:" ) )
 DECLARE gendercaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap6" ,
   "Birth Sex:" ) )
 DECLARE wtabbrvcaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap7" ,"Wt:"
   ) )
 DECLARE pregnumcaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap8" ,
   "Pregnancy #" ) )
 DECLARE neonateoutcomecaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap9"
   ,"Birth Outcome:" ) )
 DECLARE pregoutcomecaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap10" ,
   "Outcome or Result:" ) )
 DECLARE anesthesiacaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap11" ,
   "Anesthesia Type:" ) )
 DECLARE deliveryhospcaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap12" ,
   "Hospital:" ) )
 DECLARE childsnamecaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap13" ,
   "Child's Name:" ) )
 DECLARE nameoffathercaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap14" ,
   "Name of Father/Guardian of Newborn:" ) )
 DECLARE fetalcompcaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap15" ,
   "Birth Complications:" ) )
 DECLARE neonatecompcaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap16" ,
   "Neonate Complications:" ) )
 DECLARE maternalcompcaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap17" ,
   "Maternal Complications:" ) )
 DECLARE pretermlaborcaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap18" ,
   "Preterm Labor:" ) )
 DECLARE commentcaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap19" ,
   "Comment:" ) )
 DECLARE wkcaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap20" ," weeks"
   ) )
 DECLARE dcaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap21" ," days" )
  )
 DECLARE hrcaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap22" ," hr" ) )
 DECLARE mincaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap23" ," min" )
  )
 DECLARE gcaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap24" ," g" ) )
 DECLARE gmscaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap25" ," gms" )
  )
 DECLARE multfetusbirthcaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,
   "cap26" ,"*denotes multiple baby birth" ) )
 DECLARE sensitivecaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap27" ,
   "      **Marked as Sensitive**" ) )
 DECLARE babycaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap28" ,
   "        Baby" ) )
 DECLARE modifiedcaption = vc WITH protect ,noconstant (uar_i18ngetmessage (i18nhandle ,"cap29" ,
   " (c)" ) )
 DECLARE mother_comp_text = vc
 DECLARE anesth_comp_text = vc
 DECLARE neonate_comp_text = vc
 DECLARE fetal_comp_text = vc
 DECLARE preterm_labor_text = vc
 DECLARE infant_weight = vc
 DECLARE len_labor = vc
 DECLARE name_of_child = vc
 DECLARE name_of_father = vc
 DECLARE hospital = vc
 SET para_gravida_located = 0
 SET g_info->gravida = "0"
 SET g_info->para_details = "0"
 SET g_info->para_full_term = "0"
 SET g_info->para_premature = "0"
 SET g_info->para_abortions = "0"
 SET g_info->para = "0"
 SET g_info->mod_ind = " "
 SELECT
  IF ((chart_access_flag = 1 ) ) INTO "nl:"
   FROM (clinical_event ce )
   PLAN (ce
    WHERE (ce.person_id = request->person[1 ].person_id )
    AND (ce.event_cd IN (gravida ,
    para_details ,
    para_full_term ,
    para_premature ,
    para_abortions ,
    para_living ) )
    AND (ce.result_status_cd IN (auth ,
    altered ,
    modified ) )
    AND (ce.event_tag != "Date\Time Correction" )
    AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND expand (en_idx ,1 ,size (encntr_list->qual ,5 ) ,ce.encntr_id ,encntr_list->qual[en_idx ].
     value ) )
   ORDER BY ce.event_cd ,
    ce.event_end_dt_tm DESC
  ELSE INTO "nl:"
   FROM (clinical_event ce )
   PLAN (ce
    WHERE (ce.person_id = request->person[1 ].person_id )
    AND (ce.event_cd IN (gravida ,
    para_details ,
    para_full_term ,
    para_premature ,
    para_abortions ,
    para_living ) )
    AND (ce.result_status_cd IN (auth ,
    altered ,
    modified ) )
    AND (ce.event_tag != "Date\Time Correction" )
    AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
   ORDER BY ce.event_cd ,
    ce.event_end_dt_tm DESC
  ENDIF
  HEAD REPORT
   g_info->gravida = "0" ,
   g_info->para_details = "0" ,
   g_info->para_full_term = "0" ,
   g_info->para_premature = "0" ,
   g_info->para_abortions = "0" ,
   g_info->para = "0" ,
   g_info->mod_ind = " "
  HEAD ce.event_cd
   g_info->mod_ind = " " ,
   CASE (ce.event_cd )
    OF gravida :
     g_info->gravida = trim (ce.result_val ) ,
     IF ((ce.result_status_cd = modified ) ) g_info->mod_ind = modifiedcaption
     ENDIF
    OF para_details :
     g_info->para_details = trim (ce.result_val ) ,
     IF ((ce.result_status_cd = modified ) ) g_info->mod_ind = modifiedcaption
     ENDIF
    OF para_full_term :
     g_info->para_full_term = trim (ce.result_val ) ,
     IF ((ce.result_status_cd = modified ) ) g_info->mod_ind = modifiedcaption
     ENDIF
    OF para_premature :
     g_info->para_premature = trim (ce.result_val ) ,
     IF ((ce.result_status_cd = modified ) ) g_info->mod_ind = modifiedcaption
     ENDIF
    OF para_abortions :
     g_info->para_abortions = trim (ce.result_val ) ,
     IF ((ce.result_status_cd = modified ) ) g_info->mod_ind = modifiedcaption
     ENDIF
    OF para_living :
     g_info->para = trim (ce.result_val ) ,
     IF ((ce.result_status_cd = modified ) ) g_info->mod_ind = modifiedcaption
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 SELECT
  IF ((chart_access_flag = 1 ) ) INTO "nl:"
   dlv_date = format (pc.delivery_dt_tm ,"mm/dd/yyyy;;d" ) ,
   gest_at_birth =
   IF ((pc.gestation_age > 0 ) )
    IF ((mod (pc.gestation_age ,7 ) = 0 ) ) build ((pc.gestation_age / 7 ) ,wkcaption )
    ELSE concat (trim (cnvtstring ((pc.gestation_age / 7 ) ) ) ,wkcaption ," " ,trim (cnvtstring (
        mod (pc.gestation_age ,7 ) ) ) ,dcaption )
    ENDIF
   ELSEIF ((pc.gestation_term_txt > " " ) ) substring (1 ,13 ,pc.gestation_term_txt )
   ELSE snot_documented
   ENDIF
   ,gender =
   IF ((pc.gender_cd > 0 ) ) substring (1 ,13 ,uar_get_code_display (pc.gender_cd ) )
   ELSE snot_documented
   ENDIF
   ,lol =
   IF ((pc.labor_duration > 0 ) )
    IF ((mod (pc.labor_duration ,60 ) = 0 ) ) build ((pc.labor_duration / 60 ) ,hrcaption )
    ELSE concat (trim (cnvtstring ((pc.labor_duration / 60 ) ) ) ,hrcaption ," " ,trim (cnvtstring (
        mod (pc.labor_duration ,60 ) ) ) ,mincaption )
    ENDIF
   ELSE snot_documented
   ENDIF
   ,wt =
   IF ((pc.weight_amt > 0 ) )
    IF ((pc.weight_unit_cd = lb_cd ) ) concat (format ((1000 * (pc.weight_amt / 2.2046 ) ) ,"#####"
       ) ,gcaption )
    ELSEIF ((pc.weight_unit_cd = kg_cd ) ) concat (format ((1000 * pc.weight_amt ) ,"#####" ) ,
      gcaption )
    ELSEIF ((pc.weight_unit_cd = gm_cd ) ) concat (format (pc.weight_amt ,"#####" ) ,gcaption )
    ENDIF
   ELSE snot_documented
   ENDIF
   ,neo_out =
   IF ((pc.neonate_outcome_cd > 0 ) ) substring (1 ,15 ,uar_get_code_display (pc.neonate_outcome_cd
      ) )
   ELSE snot_documented
   ENDIF
   ,preg_out =
   IF ((pc.delivery_method_cd > 0 ) ) uar_get_code_display (pc.delivery_method_cd )
   ELSE snot_documented
   ENDIF
   ,compl = uar_get_code_display (pr.parent_entity_id ) ,
   delivery_hospital =
   IF ((pc.delivery_hospital > " " ) ) substring (1 ,30 ,pc.delivery_hospital )
   ELSE snot_documented
   ENDIF
   ,child_name =
   IF ((pc.child_name > " " ) ) substring (1 ,30 ,pc.child_name )
   ELSE snot_documented
   ENDIF
   ,father_name =
   IF ((pc.father_name > " " ) ) substring (1 ,30 ,pc.father_name )
   ELSE snot_documented
   ENDIF
   ,preg_comments = trim (lt.long_text ) ,
   anesthesia = trim (pc.anesthesia_txt ) ,
   preterm_labor = trim (pc.preterm_labor_txt )
   FROM (pregnancy_instance pi ),
    (pregnancy_child pc ),
    (pregnancy_child_entity_r pr ),
    (long_text lt ),
    (code_value cv ),
    (nomenclature n ),
    (long_text lt2 )
   PLAN (pi
    WHERE (pi.person_id = request->person[1 ].person_id )
    AND (pi.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (pi.active_ind = 1 )
    AND expand (en_idx ,1 ,size (encntr_list->qual ,5 ) ,pi.encntr_id ,encntr_list->qual[en_idx ].
     value ) )
    JOIN (pc
    WHERE (pc.pregnancy_id = pi.pregnancy_id )
    AND (pc.active_ind = 1 )
    AND (pc.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
    JOIN (pr
    WHERE (pr.pregnancy_child_id = outerjoin (pc.pregnancy_child_id ) )
    AND (pr.active_ind = outerjoin (1 ) ) )
    JOIN (cv
    WHERE (cv.code_value = outerjoin (pr.parent_entity_id ) ) )
    JOIN (n
    WHERE (n.nomenclature_id = outerjoin (pr.parent_entity_id ) ) )
    JOIN (lt
    WHERE (lt.parent_entity_id = outerjoin (pc.pregnancy_child_id ) )
    AND (lt.parent_entity_name = outerjoin ("PREGNANCY_CHILD" ) )
    AND (lt.active_ind = outerjoin (1 ) ) )
    JOIN (lt2
    WHERE (lt2.long_text_id = outerjoin (pr.parent_entity_id ) ) )
   ORDER BY pc.delivery_dt_tm ,
    pc.pregnancy_child_id ,
    pr.component_type_cd ,
    n.source_string ,
    cv.display ,
    pr.updt_dt_tm
  ELSE INTO "nl:"
   dlv_date = format (pc.delivery_dt_tm ,"mm/dd/yyyy;;d" ) ,
   gest_at_birth =
   IF ((pc.gestation_age > 0 ) )
    IF ((mod (pc.gestation_age ,7 ) = 0 ) ) build ((pc.gestation_age / 7 ) ,wkcaption )
    ELSE concat (trim (cnvtstring ((pc.gestation_age / 7 ) ) ) ,wkcaption ," " ,trim (cnvtstring (
        mod (pc.gestation_age ,7 ) ) ) ,dcaption )
    ENDIF
   ELSEIF ((pc.gestation_term_txt > " " ) ) substring (1 ,13 ,pc.gestation_term_txt )
   ELSE snot_documented
   ENDIF
   ,gender =
   IF ((pc.gender_cd > 0 ) ) substring (1 ,13 ,uar_get_code_display (pc.gender_cd ) )
   ELSE snot_documented
   ENDIF
   ,lol =
   IF ((pc.labor_duration > 0 ) )
    IF ((mod (pc.labor_duration ,60 ) = 0 ) ) build ((pc.labor_duration / 60 ) ,hrcaption )
    ELSE concat (trim (cnvtstring ((pc.labor_duration / 60 ) ) ) ,hrcaption ," " ,trim (cnvtstring (
        mod (pc.labor_duration ,60 ) ) ) ,mincaption )
    ENDIF
   ELSE snot_documented
   ENDIF
   ,wt =
   IF ((pc.weight_amt > 0 ) )
    IF ((pc.weight_unit_cd = lb_cd ) ) concat (format ((1000 * (pc.weight_amt / 2.2046 ) ) ,"#####"
       ) ,gcaption )
    ELSEIF ((pc.weight_unit_cd = kg_cd ) ) concat (format ((1000 * pc.weight_amt ) ,"#####" ) ,
      gcaption )
    ELSEIF ((pc.weight_unit_cd = gm_cd ) ) concat (format (pc.weight_amt ,"#####" ) ,gcaption )
    ENDIF
   ELSE snot_documented
   ENDIF
   ,neo_out =
   IF ((pc.neonate_outcome_cd > 0 ) ) substring (1 ,15 ,uar_get_code_display (pc.neonate_outcome_cd
      ) )
   ELSE snot_documented
   ENDIF
   ,preg_out =
   IF ((pc.delivery_method_cd > 0 ) ) uar_get_code_display (pc.delivery_method_cd )
   ELSE snot_documented
   ENDIF
   ,compl = uar_get_code_display (pr.parent_entity_id ) ,
   delivery_hospital =
   IF ((pc.delivery_hospital > " " ) ) substring (1 ,30 ,pc.delivery_hospital )
   ELSE snot_documented
   ENDIF
   ,child_name =
   IF ((pc.child_name > " " ) ) substring (1 ,30 ,pc.child_name )
   ELSE snot_documented
   ENDIF
   ,father_name =
   IF ((pc.father_name > " " ) ) substring (1 ,30 ,pc.father_name )
   ELSE snot_documented
   ENDIF
   ,preg_comments = trim (lt.long_text ) ,
   anesthesia = trim (pc.anesthesia_txt ) ,
   preterm_labor = trim (pc.preterm_labor_txt )
   FROM (pregnancy_instance pi ),
    (pregnancy_child pc ),
    (pregnancy_child_entity_r pr ),
    (long_text lt ),
    (code_value cv ),
    (nomenclature n ),
    (long_text lt2 )
   PLAN (pi
    WHERE (pi.person_id = request->person[1 ].person_id )
    AND (pi.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (pi.active_ind = 1 ) )
    JOIN (pc
    WHERE (pc.pregnancy_id = pi.pregnancy_id )
    AND (pc.active_ind = 1 )
    AND (pc.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
    JOIN (pr
    WHERE (pr.pregnancy_child_id = outerjoin (pc.pregnancy_child_id ) )
    AND (pr.active_ind = outerjoin (1 ) ) )
    JOIN (cv
    WHERE (cv.code_value = outerjoin (pr.parent_entity_id ) ) )
    JOIN (n
    WHERE (n.nomenclature_id = outerjoin (pr.parent_entity_id ) ) )
    JOIN (lt
    WHERE (lt.parent_entity_id = outerjoin (pc.pregnancy_child_id ) )
    AND (lt.parent_entity_name = outerjoin ("PREGNANCY_CHILD" ) )
    AND (lt.active_ind = outerjoin (1 ) ) )
    JOIN (lt2
    WHERE (lt2.long_text_id = outerjoin (pr.parent_entity_id ) ) )
   ORDER BY pc.delivery_dt_tm ,
    pc.pregnancy_child_id ,
    pr.component_type_cd ,
    n.source_string ,
    cv.display ,
    pr.updt_dt_tm
  ENDIF
  HEAD REPORT
   preg_cnt = 0 ,
   child_cnt = 0
  HEAD pi.pregnancy_instance_id
   preg_cnt = (preg_cnt + 1 ) ,child_cnt = 0 ,stat = alterlist (preghist->preg ,preg_cnt ) ,
   IF ((pi.sensitive_ind = 1 ) ) preghist->preg[preg_cnt ].sensitive_ind = 1
   ENDIF
  HEAD pc.pregnancy_child_id
   child_cnt = (child_cnt + 1 ) ,stat = alterlist (preghist->preg[preg_cnt ].child ,child_cnt ) ,
   CASE (pc.delivery_date_precision_flag )
    OF 0 :
     preghist->preg[preg_cnt ].child[child_cnt ].dlv_date = format (pc.delivery_dt_tm ,
      "@SHORTDATE4YR" )
    OF 1 :
     preghist->preg[preg_cnt ].child[child_cnt ].dlv_date = format (pc.delivery_dt_tm ,"MM/YYYY;;d"
      )
    OF 2 :
     preghist->preg[preg_cnt ].child[child_cnt ].dlv_date = format (pc.delivery_dt_tm ,"YYYY;;d" )
    OF 3 :
     preghist->preg[preg_cnt ].child[child_cnt ].dlv_date = format (pc.delivery_dt_tm ,"YYYY;;d" )
   ENDCASE
   ,preghist->preg[preg_cnt ].child[child_cnt ].delivery_date_qualifier_flag = pc.delivery_date_qualifier_flag
   ,case (pc.delivery_date_qualifier_flag)
	of 1:	preghist->preg[preg_cnt ].child[child_cnt ].delivery_date_qualifier = "Before "
	of 2:	preghist->preg[preg_cnt ].child[child_cnt ].delivery_date_qualifier = "About "
	of 3:	preghist->preg[preg_cnt ].child[child_cnt ].delivery_date_qualifier = "After "
   endcase
   ,preghist->preg[preg_cnt ].child[child_cnt ].gest_at_birth = gest_at_birth ,preghist->preg[
   preg_cnt ].child[child_cnt ].child_gender = gender ,preghist->preg[preg_cnt ].child[child_cnt ].
   length_labor = lol ,preghist->preg[preg_cnt ].child[child_cnt ].infant_wt = trim (wt ) ,preghist->
   preg[preg_cnt ].child[child_cnt ].preterm_labor = pc.preterm_labor_txt ,preghist->preg[preg_cnt ].
   child[child_cnt ].neonate_outcome = neo_out ,preghist->preg[preg_cnt ].child[child_cnt ].
   preg_outcome = preg_out ,preghist->preg[preg_cnt ].child[child_cnt ].anesth_type = pc
   .anesthesia_txt ,preghist->preg[preg_cnt ].child[child_cnt ].dlv_hosp = delivery_hospital ,
   preghist->preg[preg_cnt ].child[child_cnt ].child_name = child_name ,preghist->preg[preg_cnt ].
   child[child_cnt ].father_name = father_name ,preghist->preg[preg_cnt ].child[child_cnt ].
   preg_comments = preg_comments ,preghist->preg[preg_cnt ].child[child_cnt ].child_comment_id = pc
   .child_comment_id ,mother_comp_text = " " ,anesth_comp_text = " " ,neonate_comp_text = " " ,
   fetal_comp_text = " " ,preterm_labor_text = " " ,mother_comp_cnt = 0 ,anesth_comp_cnt = 0 ,
   neonate_comp_cnt = 0 ,fetal_comp_cnt = 0 ,preterm_labor_cnt = 0 ,preghist->preg[preg_cnt ].child[
   child_cnt ].maternal_complic_ind = 0 ,preghist->preg[preg_cnt ].child[child_cnt ].anesth_type_ind
   = 0 ,preghist->preg[preg_cnt ].child[child_cnt ].neonate_complic_ind = 0 ,preghist->preg[preg_cnt
   ].child[child_cnt ].preterm_labor_ind = 0 ,preghist->preg[preg_cnt ].child[child_cnt ].
   fetal_complic_ind = 0 ,
   IF ((pc.anesthesia_txt > " " ) ) anesth_comp_text = trim (build (anesth_comp_text ,";" ,pc
      .anesthesia_txt ) ) ,preghist->preg[preg_cnt ].child[child_cnt ].anesth_type_ind = 1
   ENDIF
   ,
   IF ((pc.preterm_labor_txt > " " ) ) preterm_labor_text = trim (build (preterm_labor_text ,";" ,pc
      .preterm_labor_txt ) ) ,preghist->preg[preg_cnt ].child[child_cnt ].preterm_labor_ind = 1
   ENDIF
  DETAIL
   CASE (pr.component_type_cd )
    OF fetus_comp :
     fetal_comp_cnt = (fetal_comp_cnt + 1 ) ,
     IF ((preghist->preg[preg_cnt ].child[child_cnt ].fetal_complic_ind = 0 ) ) preghist->preg[
      preg_cnt ].child[child_cnt ].fetal_complic_ind = 1
     ENDIF
     ,
     IF ((pr.parent_entity_name = "NOMENCLATURE" ) ) fetal_comp_text = trim (build (fetal_comp_text ,
        ";" ,n.source_string ) )
     ELSEIF ((pr.parent_entity_name = "LONG_TEXT" ) ) fetal_comp_text = trim (build (fetal_comp_text
        ,";" ,lt2.long_text ) )
     ELSEIF ((pr.parent_entity_name = "CODE_VALUE" ) ) fetal_comp_text = trim (build (
        fetal_comp_text ,";" ,cv.display ) )
     ENDIF
    OF mother_comp :
     mother_comp_cnt = (mother_comp_cnt + 1 ) ,
     IF ((preghist->preg[preg_cnt ].child[child_cnt ].maternal_complic_ind = 0 ) ) preghist->preg[
      preg_cnt ].child[child_cnt ].maternal_complic_ind = 1
     ENDIF
     ,
     IF ((pr.parent_entity_name = "NOMENCLATURE" ) ) mother_comp_text = trim (build (
        mother_comp_text ,";" ,n.source_string ) )
     ELSEIF ((pr.parent_entity_name = "LONG_TEXT" ) ) mother_comp_text = trim (build (
        mother_comp_text ,";" ,lt2.long_text ) )
     ELSEIF ((pr.parent_entity_name = "CODE_VALUE" ) ) mother_comp_text = trim (build (
        mother_comp_text ,";" ,cv.display ) )
     ENDIF
    OF newborn_comp :
     neonate_comp_cnt = (neonate_comp_cnt + 1 ) ,
     IF ((preghist->preg[preg_cnt ].child[child_cnt ].neonate_complic_ind = 0 ) ) preghist->preg[
      preg_cnt ].child[child_cnt ].neonate_complic_ind = 1
     ENDIF
     ,
     IF ((pr.parent_entity_name = "NOMENCLATURE" ) ) neonate_comp_text = trim (build (
        neonate_comp_text ,";" ,n.source_string ) )
     ELSEIF ((pr.parent_entity_name = "LONG_TEXT" ) ) neonate_comp_text = trim (build (
        neonate_comp_text ,";" ,lt2.long_text ) )
     ELSEIF ((pr.parent_entity_name = "CODE_VALUE" ) ) neonate_comp_text = trim (build (
        neonate_comp_text ,";" ,cv.display ) )
     ENDIF
    OF anesth_comp :
     anesth_comp_cnt = (anesth_comp_cnt + 1 ) ,
     IF ((preghist->preg[preg_cnt ].child[child_cnt ].anesth_type_ind = 0 ) ) preghist->preg[
      preg_cnt ].child[child_cnt ].anesth_type_ind = 1
     ENDIF
     ,
     IF ((pr.parent_entity_name = "NOMENCLATURE" ) ) anesth_comp_text = trim (build (
        anesth_comp_text ,";" ,n.source_string ) )
     ELSEIF ((pr.parent_entity_name = "LONG_TEXT" ) ) anesth_comp_text = trim (build (
        anesth_comp_text ,";" ,lt2.long_text ) )
     ELSEIF ((pr.parent_entity_name = "CODE_VALUE" ) ) anesth_comp_text = trim (build (
        anesth_comp_text ,";" ,cv.display ) )
     ENDIF
    OF preterm_comp :
     preterm_labor_cnt = (preterm_labor_cnt + 1 ) ,
     IF ((preghist->preg[preg_cnt ].child[child_cnt ].preterm_labor_ind = 0 ) ) preghist->preg[
      preg_cnt ].child[child_cnt ].preterm_labor_ind = 1
     ENDIF
     ,
     IF ((pr.parent_entity_name = "NOMENCLATURE" ) ) preterm_labor_text = trim (build (
        preterm_labor_text ,";" ,n.source_string ) )
     ELSEIF ((pr.parent_entity_name = "LONG_TEXT" ) ) preterm_labor_text = trim (build (
        preterm_labor_text ,";" ,lt2.long_text ) )
     ELSEIF ((pr.parent_entity_name = "CODE_VALUE" ) ) preterm_labor_text = trim (build (
        preterm_labor_text ,";" ,cv.display ) )
     ENDIF
   ENDCASE
  FOOT  pc.pregnancy_child_id
   preghist->preg[preg_cnt ].child_cnt = child_cnt ,
   IF ((preghist->preg[preg_cnt ].child[child_cnt ].fetal_complic_ind = 1 ) ) preghist->preg[
    preg_cnt ].child[child_cnt ].fetal_complic = fetal_comp_text ,preghist->preg[preg_cnt ].child[
    child_cnt ].fetal_complic = trim (replace (preghist->preg[preg_cnt ].child[child_cnt ].
      fetal_complic ,";" ,"" ,1 ) ,3 ) ,preghist->preg[preg_cnt ].child[child_cnt ].fetal_complic =
    replace (preghist->preg[preg_cnt ].child[child_cnt ].fetal_complic ,";" ,"; " )
   ENDIF
   ,
   IF ((preghist->preg[preg_cnt ].child[child_cnt ].maternal_complic_ind = 1 ) ) preghist->preg[
    preg_cnt ].child[child_cnt ].maternal_complic = mother_comp_text ,preghist->preg[preg_cnt ].
    child[child_cnt ].maternal_complic = trim (replace (preghist->preg[preg_cnt ].child[child_cnt ].
      maternal_complic ,";" ,"" ,1 ) ,3 ) ,preghist->preg[preg_cnt ].child[child_cnt ].
    maternal_complic = replace (preghist->preg[preg_cnt ].child[child_cnt ].maternal_complic ,";" ,
     "; " )
   ENDIF
   ,
   IF ((preghist->preg[preg_cnt ].child[child_cnt ].neonate_complic_ind = 1 ) ) preghist->preg[
    preg_cnt ].child[child_cnt ].neonate_complic = neonate_comp_text ,preghist->preg[preg_cnt ].
    child[child_cnt ].neonate_complic = trim (replace (preghist->preg[preg_cnt ].child[child_cnt ].
      neonate_complic ,";" ,"" ,1 ) ,3 ) ,preghist->preg[preg_cnt ].child[child_cnt ].neonate_complic
     = replace (preghist->preg[preg_cnt ].child[child_cnt ].neonate_complic ,";" ,"; " )
   ENDIF
   ,
   IF ((preghist->preg[preg_cnt ].child[child_cnt ].anesth_type_ind = 1 ) ) preghist->preg[preg_cnt ]
    .child[child_cnt ].anesth_type = anesth_comp_text ,preghist->preg[preg_cnt ].child[child_cnt ].
    anesth_type = trim (replace (preghist->preg[preg_cnt ].child[child_cnt ].anesth_type ,";" ,"" ,1
      ) ,3 ) ,preghist->preg[preg_cnt ].child[child_cnt ].anesth_type = replace (preghist->preg[
     preg_cnt ].child[child_cnt ].anesth_type ,";" ,"; " )
   ENDIF
   ,
   IF ((preghist->preg[preg_cnt ].child[child_cnt ].preterm_labor_ind = 1 ) ) preghist->preg[
    preg_cnt ].child[child_cnt ].preterm_labor = preterm_labor_text ,preghist->preg[preg_cnt ].child[
    child_cnt ].preterm_labor = trim (replace (preghist->preg[preg_cnt ].child[child_cnt ].
      preterm_labor ,";" ,"" ,1 ) ,3 ) ,preghist->preg[preg_cnt ].child[child_cnt ].preterm_labor =
    replace (preghist->preg[preg_cnt ].child[child_cnt ].preterm_labor ,";" ,"; " )
   ENDIF
  FOOT  pi.pregnancy_instance_id
   preghist->preg_cnt = preg_cnt
  WITH nocounter ,outerjoin = d1
 ;end select
 FOR (pcnt = 1 TO preghist->preg_cnt )
  FOR (ccnt = 1 TO preghist->preg[pcnt ].child_cnt )
   IF ((preghist->preg[pcnt ].child[ccnt ].child_comment_id > 0 ) )
    FREE RECORD pt
    RECORD pt (
      1 line_cnt = i2
      1 lns [* ]
        2 line = vc
    )
    SET pt->line_cnt = 0
    SET max_length = 90
    EXECUTE dcp_parse_text value (preghist->preg[pcnt ].child[ccnt ].preg_comments ) ,
    value (max_length )
    SET stat = alterlist (preghist->preg[pcnt ].child[ccnt ].comment_wrapped ,pt->line_cnt )
    FOR (wrapcnt = 1 TO pt->line_cnt )
     SET preghist->preg[pcnt ].child[ccnt ].comment_wrapped[wrapcnt ].wrap_text = pt->lns[wrapcnt ].
     line
    ENDFOR
   ENDIF
  ENDFOR
 ENDFOR
 FOR (pcnt = 1 TO preghist->preg_cnt )
  FOR (ccnt = 1 TO preghist->preg[pcnt ].child_cnt )
   IF ((preghist->preg[pcnt ].child[ccnt ].maternal_complic_ind = 1 ) )
    FREE RECORD pt
    RECORD pt (
      1 line_cnt = i2
      1 lns [* ]
        2 line = vc
    )
    SET pt->line_cnt = 0
    SET max_length = 90
    EXECUTE dcp_parse_text value (preghist->preg[pcnt ].child[ccnt ].maternal_complic ) ,
    value (max_length )
    SET stat = alterlist (preghist->preg[pcnt ].child[ccnt ].maternal_comp_wrap ,pt->line_cnt )
    FOR (wrapcnt = 1 TO pt->line_cnt )
     SET preghist->preg[pcnt ].child[ccnt ].maternal_comp_wrap[wrapcnt ].wrap_text = pt->lns[wrapcnt
     ].line
    ENDFOR
   ENDIF
  ENDFOR
 ENDFOR
 FOR (pcnt = 1 TO preghist->preg_cnt )
  FOR (ccnt = 1 TO preghist->preg[pcnt ].child_cnt )
   IF ((preghist->preg[pcnt ].child[ccnt ].anesth_type_ind = 1 ) )
    FREE RECORD pt
    RECORD pt (
      1 line_cnt = i2
      1 lns [* ]
        2 line = vc
    )
    SET pt->line_cnt = 0
    SET max_length = 90
    EXECUTE dcp_parse_text value (preghist->preg[pcnt ].child[ccnt ].anesth_type ) ,
    value (max_length )
    SET stat = alterlist (preghist->preg[pcnt ].child[ccnt ].anesth_type_wrap ,pt->line_cnt )
    FOR (wrapcnt = 1 TO pt->line_cnt )
     SET preghist->preg[pcnt ].child[ccnt ].anesth_type_wrap[wrapcnt ].wrap_text = pt->lns[wrapcnt ].
     line
    ENDFOR
   ENDIF
  ENDFOR
 ENDFOR
 FOR (pcnt = 1 TO preghist->preg_cnt )
  FOR (ccnt = 1 TO preghist->preg[pcnt ].child_cnt )
   IF ((preghist->preg[pcnt ].child[ccnt ].fetal_complic_ind = 1 ) )
    FREE RECORD pt
    RECORD pt (
      1 line_cnt = i2
      1 lns [* ]
        2 line = vc
    )
    SET pt->line_cnt = 0
    SET max_length = 90
    EXECUTE dcp_parse_text value (preghist->preg[pcnt ].child[ccnt ].fetal_complic ) ,
    value (max_length )
    SET stat = alterlist (preghist->preg[pcnt ].child[ccnt ].fetal_comp_wrap ,pt->line_cnt )
    FOR (wrapcnt = 1 TO pt->line_cnt )
     SET preghist->preg[pcnt ].child[ccnt ].fetal_comp_wrap[wrapcnt ].wrap_text = pt->lns[wrapcnt ].
     line
    ENDFOR
   ENDIF
  ENDFOR
 ENDFOR
 FOR (pcnt = 1 TO preghist->preg_cnt )
  FOR (ccnt = 1 TO preghist->preg[pcnt ].child_cnt )
   IF ((preghist->preg[pcnt ].child[ccnt ].neonate_complic_ind = 1 ) )
    FREE RECORD pt
    RECORD pt (
      1 line_cnt = i2
      1 lns [* ]
        2 line = vc
    )
    SET pt->line_cnt = 0
    SET max_length = 90
    EXECUTE dcp_parse_text value (preghist->preg[pcnt ].child[ccnt ].neonate_complic ) ,
    value (max_length )
    SET stat = alterlist (preghist->preg[pcnt ].child[ccnt ].neonate_comp_wrap ,pt->line_cnt )
    FOR (wrapcnt = 1 TO pt->line_cnt )
     SET preghist->preg[pcnt ].child[ccnt ].neonate_comp_wrap[wrapcnt ].wrap_text = pt->lns[wrapcnt ]
     .line
    ENDFOR
   ENDIF
  ENDFOR
 ENDFOR
 FOR (pcnt = 1 TO preghist->preg_cnt )
  FOR (ccnt = 1 TO preghist->preg[pcnt ].child_cnt )
   IF ((preghist->preg[pcnt ].child[ccnt ].preterm_labor_ind = 1 ) )
    FREE RECORD pt
    RECORD pt (
      1 line_cnt = i2
      1 lns [* ]
        2 line = vc
    )
    SET pt->line_cnt = 0
    SET max_length = 90
    EXECUTE dcp_parse_text value (preghist->preg[pcnt ].child[ccnt ].preterm_labor ) ,
    value (max_length )
    SET stat = alterlist (preghist->preg[pcnt ].child[ccnt ].preterm_labor_wrap ,pt->line_cnt )
    FOR (wrapcnt = 1 TO pt->line_cnt )
     SET preghist->preg[pcnt ].child[ccnt ].preterm_labor_wrap[wrapcnt ].wrap_text = pt->lns[wrapcnt
     ].line
    ENDFOR
   ENDIF
  ENDFOR
 ENDFOR
 IF (validate (debug_ind ,0 ) )
  CALL echorecord (g_info )
  CALL echorecord (preghist )
 ENDIF
 IF ((stand_alone_ind = 0 ) )
  SET reply->text = concat (reply->text ,rsechead ,colornavy ,preghistorycaption ,wr )
 ELSE
  SET reply->text = concat (reply->text ,rhead ,rhead_colors1 ,rhead_colors2 ,rhead_colors3 )
  IF ((validate (antepartum_run_ind ) = 1 ) )
   SET reply->text = concat (reply->text ,rsechead ,colornavy ,preghistorycaption ,wr )
  ENDIF
 ENDIF
 SET reply->text = concat (reply->text ,"    " ,wb18 ,"G" ,g_info->gravida ," P" ,g_info->
  para_details ,"(" ,g_info->para_full_term ,"," ,g_info->para_premature ,"," ,g_info->para_abortions
   ,"," ,g_info->para ,")" ,wsd ,"     " ,colorgrey ,wr )
 IF ((size (preghist->preg ,5 ) < 1 ) )
  SET reply->text = concat (reply->text ,rpard ,rtabstopnd ,reol ,reol ,rtab ,wr ,nodatacaption )
 ENDIF
 FOR (p = 1 TO size (preghist->preg ,5 ) )
  SET preg_nbr = trim (cnvtstring (p ) )
  IF ((p = 1 ) )
   SET reply->text = concat (reply->text ,rpard ,"\tx1000\tx4400\tx6300" ,reol ,wb ,pregnumcaption ,
    " " ,preg_nbr )
  ELSE
   SET reply->text = concat (reply->text ,rpard ,"\tx1000\tx4400\tx6300" ,reol ,reol ,wb ,
    pregnumcaption ," " ,preg_nbr )
  ENDIF
  IF ((preghist->preg[p ].sensitive_ind = 1 ) )
   SET reply->text = concat (reply->text ,wr ,colorred ,sensitivecaption ,wr )
  ENDIF
  FOR (c = 1 TO size (preghist->preg[p ].child ,5 ) )
   SET baby_nbr = trim (cnvtstring (c ) )
   SET reply->text = concat (reply->text ,reol ,wr ,babycaption ," " ,baby_nbr ,reol )
   IF ((preghist->preg[p ].child[c ].infant_wt != snot_documented ) )
    SET infant_weight = concat (rtab ,wr ,colorgrey ,wtabbrvcaption ," " ,wr ,preghist->preg[p ].
     child[c ].infant_wt )
   ENDIF
   SET reply->text = concat (
   								 reply->text 
   								,wr 
   								,rtab 
   								,wr 
   								,colorgrey 
   								,outcomecaption 
   								," "
   							)
   							
   if (preghist->preg[p ].child[c ].delivery_date_qualifier_flag in(1,2,3))
   	SET reply->text = concat (
   								 reply->text 
   								,wr 
   								,preghist->preg[p ].child[c ].delivery_date_qualifier
   								," "
   								,wr
   							)
   endif
   
   SET reply->text = concat (
   								 reply->text
   								,wr
   								,preghist->preg[p ].child[c ].dlv_date 
   								,rtab 
   								,wr 
 						 		,colorgrey 
   								,pregoutcomecaption 
   								," " 
   								,wr 
   								,preghist->preg[p ].child[c ].preg_outcome 
   								,reol 
   								,rtab 
   								,wr 
   								,colorgrey 
   								,gestagecaption 
   								," " 
   								,wr 
   								,preghist->preg[p].child[c ].gest_at_birth 
   								,rtab 
   								,wr 
   								,colorgrey 
   								,neonateoutcomecaption 
   								," " 
   								,wr 
   								,preghist->preg[p].child[c ].neonate_outcome
   								,reol 
   								,rtab 
   								,wr 
   								,colorgrey 
   								,gendercaption 
   								," " 
   								,wr 
   								,preghist->preg[p].child[c ].child_gender 
   								,infant_weight 
   							)
   FOR (z = 1 TO size (preghist->preg[p ].child[c ].maternal_comp_wrap ,5 ) )
    IF ((z = 1 ) )
     SET reply->text = concat (reply->text ,reol ,rtab ,wr ,colorgrey ,maternalcompcaption ," " ,wr ,
      preghist->preg[p ].child[c ].maternal_comp_wrap[z ].wrap_text )
    ELSE
     SET reply->text = concat (reply->text ,reol ,rtab ,preghist->preg[p ].child[c ].
      maternal_comp_wrap[z ].wrap_text )
    ENDIF
   ENDFOR
   FOR (z = 1 TO size (preghist->preg[p ].child[c ].fetal_comp_wrap ,5 ) )
    IF ((z = 1 ) )
     SET reply->text = concat (reply->text ,reol ,rtab ,wr ,colorgrey ,fetalcompcaption ," " ,wr ,
      preghist->preg[p ].child[c ].fetal_comp_wrap[z ].wrap_text )
    ELSE
     SET reply->text = concat (reply->text ,reol ,rtab ,preghist->preg[p ].child[c ].fetal_comp_wrap[
      z ].wrap_text )
    ENDIF
   ENDFOR
   FOR (z = 1 TO size (preghist->preg[p ].child[c ].neonate_comp_wrap ,5 ) )
    IF ((z = 1 ) )
     SET reply->text = concat (reply->text ,reol ,rtab ,wr ,colorgrey ,neonatecompcaption ," " ,wr ,
      preghist->preg[p ].child[c ].neonate_comp_wrap[z ].wrap_text )
    ELSE
     SET reply->text = concat (reply->text ,reol ,rtab ,preghist->preg[p ].child[c ].
      neonate_comp_wrap[z ].wrap_text )
    ENDIF
   ENDFOR
   FOR (z = 1 TO size (preghist->preg[p ].child[c ].anesth_type_wrap ,5 ) )
    IF ((z = 1 ) )
     SET reply->text = concat (reply->text ,reol ,rtab ,wr ,colorgrey ,anesthesiacaption ," " ,wr ,
      preghist->preg[p ].child[c ].anesth_type_wrap[z ].wrap_text )
    ELSE
     SET reply->text = concat (reply->text ,reol ,rtab ,preghist->preg[p ].child[c ].
      anesth_type_wrap[z ].wrap_text )
    ENDIF
   ENDFOR
   FOR (z = 1 TO size (preghist->preg[p ].child[c ].preterm_labor_wrap ,5 ) )
    IF ((z = 1 ) )
     SET reply->text = concat (reply->text ,reol ,rtab ,wr ,colorgrey ,pretermlaborcaption ," " ,wr ,
      preghist->preg[p ].child[c ].preterm_labor_wrap[z ].wrap_text )
    ELSE
     SET reply->text = concat (reply->text ,reol ,rtab ,preghist->preg[p ].child[c ].
      preterm_labor_wrap[z ].wrap_text )
    ENDIF
   ENDFOR
   IF ((preghist->preg[p ].child[c ].length_labor != snot_documented ) )
    SET len_labor = concat (reol ,rtab ,wr ,colorgrey ,lenlaborcaption ," " ,wr ,preghist->preg[p ].
     child[c ].length_labor )
   ENDIF
   IF ((preghist->preg[p ].child[c ].child_name != snot_documented ) )
    SET name_of_child = concat (reol ,rtab ,wr ,colorgrey ,childsnamecaption ," " ,wr ,preghist->
     preg[p ].child[c ].child_name )
   ENDIF
   IF ((preghist->preg[p ].child[c ].father_name != snot_documented ) )
    SET name_of_father = concat (reol ,rtab ,wr ,colorgrey ,nameoffathercaption ," " ,wr ,preghist->
     preg[p ].child[c ].father_name )
   ENDIF
   IF ((preghist->preg[p ].child[c ].dlv_hosp != snot_documented ) )
    SET hospital = concat (reol ,rtab ,wr ,colorgrey ,deliveryhospcaption ," " ,wr ,preghist->preg[p
     ].child[c ].dlv_hosp )
   ENDIF
   SET reply->text = concat (reply->text ,wr ,len_labor ,name_of_child ,name_of_father ,hospital )
   FOR (z = 1 TO size (preghist->preg[p ].child[c ].comment_wrapped ,5 ) )
    IF ((z = 1 ) )
     SET reply->text = concat (reply->text ,reol ,rtab ,wr ,colorgrey ,commentcaption ," " ,wr ,
      preghist->preg[p ].child[c ].comment_wrapped[z ].wrap_text )
    ELSE
     SET reply->text = concat (reply->text ,reol ,rtab ,preghist->preg[p ].child[c ].comment_wrapped[
      z ].wrap_text )
    ENDIF
   ENDFOR
  ENDFOR
 ENDFOR
 SET reply->text = concat (reply->text ,reol ,rpard )
#exit_script
 IF ((stand_alone_ind = 1 ) )
  SET reply->text = concat (reply->text ,rtfeof )
 ENDIF
 SET script_version = "001"
END GO
