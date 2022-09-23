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
 *002   03/25/2022  Chris Grobbel         Add processing for CC Provider 2                                                 *
 *003   07/11/2022  Chad Cummings		  Added Original Order Id                                                          *	
 *004   09/08/2022  Chris Grobbel         Blank the UPCC if alias does not exist                                           *
 ***************************************************************************************************************************
 
 ******************  END OF ALL MODCONTROL BLOCKS  *************************************************************************/
drop program phsa_cd_gen_lab_preprocessing:dba go
create program phsa_cd_gen_lab_preprocessing:dba
/*
select into "cjg_pre.dat"
from (dummyt d with seq=1)
plan d
detail
col 0 reqinfo->updt_id
row+1
with nocounter
*/

/*temp for logging*/
if( not validate(mnLOG_LEVEL_ERROR) )
	;Subroutines
	declare LogMessage( sMessage = vc, nLevel = i2 ) = NULL
	declare LogReply( recReply = VC(REF), nLevel = i2 ) = NULL
	;Constants
	declare mnLOG_LEVEL_ERROR = i2		with constant(0), protect
	declare mnLOG_LEVEL_WARNING = i2 	with constant(1), protect
	declare mnLOG_LEVEL_AUDIT = i2 		with constant(2), protect
	declare mnLOG_LEVEL_INFO = i2 		with constant(3), protect
	declare mnLOG_LEVEL_DEBUG = i2 		with constant(4), protect
	;Variables
	;This variable should be overridden in parent script
	declare msLogEventName = c31 		with noconstant("RadLogMessage"), protect 
	declare pft_log_vrsn = i2 			with noconstant(0),protect ;Variable for pft_log script

	/*************************************************/
	;Logs a message to the message log on the process server.
	;@param sMessage:  	The message that will be logged out
	;@param nLevel:  	The level to log out the message
	/*************************************************/
	subroutine LogMessage( sMessage, nLevel)
		;call echo(build("Logging message:",sMessage," at level:",nLevel))
		execute pft_log msLogEventName , sMessage, nLevel
	end

	/*************************************************/
	;Logs all the subevents out to the message log
	;@param recReply:  	The record structure that has the subevents to log
	;@param nLevel:  	The level to log out the messages
	/*************************************************/
	subroutine LogReply( recReply, nLevel)
		declare nNdx = i2 with noconstant(1), protect
		for( nNdx = 1 to size(recReply->status_data.subeventstatus,5))
			call LogMessage(build(
						recReply->status_data.subeventstatus[nNdx].OperationName,":",
						recReply->status_data.subeventstatus[nNdx].OperationStatus),nLevel)
			call LogMessage(build(
						recReply->status_data.subeventstatus[nNdx].TargetObjectName,":",
						recReply->status_data.subeventstatus[nNdx].TargetObjectValue),nLevel)
		endfor
	end

endif

declare mlDETAIL_SIZE = i4 with protect, constant(size(request->detaillist, 5))
call LogMessage("Starting phsa_cd_gen_lab_preprocessing pre-processing script", mnLOG_LEVEL_AUDIT)
call LogMessage(build("person id: ",request->personid), mnLOG_LEVEL_AUDIT)
call LogMessage(build("encntr id: ",request->encntrid), mnLOG_LEVEL_AUDIT)
call LogMessage(build("order id: ",request->orderid), mnLOG_LEVEL_AUDIT)
call LogMessage(build("catalog cd: ",request->catalogcd), mnLOG_LEVEL_AUDIT)
call LogMessage(build("orderdetail list size: ", mlDETAIL_SIZE), mnLOG_LEVEL_AUDIT)

/*end temp for logging*/


call echoxml(request,"request_pre.xml")
 
/****************************************************************************
*                                  Request Record                           *
*****************************************************************************/
/*
record request
(
     1 encntrid              = f8
     1 personid              = f8
     1 synonymid             = f8
     1 catalogcd             = f8
     1 orderid               = f8
     1 detaillist[*]
       2 oefieldid           = f8
       2 oefieldvalue        = f8
       2 oefielddisplayvalue = vc
       2 oefielddttmvalue    = dq8
       2 oefieldmeaningid    = f8
       2 valuerequiredind    = i2
)
*/


/****************************************************************************
*                                  Reply Record                             *
*****************************************************************************/
if ( not validate(reply,0) )
record reply
(
    1 orderchangeflag       = i2
    1 orderid               = f8
    1 detaillist[*]
        2 oefieldid           = f8
        2 oefieldvalue        = f8
        2 oefielddisplayvalue = vc
        2 oefielddttmvalue    = dq8
        2 oefieldmeaningid    = f8
        2 valuerequiredind    = i2
%i cclsource:status_block.inc
 
)
endif
 
set modify predeclare
 
;set default status
set reply->status_data->status = "F"
 
/**************************************************************
 *                  Declare Variables                         *
 **************************************************************/
declare cc_provider_oe_field_id  = f8 with public, noconstant(0.00)
declare cc_provider2_oe_field_id = f8 with public, noconstant(0.00)  ;002
declare original_order_oe_field_id = f8 with public, noconstant(0.00)  ;003
declare num                      = i4 with public, noconstant(0)
declare idx                      = i4 with public, noconstant(0)
declare num2                     = i4 with public, noconstant(0)
declare idx2                     = i4 with public, noconstant(0)

;MOD 004
declare cs88_External_Institutional_Entity_cd = f8 with constant(uar_get_code_by("DISPLAY_KEY",88,"EXTERNALINSTITUTIONALENTITY")) 
 
/**************************************************************
 *               Get the cc_provider_oe_field_id              *
 **************************************************************/
select into "nl:"
from order_entry_fields o
where o.description = "CC Provider"
head report
   cc_provider_oe_field_id = o.oe_field_id
with nocounter,time=30
 
/**************************************************************
 *        MOD 002 - Get the cc_provider_oe_field_id           *
 **************************************************************/
select into "nl:"
from order_entry_fields o
where o.description = "CC Provider 2"
head report
   cc_provider2_oe_field_id = o.oe_field_id
with nocounter,time=30

/**************************************************************
 *        MOD 003 - Get the original_order_oe_field_id           *
 **************************************************************/
select into "nl:"
from order_entry_fields o
where o.description = "Original Order Id"
head report
   original_order_oe_field_id = o.oe_field_id
with nocounter,time=30
  
/**************************************************************
 *                        Main                                *
 **************************************************************/
/* Begin CC Provider 1 processing */
set idx = 0
set idx = locateval(num,1,size(request->detaillist,5),cc_provider_oe_field_id,request->detaillist[num].oefieldid)
if(idx > 0)
call echo(build("idx = ",idx))
   ; The cc_provider_oe_field_id order detail exists in the request
   ; See if the cc_provider_oe_field_id order detail is valued.  If so, leave the order alone and exit the script
  ; if(request->detaillist[idx].oefieldvalue > 0.00)
      ; The user that placed the order already populated the field so leave it be and exit the script
  ;    go to exit_script
  ; else
      ; The cc_provider_oe_field_id order detail is in the request but not valued.
      ; Get the Primary Care Physician for the patient and populate the cc_provider_oe_field_id order detail with that.
 
      set request->detaillist[idx].oefieldvalue = 0.00 ; CJG 11/02/2020
 
      ; Mod 002 - Exclude BCW CARE Program encounters
      select into "nl:"
      from encounter e
      plan e
      where e.encntr_id = request->encntrid
         and e.encntr_id != 0.00
         and e.loc_facility_cd = (select cv.code_value
                                  from code_value cv
                                  where cv.code_set = 220
                                     and cdf_meaning = "FACILITY"
                                     and cv.display_key = "BCWCARE"
                                     and cv.active_ind = 1)
      with nocounter
 
      if (curqual > 0) ; This is a BCW CARE Program encounter
         ; Update field in the reply
         set reply->orderchangeflag = 1
         set reply->orderid = request->orderid
         set stat = alterlist(reply->detaillist,size(reply->detaillist,5)+1)
         set reply->detaillist[size(reply->detaillist,5)].oefieldid = request->detaillist[idx].oefieldid
         set reply->detaillist[size(reply->detaillist,5)].oefieldvalue = 0.00
         set reply->detaillist[size(reply->detaillist,5)].oefielddisplayvalue = ""
         set reply->detaillist[size(reply->detaillist,5)].oefielddttmvalue = request->detaillist[idx].oefielddttmvalue
         set reply->detaillist[size(reply->detaillist,5)].oefieldmeaningid = request->detaillist[idx].oefieldmeaningid
         set reply->detaillist[size(reply->detaillist,5)].valuerequiredind = request->detaillist[idx].valuerequiredind
      else
         select into "nl:"
         from person_prsnl_reltn ppr,
              prsnl p
         plan ppr
         where ppr.person_id= request->personid
            and ppr.person_prsnl_r_cd= (select code_value from code_value where code_set = 331
                                         and display_key = "PRIMARYCAREPHYSICIAN"
                                         and active_ind = 1
                                        )
            and ppr.active_ind = 1
            and ppr.end_effective_dt_tm > sysdate
         join p
            where p.person_id = ppr.prsnl_person_id
         head report
            ; Update field in the reply
            reply->orderchangeflag = 1
            reply->orderid = request->orderid
            stat = alterlist(reply->detaillist,size(reply->detaillist,5)+1)
            reply->detaillist[size(reply->detaillist,5)].oefieldid = request->detaillist[idx].oefieldid
            reply->detaillist[size(reply->detaillist,5)].oefieldvalue =  p.person_id
            reply->detaillist[size(reply->detaillist,5)].oefielddisplayvalue = p.name_full_formatted
            reply->detaillist[size(reply->detaillist,5)].oefielddttmvalue = request->detaillist[idx].oefielddttmvalue
            reply->detaillist[size(reply->detaillist,5)].oefieldmeaningid = request->detaillist[idx].oefieldmeaningid
            reply->detaillist[size(reply->detaillist,5)].valuerequiredind = request->detaillist[idx].valuerequiredind
         with nocounter
      endif
  ; endif
else
   ; The cc_provider_oe_field_id does not exist in the request.  Get the Primary Care Physician and add that
   ; as a new field to the reply
   ; Mod 002 - Exclude BCW CARE Program encounters
   select into "nl:"
   from encounter e
   plan e
   where e.encntr_id = request->encntrid
      and e.encntr_id != 0.00
      and e.loc_facility_cd = (select cv.code_value
                               from code_value cv
                               where cv.code_set = 220
                                  and cdf_meaning = "FACILITY"
                                  and cv.display_key = "BCWCARE"
                                  and cv.active_ind = 1)
   with nocounter
 
   if (curqual > 0) ; This is a BCW CARE Program encounter
      go to exit_script
   else
      select into "nl:"
      from person_prsnl_reltn ppr,
           prsnl p
      plan ppr
      where ppr.person_id= request->personid
         and ppr.person_prsnl_r_cd= (select code_value from code_value where code_set = 331
                                      and display_key = "PRIMARYCAREPHYSICIAN"
                                      and active_ind = 1
                                     )
         and ppr.active_ind = 1
         and ppr.end_effective_dt_tm > sysdate
      join p
         where p.person_id = ppr.prsnl_person_id
      head report
         ; Add field to reply
         reply->orderchangeflag = 1
         reply->orderid = request->orderid
 
         stat = alterlist(reply->detaillist,size(reply->detaillist,5)+1)
         reply->detaillist[size(reply->detaillist,5)].oefieldid = cc_provider_oe_field_id
         reply->detaillist[size(reply->detaillist,5)].oefieldvalue =  p.person_id
         reply->detaillist[size(reply->detaillist,5)].oefielddisplayvalue = p.name_full_formatted
;      reply->detaillist[size(reply->detaillist,5)].oefielddttmvalue = request->detaillist[mlLocPos].oefielddttmvalue
;      reply->detaillist[size(reply->detaillist,5)].oefieldmeaningid = request->detaillist[mlLocPos].oefieldmeaningid
;      reply->detaillist[size(reply->detaillist,5)].valuerequiredind = request->detaillist[mlLocPos].valuerequiredind
      with nocounter
   endif
endif
/* End CC Provider 1 processing */
 
 
/* MOD 002 - Begin CC Provider 2 processing */
/*
 <ITEM>
  <OEFIELDID type="DOUBLE" value="2596435727.000000"/>
  <OEFIELDVALUE type="DOUBLE" value="0.000000"/>
  <OEFIELDDISPLAYVALUE type="STRING" length="32"><![CDATA[Southeast Urgent Care, Vancouver]]></OEFIELDDISPLAYVALUE>
  <OEFIELDDTTMVALUE type="DATETIME" value="0000-00-00T00:00:00.000+00:00"/>
  <OEFIELDMEANINGID type="DOUBLE" value="3589.000000"/>
  <VALUEREQUIREDIND type="INT" value="0"/>
 </ITEM>
*/
set idx = 0
set idx = locateval(num,1,size(request->detaillist,5),cc_provider2_oe_field_id,request->detaillist[num].oefieldid)
if(idx > 0)
   call echo(build("idx = ",idx))
 
   ; Mod 002 - Exclude BCW CARE Program encounters
   select into "nl:"
   from encounter e
   plan e
   where e.encntr_id = request->encntrid
      and e.encntr_id != 0.00
      and e.loc_facility_cd = (select cv.code_value
                               from code_value cv
                               where cv.code_set = 220
                                  and cdf_meaning = "FACILITY"
                                  and cv.display_key = "BCWCARE"
                                  and cv.active_ind = 1)
   with nocounter
 
   if (curqual > 0) ; This is a BCW CARE Program encounter
      ; Update field in the reply
      set reply->orderchangeflag = 1
      set reply->orderid = request->orderid
      set stat = alterlist(reply->detaillist,size(reply->detaillist,5)+1)
      set reply->detaillist[size(reply->detaillist,5)].oefieldid = request->detaillist[idx].oefieldid
      set reply->detaillist[size(reply->detaillist,5)].oefieldvalue = 0.00
      set reply->detaillist[size(reply->detaillist,5)].oefielddisplayvalue = ""
      set reply->detaillist[size(reply->detaillist,5)].oefielddttmvalue = request->detaillist[idx].oefielddttmvalue
      set reply->detaillist[size(reply->detaillist,5)].oefieldmeaningid = request->detaillist[idx].oefieldmeaningid
      set reply->detaillist[size(reply->detaillist,5)].valuerequiredind = request->detaillist[idx].valuerequiredind
   else
      ; This is NOT a BCW CARE Program encounter so proceed
      ; MOD 004 - First see if the CC Provider 2 field contains a real provider
      ;if request->detaillist[idx].oefieldvalue > 0.00 indicatates a real provider so keep it 
      call echo("here1")
      if(request->detaillist[idx].oefieldvalue = 0.00) ; We got a UPCC so the CC Provider 2 field was not a real provider
         call echo("here2")
         ; Get the UPCC for the encounter and populate the cc_provider2_oe_field_id order detail with that.
         select into "nl:"
         from code_value_outbound cvo,
              encounter e,
              prsnl p
         plan cvo
            where cvo.code_set = 220
               and cvo.contributor_source_cd = value(uar_get_code_by("DISPLAY_KEY",73,"INSTENTITYINBOX")) ;2617959211.00
         join e
            where e.loc_nurse_unit_cd = cvo.code_value
               and e.encntr_id = request->encntrid
         join p
            where p.person_id = cnvtreal(cvo.alias)
         head report
            ; Update field in the reply
            reply->orderchangeflag = 1
            reply->orderid = request->orderid
            stat = alterlist(reply->detaillist,size(reply->detaillist,5)+1)
            reply->detaillist[size(reply->detaillist,5)].oefieldid = request->detaillist[idx].oefieldid
            reply->detaillist[size(reply->detaillist,5)].oefieldvalue =  p.person_id
            reply->detaillist[size(reply->detaillist,5)].oefielddisplayvalue = p.name_full_formatted
            reply->detaillist[size(reply->detaillist,5)].oefielddttmvalue = request->detaillist[idx].oefielddttmvalue
            reply->detaillist[size(reply->detaillist,5)].oefieldmeaningid = request->detaillist[idx].oefieldmeaningid
            reply->detaillist[size(reply->detaillist,5)].valuerequiredind = request->detaillist[idx].valuerequiredind
         with nocounter
         ; MOD 004
         if(curqual = 0)
            call echo("here3")
            ; The encounter is currently in a location that is not a UPCC so blank out CC Provider 2
            ; Update field in the reply
            set reply->orderchangeflag = 1
            set reply->orderid = request->orderid
            set stat = alterlist(reply->detaillist,size(reply->detaillist,5)+1)
            set reply->detaillist[size(reply->detaillist,5)].oefieldid = request->detaillist[idx].oefieldid
            set reply->detaillist[size(reply->detaillist,5)].oefieldvalue = 0.00
            set reply->detaillist[size(reply->detaillist,5)].oefielddisplayvalue = ""
            set reply->detaillist[size(reply->detaillist,5)].oefielddttmvalue = request->detaillist[idx].oefielddttmvalue
            set reply->detaillist[size(reply->detaillist,5)].oefieldmeaningid = request->detaillist[idx].oefieldmeaningid
            set reply->detaillist[size(reply->detaillist,5)].valuerequiredind = request->detaillist[idx].valuerequiredind      
         endif
      endif ; if(curqual > 0) ; We got a UPCC so the CC Provider 2 field was not a real provider
   endif
else
   call echo("here4")
   ; The cc_provider2_oe_field_id does not exist in the request.
   ; Mod 002 - Exclude BCW CARE Program encounters
   select into "nl:"
   from encounter e
   plan e
   where e.encntr_id = request->encntrid
      and e.encntr_id != 0.00
      and e.loc_facility_cd = (select cv.code_value
                               from code_value cv
                               where cv.code_set = 220
                                  and cdf_meaning = "FACILITY"
                                  and cv.display_key = "BCWCARE"
                                  and cv.active_ind = 1)
   with nocounter
 
   if (curqual > 0) ; This is a BCW CARE Program encounter
      go to exit_script
   else
      ; This is NOT a BCW CARE Program encounter so proceed
      select into "nl:"
      from code_value_outbound cvo,
           encounter e,
           prsnl p
      plan cvo
         where cvo.code_set = 220
            and cvo.contributor_source_cd = value(uar_get_code_by("DISPLAY_KEY",73,"INSTENTITYINBOX")) ;2617959211.00
      join e
         where e.loc_nurse_unit_cd = cvo.code_value
            and e.encntr_id = request->encntrid
      join p
         where p.person_id = cnvtreal(cvo.alias)
      head report
         ; Add field to reply
         reply->orderchangeflag = 1
         reply->orderid = request->orderid
 
         stat = alterlist(reply->detaillist,size(reply->detaillist,5)+1)
         reply->detaillist[size(reply->detaillist,5)].oefieldid = cc_provider2_oe_field_id
         reply->detaillist[size(reply->detaillist,5)].oefieldvalue =  p.person_id
         reply->detaillist[size(reply->detaillist,5)].oefielddisplayvalue = p.name_full_formatted
;      reply->detaillist[size(reply->detaillist,5)].oefielddttmvalue = request->detaillist[mlLocPos].oefielddttmvalue
;      reply->detaillist[size(reply->detaillist,5)].oefieldmeaningid = request->detaillist[mlLocPos].oefieldmeaningid
;      reply->detaillist[size(reply->detaillist,5)].valuerequiredind = request->detaillist[mlLocPos].valuerequiredind
      with nocounter
   endif
endif
/* MOD 002 - End CC Provider 2 processing */
 



/* MOD 004 - Begin Original Order Id processing */
/*
 <ITEM>
  <OEFIELDID type="DOUBLE" value="2596435727.000000"/>
  <OEFIELDVALUE type="DOUBLE" value="0.000000"/>
  <OEFIELDDISPLAYVALUE type="STRING" length="32"><![CDATA[Southeast Urgent Care, Vancouver]]></OEFIELDDISPLAYVALUE>
  <OEFIELDDTTMVALUE type="DATETIME" value="0000-00-00T00:00:00.000+00:00"/>
  <OEFIELDMEANINGID type="DOUBLE" value="3589.000000"/>
  <VALUEREQUIREDIND type="INT" value="0"/>
 </ITEM>
*/
set idx = 0
set idx = locateval(num,1,size(request->detaillist,5),original_order_oe_field_id,request->detaillist[num].oefieldid)
if(idx > 0)

set reply->orderchangeflag = 1
      set reply->orderid = request->orderid
      set stat = alterlist(reply->detaillist,size(reply->detaillist,5)+1)
      set reply->detaillist[size(reply->detaillist,5)].oefieldid = request->detaillist[idx].oefieldid
      set reply->detaillist[size(reply->detaillist,5)].oefieldvalue =request->orderid
      set reply->detaillist[size(reply->detaillist,5)].oefielddisplayvalue = cnvtstring(request->orderid)
      set reply->detaillist[size(reply->detaillist,5)].oefielddttmvalue = request->detaillist[idx].oefielddttmvalue
      set reply->detaillist[size(reply->detaillist,5)].oefieldmeaningid = request->detaillist[idx].oefieldmeaningid
      set reply->detaillist[size(reply->detaillist,5)].valuerequiredind = request->detaillist[idx].valuerequiredind

else
   ; The Original Order Id does not exist in the request.
	set reply->orderchangeflag = 1
	set reply->orderid = request->orderid
 
	set stat = alterlist(reply->detaillist,size(reply->detaillist,5)+1)
	set reply->detaillist[size(reply->detaillist,5)].oefieldid = original_order_oe_field_id
	set reply->detaillist[size(reply->detaillist,5)].oefieldvalue =  request->orderid
	set reply->detaillist[size(reply->detaillist,5)].oefielddisplayvalue = cnvtstring(request->orderid)
	set reply->detaillist[size(reply->detaillist,5)].oefieldmeaningid = 1561
	set reply->detaillist[size(reply->detaillist,5)].valuerequiredind = 1
               
  
endif
/* MOD 003 - End Original Order Id processing */ 
 
#exit_script
set reply->status_data->status = "S"
 
set modify nopredeclare
call echorecord(reply)
call echoxml(reply,"reply_pre.xml")
 
end
go
 
