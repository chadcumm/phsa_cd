/*****************************************************************************
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       07/20/2021
  Solution:
  Source file name:   bc_all_rm_audit_unprocessed.prg
  Object name:        bc_all_rm_audit_unprocessed
  Request #:
 
  Program purpose:
 
  Executing from:
 
  Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   07/20/2021  Chad Cummings			Initial Release
001   09/09/2021  Miro Kralovic			CST-138570 - added generated_on column
002   11/29/2021  Miro Kralovic			CST-138570 - Adding FTP Output
******************************************************************************/
drop program bc_all_rm_audit_unprocessed go
create program bc_all_rm_audit_unprocessed
 
prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Send To File" = 0
	, "Requisition Location" = 0
	, "All Requested Dates" = "Any Date"
	, "Beginning Requested Date and Time" = "CURDATE"
	, "Ending Requested Date and Time" = "CURDATE" 

with OUTDEV, SENDTOFILE, location, ANY_DATE, REQ_DT_TM_BEG, REQ_DT_TM_END
 
execute bc_all_location_routines ^"showUnits":["AMBULATORY","NURSEUNIT"],"maxViewLevel":"NURSEUNIT"^, $location
 
EXECUTE BC_ALL_ALL_DATE_ROUTINES
EXECUTE BC_ALL_ALL_STD_ROUTINES
 
;CREATE THE RECORD STRUCTURE THAT CCLIO() USES
FREE RECORD FREC
RECORD FREC(
     1 FILE_DESC = I4
     1 FILE_OFFSET = I4
     1 FILE_DIR = I4
     1 FILE_NAME = VC
     1 FILE_BUF = VC
) with protect
 
record output_data (
	1 cnt = i4
	1 yesterday_start_dt_tm = dq8
	1 yesterday_end_dt_tm = dq8
	1 qual[*]
	 	 2 parent_event_id = f8
	 2 ordered_dt_tm = dq8
	 2 ordered_dt = vc
	 2 requested_dt_tm = dq8
	 2 requested_dt = vc
	 2 requisition_type = vc
	 2 printed_ind = i2
	 2 printed_dt_tm = dq8
	 2 printed_dt = vc
	 2 processed_yesterday_ind = i2
	 2 net_new_yesterday_ind = i2
	 2 processed_ind = i2
	 2 overdue_ind = i2
	 2 current_req_status = vc
	 2 req_status_dt_tm = dq8
	 2 req_status_dt = vc
	 2 calc_requested_dt_tm = dq8
	 2 calc_request_dt = vc
	 2 completed_dt_tm = dq8
	 2 completed_dt = vc
	 2 priority = vc
	 2 unit = vc
	 2 mrn = vc
	 2 subtype = vc
	 2 req_title = vc
	 2 ordering_provider = vc
) with PERSISTSCRIPT
 
;SFTP variables
DECLARE vEXTRACT_FOLDER = VC WITH NOCONSTANT("reqstats/"), PROTECT
DECLARE vEXTRACT_NAME = VC WITH NOCONSTANT("BC_ALL_RM_AUDIT_UNPROC"), PROTECT
DECLARE vEXTRACT_DT = VC WITH PROTECT
DECLARE vEXTRACT_EXT = VC WITH NOCONSTANT(".csv"), PROTECT
DECLARE vEXTRACT_FULL = VC WITH PROTECT
DECLARE vFILE_NAME = C32 WITH PROTECT
DECLARE vDELIM = VC WITH NOCONSTANT(","), PROTECT
DECLARE vCRLF = VC WITH NOCONSTANT(CONCAT(CHAR(13),CHAR(10))), PROTECT
DECLARE vFILEERROR = VC WITH NOCONSTANT(""), PROTECT
DECLARE vPRINT_LINE = VC WITH PROTECT
DECLARE nNUM = I4 WITH NOCONSTANT(0), PROTECT
 
SET vEXTRACT_DT = FORMAT(SYSDATE, "YYYYMMDD;;Q")
SET vFILE_NAME = CONCAT(vEXTRACT_NAME, "_", vEXTRACT_DT)
 
declare vPRSNL_ID = f8 with noconstant(reqinfo->updt_id), protect
declare vLOCATION_PARSER = vc with protect

call echo(build2("$REQ_DT_TM_BEG=",$REQ_DT_TM_BEG))
call echo(build2("$REQ_DT_TM_END=",$REQ_DT_TM_END))
 
if ($SENDTOFILE = 1)
	set vPRSNL_ID = 2
endif
call echo(build2("vPRSNL_ID=",vPRSNL_ID))
 
SELECT DISTINCT into "nl:"
	   location_cd = l3.location_cd ,
	   location = trim (uar_get_code_display (l3.location_cd ) ),
	   facility = trim (uar_get_code_description (l.location_cd ) )
	FROM
		prsnl_org_reltn por,
	    organization org,
	    location l,
	    location_group lg,
	    location l2,
	    location_group lg2,
	    location l3,
	    code_value cv1,
	    code_value cv2,
	    code_value cv3,
	    dummyt d1
	plan por
		where por.person_id = vPRSNL_ID
	    and por.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3)
	    and por.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3)
	    and por.active_ind = 1
	join org
	    where org.organization_id = por.organization_id
	    and org.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 )
	    and org.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 )
	    and org.active_ind = 1
	join l
	   	where l.organization_id = org.organization_id
	    and l.location_type_cd = value(uar_get_code_by_cki("CKI.CODEVALUE!2844"))
	    and l.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 )
	    and l.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 )
	    and l.active_ind = 1
	join cv1
	    where cv1.code_value = l.location_cd
	join lg
	    where lg.parent_loc_cd = l.location_cd
	    and lg.root_loc_cd = 0
	    and lg.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 )
	    and lg.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 )
	    and lg.active_ind = 1
	join l2
	    where l2.location_cd = lg.child_loc_cd
	    and l2.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 )
	    and l2.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 )
	    and l2.active_ind = 1
	join lg2
	    where lg.child_loc_cd = lg2.parent_loc_cd
	    and lg2.root_loc_cd = 0
	    and lg2.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 )
	    and lg2.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 )
	    and lg2.active_ind = 1
	join l3
	    where l3.location_cd = lg2.child_loc_cd
	    and l3.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 )
	    and l3.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 )
	    and l3.active_ind = 1
	    and expand(nNum, 1, size(rFilteredLocations->data, 5), l3.location_cd, rFilteredLocations->data[nNum].location_cd)
	    and l3.location_type_cd in(
	    							 select
								     cv.code_value
								     from code_value cv
								     where cv.cdf_meaning in("AMBULATORY","NURSEUNIT")
								   )
	join cv2
	    where cv2.code_value = l3.location_cd
	join d1
	join cv3
	    where cv3.code_set = 103507
	    and   cv3.cdf_meaning in( "LOCATION","LOCATION_LTD")
	    and   cv3.active_ind = 1
	    and   cv3.display = cv2.display
	   ; and   cv3.display = "BCC*"
	order by
	   	facility ,
	   	location,
	   	l.location_cd,
	    l3.location_cd
 	head report
 		vLOCATION_PARSER = build2(^value(^)
 		cnt = 0
 	detail
 		call echo(build2("location=",trim(org.org_name),":",uar_get_code_display(l3.location_cd)))
 		if (cnt > 0)
 			vLOCATION_PARSER = build2(vLOCATION_PARSER,^,^)
 		endif
 		vLOCATION_PARSER = build2(vLOCATION_PARSER,l3.location_cd)
 		cnt = (cnt + 1)
 	foot report
 		vLOCATION_PARSER = build2(vLOCATION_PARSER,^)^)
 	with nocounter, expand = 2
 
call echo(build2("vLOCATION_PARSER=",vLOCATION_PARSER))
;call echorecord(rFilteredLocations)


execute bc_all_rm_audit_unproc_drv
 
^NOFORMS^,
vPRSNL_ID,
441.0,
^01-Jan-1900^,
^01-Jan-1900^,
value($REQ_DT_TM_BEG),
value($REQ_DT_TM_END),
parser(vLOCATION_PARSER),
value(0),
value(0),
^Any Date^,
value($ANY_DATE)

call echorecord(output_data)
 
IF($SENDTOFILE = 0) ;display mode
	select into $OUTDEV
		 unit					= substring(1,50,output_data->qual[d1.seq].unit)
		,mrn					= substring(1,50,output_data->qual[d1.seq].mrn)
		,requisition_type		= substring(1,75,output_data->qual[d1.seq].requisition_type)
		,subtype				= substring(1,75,output_data->qual[d1.seq].subtype)
		,priority				= substring(1,50,output_data->qual[d1.seq].priority)
		,requisition_title		= substring(1,200,output_data->qual[d1.seq].req_title)
		,ordered_dt				= substring(1,12,output_data->qual[d1.seq].ordered_dt)
		,requested_dt			= substring(1,12,output_data->qual[d1.seq].requested_dt)
		,overdue_ind			= output_data->qual[d1.seq].overdue_ind
		,generated_on			= FORMAT(sysdate,"DD-MMM-YYYY HH:MM:SS;;Q") ;001
	from
		(dummyt d1 with seq=output_data->cnt)
	plan d1
		where output_data->qual[d1.seq].processed_ind in(0 )
		and   output_data->qual[d1.seq].overdue_ind in(0, 1)
		and   output_data->qual[d1.seq].subtype > " "
		and   output_data->qual[d1.seq].priority > " "
	with format,separator= " "
ELSE
	select into "NL:"
		 mrn					= substring(1,50,output_data->qual[d1.seq].mrn)
		,requisition_type		= substring(1,75,output_data->qual[d1.seq].requisition_type)
		,subtype				= substring(1,75,output_data->qual[d1.seq].subtype)
		,priority				= substring(1,50,output_data->qual[d1.seq].priority)
		,requisition_title		= substring(1,200,output_data->qual[d1.seq].req_title)
		,ordered_dt				= substring(1,12,output_data->qual[d1.seq].ordered_dt)
		,requested_dt			= substring(1,12,output_data->qual[d1.seq].requested_dt)
		,overdue_ind			= IF(output_data->qual[d1.seq].overdue_ind=1) "1" ELSE "0" ENDIF
		,generated_on			= FORMAT(sysdate,"DD-MMM-YYYY HH:MM:SS;;Q") ;001
	from
		(dummyt d1 with seq=output_data->cnt)
	plan d1
		where output_data->qual[d1.seq].processed_ind in(0 )
		and   output_data->qual[d1.seq].overdue_ind in(0, 1)
		and   output_data->qual[d1.seq].subtype > " "
		and   output_data->qual[d1.seq].priority > " "
 
	HEAD REPORT
		FREC->FILE_NAME = sSFTP_FileNameTmp(TRIM(vEXTRACT_FOLDER, 3), TRIM(vFILE_NAME, 3))
		FREC->FILE_BUF = "w"
		STAT = CCLIO("OPEN", FREC)
		FREC->FILE_BUF = " "
 
		vPRINT_LINE = CONCAT( "MRN", vDELIM
							, "REQUISITION_TYPE", vDELIM
							, "SUBTYPE", vDELIM
							, "PRIORITY", vDELIM
							, "REQUISITION_TITLE", vDELIM
							, "ORDERED_DT", vDELIM
							, "REQUESTED_DT", vDELIM
							, "OVERDUE_IND", vDELIM
							, "GENERATED_ON", vCRLF
							)
 
		FREC->FILE_BUF = vPRINT_LINE
		STAT = CCLIO("PUTS", FREC)
 
	DETAIL
		vPRINT_LINE = " "
		vPRINT_LINE = CONCAT(vPRINT_LINE, ^"^, TRIM(MRN, 3), ^"^, vDELIM)
		vPRINT_LINE = CONCAT(vPRINT_LINE, ^"^, TRIM(REQUISITION_TYPE, 3), ^"^, vDELIM)
		vPRINT_LINE = CONCAT(vPRINT_LINE, ^"^, TRIM(SUBTYPE, 3), ^"^, vDELIM)
		vPRINT_LINE = CONCAT(vPRINT_LINE, ^"^, TRIM(PRIORITY, 3), ^"^, vDELIM)
		vPRINT_LINE = CONCAT(vPRINT_LINE, ^"^, TRIM(REQUISITION_TITLE, 3), ^"^, vDELIM)
		vPRINT_LINE = CONCAT(vPRINT_LINE, ^"^, TRIM(ORDERED_DT, 3), ^"^, vDELIM)
		vPRINT_LINE = CONCAT(vPRINT_LINE, ^"^, TRIM(REQUESTED_DT, 3), ^"^, vDELIM)
		vPRINT_LINE = CONCAT(vPRINT_LINE, ^"^, TRIM(OVERDUE_IND, 3), ^"^, vDELIM)
		vPRINT_LINE = CONCAT(vPRINT_LINE, ^"^, TRIM(GENERATED_ON, 3), ^"^, vCRLF)
 
		FREC->FILE_BUF = vPRINT_LINE
		STAT = CCLIO("PUTS", FREC)
 
	FOOT REPORT
		;close file
		STAT = CCLIO("CLOSE",FREC)
 
		IF (FREC->FILE_BUF != " " AND STAT = 0)
			vFILEERROR = CONCAT (vFILEERROR,",",TRIM(FREC->FILE_NAME,3))
		ELSE
			CALL sSFTP_RenameExt( TRIM(vEXTRACT_FOLDER, 3), TRIM(vFILE_NAME, 3), TRIM(vEXTRACT_EXT, 3) )
			vEXTRACT_FULL = BUILD( TRIM(vEXTRACT_FOLDER, 3), TRIM(vFILE_NAME, 3), TRIM(vEXTRACT_EXT, 3) )
			vFILEERROR = "None"
		ENDIF
 
 
	with format,separator= " "
 
	;DISPLAY CONFIRMATION
 	SELECT INTO $OUTDEV
    FROM DUMMYT D
    DETAIL
		COL 1, "Extract Complete"
		ROW + 1
		COL 1, "File > "
		ROW + 1
		COL 4, vEXTRACT_FULL
		row + 1
		COL 1, "Error(s) > "
		ROW + 1
		COL 4, vFILEERROR
		ROW + 1
 
    WITH NOCOUNTER, NOHEADING, NOFORMAT
ENDIF
 
end go
