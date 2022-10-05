DROP PROGRAM phsa_lib_common :dba GO
CREATE PROGRAM phsa_lib_common :dba
 CALL echo ("Loading phsa_lib_common..." )
 IF (NOT (validate (common_lib_loaded ) ) )
  DECLARE common_lib_loaded = i1 WITH constant (true ) ,persistscript
  DECLARE ssftplogical = vc WITH constant ("sftp_xfer" ) ,persistscript
  DECLARE ssftptmpext = c4 WITH constant (".tmp" ) ,persistscript
 ENDIF
 SUBROUTINE  (comparestr (str1 =vc ,str2 =vc ) =i2 WITH copy )
  DECLARE string1 = vc WITH noconstant (lowertrim (str1 ) )
  DECLARE string2 = vc WITH noconstant (lowertrim (str2 ) )
  IF ((((textlen (string1 ) = 0 ) ) OR ((textlen (string2 ) = 0 ) )) )
   RETURN (0 )
  ELSEIF ((textlen (string1 ) != textlen (string2 ) ) )
   RETURN (0 )
  ELSEIF ((string1 = string2 ) )
   RETURN (1 )
  ENDIF
  RETURN (0 )
 END ;Subroutine
 SUBROUTINE  (lowertrim (str =vc ) =vc WITH copy )
  DECLARE newstr = vc WITH noconstant (cnvtlower (trim (str ,3 ) ) ) ,private
  RETURN (newstr )
 END ;Subroutine
 SUBROUTINE  (uppertrim (str =vc ) =vc WITH copy )
  DECLARE newstr = vc WITH noconstant (cnvtupper (trim (str ,3 ) ) ) ,private
  RETURN (newstr )
 END ;Subroutine
 SUBROUTINE  (getdayshoursminsdisplayfrommins (timediffmins =f8 ) =vc WITH copy )
  DECLARE days = i4 WITH noconstant (floor ((timediffmins / 1440 ) ) ) ,protect
  DECLARE hours = i4 WITH noconstant (floor (((timediffmins - (days * 1440 ) ) / 60 ) ) ) ,protect
  DECLARE mins = i4 WITH noconstant (floor (((timediffmins - (days * 1440 ) ) - (hours * 60 ) ) ) ) ,
  protect
  DECLARE days_str = vc WITH noconstant (build (days ) ) ,protect
  DECLARE hours_str = vc WITH noconstant (build (hours ) ) ,protect
  DECLARE mins_str = vc WITH noconstant (build (mins ) ) ,protect
  DECLARE duration_str = vc WITH noconstant (fillstring (100 ," " ) ) ,protect
  IF ((days > 1 ) )
   SET days_str = concat (days_str ," days" )
  ELSE
   SET days_str = concat (days_str ," day" )
  ENDIF
  IF ((hours > 1 ) )
   SET hours_str = concat (hours_str ," hours" )
  ELSE
   SET hours_str = concat (hours_str ," hour" )
  ENDIF
  IF ((mins > 1 ) )
   SET mins_str = concat (mins_str ," minutes" )
  ELSE
   SET mins_str = concat (mins_str ," minute" )
  ENDIF
  IF (days )
   SET duration_str = days_str
  ENDIF
  IF (hours )
   IF (NOT (isemptystr (duration_str ) ) )
    SET duration_str = concat (duration_str ,", " ,hours_str )
   ELSE
    SET duration_str = hours_str
   ENDIF
  ENDIF
  IF (mins )
   IF (NOT (isemptystr (duration_str ) ) )
    IF (days
    AND hours )
     SET duration_str = concat (duration_str ,", and " ,mins_str )
    ELSE
     SET duration_str = concat (duration_str ," and " ,mins_str )
    ENDIF
   ELSE
    SET duration_str = mins_str
   ENDIF
  ENDIF
  IF (isemptystr (duration_str ) )
   SET duration_str = "Less than a minute"
  ENDIF
  RETURN (trim (duration_str ) )
 END ;Subroutine
 SUBROUTINE  (isemptystr (str1 =vc ) =i2 WITH copy )
  DECLARE string1 = vc WITH noconstant (trim (str1 ,3 ) )
  IF ((textlen (string1 ) = 0 ) )
   RETURN (true )
  ELSE
   RETURN (false )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (iscodeoncodeset (cd ,cs ) =i2 WITH copy )
  IF ((uar_get_code_by ("DISPLAY_KEY" ,cs ,nullterm (uar_get_displaykey (cnvtreal (cd ) ) ) ) = - (
  1.0 ) ) )
   CALL echo (build2 ("Code " ,trim (cnvtstring (cd ) ,3 ) ," not found on codeset " ,trim (
      cnvtstring (cs ) ,3 ) ," !" ) )
   RETURN (false )
  ENDIF
  RETURN (true )
 END ;Subroutine
 SUBROUTINE  (enforceccllogin (null ) =i2 WITH copy )
  IF (validate (xxcclseclogin ) )
   IF (NOT (xxcclseclogin->loggedin ) )
    EXECUTE cclseclogin
    RETURN (xxcclseclogin->loggedin )
   ENDIF
  ENDIF
  RETURN (true )
 END ;Subroutine
 SUBROUTINE  (isrunningfromccl (null ) =i1 WITH copy )
  IF ((curimage = "CCL" ) )
   RETURN (true )
  ELSE
   RETURN (false )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (gen_random_id (len =i2 (value ,8 ) ) =c200 WITH copy )
  DECLARE currdbhdl = vc
  DECLARE randnum = vc
  DECLARE currdbhdl_len = i2
  DECLARE randnum_len = i2
  DECLARE rand_id = vc
  SET currdbhdl = cnvtstring (currdbhandle )
  SET randnum = cnvtstring (rand (null ) )
  SET currdbhdl_len = textlen (currdbhdl )
  SET randnum_len = textlen (randnum )
  IF ((((len = null ) ) OR ((len < 8 ) )) )
   CALL echo ("Random number must be 8 or more digits long" )
   SET len = 8
  ENDIF
  IF ((len <= 8 ) )
   SET rand_id = build (randnum ,substring ((currdbhdl_len - 2 ) ,currdbhdl_len ,currdbhdl ) )
  ELSEIF ((len < 15 ) )
   SET rand_id = build (randnum ,substring ((currdbhdl_len - 4 ) ,currdbhdl_len ,currdbhdl ) )
  ELSE
   SET rand_id = build (randnum ,currdbhdl )
  ENDIF
  WHILE ((textlen (rand_id ) < len ) )
   SET rand_id = build (cnvtstring (rand (null ) ) ,rand_id )
  ENDWHILE
  SET randnum_len = textlen (rand_id )
  SET rand_id = substring (((randnum_len - len ) + 1 ) ,randnum_len ,rand_id )
  RETURN (rand_id )
 END ;Subroutine
 SUBROUTINE  (gen_unique_filename (ext =vc (value ,"" ) ,rndmlen =i2 (value ,8 ) ) =c200 WITH copy )
  RETURN (build (cnvtlower (trim (curdomain ) ) ,"_" ,cnvtlower (trim (curprog ) ) ,"_" ,
   gen_random_id (rndmlen ) ,formatextension (ext ) ) )
 END ;Subroutine
 SUBROUTINE  (gen_unique_filename_with_date (ext =vc (value ,"" ) ,rndmlen =i2 (value ,8 ) ) =c200
  WITH copy )
  RETURN (build (gen_unique_filename (null ,rndmlen ) ,"_" ,format (sysdate ,"YYYYMMDD_HHMMSS;;D" ) ,
   formatextension (ext ) ) )
 END ;Subroutine
 SUBROUTINE  (gen_filename_with_date (ext =vc (value ,"" ) ) =c200 WITH copy )
  RETURN (build (cnvtlower (trim (curdomain ) ) ,"_" ,cnvtlower (trim (curprog ) ) ,"_" ,format (
    sysdate ,"YYYYMMDD_HHMMSS;;D" ) ,formatextension (ext ) ) )
 END ;Subroutine
 SUBROUTINE  (formatextension (ext =vc ) =c50 WITH copy )
  CALL echo (build2 ("Incoming extension: " ,ext ) )
  IF ((ext = null ) )
   RETURN (null )
  ENDIF
  DECLARE formattedext = vc WITH noconstant (trim (cnvtlower (ext ) ,3 ) )
  IF ((textlen (formattedext ) = 0 ) )
   RETURN (null )
  ENDIF
  IF ((substring (1 ,1 ,formattedext ) != "." ) )
   SET formattedext = build ("." ,formattedext )
  ENDIF
  RETURN (formattedext )
 END ;Subroutine
 SUBROUTINE  (getparentprog (null ) =c100 WITH copy )
  DECLARE num = i4 WITH noconstant (1 ) ,private
  WHILE ((num > 0 ) )
   IF ((curprog (num ) = " " ) )
    IF ((num > 1 ) )
     RETURN (curprog ((num - 2 ) ) )
    ELSE
     RETURN (curprog )
    ENDIF
   ELSE
    SET num +=1
   ENDIF
  ENDWHILE
 END ;Subroutine
 SUBROUTINE  (getcurrentsub (null ) =c100 WITH copy )
  IF (NOT (checkfun ("CURSUB" ) ) )
   RETURN ("CURSUB NOT SUPPORTED" )
  ENDIF
  DECLARE num = i4 WITH noconstant (1 ) ,private
  WHILE ((num > 0 ) )
   IF ((cursub (num ) = " " ) )
    IF ((num > 1 ) )
     RETURN (cursub ((num - 2 ) ) )
    ELSE
     RETURN (0 )
    ENDIF
   ELSE
    SET num +=1
   ENDIF
  ENDWHILE
 END ;Subroutine
 SUBROUTINE  (showerror (msg =vc ,writetolog =i1 (value ,true ) ) =null WITH copy )
  IF (NOT (validate (pt ) ) )
   RECORD pt (
     1 line_cnt = i4
     1 lns [* ]
       2 line = vc
   )
  ELSE
   SET stat = initrec (pt )
  ENDIF
  EXECUTE dcp_parse_text value (msg ) ,
  value (100 )
  IF (NOT (validate (_outfile ) ) )
   DECLARE _outfile = vc WITH noconstant ("MINE" ) ,protect
  ENDIF
  SELECT INTO value (_outfile )
   FROM (dummyt d1 WITH seq = size (pt->lns ,5 ) )
   PLAN (d1 )
   HEAD REPORT
    ">>>> ERROR <<<<" ,
    row + 2
   DETAIL
    pt->lns[d1.seq ].line ,
    row + 1
   FOOT REPORT
    row + 1 ,
    "Contact the CST Cerner Support Desk for assistance."
   WITH nocounter ,nullreport ,format
  ;end select
  IF (validate (logging_lib_loaded )
  AND writetolog )
   CALL logerrormsg (msg )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (showmessage (msg =vc ,writetolog =i1 (value ,true ) ) =null WITH copy )
  IF (NOT (validate (pt ) ) )
   RECORD pt (
     1 line_cnt = i4
     1 lns [* ]
       2 line = vc
   )
  ELSE
   SET stat = initrec (pt )
  ENDIF
  EXECUTE dcp_parse_text value (msg ) ,
  value (100 )
  IF (NOT (validate (_outfile ) ) )
   DECLARE _outfile = vc WITH noconstant ("MINE" ) ,protect
  ENDIF
  SELECT INTO value (_outfile )
   FROM (dummyt d1 WITH seq = size (pt->lns ,5 ) )
   PLAN (d1 )
   DETAIL
    pt->lns[d1.seq ].line ,
    row + 1
   WITH nocounter ,nullreport ,format
  ;end select
  IF (validate (logging_lib_loaded )
  AND writetolog )
   CALL loginfomsg (msg )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (getcolumnwidth (tablename =vc ,columnname =vc ) =i2 WITH copy )
  DECLARE width = i2 WITH protect
  SELECT INTO "NL:"
   FROM (dtableattr a ),
    (dtableattrl l )
   WHERE (a.table_name = cnvtupper (tablename ) )
   AND (l.structtype = "F" )
   AND (l.attr_name = cnvtupper (columnname ) )
   DETAIL
    width = l.len
   WITH nocounter ,maxrec = 1
  ;end select
  RETURN (width )
 END ;Subroutine
 SUBROUTINE  (columnexists (tablename =vc ,columnname =vc ) =i2 WITH copy )
  SELECT INTO "NL:"
   FROM (dtableattr a ),
    (dtableattrl l )
   WHERE (a.table_name = cnvtupper (tablename ) )
   AND (l.structtype = "F" )
   AND (l.attr_name = cnvtupper (columnname ) )
   WITH nocounter
  ;end select
  RETURN (curqual )
 END ;Subroutine
 SUBROUTINE  (getappnodes (rec =vc (ref ) ,domain =vc (value ,curdomain ) ) =null WITH copy )
  EXECUTE ccluarxhost
  DECLARE i = i4 WITH protect
  SET stat = arraysplit (rec->nodes[i ].node ,i ,uar_gethostnames (nullterm (cnvtupper (trim (domain
       ) ) ) ) ,"|" )
 END ;Subroutine
 SUBROUTINE  (starttimer (null ) =null WITH copy )
  DECLARE swstart = dm12 WITH public ,persistscript
  DECLARE swstop = dm12 WITH public ,persistscript
  SET swstart = systimestamp
 END ;Subroutine
 SUBROUTINE  (gettimerelapsedsecs (null ) =f8 WITH copy )
  SET swstop = systimestamp
  RETURN (gettimersecs (null ) )
 END ;Subroutine
 SUBROUTINE  (stoptimer (null ) =c100 WITH copy )
  SET swstop = systimestamp
  RETURN (gettimersecsformatted (null ) )
 END ;Subroutine
 SUBROUTINE  (gettimersecsformatted (null ) =c100 WITH copy )
  RETURN (build (gettimersecs (null ) ," s" ) )
 END ;Subroutine
 SUBROUTINE  (gettimersecs (null ) =f8 WITH copy )
  RETURN (timestampdiff (swstop ,swstart ) )
 END ;Subroutine
 SUBROUTINE  (getmaxdatestr (null ) =vc WITH copy )
  RETURN ("31-DEC-2100 00:00:00.00" )
 END ;Subroutine
 SUBROUTINE  (ssftp_filenametmp (sfolder =vc ,sfilenoext =vc ) =vc WITH copy )
  DECLARE vsftppath = vc
  DECLARE vpathfilenametmp = vc
  DECLARE len = i4 WITH noconstant (textlen (sfolder ) )
  IF ((substring (len ,len ,sfolder ) != "/" ) )
   SET sfolder = build2 (sfolder ,"/" )
  ENDIF
  SET vsftppath = concat (trim (logical (ssftplogical ) ,3 ) ,"/" ,trim (sfolder ,3 ) )
  SET vpathfilenametmp = concat (vsftppath ,cnvtlower (trim (sfilenoext ,3 ) ) ,trim (ssftptmpext ,3
    ) )
  CALL echo (concat ("SFTP File Path: " ,vpathfilenametmp ) )
  RETURN (vpathfilenametmp )
 END ;Subroutine
 SUBROUTINE  (ssftp_renameext (sfolder =vc ,sfilenoext =vc ,sfileext =vc ) =null WITH copy )
  DECLARE vsftppath = vc
  DECLARE vpathfilenametmp = vc
  DECLARE vpathfilenamenew = vc
  DECLARE vmvcmd = vc
  DECLARE vdcllen = i4
  DECLARE vdclstatus = i4
  DECLARE len = i4 WITH noconstant (textlen (sfolder ) )
  IF ((substring (len ,len ,sfolder ) != "/" ) )
   SET sfolder = build2 (sfolder ,"/" )
  ENDIF
  SET vsftppath = concat (trim (logical (ssftplogical ) ,3 ) ,"/" ,trim (sfolder ,3 ) )
  SET vpathfilenametmp = concat (vsftppath ,cnvtlower (trim (sfilenoext ,3 ) ) ,trim (ssftptmpext ,3
    ) )
  SET vpathfilenamenew = concat (vsftppath ,cnvtlower (trim (sfilenoext ,3 ) ) ,formatextension (
    sfileext ) )
  SET vmvcmd = concat ("mv " ,vpathfilenametmp ," " ,vpathfilenamenew )
  SET vdcllen = size (trim (vmvcmd ,3 ) )
  SET vdclstatus = 0
  CALL echo (concat ("Move Command: " ,vmvcmd ) )
  CALL dcl (vmvcmd ,vdcllen ,vdclstatus )
 END ;Subroutine
#exit_script
END GO
