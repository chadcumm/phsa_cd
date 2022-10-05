DROP PROGRAM pf_adhoc_email GO
CREATE PROGRAM pf_adhoc_email
 PROMPT
  "Email Subject" = "<No subject>" ,
  "Email Body" = "<End of message>" ,
  "Email address to sent email to" = "phillip.freeman@phsa.ca" ,
  "Include domain and parent program in subject?" = "1"
  WITH subject ,body ,emailaddress ,inclinfo
 EXECUTE phsa_lib_common
 DECLARE subject = vc WITH noconstant ( $SUBJECT ) ,protect
 IF (( $INCLINFO = "1" ) )
  SET subject = concat ("[" ,build (curdomain ) ,"/" ,trim (getparentprog (null ) ,3 ) ,"] " ,
   subject )
 ENDIF
 CALL uar_send_mail (nullterm ( $EMAILADDRESS ) ,nullterm (subject ) ,nullterm ( $BODY ) ,nullterm (
   build ("do.not.reply@" ,curdomain ,"." ,curnode ) ) ,5 ,nullterm ("IPM.NOTE" ) )
#exit_script
END GO
