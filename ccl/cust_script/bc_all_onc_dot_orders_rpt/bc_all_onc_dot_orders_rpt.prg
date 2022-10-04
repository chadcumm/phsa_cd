/***********************************************************************************************************************
  Program Name:       	bc_all_onc_dot_orders_rpt
  Source File Name:   	bc_all_onc_dot_orders_rpt.prg
  Program Written By: 	John Simpson
  Date:  			  	26-May-2021
  Program Purpose:   	PowerPlan and non-PowerPlan orders for downtime purposes
 
************************************************************************************************************************
												*MODIFICATION HISTORY*
************************************************************************************************************************
 
Rev  Date         Jira       Programmer             Comment
---  -----------  ---------  ---------------------  --------------------------------------------------------------------
000  26-May-2021  CST-96425  John Simpson           Created
001  10-Jun-2021  CST-96425  Chad Cummings          Added echo logging
002  10-Jun-2021  CST-96425  Chad Cummings          ReAdded apc.included_ind line and pw_status_cd 
003  10-Jun-2021  CST-96425  Chad Cummings          Add outrec qualified indicator for planned orders 
004  10-Jun-2021  CST-96425  Chad Cummings          Added Proposals order selection to include planned orders
005  10-Jun-2021  CST-96425  Chad Cummings          Temporarily hard coded cv14_OrderComment as the code value/json is failing
006  10-Jun-2021  CST-96425  Chad Cummings          Added MAR Note
007  11-Jun-2021  CST-96425  Chad Cummings          Added date, time and offset to planned orders
008  11-Jun-2021  CST-96425  Chad Cummings          updated cLabel array to use c40 instead of VC
009  11-Jun-2021  CST-96425  Chad Cummings          added new SaveNewDocument to use clincal event server
010  12-Jun-2021  CST-96425  Chad Cummings          updated temp record to handle days of treatment with the same name
011  12-Jun-2021  CST-96425  Chad Cummings          Hide Zero Time (removed)
012  12-Jun-2021  CST-96425  Chad Cummings          Add Transfusion conditional logic
013  12-Jun-2021  CST-96425  Chad Cummings          Updated status on orders when proposed 
014  13-Jun-2021  CST-96425  Chad Cummings          Added offsets for planned orders from act_pw_comp table 
015  13-Jun-2021  CST-96425  Chad Cummings          Added offsets for active orders from act_pw_comp table 
016  13-Jun-2021  CST-96425  Chad Cummings          Added logic in report to determine if output should be generated
017  13-Jun-2021  CST-96425  Chad Cummings          Included orders with overdue tasks regadless of date
018  14-Jun-2021  CST-96425  Chad Cummings          Updated to use order_mnemonic instead of ordered_as_mnemonic
019  14-Jun-2021  CST-96425  Chad Cummings          Added regimen logic for finding planned powerplans
020  14-Jun-2021  CST-96425  Chad Cummings          Reversed 005
021  14-Jun-2021  CST-96425  Chad Cummings          Discretely store cdl, simplified display line and template type
022  14-Jun-2021  CST-96425  Chad Cummings          Use CDL for protocol orders not in DOT
023  14-Jun-2021  CST-96425  Chad Cummings          Added sequence for sorting of Powerplans
024  15-Jun-2021  CST-96425  Chad Cummings          Added physician cosignature indicator
025  15-Jun-2021  CST-96425  Chad Cummings          Added Regimen name
026  17-Jun-2021  CST-96425  Chad Cummings          Updated query for order proposals to include start date time
027  17-Jun-2021  CST-96425  Chad Cummings          Updated qualifier to include proposed plans
028  17-Jun-2021  CST-96425  Chad Cummings          Updated order proposals to check for previous start date and time entries
029  17-Jun-2021  CST-96425  Chad Cummings          changed run time format to include seconds
***********************************************************************************************************************/
 
; https://wiki.phsa.ca/display/onc/Downtime+Report+-+Sub-Requirements
 
drop program bc_all_onc_dot_orders_rpt:dba go
create program bc_all_onc_dot_orders_rpt:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "From Date" = "CURDATE"
	, "To Date" = "CURDATE"
	, "encntr_id" = 111159533 

with outdev, fromDate, toDate, encntrId
 
; bc_all_onc_dot_orders_rpt "MINE","-|1|D","+|5|D", 110476011 go
; bc_all_onc_dot_orders_rpt "MINE","17-MAY-2021", "23-MAY-2021", 110476011 go
; bc_all_onc_dot_orders_rpt "MINE","-|2|D","+|5|D",  112072327 go
; bc_all_onc_dot_orders_rpt "MINE","-|2|D","+|5|D",  112154295 go
; bc_all_onc_dot_orders_rpt "MINE","-|2|D","+|5|D", 112225275 go
 
; Standard executes
execute bc_all_all_date_routines
execute bc_all_all_std_routines
execute bc_all_std_write_pc_document
 
; Read all code values in from reference template JSON document
execute bc_all_ccl_ref_template "bc_all_onc_dot_orders_rpt", 1
 
; Define date range variables
declare dFromDate = dq8
declare dToDate = dq8

; Define Encounter
declare dEncntrID = f8

if (validate(request->encntr_id))
	set dFromDate = cnvtdatetime(request->fromDate)
	set dToDate = cnvtdatetime(request->toDate)
	set dEncntrID = request->encntr_id
else
	if (substring(1,1,$fromDate) in ("+","-"))
	  set dFromDate = sCST_DATE_RANGE_FROM($fromDate)
	  set dToDate = sCST_DATE_RANGE_TO($toDate)
	else
	  set dFromDate = cnvtdatetime($fromDate)
	  set dToDate = cnvtdatetime(concat($toDate, " 23:59:59"))
	endif
	set dEncntrID = $encntrId
endif 
; Misc variables
declare nNum = i4
declare cString = vc
declare _key = vc ;010	
declare cHTML = vc
declare cHeader = vc
if (not validate(request->encntr_id))
	if (findstring("cclscratch", $outdev) > 0 and $encntrId > 0)
	    declare _Memory_Reply_String = vc
	endif
endif
declare dDates[40] = dq8
declare cLabels[40] = c40 ;008
declare order_comment = vc ;012

 
; Declare subroutines
declare addStr(cAddString=vc) = null
declare content(cTag = vc, cText = vc) = null
 
; Define report structure
free record outrec
record outrec (
    1 data[*]
        2 person_id                 = f8
        2 encntr_id                 = f8
        2 qualified                 = i4
        2 cdr_name_full_formatted   = vc
        2 cdr_birth_date            = vc
        2 cdr_age                   = vc
        2 cdr_mrn                   = vc
        2 cdr_encounter             = vc
        2 cdr_phn                   = vc
        2 dual_modality             = vc
        2 dot_order_action_found_ind = i2 ;016
)
 
; Primary select
if (dEncntrID > 0)
    select into "nl:"
    from    encounter           e
    plan e
        where e.encntr_id = dEncntrID
        and e.active_ind = 1
        and e.active_status_cd = cv48_Active
    detail
        stat = alterlist(outrec->data, 1)
        outrec->data[1].encntr_id = e.encntr_id
        outrec->data[1].person_id = e.person_id
        outrec->data[1].dual_modality = "No"
 
;        outrec->data[1].qualified = 1       ; Remove this after testing
    with counter
    
    /* start 016 */
		select distinct into "nl:"
			o.encntr_id
			,o.originating_encntr_id
		from
			 orders o
			,act_pw_comp apc
			,pathway p
		plan o
			where o.person_id = outrec->data[1].person_id
			and o.order_status_cd in(
										  value(uar_get_code_by("MEANING",6004,"ORDERED"))
										 ,value(uar_get_code_by("MEANING",6004,"FUTURE"))
										 ,value(uar_get_code_by("MEANING",6004,"PENDING"))
										)
		 
			and o.current_start_dt_tm between cnvtdatetime(dFromDate) and cnvtdatetime(dToDate)
		join apc
			where apc.parent_entity_id = o.order_id
		join p
			where p.pathway_id = apc.pathway_id
			and   p.type_mean = "DOT"
		order by
			o.person_id
			,o.orig_order_dt_tm
		head o.person_id
			outrec->data[1].dot_order_action_found_ind = 1
		with nocounter
		 
		if (outrec->data[1].dot_order_action_found_ind = 0)
			select into "nl:"
			from
				  pathway p
				 ,regimen_detail rd	;019
				 ,regimen r	;019
			plan p
				where p.pw_status_cd in(value(uar_get_code_by("MEANING",16769,"PLANNED")))
				;019 and   p.duration_qty > 0
				and   p.person_id = outrec->data[1].person_id
			join rd												;019
				where rd.activity_entity_id = p.pw_group_nbr	;019
			join r												;019
				where r.regimen_id = rd.regimen_id				;019
			order by
				 p.person_id
				,p.order_dt_tm desc
			head p.person_id
				outrec->data[1].dot_order_action_found_ind = 1
			with nocounter
		endif
		
	/*start 027 */	
		if (outrec->data[1].dot_order_action_found_ind = 0)
			select into "nl:"
		    from
		    	pathway p
		    plan p
		    	where p.person_id = outrec->data[1].person_id
		    	and   p.pw_status_cd in(
		    									 value(uar_get_code_by("MEANING",16769,"PLANNED"))
		    									,value(uar_get_code_by("MEANING",16769,"ORDERED"))
		    									,value(uar_get_code_by("MEANING",16769,"STARTED"))
		    									,value(uar_get_code_by("MEANING",16769,"FUTURE"))
		    									,value(uar_get_code_by("MEANING",16769,"PROPOSED"))
		    									,value(uar_get_code_by("MEANING",16769,"FUTURPROPOSE"))
		    									,value(uar_get_code_by("MEANING",16769,"INITIATED")))
		    	and   p.review_status_flag = 1
		    	and   p.type_mean = "DOT"
		    order by
		   		p.person_id
		   	head p.person_id
		   		outrec->data[1].dot_order_action_found_ind = 1
		    with nocounter
		endif
	/*end 027 */
		
		if (outrec->data[1].dot_order_action_found_ind = 0)
			go to end_program
		endif
    /* end 016 */
else    ; Currently no batch logic so abort
    go to end_program
endif
 
; Execute the CDR to collect common data
execute bc_all_common_data_collection
 
; Collect the dual modality
select into "nl:"
from    person_info     pi
plan pi
    where expand(nNum, 1, size(outrec->data, 5), pi.person_id, outrec->data[nNum].person_id)
    and pi.info_sub_type_cd = cv356_DualModality
    and pi.active_ind = 1
    and pi.end_effective_dt_tm > sysdate
    and pi.active_status_cd = cv48_Active
detail
    nQualPos = 0
 
    while (locateval(nNum,nQualPos+1,size(outrec->data,5), pi.person_id, outrec->data[nNum].person_id)>0)
        nQualPos = nNum
        if (cnvtupper(uar_get_code_display(pi.value_cd)) = "YES")
            outrec->data[nQualPos].dual_modality = "Yes"
        endif
    endwhile
with counter
 
; Define the pathways structure
free record pathway
record pathway (
    1 group[*]
        2 section_label             = vc
        2 pw_group_nbr              = f8
        2 pw_group_desc             = vc
        2 pathway_id                = f8
        2 pathway_group_id          = f8
        2 period_nbr                = i4
        2 description               = vc
        2 pw_status_cd              = f8
        2 type_mean                 = vc
        2 start_dt_tm               = dq8
        2 pathway_sequence			= i4 ;023
    1 orders[*]
        2 qualified                 = i4
        2 pathway_id                = f8
        2 pathway_seq               = i4
        2 sequence                  = i4
        2 act_pw_comp_id            = f8
        2 type                      = vc
        2 order_id                  = f8
        2 period                    = vc
        2 template_order_id         = f8
        2 protocol_order_id         = f8
        2 order_proposal_id         = f8
        2 long_text_id              = f8
        2 order_sentence_id         = f8
        2 catalog_type_cd           = f8
        2 catalog_cd                = f8
        2 display_line              = vc
        2 clinical_display_line		= vc	;021
        2 simplified_display_line	= vc	;021
        2 template_order_flag		= i2	;021
        2 ordered_as_mnemonic       = vc
        2 order_mnemonic			= vc ;018
        2 current_start_dt_tm       = dq8
        2 order_status_cd           = f8
        2 projected_stop_dt_tm      = dq8
        2 prescription_ind          = i4
        2 order_comment             = vc
        2 mar_note					= vc ;006
        2 transfuse_order_comment   = vc
        2 offset_quantity           = f8
        2 offset_unit_cd            = f8
        2 cosignature_ind			= i2 ;026
        2 regimen_name				= vc ;025
)
 
; Used in building HTML tables
free record temp
record temp (
    1 titles[*]
        2 label             = vc
        2 date              = dq8
        2 _key				= vc	;010
    1 data[*]
        2 type              = i4
        2 sentence          = vc
        2 columns[*]
            3 status        = vc
            3 cosign		= vc ;026
            3 label         = vc
            3 date          = dq8
            3 _key			= vc	;010
    1 single_ind            = i4
)
 
; Setup the RTL2 File
free define rtl2
define rtl2 is "cust_script:bc_all_onc_dot_orders_rpt.html"
 
 
; Perform data collection of order information
; --------------------------------------------
for (nLoop = 1 to size(outrec->data, 5))
 
    ; Clear any old values
    set stat = initrec(pathway)
 
    ; Collect the pathway information first. At this most of the filtering isn't happening but will
    ; happen later when the orders are collected
    select into "nl:"
        pw_group_nbr        = p.pw_group_nbr,
        pathway_id          = p.pathway_id,
        p.period_nbr,
        type_mean           = p.type_mean,
        pw_group_desc       = p.pw_group_desc,
        sequence            = apc.sequence,
        act_pw_comp_id      = apc.act_pw_comp_id,
        "*** R ****", r.*,
        "*** P ***", p.*,
        "*** APC ***", apc.*
    from    pathway             p,
            act_pw_comp         apc,
            act_pw_comp_r       r
    plan p
        where p.person_id = outrec->data[nLoop].person_id
        and (p.cross_encntr_ind = 1 or p.encntr_id = outrec->data[nLoop].encntr_id)
        and p.discontinued_ind = 0
        and p.dc_reason_cd = 0.0
        and p.pw_status_cd not in (cv16769_Excluded) ;002
    join apc
        where apc.pathway_id = p.pathway_id
        and ((apc.parent_entity_name in ("ORDERS", "PROPOSAL") and apc.included_ind = 1) ;002
            or apc.parent_entity_name = "LONG TEXT")									 ;002
        ;002 and (apc.parent_entity_name in ("ORDERS", "PROPOSAL") or apc.parent_entity_name = "LONG TEXT")
        and apc.active_ind = 1
    join r
        where r.act_pw_comp_t_id = outerjoin(apc.act_pw_comp_id)
        and r.type_mean = outerjoin("TIMEZERO")
    order pw_group_nbr, pathway_id, act_pw_comp_id,r.act_pw_comp_t_id ;sequence
    
;/*
    head report
        nCount = 0
        nTitles = 0
        nOrders = 0
        pSeq = 0 ;023
    head pw_group_nbr
    	call echo(build2(" "))	;001
    	call echo(build2("----------------------------------------")) ;001
    	call echo(build2("pw_group_nbr:",pw_group_nbr)) ;001
    	call echo(build2("->p.pw_group_desc:",p.pw_group_desc)) ;001
        x = 0
        pSeq = 0;023
    head pathway_id
        nCount = nCount + 1
        stat = alterlist(pathway->group, nCount)
        pathway->group[nCount].section_label = "Need to build"
        pathway->group[nCount].pw_group_nbr = pw_group_nbr
        pathway->group[nCount].pathway_group_id = p.pathway_group_id
        pathway->group[nCount].pw_group_desc = pw_group_desc
        pathway->group[nCount].pathway_id = pathway_id
        pathway->group[nCount].period_nbr = p.period_nbr
        pathway->group[nCount].description = p.description
        pathway->group[nCount].pw_status_cd = p.pw_status_cd
        pathway->group[nCount].type_mean = type_mean
        pathway->group[nCount].start_dt_tm = p.start_dt_tm
        pSeq = (pSeq + 1);023
        pathway->group[nCount].pathway_sequence = pSeq ;023
		call echo(build2("->p.pathway_id:",p.pathway_id)) ;001
		call echo(build2("->p.description:",p.description)) ;001
        call echo(build2("->pw_status_cd:",uar_get_code_display(p.pw_status_cd))) ;001
    head act_pw_comp_id ;sequence
        x = 0
    detail
        nOrders = nOrders + 1
        stat = alterlist(pathway->orders, nOrders)
        pathway->orders[nOrders].pathway_id = pathway_id
        pathway->orders[nOrders].pathway_seq = nCount   ; Used for direct reference to avoid locateval calls
        pathway->orders[nOrders].sequence = sequence
        pathway->orders[nOrders].act_pw_comp_id = act_pw_comp_id
        pathway->orders[nOrders].type = apc.parent_entity_name
        call echo(build2("-->sequence:",sequence)) ;001
        call echo(build2("-->parent_entity_name:",apc.parent_entity_name)) ;001
        call echo(build2("-->parent_entity_id:",apc.parent_entity_id)) ;001
        call echo(build2("-->order_sentence_id:",apc.order_sentence_id)) ;001
        
        if (apc.parent_entity_name = "ORDERS" and apc.parent_entity_id > 0.0)
            pathway->orders[nOrders].order_id = apc.parent_entity_id
;        elseif (apc.parent_entity_name = "ORDERS")
            pathway->orders[nOrders].order_sentence_id = apc.order_sentence_id
        ;004 elseif (apc.parent_entity_name = "PROPOSAL" and
        ;004        p.review_status_flag = 1 and
        ;004         p.pw_status_cd not in (cv16769_Discontinued, cv16769_Excluded))
        /* start 004 */
        elseif (
        			(	apc.parent_entity_name = "PROPOSAL" and
                		p.review_status_flag = 1 and
        				p.pw_status_cd not in (cv16769_Discontinued, cv16769_Excluded)
        			)
        		or  (
        				apc.parent_entity_name = "PROPOSAL" and
                		;p.review_status_flag = 4 and
        				p.pw_status_cd in (cv16769_Planned)
        			)
        		)
        /* end 004 */
            pathway->orders[nOrders].order_proposal_id = apc.parent_entity_id
        elseif (apc.parent_entity_name = "LONG TEXT")
            pathway->orders[nOrders].long_text_id = apc.parent_entity_id
        endif
        pathway->orders[nOrders].offset_quantity = r.offset_quantity
        pathway->orders[nOrders].offset_unit_cd = r.offset_unit_cd
        if ((apc.offset_quantity > 0.0) and (pathway->orders[nOrders].offset_quantity = 0.0))	;015
            	pathway->orders[nOrders].offset_quantity = apc.offset_quantity            	;015
            	pathway->orders[nOrders].offset_unit_cd = apc.offset_unit_cd					;015
        endif																				;015
 
;*/
    with counter
 
    ; Collect the orders
    select into "nl:"
    from    orders              o,
            order_comment       oc,
            order_comment       oc2, ;006
            long_text           lt,
            long_text           lt2	;006
    plan o
        where o.person_id = outrec->data[nLoop].person_id
        and (
            ; Start time is within the time frame
            o.current_start_dt_tm <= cnvtdatetime(dToDate)
 
            ; Any order whose stop date/time (or projected stop date/time) does not yet exist,
            ; or is beyond the end date/time of the report
            or (
                nullind(o.projected_stop_dt_tm) = 1 or o.projected_stop_dt_tm > cnvtdatetime(dToDate)
               
            )
 
            ; Non-DOT orders that have already fired a task and the task is due within the time frame or before
            ; (which means we're including overdue tasks as well)
            or exists (
                select o.order_id
                from orders     o2
                where o2.current_start_dt_tm < cnvtdatetime(dToDate)
                and o2.template_order_id = o.order_id
                and o2.order_status_cd not in (cv6004_Canceled, cv6004_Completed, cv6004_Discontinued,
                                    cv6004_TransferCanceled, cv6004_VoidedWithResults)
            )
            
            /* start 017 */
            or exists (
                
                select ta.order_id 
				from 
					 task_activity ta 
				
					where ta.person_id =    o.person_id
					and ta.order_id > 0.0
					and ta.task_status_cd = cv79_Overdue
            )
            
            /* end 017 */
 
            ; Non-DOT orders that are continuous infusions or other unscheduled orders whose start time is any time
            ; before the time frame (this is because continuous infusions and unscheduled orders don't fire off tasks
            or (
                o.freq_type_flag = 5
                and o.current_start_dt_tm < cnvtdatetime(dFromDate)
            )
        )
        and o.order_id != 0
        and o.product_id = 0
        and o.order_status_cd not in (cv6004_Canceled, cv6004_Completed, cv6004_Discontinued,
                                    cv6004_Deleted, cv6004_TransferCanceled, cv6004_VoidedWithResults)
        and o.orig_ord_as_flag in (0, 1, 5)
        and o.template_order_flag != 4
    join oc
        where oc.order_id = outerjoin(o.order_id)
        and oc.action_sequence = outerjoin(1)
        ;005 and oc.comment_type_cd = outerjoin(cv14_OrderComment)
        and oc.comment_type_cd = outerjoin(cv14_OrderComment) ;020
        ;020 and oc.comment_type_cd = outerjoin(66)
    join lt
        where lt.long_text_id = outerjoin(oc.long_text_id)
        and lt.active_ind = outerjoin(1)
    /* start 006 */
    join oc2
        where oc2.order_id = outerjoin(o.order_id)
        and oc2.action_sequence = outerjoin(1)
        ;005 and oc.comment_type_cd = outerjoin(cv14_OrderComment)
        and oc2.comment_type_cd = outerjoin(643447)
    join lt2
        where lt2.long_text_id = outerjoin(oc2.long_text_id)
        and lt2.active_ind = outerjoin(1)
	/* end 006 */       
    detail
        ; Determine if in pathway
        nOrderPos = locateval(nNum, 1, size(pathway->orders, 5), o.order_id, pathway->orders[nNum].order_id)
        nExclude = 0
 		
        ; Exclude future orders not part of an encounter
        ;if (nOrderPos = 0 and o.encntr_id = 0)
            ;nExclude = 1
        ;endif
 
        ; Filter out unwanted orders
/*
        if ((nOrderPos = 0 or o.protocol_order_id > 0) and (
            (o.current_start_dt_tm < cnvtdatetime(dFromDate) and o.projected_stop_dt_tm < cnvtdatetime(dFromDate)) or
            (o.current_start_dt_tm > cnvtdatetime(dToDate) and o.projected_stop_dt_tm > cnvtdatetime(dToDate))))
            nExclude = 1
        endif
  */
 
        ; Only use pathway orders or non-child orders
        if ((nOrderPos > 0 or (o.protocol_order_id = 0 and o.template_order_id = 0)) and nExclude = 0)
 
            ; If non-pathway order, add a new entry to the structure
            if (nOrderPos = 0)
                nOrderPos = size(pathway->orders, 5) + 1
                stat = alterlist(pathway->orders, nOrderPos)
                pathway->orders[nOrderPos].order_id = o.order_id
                pathway->orders[nOrderPos].type = "SINGLEORDER"
            endif
 
            pathway->orders[nOrderPos].catalog_type_cd = o.catalog_type_cd
            pathway->orders[nOrderPos].catalog_cd = o.catalog_cd
            pathway->orders[nOrderPos].template_order_id = o.template_order_id
            pathway->orders[nOrderPos].protocol_order_id = o.protocol_order_id
            pathway->orders[nOrderPos].clinical_display_line = o.clinical_display_line		;021
            pathway->orders[nOrderPos].simplified_display_line = o.simplified_display_line	;021	
            pathway->orders[nOrderPos].template_order_flag = o.template_order_flag			;021	
            if (size(trim(o.simplified_display_line)) > 1)
                pathway->orders[nOrderPos].display_line = o.simplified_display_line
            else
                pathway->orders[nOrderPos].display_line = o.clinical_display_line
            endif
            pathway->orders[nOrderPos].ordered_as_mnemonic = o.ordered_as_mnemonic
            pathway->orders[nOrderPos].order_mnemonic = o.order_mnemonic ;018
            pathway->orders[nOrderPos].current_start_dt_tm = o.current_start_dt_tm
            pathway->orders[nOrderPos].order_status_cd = o.order_status_cd
            pathway->orders[nOrderPos].projected_stop_dt_tm = o.projected_stop_dt_tm
            if (o.orig_ord_as_flag = 1)
                pathway->orders[nOrderPos].prescription_ind = 1
            endif
            pathway->orders[nOrderPos].order_comment = lt.long_text
            pathway->orders[nOrderPos].mar_note = lt2.long_text ;006
 			pathway->orders[nOrderPos].cosignature_ind = o.need_doctor_cosign_ind ;026
            ; Don't qualify top level orders if dates passed. Will need to perform another pass to test children
/*
            if (nOrderPos > 0 and (
                (o.current_start_dt_tm < cnvtdatetime(dFromDate) and o.projected_stop_dt_tm < cnvtdatetime(dFromDate)) or
                (o.current_start_dt_tm > cnvtdatetime(dToDate) and o.projected_stop_dt_tm > cnvtdatetime(dToDate))))
                pathway->orders[nOrderPos].qualified = 0
            else
                pathway->orders[nOrderPos].qualified = 1
                outrec->data[nLoop].qualified = 1
            endif
            */
        endif
    with counter
 
    ; Qualify the parent orders by comparing to children
    select into "nl:"
        dot_qual            = if (d2.seq > 0)
                                1
                              endif,
        order_start_dt_tm   = pathway->orders[d.seq].current_start_dt_tm,
        order_stop_dt_tm    = pathway->orders[d.seq].projected_stop_dt_tm,
        dot_start_dt_tm     = pathway->orders[d2.seq].current_start_dt_tm,
        dot_stop_dt_tm      = pathway->orders[d2.seq].projected_stop_dt_tm
    from    (dummyt         d with seq=value(size(pathway->orders, 5))),
            (dummyt         d2 with seq=value(size(pathway->orders, 5))),
            dummyt          oj
    plan d
        where pathway->orders[d.seq].current_start_dt_tm > 0
    join oj
    join d2
        where pathway->orders[d2.seq].protocol_order_id = pathway->orders[d.seq].order_id
        and pathway->orders[d2.seq].protocol_order_id > 0
    detail
        if (dot_qual = 0)
            if (cnvtdatetime(order_start_dt_tm) < cnvtdatetime(dToDate) and
                (cnvtdatetime(order_stop_dt_tm) >= cnvtdatetime(dFromDate) or order_stop_dt_tm = 0))
                pathway->orders[d.seq].qualified = 1
                outrec->data[nLoop].qualified = 1
            endif
        else
            if (cnvtdatetime(dot_start_dt_tm) < cnvtdatetime(dToDate) and
                (cnvtdatetime(dot_stop_dt_tm) >= cnvtdatetime(dFromDate) or dot_stop_dt_tm = 0))
                pathway->orders[d.seq].qualified = 1
                pathway->orders[d2.seq].qualified = 1
                outrec->data[nLoop].qualified = 1
            endif
        endif
    with outerjoin=oj, counter
 
 
    ; Collect the order details
    select into "nl:"
        order_id            = o.order_id,
        action_sequence     = od.action_sequence,
        detail_sequence     = od.detail_sequence,
        group_seq           = off.group_seq,
        label               = off.clin_line_label,
        include_ind         = if (off.accept_flag != 2 and off.clin_line_ind = 1)
                                1
                              endif,
        display_value       = if ((off.disp_yes_no_flag in (0,1) and cnvtupper(od.oe_field_display_value) = "YES"))
                                off.label_text
                              elseif (oef.field_type_flag = 3)
                                sCST_DATE(od.oe_field_dt_tm_value)
                              elseif (oef.field_type_flag = 5)
                                sCST_DT_TM(od.oe_field_dt_tm_value)
                              else
                                od.oe_field_display_value
                              endif
    from    orders                  o,
            order_detail            od,
            order_entry_fields      oef,
            oe_format_fields        off
    plan o
        where expand(nNum, 1, size(pathway->orders, 5), o.order_id, pathway->orders[nNum].order_id)
    join od
        where od.order_id = o.order_id
    join oef
        where oef.oe_field_id = od.oe_field_id
    join off
        where off.oe_field_id = oef.oe_field_id
        and off.oe_format_id = o.oe_format_id
        and ((off.accept_flag != 2 and off.clin_line_ind = 1) or od.oe_field_meaning in ("TREATMENTPERIOD", "PPSCHEDULEDPHASE"))
        and off.action_type_cd = cv6003_Order
        and (off.disp_yes_no_flag = 0 or
             (off.disp_yes_no_flag = 1 and od.oe_field_display_value != "No") or
             (off.disp_yes_no_flag = 2 and od.oe_field_display_value != "Yes"))
    order order_id, group_seq, action_sequence desc, detail_sequence
;/*
    head order_id
        cString = ""
 
        nOrderPos = locateval(nNum, 1, size(pathway->orders, 5), o.order_id, pathway->orders[nNum].order_id)
    head group_seq
        if (include_ind = 1)
            if (trim(cString) != "")
                cString = concat(trim(cString), ",")
            endif
            cString = trim(concat(trim(cString), " ", label),3)
            nSeq = action_sequence
        endif
    head action_sequence
        x = 0
    detail
        if (include_ind = 1)
            if (action_sequence = nSeq)
                cString = concat(trim(cString), " ", trim(display_value))
            endif
        endif
 
        ; Add the period
        if (od.oe_field_meaning in ("TREATMENTPERIOD", "PPSCHEDULEDPHASE") and nOrderPos > 0)
            pathway->orders[nOrderPos].period = od.oe_field_display_value
        endif
    foot action_sequence
        x = 0
    foot group_seq
        x = 0
    foot order_id
        if (nOrderPos > 0)
            pathway->orders[nOrderPos].display_line = cString
        endif
    with expand=2, maxcol=1000
 
    ; Collect planned orders with no order_id
    select  into "nl:"
    from    act_pw_comp             apc,
            order_catalog_synonym   ocs,
            order_sentence          os,
            long_text               lt
    plan apc
        where expand(nNum, 1, size(pathway->orders, 5), apc.parent_entity_id, pathway->orders[nNum].order_id)
        and apc.parent_entity_name = "ORDERS"
        and apc.parent_entity_id > 0
        and not exists (select o.order_id from orders o where o.order_id = apc.parent_entity_id)
    join ocs
        where ocs.synonym_id = apc.ref_prnt_ent_id
    join os
        where os.order_sentence_id = outerjoin(apc.order_sentence_id)
        and os.order_sentence_id > outerjoin(0)
    join lt
        where lt.long_text_id = outerjoin(os.ord_comment_long_text_id)
;/*
    detail
        nOrderPos = locateval(nNum, 1, size(pathway->orders, 5), apc.parent_entity_id, pathway->orders[nNum].order_id)
 
        if (nOrderPos > 0 and pathway->group[pathway->orders[nOrderPos].pathway_seq].pw_status_cd = cv16769_Planned)
            outrec->data[nLoop].qualified = 1	;003
            pathway->orders[nOrderPos].qualified = 1
            pathway->orders[nOrderPos].catalog_type_cd = ocs.catalog_type_cd
            pathway->orders[nOrderPos].display_line = os.order_sentence_display_line
            pathway->orders[nOrderPos].order_status_cd = cv16769_Planned
            pathway->orders[nOrderPos].ordered_as_mnemonic = ocs.mnemonic
            pathway->orders[nOrderPos].order_mnemonic = ocs.mnemonic	;018
            pathway->orders[nOrderPos].order_comment = lt.long_text
			if (apc.offset_quantity > 0.0)												;014
            	pathway->orders[nOrderPos].offset_quantity = apc.offset_quantity   		;014         
            	pathway->orders[nOrderPos].offset_unit_cd = apc.offset_unit_cd			;014
            endif
 
;            pathway->orders[nOrderPos].transfuse_order_comment = concat(^<b>^, trim(ocs.mnemonic), ^</b> ^,
;                    ^(^, trim(uar_get_code_display(pathway->group[pathway->orders[nOrderPos].pathway_seq].pw_status_cd)), ^), ^,
;                    trim(os.order_sentence_display_line), " ",
;                    trim(lt.long_text))
 
            pathway->orders[nOrderPos].type = "PLANNED ORDER"
        endif
;*/
    with expand=2
 
 
    ; Collect the order proposals
    select into "nl:"
        order_proposal_id   = op.order_proposal_id,
        detail_sequence     = opd.detail_sequence,
        order_proposal_detail_id	= opd.order_proposal_detail_id, ;028
        display_value       = if (cnvtupper(opd.oe_field_display_value) = "YES")
                                off.label_text
                              elseif (oef.field_type_flag = 3)
                                sCST_DATE(opd.oe_field_dt_tm_value)
                              elseif (oef.field_type_flag = 5)
                               sCST_DT_TM(opd.oe_field_dt_tm_value)
                              else
                                opd.oe_field_display_value
                              endif
    from    order_proposal          op,
            order_catalog_synonym   ocs,
            order_proposal_detail   opd,
            order_entry_fields      oef,
            oe_format_fields        off,
            order_proposal_comment  opc,
            order_proposal			op2, ;028
            long_text               lt
    plan op
        where expand(nNum, 1, size(pathway->orders, 5), op.order_proposal_id, pathway->orders[nNum].order_proposal_id)
        and op.order_proposal_id > 0
    join ocs
        where ocs.synonym_id = op.synonym_id
    join op2														;028
    	where op2.projected_order_id = op.projected_order_id		;028
    join opd
        ;028 where opd.order_proposal_id = op.order_proposal_id
        where opd.order_proposal_id = op2.order_proposal_id ;028
    join oef
        where oef.oe_field_id = opd.oe_field_id
    join off
        where off.oe_field_id = oef.oe_field_id
        and off.oe_format_id = op.oe_format_id
        and off.clin_line_ind = 1
        and off.action_type_cd = cv6003_Order
        ;026 and (off.disp_yes_no_flag = 0 or
        ;026      (off.disp_yes_no_flag = 1 and opd.oe_field_display_value = "Yes") or
        ;026      (off.disp_yes_no_flag = 2 and opd.oe_field_display_value = "No"))
        and ((off.disp_yes_no_flag = 0 or	;026
             (off.disp_yes_no_flag = 1 and opd.oe_field_display_value = "Yes") or ;026
             (off.disp_yes_no_flag = 2 and opd.oe_field_display_value = "No")) ;026
             or (off.label_text in("Start Date/Time","Requested Start Date/Time"))) ;026
    join opc
        where opc.order_proposal_id = outerjoin(op.order_proposal_id)
    join lt
        where lt.long_text_id = outerjoin(opc.long_text_id)
        and lt.active_ind = outerjoin(1)
    ;028 order order_proposal_id, detail_sequence
    order order_proposal_id, detail_sequence, order_proposal_detail_id ;028
    head order_proposal_id
        cString = ""
        nQualified = 0
        nStartDtTm = sysdate
    head detail_sequence
        /*start 028 *
        if (trim(cString) != "")
            cString = concat(trim(cString), ",")
        endif
        cString = trim(concat(trim(cString), " ", display_value),3)
        end 028 */
        x = 0 ;028
    detail
        if (opd.oe_field_meaning = "REQSTARTDTTM" and opd.oe_field_dt_tm_value < cnvtdatetime(dToDate))
            nQualified = 1
            nStartDtTm = opd.oe_field_dt_tm_value
        endif
    foot detail_sequence
        ;028 x = 0
        /*start 028*/
        if (op.order_proposal_id = op2.order_proposal_id)
	        if (trim(cString) != "")
	            cString = concat(trim(cString), ",")
	        endif
	        cString = trim(concat(trim(cString), " ", display_value),3)
	    endif
    foot order_proposal_id
        if (nQualified = 1)
            nOrderPos = locateval(nNum, 1, size(pathway->orders, 5), op.order_proposal_id, pathway->orders[nNum].order_proposal_id)
 
            pathway->orders[nOrderPos].order_id = op.projected_order_id
            pathway->orders[nOrderPos].catalog_type_cd = ocs.catalog_type_cd
            pathway->orders[nOrderPos].catalog_cd = ocs.catalog_cd
            pathway->orders[nOrderPos].display_line = cString
            pathway->orders[nOrderPos].ordered_as_mnemonic = op.ordered_as_mnemonic
            pathway->orders[nOrderPos].order_mnemonic = op.order_mnemonic	;018
            pathway->orders[nOrderPos].current_start_dt_tm = nStartDtTm
           ;013  pathway->orders[nOrderPos].order_status_cd = cv6004_Future
            pathway->orders[nOrderPos].order_status_cd = uar_get_code_by("MEANING",17969,"REVIEWREQ") ;013

            if (op.orig_ord_as_flag = 1)
                pathway->orders[nOrderPos].prescription_ind = 1
            endif
            pathway->orders[nOrderPos].order_comment = lt.long_text
            pathway->orders[nOrderPos].qualified = 1
            outrec->data[nLoop].qualified = 1
 
        endif
    with expand=2
    
    /* start 004 */
	; Collect the order proposals that are planned orders
    select into "nl:"
        order_proposal_id   = op.order_proposal_id,
        detail_sequence     = opd.detail_sequence,
        display_value       = if (cnvtupper(opd.oe_field_display_value) = "YES")
                                off.label_text
                              elseif (oef.field_type_flag = 3)
                                sCST_DATE(opd.oe_field_dt_tm_value)
                              elseif (oef.field_type_flag = 5)
                               sCST_DT_TM(opd.oe_field_dt_tm_value)
                              else
                                opd.oe_field_display_value
                              endif
		from
			order_proposal          op,
			order_proposal_detail   opd,
			order_entry_fields      oef,
			oe_format_fields        off,
			order_catalog_synonym   ocs,
			order_proposal_comment  opc,
			long_text               lt,
			act_pw_comp             apc,
			pathway 				p,
			act_pw_comp_r       	r
		plan op
		   where expand(nNum, 1, size(pathway->orders, 5), op.order_proposal_id, pathway->orders[nNum].order_proposal_id)
		        and op.order_proposal_id > 0
		join opd
		        where opd.order_proposal_id = op.order_proposal_id
		join apc
			where apc.parent_entity_id = op.order_proposal_id
		join p
			where p.pathway_id = apc.pathway_id
			and   p.pw_status_cd = cv16769_Planned
		join oef
		        where oef.oe_field_id = opd.oe_field_id
		join off
		        where off.oe_field_id = oef.oe_field_id
		        and off.oe_format_id = op.oe_format_id
		        and off.clin_line_ind = 1
		    	and off.action_type_cd = cv6003_Order
        		and (off.disp_yes_no_flag = 0 or
		             (off.disp_yes_no_flag = 1 and opd.oe_field_display_value = "Yes") or
		             (off.disp_yes_no_flag = 2 and opd.oe_field_display_value = "No"))
    	join ocs
        	where ocs.synonym_id = op.synonym_id
	    join opc
	        where opc.order_proposal_id = outerjoin(op.order_proposal_id)
	    join lt
	        where lt.long_text_id = outerjoin(opc.long_text_id)
	        and lt.active_ind = outerjoin(1)
	    join r
	    	where r.act_pw_comp_t_id = outerjoin(apc.act_pw_comp_id)
    order order_proposal_id, detail_sequence
    head order_proposal_id
        cString = ""
        nQualified = 0
        nStartDtTm = sysdate
    head detail_sequence
        if (trim(cString) != "")
            cString = concat(trim(cString), ",")
        endif
        cString = trim(concat(trim(cString), " ", display_value),3)
    detail
        ;if (opd.oe_field_meaning = "REQSTARTDTTM" and opd.oe_field_dt_tm_value < cnvtdatetime(dToDate))
            nQualified = 1
            nStartDtTm = opd.oe_field_dt_tm_value
        ;endif
    foot detail_sequence
        x = 0
    foot order_proposal_id
        if (nQualified = 1)
            nOrderPos = locateval(nNum, 1, size(pathway->orders, 5), op.order_proposal_id, pathway->orders[nNum].order_proposal_id)
 
            pathway->orders[nOrderPos].order_id = op.projected_order_id
            pathway->orders[nOrderPos].catalog_type_cd = ocs.catalog_type_cd
            pathway->orders[nOrderPos].catalog_cd = ocs.catalog_cd
            pathway->orders[nOrderPos].display_line = op.clinical_display_line
            pathway->orders[nOrderPos].clinical_display_line = op.clinical_display_line ;021
            pathway->orders[nOrderPos].simplified_display_line = op.simplified_display_line ;021
            pathway->orders[nOrderPos].ordered_as_mnemonic = op.ordered_as_mnemonic
            pathway->orders[nOrderPos].order_mnemonic = op.order_mnemonic ;018
            pathway->orders[nOrderPos].current_start_dt_tm = nStartDtTm
            pathway->orders[nOrderPos].order_status_cd = p.pw_status_cd
            call echo(build2("pathway->orders[nOrderPos].order_id=",pathway->orders[nOrderPos].order_id))
            call echo(build2("pathway->orders[nOrderPos].ordered_as_mnemonic=",pathway->orders[nOrderPos].ordered_as_mnemonic))
            call echo(build2("pathway->orders[nOrderPos].order_mnemonic=",pathway->orders[nOrderPos].order_mnemonic)) ;018
              
            if (op.orig_ord_as_flag = 1)
                pathway->orders[nOrderPos].prescription_ind = 1
            endif
            pathway->orders[nOrderPos].order_comment = lt.long_text
            pathway->orders[nOrderPos].type = "PLANNED ORDER"
            if (apc.offset_quantity > 0.0)
            	pathway->orders[nOrderPos].offset_quantity = apc.offset_quantity            
            	pathway->orders[nOrderPos].offset_unit_cd = apc.offset_unit_cd
            endif
            if ((r.offset_quantity > 0.0) and (pathway->orders[nOrderPos].offset_quantity = 0.0))
            	pathway->orders[nOrderPos].offset_quantity = r.offset_quantity            
            	pathway->orders[nOrderPos].offset_unit_cd = r.offset_unit_cd
            endif
            call echo(build2("pathway->orders[nOrderPos].offset_quantity=",pathway->orders[nOrderPos].offset_quantity))
            call echo(build2("pathway->orders[nOrderPos].offset_unit_cd=",
            	uar_get_code_display(pathway->orders[nOrderPos].offset_unit_cd)))
            pathway->orders[nOrderPos].type = "PLANNED ORDER"
            pathway->orders[nOrderPos].qualified = 1
            outrec->data[nLoop].qualified = 1
 
        endif
    with expand=2
 	/* end 004 */
 	
 	
    ; Collect the long text values
    select into "nl:"
    from    long_text           lt
    plan    lt
        where expand(nNum, 1, size(pathway->orders, 5), lt.long_text_id, pathway->orders[nNum].long_text_id)
        and lt.long_text_id > 0
        and lt.active_ind = 1
    detail
        nOrderPos = locateval(nNum, 1, size(pathway->orders, 5), lt.long_text_id, pathway->orders[nNum].long_text_id)
        nPathwayId = pathway->orders[nOrderPos].pathway_id
        nQualPos = 0
 
        if (nOrderPos > 0)
    		while (locateval(nNum,nQualPos+1,size(pathway->orders,5), nPathwayId, pathway->orders[nNum].pathway_id)>0)
                nQualPos = nNum
    			if (pathway->orders[nNum].qualified = 1)
                    pathway->orders[nOrderPos].qualified = 1
                endif
            endwhile
 
            pathway->orders[nOrderPos].ordered_as_mnemonic = "Note"
            pathway->orders[nOrderPos].transfuse_order_comment = concat(^Note: ^, trim(lt.long_text,3))
        endif
    with expand=2
 
    if (outrec->data[nLoop].qualified = 1)
 
        ; Read the .html file and store in memory
        select into "nl:"
            r.line
        from rtl2t r
        detail
            cHTML = trim(concat(trim(cHTML), " ", trim(r.line)),3)
        with counter
 
        ; Replace the tags in the HTML with our data (Loop through each qualified patient)
        ;029 call content("run_date", format(sysdate))
        call content("run_date", format(sysdate,"dd-mmm-yyyy hh:mm:ss;;q")) ;029
        call content("from_date", sCST_DATE(dFromDate))
        call content("end_date", sCST_DATE(dToDate))
        call content("phn", outrec->data[nLoop].cdr_phn)
        call content("dob", substring(1,11,outrec->data[nLoop].cdr_birth_date))
        call content("age", trim(outrec->data[nLoop].cdr_age, 3))
        call content("mrn", outrec->data[nLoop].cdr_mrn)
        call content("encntr_nbr", outrec->data[nLoop].cdr_encounter)
        call content("dual_modality", outrec->data[nLoop].dual_modality)
 
/* start 025 */

select into "nl:"
from
	  pathway p
	 ,regimen_detail rd	
	 ,regimen r	
	 ,(dummyt         d with seq=value(size(pathway->orders, 5)))
	 ,(dummyt         d2 with seq=value(size(pathway->group, 5)))
plan d
join d2
	where pathway->group[d2.seq].pathway_id = pathway->orders[d.seq].pathway_id
join p
	where p.pathway_id = pathway->group[d2.seq].pathway_id
join rd												
	where rd.activity_entity_id = p.pw_group_nbr	
join r												
	where r.regimen_id = rd.regimen_id				
order by
	p.pathway_id
detail
	pathway->orders[d.seq].regimen_name = r.regimen_name
with nocounter

/* end 025 */

/* start 007 */
	call echo("start 007a")
	select into "nl:"
		from    (dummyt         d with seq=value(size(pathway->orders, 5))),
                (dummyt         d2 with seq=value(size(pathway->group, 5)))
                
        plan d
            where pathway->orders[d.seq].qualified = 1
            and pathway->orders[d.seq].type = "PLANNED ORDER"
        join d2
            where pathway->group[d2.seq].pathway_id = pathway->orders[d.seq].pathway_id
        head report
        	null
        detail
        	call echo(build("pathway->orders[d.seq].ordered_as_mnemonic=",pathway->orders[d.seq].ordered_as_mnemonic))
        	call echo(build("pathway->orders[d.seq].order_mnemonic=",pathway->orders[d.seq].order_mnemonic)) ;018
        	call echo(build("pathway->orders[d.seq].order_proposal_id=",pathway->orders[d.seq].order_proposal_id))
        	call echo(build("pathway->group[d2.seq].description=",pathway->group[d2.seq].description))
        	call echo(build("pathway->group[d2.seq].start_dt_tm=",sCST_DT_TM(pathway->group[d2.seq].start_dt_tm)))
        	if (pathway->group[d2.seq].start_dt_tm > 0)
        		pathway->orders[d.seq].current_start_dt_tm = pathway->group[d2.seq].start_dt_tm
        	endif
        with nocounter
    call echo("start 007b")
    select into "nl:"
		from    (dummyt  d with seq=value(size(pathway->orders, 5))),
                act_pw_comp apc
                
        plan d
            where pathway->orders[d.seq].qualified = 1
            and pathway->orders[d.seq].type = "PLANNED ORDER"
            and pathway->orders[d.seq].order_proposal_id > 0.0
        join apc
            where apc.parent_entity_id = pathway->orders[d.seq].order_proposal_id
        head report
        	null
        detail
        	call echo(build("pathway->orders[d.seq].ordered_as_mnemonic=",pathway->orders[d.seq].ordered_as_mnemonic))
        	call echo(build("pathway->orders[d.seq].order_mnemonic=",pathway->orders[d.seq].order_mnemonic)) ;018
        	call echo(build("pathway->orders[d.seq].order_proposal_id=",pathway->orders[d.seq].order_proposal_id))
        	if (apc.offset_quantity > 0.0)
        		pathway->orders[d.seq].offset_quantity = apc.offset_quantity
        		pathway->orders[d.seq].offset_unit_cd = apc.offset_unit_cd
        	endif
        with nocounter
/* end 007 */

/* start 011 
select into "nl:"
		from    (dummyt         d with seq=value(size(pathway->orders, 5)))
                
        plan d
            where pathway->orders[d.seq].ordered_as_mnemonic = "Zero Time"
        head report
        	null
        detail
        	pathway->orders[d.seq].qualified = 0
        with nocounter

/* end 011 */


/* start 012 */ 
    select into "nl:"
        order_id = o.order_id
    from orders o
        , order_detail od
        , order_entry_format oef
        , oe_format_fields off
        ,(dummyt         d with seq=value(size(pathway->orders, 5)))            
    plan d
            where pathway->orders[d.seq].qualified = 1
            and pathway->orders[d.seq].order_id > 0.0
    join o where o.order_id = pathway->orders[d.seq].order_id
    join oef where oef.oe_format_id = o.oe_format_id
        and oef.action_type_cd = cv6003_Order
        ;and cnvtupper(oef.oe_format_name) like "*LAB*PRODUCT*CONDITIONAL*"
        and oef.oe_format_name in( 		"Lab - Product Administration (Platelets Adult Conditional)"
        							,	"Lab - Product Administration (Red Blood Cell Adult Conditional)"
        							,	"Lab - Product Administration IP (Platelets Adult Conditional)"

        						)
    join od where od.order_id = o.order_id
        and od.oe_field_id in (
              cv_16449_condition1operator
            , cv_16449_condition1value
            , cv_16449_condition1action
            , cv_16449_condition2aoperator
            , cv_16449_condition2avalue
            , cv_16449_condition2boperator
            , cv_16449_condition2bvalue
            , cv_16449_condition2action
            , cv_16449_condition3aoperator
            , cv_16449_condition3avalue
            , cv_16449_condition3boperator
            , cv_16449_condition3bvalue
            , cv_16449_condition3action
            , cv_16449_collectionpriority
            , cv_16449_routeofadministration
            , cv_16449_tmlschedule
            , cv_16449_specialbloodproductneeds
            , cv_16449_specialinstructionsbblab
            , cv_16449_specialinstructionsbbrn
        )
     join off
     	where off.oe_field_id = od.oe_field_id
     	and   off.oe_format_id = oef.oe_format_id
    order by o.order_id
        	,off.group_seq
			,off.field_seq
			,od.oe_field_id
			,od.action_sequence desc
    head o.order_id
        order_comment = " "
    head od.oe_field_id
        case (od.oe_field_id)
            of cv_16449_condition1operator :
                order_comment = build2(order_comment, off.clin_line_label, " ", od.oe_field_display_value)
            of cv_16449_condition1value :
                order_comment = build2(order_comment, " ", trim(od.oe_field_display_value), " ", off.clin_line_label)
            of cv_16449_condition1action :
                order_comment = build2(order_comment, " ", trim(od.oe_field_display_value), " ", off.clin_line_label)
            of cv_16449_condition2aoperator :
                order_comment = build2(order_comment, ", ", off.clin_line_label, " ", od.oe_field_display_value)
            of cv_16449_condition2avalue :
                order_comment = build2(order_comment, " ", trim(od.oe_field_display_value), " ", off.clin_line_label)
            of cv_16449_condition2boperator :
                order_comment = build2(order_comment, " ",off.clin_line_label," ", od.oe_field_display_value)
            of cv_16449_condition2bvalue :
                order_comment = build2(order_comment, " ", trim(od.oe_field_display_value), " ",off.clin_line_label)
            of cv_16449_condition2action :
                order_comment = build2(order_comment, " ", trim(od.oe_field_display_value), " ", off.clin_line_label)
            of cv_16449_condition3aoperator :
                order_comment = build2(order_comment, ", ", off.clin_line_label, " ", od.oe_field_display_value)
            of cv_16449_condition3avalue :
                order_comment = build2(order_comment, " ", trim(od.oe_field_display_value), " ", off.clin_line_label)
            of cv_16449_condition3boperator :
                order_comment = build2(order_comment, " ",off.clin_line_label, " ", od.oe_field_display_value)
            of cv_16449_condition3bvalue :
                order_comment = build2(order_comment, " ", trim(od.oe_field_display_value), " ", off.clin_line_label)
            of cv_16449_condition3action :
                order_comment = build2(order_comment, " ", trim(od.oe_field_display_value), " ",off.clin_line_label)
            of cv_16449_collectionpriority :
                order_comment = build2(order_comment, ", ", trim(od.oe_field_display_value))
            of cv_16449_routeofadministration :
                order_comment = build2(order_comment, ", ", trim(od.oe_field_display_value))
            of cv_16449_tmlschedule :
                order_comment = build2(order_comment, " ",off.clin_line_label, " ", trim(od.oe_field_display_value))
            of cv_16449_specialbloodproductneeds :
                order_comment = build2(order_comment, ", ", od.oe_field_display_value)
            of cv_16449_specialinstructionsbblab :
                order_comment = build2(order_comment, " ",off.clin_line_label, " ", trim(od.oe_field_display_value))
            of cv_16449_specialinstructionsbbrn :
                order_comment = build2(order_comment, " ",off.clin_line_label, " ", trim(od.oe_field_display_value))
            endcase
    foot o.order_id
    		pathway->orders[d.seq]->display_line = " "
            pathway->orders[d.seq]->transfuse_order_comment = order_comment
    with nocounter


/* end 012 */

/* start 017 */
	select into "nl:"
	from    (dummyt  d with seq=value(size(pathway->orders, 5))),
            task_activity ta
    plan d
            where pathway->orders[d.seq].qualified = 0
            and pathway->orders[d.seq].order_id > 0.0
    join ta
            where ta.order_id = pathway->orders[d.seq].order_id
            and ta.task_status_cd = cv79_Overdue
            and ta.active_ind = 1
     head report
        	null
     detail
        	call echo(build("pathway->orders[d.seq].ordered_as_mnemonic=",pathway->orders[d.seq].ordered_as_mnemonic))
        	call echo(build("pathway->orders[d.seq].order_mnemonic=",pathway->orders[d.seq].order_mnemonic)) ;018
        	call echo(build("pathway->orders[d.seq].order_id=",pathway->orders[d.seq].order_id))
        	pathway->orders[d.seq].qualified = 1
     with nocounter
      

/* end 017 */

/* start 022 */
	select into "nl:"
	type_mean	= evaluate(pathway->orders[d.seq].pathway_seq, 0, "ORDER",
					pathway->group[pathway->orders[d.seq].pathway_seq].type_mean)
	from    (dummyt d with seq=value(size(pathway->orders, 5))),
                (dummyt d2 with seq=value(size(pathway->orders, 5))),
                dummyt doj
        plan d
            where pathway->orders[d.seq].qualified = 1
            and pathway->orders[d.seq].protocol_order_id = 0
        join doj
        join d2
            where pathway->orders[d2.seq].protocol_order_id = pathway->orders[d.seq].order_id
            and pathway->orders[d2.seq].protocol_order_id > 0
            and pathway->orders[d2.seq].qualified = 1
    detail
    	call echo(build2("pathway->orders[d.seq].order_id=",pathway->orders[d.seq].order_id))
    	call echo(build2("pathway->orders[d.seq].order_mnemonic=",pathway->orders[d.seq].order_mnemonic))
    	call echo(build2("type_mean=",type_mean))
    	if ((type_mean != "DOT") and (pathway->orders[d.seq].template_order_flag = 7))
    		call echo(build2("->setting display_line to =",pathway->orders[d.seq].clinical_display_line))
    		pathway->orders[d.seq].display_line = pathway->orders[d.seq].clinical_display_line
    	endif
    with outerjoin=doj, counter
/* end 022 */
;call echorecord(pathway->orders)
; go to end_program
 
 
        ; Output the HTML
        select into "nl:"
            sort_group          = if (pathway->orders[d.seq].pathway_seq > 0)
                                    1
                                  else
                                    9
                                  endif,
            section_label       = evaluate(pathway->orders[d.seq].pathway_seq, 0, "Non-PowerPlan Orders", "PowerPlan Orders"),
;                                    substring(1,75,pathway->group[pathway->orders[d.seq].pathway_seq].section_label)),
            pw_group            = evaluate(pathway->orders[d.seq].pathway_seq, 0,
                                    uar_get_code_display(pathway->orders[d.seq].catalog_type_cd),
                                    substring(1,120,pathway->group[pathway->orders[d.seq].pathway_seq].pw_group_desc)),
            pw_description      = if (pathway->orders[d.seq].pathway_seq > 0)
                                    substring(1,120,pathway->group[pathway->orders[d.seq].pathway_seq].description)
                                  else
                                    format(pathway->orders[d.seq].current_start_dt_tm, "yyyymmddhhmmss;;q")
                                    ;cnvtlower(substring(1,120,pathway->orders[d.seq].ordered_as_mnemonic))
                                  endif,
            dot_description     = evaluate(pathway->orders[d.seq].pathway_seq, 0, " ",
                                        substring(1,40,pathway->group[pathway->orders[d2.seq].pathway_seq].description)),
            period              = substring(1,30,pathway->orders[d.seq].period),
            period2              = substring(1,30,pathway->orders[d2.seq].period),
            type                = substring(1,20,pathway->orders[d.seq].type),
            status              = uar_get_code_display(pathway->orders[d.seq].order_status_cd),
            type_mean           = evaluate(pathway->orders[d.seq].pathway_seq, 0, "ORDER",
                                    pathway->group[pathway->orders[d.seq].pathway_seq].type_mean),
            pw_group_nbr        = evaluate(pathway->orders[d.seq].pathway_seq, 0, 0.0,
                                    pathway->group[pathway->orders[d.seq].pathway_seq].pw_group_nbr),
			pathway_sequence    = evaluate(pathway->orders[d.seq].pathway_seq, 0, 0.0,						;023
                                    pathway->group[pathway->orders[d.seq].pathway_seq].pathway_sequence),	;023
			regimen_name 		= substring(1,200,pathway->orders[d.seq].regimen_name), ;025
            qualified           = pathway->orders[d.seq].qualified,
            pathway_id          = pathway->orders[d.seq].pathway_id,
            pathway_group_id    = if (pathway->orders[d.seq].pathway_seq > 0)
                                    pathway->group[pathway->orders[d.seq].pathway_seq].pathway_group_id
                                  endif,
            period_nbr          = evaluate(pathway->orders[d2.seq].pathway_seq, 0, 0,
                                    pathway->group[pathway->orders[d2.seq].pathway_seq].period_nbr),
            sequence            = pathway->orders[d.seq].sequence,
            act_pw_comp_id      = pathway->orders[d.seq].act_pw_comp_id,
            order_id            = pathway->orders[d.seq].order_id,
            template_order_id   = pathway->orders[d.seq].template_order_id,
            protocol_order_id   = pathway->orders[d.seq].protocol_order_id,
            sort_date           = format(pathway->orders[d.seq].current_start_dt_tm, "yyyymmddhhmm;;q"),
            ordered_as_mnemonic = substring(1,300,pathway->orders[d.seq].ordered_as_mnemonic),
            order_mnemonic = substring(1,300,pathway->orders[d.seq].order_mnemonic), ;018
            child_date          = sCST_DT_TM(pathway->orders[d2.seq].current_start_dt_tm),
			cosignature_ind    = pathway->orders[d.seq].cosignature_ind, ;026
            offset              = if (pathway->orders[d2.seq].offset_quantity > 0.0)
                                    concat("+", trim(format(pathway->orders[d2.seq].offset_quantity, "#######"),3),
                                    " ", uar_get_code_display(pathway->orders[d2.seq].offset_unit_cd))
                                  elseif (pathway->orders[d2.seq].offset_quantity < 0.0)
                                    concat(trim(format(pathway->orders[d2.seq].offset_quantity, "#######"),3),
                                    " ", uar_get_code_display(pathway->orders[d2.seq].offset_unit_cd))
                                  endif,
            /* start 007 */
            offset2              = if (pathway->orders[d.seq].offset_quantity > 0.0)
                                    concat("+", trim(format(pathway->orders[d.seq].offset_quantity, "#######"),3),
                                    " ", uar_get_code_display(pathway->orders[d.seq].offset_unit_cd))
                                  elseif (pathway->orders[d.seq].offset_quantity < 0.0)
                                    concat(trim(format(pathway->orders[d.seq].offset_quantity, "#######"),3),
                                    " ", uar_get_code_display(pathway->orders[d.seq].offset_unit_cd))
                                  endif
            /* end 007 */
        from    (dummyt         d with seq=value(size(pathway->orders, 5))),
                (dummyt         d2 with seq=value(size(pathway->orders, 5))),
                dummyt          doj
        plan d
            where pathway->orders[d.seq].qualified = 1
            and pathway->orders[d.seq].protocol_order_id = 0
        join doj
        join d2
            where pathway->orders[d2.seq].protocol_order_id = pathway->orders[d.seq].order_id
            and pathway->orders[d2.seq].protocol_order_id > 0
            and pathway->orders[d2.seq].qualified = 1
        ;023 order sort_group, section_label, pw_group, pw_group_nbr, pathway_id, pw_description, act_pw_comp_id; sequence
        order sort_group, section_label, pw_group_nbr, pw_group, pathway_sequence, pathway_id, act_pw_comp_id; sequence ;023
;/*
        head report
            cString = ^^
 			_key = ^^	;010
            ; Add new entry to temp structure
            subroutine addTemp(x)
                nSeq = nSeq + 1
                stat = alterlist(temp->data, nSeq)
            end
 
            ; Add date to temp structure
            ;026 subroutine addDate(cLabel, dDate, cStatus)
            subroutine addDate(cLabel, dDate, cStatus, cCosign)
            	_key = concat(format(dDate,"yyyymmddhhmm;;q"),":",trim(cLabel))	;010
                if (type = "SINGLEORDER" or temp->single_ind = 1)
                    temp->single_ind = 1
                else
                    ; Update the dates array
                    nFound = 0
                    for (nDateLoop = 1 to nDateCount)
                        ;010 if (cLabels[nDateLoop] = cLabel) 
                        if (cLabels[nDateLoop] = _key) ;010
                            nFound = 1
                        endif
 
                        ;if (dDates[nDateLoop] = dDate)
                            ;nFound = 1
                        ;endif
                    endfor
                    if (nFound = 0)
                        nDateCount = nDateCount + 1
                        ;010 cLabels[nDateCount] = cLabel
                        cLabels[nDateCount] = _key ;010
                        ; dDates[nDateCount] = dDate
 
                        ; Update the titles
                        stat = alterlist(temp->titles, size(temp->titles, 5)+1)
                        temp->titles[size(temp->titles,5)].label = cLabel
                        temp->titles[size(temp->titles,5)].date = dDate
                        temp->titles[size(temp->titles,5)]._key = _key	;010
                    endif
                endif
 
                ; Update the columns
                nCol = size(temp->data[nSeq].columns, 5)+1
                stat = alterlist(temp->data[nSeq].columns, nCol)
                temp->data[nSeq].columns[nCol].date = dDate
                temp->data[nSeq].columns[nCol].label = cLabel
                temp->data[nSeq].columns[nCol]._key = _key	;010
 				
                if (trim(offset) != "")
                    temp->data[nSeq].columns[nCol].status =
                        concat(trim(cStatus,3), ^ (<span style="color: red;">^, trim(offset, 3), ^</span>)^)
                /* start 007 */
                elseif ((trim(offset2) != "") and nCol = 1)
                    temp->data[nSeq].columns[nCol].status =
                        concat(trim(cStatus,3), ^ (<span style="color: red;">^, trim(offset2, 3), ^</span>)^)
                /* end 007 */
                else
                    temp->data[nSeq].columns[nCol].status = cStatus
                endif
                if (cCosign = 1)
 					temp->data[nSeq].columns[nCol].cosign = "Cosignature Required"
 					temp->data[nSeq].columns[nCol].status =
                        concat(trim(cStatus,3), ^ <br /><span style="color: red;">^, 
                        		trim(temp->data[nSeq].columns[nCol].cosign), ^</span>^)
 				endif
                ;temp->data[nSeq].columns[nCol].status = cStatus
            end
 
            ; Starts a new order row. Added to subroutine as it is called from multiple places
            subroutine display_order(x)
            	if (ordered_as_mnemonic = " ")														;018
            		temp->data[nSeq].sentence = concat(^<b>^, trim(order_mnemonic,3), ^</b>^)	;018
            	else	;018
                	temp->data[nSeq].sentence = concat(^<b>^, trim(ordered_as_mnemonic,3), ^</b>^)
 				endif	;018
                if (trim(pathway->orders[d.seq].display_line) != "")
                    temp->data[nSeq].sentence = concat(trim(temp->data[nSeq].sentence), ^, ^,
                            trim(pathway->orders[d.seq].display_line))
                endif
 				
                ;006 temp->data[nSeq].sentence = concat(trim(temp->data[nSeq].sentence),"<br/>",
                ;006            trim(concat(trim(pathway->orders[d.seq].order_comment), " ",
                ;006            trim(pathway->orders[d.seq].mar_note), " ",	;006
                ;006            trim(pathway->orders[d.seq].transfuse_order_comment)),3), ^</td>^)
                
                /*start 006 */
                temp->data[nSeq].sentence = concat(trim(temp->data[nSeq].sentence))
                if (pathway->orders[d.seq].order_comment > " ")
                	temp->data[nSeq].sentence = concat(trim(temp->data[nSeq].sentence),"<br/>Order Comment:",
                		trim(pathway->orders[d.seq].order_comment)," ")
                endif
                if (pathway->orders[d.seq].mar_note > " ")
                	temp->data[nSeq].sentence = concat(trim(temp->data[nSeq].sentence),"<br/>MAR Note:",
                		trim(pathway->orders[d.seq].mar_note)," ")
                endif
                temp->data[nSeq].sentence = concat(trim(temp->data[nSeq].sentence),"<br/>",
                	trim(pathway->orders[d.seq].transfuse_order_comment))
                /*end 006 */
            end
 
        head sort_group
            x = 0
        head section_label
            call addStr(concat(^<h1>^,
                            trim(section_label,3), ^</h1>^))
        ;023 head pw_group
        ;023     x = 0
        head pw_group_nbr
            ;023 call addStr(concat(^<h2 style="background-color: #f2f2f2; padding: 1rem;">^, trim(pw_group,3), ^</h2>^))
            x = 0 ;023
        head pw_group	;023
        	if (regimen_name > " ")
        		call addStr(concat(^<h2 style="background-color: #f2f2f2; padding: 1rem;">^,	;025
        					 trim(pathway->orders[d.seq].regimen_name,3),^<br/>^,				;025
        					 trim(pw_group,3), ^</h2>^) 										;023 ;025
        					)
        	else	;025
        		call addStr(concat(^<h2 style="background-color: #f2f2f2; padding: 1rem;">^, trim(pw_group,3), ^</h2>^)) ;023
        	endif ;025
        head pathway_id
 
            stat = initrec(temp)
            nSeq = 0
            nDateCount = 0
            stat = initarray(dDates, 0) ; clear the dates array
            stat = initarray(cLabels, " ") ; clear the labels array
 
            if (pathway_id > 0)
                call addStr(concat(^<h3>^, trim(pw_description,3), ^</h3>^))
            endif
 
            call addStr(^<table style="border: 3px solid; border-collapse: collapse;">^)
        head pw_description
            x = 0
        head act_pw_comp_id ;sequence
            ; Build the sentence line
            if (type = "LONG TEXT")
                call addTemp(0)
                temp->data[nSeq].sentence = pathway->orders[d.seq].transfuse_order_comment
                temp->data[nSeq].type = 2 ; Comment
            elseif (type != "SINGLEORDER")
                call addTemp(0)
                call display_order(0)
            endif
        detail
            if (type = "SINGLEORDER")
                call addTemp(0)
                call display_order(0)
            endif
 			
            ; Add the child orders
            if (d2.seq > 0 and type != "LONG TEXT")
                call addDate(   dot_description,
                                pathway->orders[d2.seq].current_start_dt_tm,
                                uar_get_code_display(pathway->orders[d2.seq].order_status_cd) ;026 )
 								,cosignature_ind) ;026
            ; Add orders that are part of a plan but not DOT
            elseif (trim(period) != "")
                call addDate(   period,
                                pathway->orders[d.seq].current_start_dt_tm,
                                uar_get_code_display(pathway->orders[d.seq].order_status_cd) ;026)
 								,cosignature_ind) ;026
            ; Display top level pathways and single orders
            elseif (type != "LONG TEXT")
                temp->single_ind = 1
                temp->data[nSeq].type = 1
                call addDate("", pathway->orders[d.seq].current_start_dt_tm,
                                uar_get_code_display(pathway->orders[d.seq].order_status_cd),cosignature_ind) ;026)
                call addDate("", pathway->orders[d.seq].projected_stop_dt_tm, "",cosignature_ind) ;026)
            endif
        foot act_pw_comp_id; sequence
            x = 0
        foot pathway_id
            ; Sort the dates array
            if (nDateCount > 1)
                stat = sort(cLabels, nDateCount)
                stat = sort(dDates, nDateCount)
            endif
 
            ; Output a title row
            call addStr(^<tr style="border: 3px solid; text-align: center; font-weight: bold;">^)
            call addStr(^<td style="border: 1px solid;">Order Sentence</td>^)
            if (temp->single_ind = 1)
                call addStr(^<td style="border: 1px solid;">Start Dt/Tm</td>^)
                call addStr(^<td style="border: 1px solid;">End Dt/Tm</td>^)
            else
                for (nDateLoop = 1 to nDateCount)
                    ;nPos = locateval(nNum, 1, size(temp->titles, 5), dDates[nDateLoop], temp->titles[nNum].date)
                    ;010 nPos = locateval(nNum, 1, size(temp->titles, 5), cLabels[nDateLoop], temp->titles[nNum].label)
                    nPos = locateval(nNum, 1, size(temp->titles, 5), cLabels[nDateLoop], temp->titles[nNum]._key)	;010
                    if (nPos > 0)
                        call addStr(concat(^<td style="border: 1px solid;">^, temp->titles[nPos].label, '<br/>',
                                    sCST_DT_TM(temp->titles[nPos].date),^</td>^))
                    endif
                endfor
            endif
            call addStr(^</tr>^)
 
            ; Loop the temp structure
            if (temp->single_ind = 1)
                nDateCount = 2
            endif
 
            for (nTempLoop = 1 to size(temp->data, 5))
                if (temp->data[nTempLoop].type = 2) ; Comment
                    call addStr(concat(^<tr><td colspan="^, build(nDateCount+1), ^" style="border: 1px solid;">^,
                                trim(temp->data[nTempLoop].sentence,3), ^</td>^))
                else                                ; Everything else
                    call addStr(concat(^<tr><td style="border: 1px solid;">^, trim(temp->data[nTempLoop].sentence,3), ^</td>^))
 
                    ; Singles print differently with Start/End Dates than Plan Items
                    if (temp->single_ind = 1)
                        for (nPos = 1 to size(temp->data[nTempLoop].columns, 5))
                            call addStr(concat(^<td style="border: 1px solid;">^,
                                    trim(temp->data[nTempLoop]->columns[nPos].status, 3),^<br/>^,
                                    trim(sCST_DT_TM(temp->data[nTempLoop]->columns[nPos].date),3)))
 
                             ; Fake a cell if one value instead of 2
                             if (size(temp->data[nTempLoop].columns, 5) = 1)
                                call addStr(^<td style="border: 1px solid;">&nbsp;</td>^)
                             endif
                        endfor
 
                    ; Print Plan Items
                    else
                        for (nDateLoop = 1 to nDateCount)
                            nPos = locateval(nNum, 1, size(temp->data[nTempLoop]->columns, 5), cLabels[nDateLoop],	;010
                                            temp->data[nTempLoop]->columns[nNum]._key)								;010
 
                           
                           ;010 nPos = locateval(nNum, 1, size(temp->data[nTempLoop]->columns, 5), cLabels[nDateLoop],
                           ;010                 temp->data[nTempLoop]->columns[nNum].label)
 
;                            nPos = locateval(nNum, 1, size(temp->data[nTempLoop]->columns, 5), dDates[nDateLoop],
;                                            temp->data[nTempLoop]->columns[nNum].date)
                            if (nPos = 0)
                                call addStr(^<td style="border: 1px solid;">&nbsp;</td>^)
                            else
                                call addStr(concat(^<td style="border: 1px solid;">^,
                                    trim(temp->data[nTempLoop]->columns[nPos].status, 3),^<br/>^,
                                    trim(sCST_DT_TM(temp->data[nTempLoop]->columns[nPos].date),3)))
                            endif
                        endfor
                    endif
                endif
                call addStr(^</tr>^)
            endfor
 
            call addStr(^</table>^)
 
        foot report
            call content("orders", cString)
;*/
        with outerjoin=doj, counter
 
        ; Output to screen if testing in DVDev
        if (not validate(request->encntr_id))
	        if (findstring("cclscratch", $outdev) > 0 and $encntrId > 0)
	            set _Memory_Reply_String = cHTML
	        else
	            call echo(cHTML)
	 
	            ;009 call saveDocument(outrec->data[nLoop].encntr_id, cclTemplate->dynDocRefTemplateDescription,
	            ;009                    cv72_FormEvent, cclTemplate->formTitleText, cHTML, 0)
	           
	            call SaveNewDocument(outrec->data[nLoop].encntr_id, outrec->data[nLoop].person_id, ;009
	                                cv72_FormEvent, "Downtime DOT Orders Report", cHTML, 0)		 ;009
	        endif
	    else
	    	call SaveNewDocument(outrec->data[nLoop].encntr_id, outrec->data[nLoop].person_id, ;009
	                                cv72_FormEvent, "Downtime DOT Orders Report", cHTML, 0)		
	    endif
    endif
 
 
endfor
 
; Subroutines
; -----------
subroutine addStr(cAddString)
    set cString = trim(concat(trim(cString)," ", cAddString),3)
end
 
subroutine content(cTag, cText)
    set cHTML = replace(cHTML, build("||", cTag, "||"), cText)
end

/*start 009 */
declare SaveNewDocument(nEncntrId = f8, nPersonId = f8,nEventCd = f8, cTitle = vc,
                        cContent = vc, nMode = i4) = null

subroutine SaveNewDocument(nEncntrId, nPersonId, nEventCd, cTitle, cContent, nMode)
declare TXT_CLASS_CD   = f8 with protect,constant(uar_get_code_by("MEANING",53,"TXT"))
declare DOC_CLASS_CD    = f8 with protect,constant(uar_get_code_by("MEANING",53,"DOC"))
declare GRP_CLASS_CD    = f8 with protect,constant(uar_get_code_by("MEANING",53,"GRP"))
declare MDOC_CLASS_CD    = f8 with protect,constant(uar_get_code_by("MEANING",53,"MDOC"))
declare REC_STAT_CD     = f8 with protect,constant(uar_get_code_by("MEANING",48,"ACTIVE"))
declare POWERCHART_SYS_CD = f8 with protect,constant(uar_get_code_by("MEANING",89,"POWERCHART"))
declare ENTRY_MODE_ONCOLOGY = f8 with protect, constant(uar_get_code_by("MEANING",29520,"ONCOLOGY"))      ;007
declare ROOT_RLTN_CD    = f8 with protect,constant(uar_get_code_by("MEANING",24,"ROOT"))
 
declare RES_STAT_AUTH_CD        = f8 with protect,constant(uar_get_code_by("MEANING", 8,"AUTH"))
declare RES_STAT_INPROGRESS_CD  = f8 with protect,constant(uar_get_code_by("MEANING", 8,"IN PROGRESS"))

 
declare c_format_RTF = f8 with protect, constant(uar_get_code_by("MEANING",23,"RTF"))
declare c_storage_BLOB = f8 with protect, constant(uar_get_code_by("MEANING",25,"BLOB"))
declare c_succession_interim = f8 with protect, constant(uar_get_code_by("MEANING",63,"INTERIM"))
 
declare SOURCE_CD = f8 with protect, constant(uar_get_code_by("MEANING",30200,"CLINICIAN"))
 
declare PERFORM_CD = f8 with protect, constant(uar_get_code_by("MEANING",21,"PERFORM"))
declare VERIFY_CD = f8 with protect, constant(uar_get_code_by("MEANING",21,"VERIFY"))
declare SIGN_CD = f8 with protect, constant(uar_get_code_by("MEANING",21,"SIGN"))
 
declare c_action_status_COMPLETED = f8 with protect, constant(uar_get_code_by("MEANING",103,"COMPLETED"))
declare c_action_status_REQUESTED = f8 with protect, constant(uar_get_code_by("MEANING",103,"REQUESTED"))
 

declare contrib_sys_cd          = f8
declare doc_cd                  = f8
declare eventCd                 = f8
declare succession_type         = f8
declare storage                 = f8
declare format                  = f8
declare record_status           = f8
declare result_status           = f8

declare ApplicationId           = i4 with constant(1000012)
declare TaskId                  = i4 with constant(1000012)
declare RequestId               = i4 with constant(1000012)

declare hApp                    = i4
declare hTask                   = i4
declare hStep                   = i4
declare hReq                    = i4
declare hRep                    = i4
declare hReply                  = i4
declare hCE                     = i4
declare hrb_list                = i4
declare hBlob                   = i4
declare hBlob2                  = i4

declare notesize                = i4

set contrib_sys_cd = uar_get_code_by("MEANING",89,"POWERCHART")

set doc_cd = uar_get_code_by("MEANING",53,"DOC")

set succession_type = uar_get_code_by("MEANING",63, "FINAL")

set storage = uar_get_code_by("MEANING",25, "BLOB")
    
set format =uar_get_code_by("MEANING",23, "HTML")

set record_status = uar_get_code_by("MEANING",48, "ACTIVE")

set result_status = uar_get_code_by("MEANING",8, "AUTH")

execute crmrtl
execute srvrtl 
   
     
  set iRet = uar_CrmBeginApp(ApplicationId, hApp)
 
  set iRet = uar_CrmBeginTask(hApp, TaskId, hTask)

  set iRet = uar_CrmBeginReq(hTask, "", RequestId, hStep)
  
  set hReq = uar_CrmGetRequest (hStep)
  
  set hCE = uar_SrvGetStruct(hReq, "clin_event");
  
  if (hCE)
      set srvstat = uar_SrvSetShort( hCE,"ensure_type", 1)
      set srvstat = uar_SrvSetDouble(hCE,"person_id",nPersonId)
      set srvstat = uar_SrvSetDouble(hCE,"contributor_system_cd", contrib_sys_cd)
      set srvstat = uar_SrvSetDouble(hCE,"event_class_cd", doc_cd)
      set srvstat = uar_SrvSetDouble(hCE,"encntr_id",nEncntrId)
      set srvstat = uar_SrvSetDouble(hCE,"event_cd", nEventCd)
    
      set srvstat = uar_SrvSetDouble(hCE,"result_status_cd", result_status)
      set srvstat = uar_SrvSetDate(  hCE,"event_end_dt_tm", cnvtdatetime(curdate, curtime3))
      set srvstat = uar_SrvSetDouble(hCE,"record_status_cd", record_status)
      set srvstat = uar_SrvSetDouble(hCE,"ENTRY_MODE_CD",  uar_get_code_by("MEANING",29520,"DYNDOC"))
      set srvstat = uar_SrvSetDate(  hCE,"event_start_dt_tm", cnvtdatetime(curdate, curtime3))
      set srvstat = uar_SrvSetLong(  hCE,"view_level", 1)
      set srvstat = uar_SrvSetShort( hCE,"authentic_flag", 1)
      set srvstat = uar_SrvSetShort( hCE,"publish_flag", 1)
      set srvstat = uar_SrvSetString(hCE, "event_title_text", cTitle)
  
      ;following code writes to the ce_blob table.    
      set hBlob = uar_SrvAddItem(hCE,"blob_result")
      if(hBlob)
         set srvstat = uar_SrvSetDouble(hBlob,"succession_type_cd", succession_type)
         set srvstat = uar_SrvSetDouble(hBlob,"storage_cd",storage)
         set srvstat = uar_SrvSetDouble(hBlob,"format_cd", format)
                  
         set hBlob2 = uar_SrvAddItem(hBlob,"blob")
         if (hBlob2)
               set notesize = size(cContent)
             set srvstat = uar_SrvSetAsIs(hBlob2,"blob_contents", cContent,notesize)
         endif
      endif
      
      set hCE3 = uar_SrvAddItem(hCE,"event_prsnl_list")
	
      set iRet = uar_SrvSetDouble(hCE3,"action_type_cd", PERFORM_CD)
  	  set iRet = uar_SrvSetDate(hCE3,"action_dt_tm", cnvtdatetime(CURDATE,CURTIME) )
  	  
      set iRet = uar_SrvSetDouble(hCE3,"action_prsnl_id", 1.0) 
      set iRet = uar_SrvSetDouble(hCE3,"action_status_cd", c_action_status_COMPLETED);


	  set hCE4 = uar_SrvAddItem(hCE,"event_prsnl_list")
	  
      set iRet = uar_SrvSetDouble(hCE4,"action_type_cd", VERIFY_CD)
  	  set iRet = uar_SrvSetDate(hCE4,"action_dt_tm", cnvtdatetime(CURDATE,CURTIME) )
      set iRet = uar_SrvSetDouble(hCE4,"action_prsnl_id", 1.0) 
      set iRet = uar_SrvSetDouble(hCE4,"action_status_cd", c_action_status_COMPLETED);
      
 
            
  endif
  
  set iRet = uar_CrmPerform(hStep)
  if (iRet != 0)
     set msg = "iRet; uar_CrmPerform failed"
    
  endif
  
  
  set hRep = uar_CrmGetReply(hStep)
  call echo(build("uar_CrmGetReply: ",hRep))
  if (hRep = 0)
     set msg = "hRep = uar_CrmGetReply failed"

  endif
end  
/*end 009 */
#end_program
if (validate(pathway))				;001
	;call echorecord(pathway) 		;001 
	call echo("end")
endif								;001
end go


