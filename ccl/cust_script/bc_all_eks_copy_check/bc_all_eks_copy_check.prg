<<<<<<< HEAD
/*****************************************************************************
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:
  Source file name:   bc_all_eks_copy_check.prg
  Object name:        bc_all_eks_copy_check
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
******************************************************************************/
drop program bc_all_eks_copy_check:dba go
create program bc_all_eks_copy_check:dba
 
set retval = -1
 
call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set debug_ind = 2	;0 = no debug, 1=basic debug with echo, 2=msgview debug
 
%i cust_script:bc_common_routines.inc

declare isPowerPlanOrder(vOrderID=f8) = f8
subroutine isPowerPlanOrder(vOrderID)
	
	declare return_val = f8 with protect
	
	select into "nl:"
	from
		orders o
	plan o
		where o.order_id = vOrderID
	detail
		return_val = o.pathway_catalog_id
	with nocounter

	return (return_val)
end
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Report *********************************************"))
 
/*
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
*/
 
free set t_rec
record t_rec
(
	1 cnt			= i4
	1 person_id		= f8
	1 encntr_id		= f8
	1 order_id		= f8
	1 event_name    = vc
	1 beg_date		= dq8
	1 end_date		= dq8
	1 copy_cnt 		= i2
	1 copy_qual[*]
	 2 order_id		= f8
	 2 order_mnemonic = vc
	 2 dc_ind 		= i2
	1 dc_cnt 		= i2
	1 dc_qual[*]
	 2 order_id		= f8
)
 
set bc_common->log_level = 2

set retval = 0

for (i=1 to size(request->orderlist,5))
	for (j=1 to size(request->orderlist[i].detaillist,5))
		if (request->orderlist[i].detaillist[j].oefieldid = 634312)
			;if (isPowerPlanOrder(request->orderlist[i].detaillist[j].oefieldvalue) = 0)
			if	(request->orderlist[i].dayoftreatment_order_ind = 0)
				set t_rec->copy_cnt += 1
				set stat = alterlist(t_rec->copy_qual,t_rec->copy_cnt)
				set t_rec->copy_qual[t_rec->copy_cnt].order_id = 
request->orderlist[i].detaillist[j].oefieldvalue
			endif
		endif
	endfor
	
	if (request->orderlist[i].actiontypecd in( 
												 
value(uar_get_code_by("MEANING",6003,"DISCONTINUE"))
												
,value(uar_get_code_by("MEANING",6003,"CANCEL"))
											 ))
		set t_rec->dc_cnt += 1
		set stat = alterlist(t_rec->dc_qual[t_rec->dc_cnt],t_rec->dc_cnt)
		set t_rec->dc_qual[t_rec->dc_cnt].order_id = request->orderlist[i].orderid
	endif
endfor


for (i=1 to t_rec->copy_cnt)
	set t_rec->copy_qual[i].dc_ind = locateval(j,1,t_rec->dc_cnt,t_rec->copy_qual[i].order_id,t_rec->dc_qual[j].order_id)
endfor

for (i=1 to t_rec->copy_cnt)
	if (t_rec->copy_qual[i].dc_ind = 0)
		set retval = 100
	endif
endfor
 
call writeLog(build2("* END   Report   *******************************************"))
call writeLog(build2("************************************************************"))

 
#exit_script
;call echorecord(t_rec)
 
call exitScript(null)
;call echorecord(t_rec)
call echorecord(program_log)

set log_message = cnvtrectojson(t_rec)
 
end
go
 
=======
/*****************************************************************************
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:
  Source file name:   bc_all_eks_copy_check.prg
  Object name:        bc_all_eks_copy_check
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
******************************************************************************/
drop program bc_all_eks_copy_check:dba go
create program bc_all_eks_copy_check:dba
 
set retval = -1
 
call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set debug_ind = 2	;0 = no debug, 1=basic debug with echo, 2=msgview debug
 
%i cust_script:bc_common_routines.inc

declare isPowerPlanOrder(vOrderID=f8) = f8
subroutine isPowerPlanOrder(vOrderID)
	
	declare return_val = f8 with protect
	
	select into "nl:"
	from
		orders o
	plan o
		where o.order_id = vOrderID
	detail
		return_val = o.pathway_catalog_id
	with nocounter

	return (return_val)
end
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Report *********************************************"))
 
/*
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
*/
 
free set t_rec
record t_rec
(
	1 cnt			= i4
	1 person_id		= f8
	1 encntr_id		= f8
	1 order_id		= f8
	1 event_name    = vc
	1 beg_date		= dq8
	1 end_date		= dq8
	1 copy_cnt 		= i2
	1 copy_qual[*]
	 2 order_id		= f8
	 2 order_mnemonic = vc
	 2 dc_ind 		= i2
	1 dc_cnt 		= i2
	1 dc_qual[*]
	 2 order_id		= f8
)
 
set bc_common->log_level = 2

set retval = 0

for (i=1 to size(request->orderlist,5))
	for (j=1 to size(request->orderlist[i].detaillist,5))
		if (request->orderlist[i].detaillist[j].oefieldid = 634312)
			;if (isPowerPlanOrder(request->orderlist[i].detaillist[j].oefieldvalue) = 0)
			if	(request->orderlist[i].dayoftreatment_order_ind = 0)
				set t_rec->copy_cnt += 1
				set stat = alterlist(t_rec->copy_qual,t_rec->copy_cnt)
				set t_rec->copy_qual[t_rec->copy_cnt].order_id = request->orderlist[i].detaillist[j].oefieldvalue
			endif
		endif
	endfor
	
	if (request->orderlist[i].actiontypecd in( 
												 value(uar_get_code_by("MEANING",6003,"DISCONTINUE"))
												,value(uar_get_code_by("MEANING",6003,"CANCEL"))
											 ))
		set t_rec->dc_cnt += 1
		set stat = alterlist(t_rec->dc_qual[t_rec->dc_cnt],t_rec->dc_cnt)
		set t_rec->dc_qual[t_rec->dc_cnt].order_id = request->orderlist[i].orderid
	endif
endfor


for (i=1 to t_rec->copy_cnt)
	set t_rec->copy_qual[i].dc_ind = locateval(j,1,t_rec->dc_cnt,t_rec->copy_qual[i].order_id,t_rec->dc_qual[j].order_id)
endfor

for (i=1 to t_rec->copy_cnt)
	if (t_rec->copy_qual[i].dc_ind = 0)
		set retval = 100
	endif
endfor
 
call writeLog(build2("* END   Report   *******************************************"))
call writeLog(build2("************************************************************"))

 
#exit_script
;call echorecord(t_rec)
 
call exitScript(null)
;call echorecord(t_rec)
call echorecord(program_log)

set log_message = cnvtrectojson(t_rec)
 
end
go
 
>>>>>>> 310787ab3760df19dc4b2f2590b0c0661815e7a8
