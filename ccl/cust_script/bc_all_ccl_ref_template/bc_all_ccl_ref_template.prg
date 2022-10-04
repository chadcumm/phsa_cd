/***********************************************************************************************************************
  Program Name:       	bc_all_ccl_ref_template
  Source File Name:   	bc_all_ccl_ref_template.prg
  Program Written By: 	John Simpson
  Date:  			  	26-May-2021
  Program Purpose:   	Consumes a JSON data source file and generates CCL variables/structures
 
************************************************************************************************************************
												*MODIFICATION HISTORY*
************************************************************************************************************************
 
Rev  Date         Jira       Programmer             Comment
---  -----------  ---------  ---------------------  --------------------------------------------------------------------
000  26-May-2021  CST-96425  John Simpson           Created
***********************************************************************************************************************/
 
drop program bc_all_ccl_ref_template:dba go
create program bc_all_ccl_ref_template:dba
 
prompt
	"JSON file" = ""                    ;* Enter or select the printer or file name to send this report to.
	, "Alert Developers on Error" = 0
 
with filename, alertDev
 
; Set the absolute maximum possible variable length
set modify maxvarlen 268435456
 
; Required variables
declare cJSON = vc
declare cParser = vc
declare nAudit = i4
 
; Subroutine declarations
declare templateError(cMessage = vc) = null
declare cvLookup(iterator = i4) = f8
 
; Declare the JSON filename. If not specified, cust_script: folder is applied and .json is added as file extension
declare cJSONFileName = vc with noconstant($filename)
if (findstring(":", $filename) = 0)
    set cJSONFileName = concat("cust_script:", trim(cJSONFileName, 3))
endif
if (findstring(".", $filename) = 0)
    set cJSONFileName = concat(trim(cJSONFileName, 3), ".json")
endif
 
; Quit if file not found
if (findfile(cJSONFileName) = 0)
    call templateError(concat("Filename ", cJSONFileName, " not found."))
endif
 
; Setup the RTL2 File
free define rtl2
define rtl2 is concat(cJSONFileName)
 
; Read the JSON file and store in memory
select into "nl:"
    r.line
from rtl2t r
plan r
head report
    cJSON = ^{"cclTemplate":^
detail
    cJSON = concat(trim(cJSON), trim(r.line, 3))
 
    ; Append an empty code value to the codeValues structure to introduce the codeValue field
    if (substring(1,100,replace(r.line, " ", "")) = ^"codeValues":[^)
        cJSON = concat(trim(cJSON), ^{"codeValue": -999.0},^)
    endif
foot report
    cJSON = concat(trim(cJSON), ^}^)
with counter
 
; Convert the JSON to a record structure
free record cclTemplate
set stat = cnvtjsontorec(cJSON, 8)
 
if (stat = 0)
    call templateError(concat("Invalid JSON in ", cJSONFileName))
endif
 
; Start mapping out the code values. They will either go into a structure or be declared as variables
if (validate(cclTemplate->codeValues) = 1)
    ; Delete the first placeholder value
    set stat = alterlist(cclTemplate->codeValues, size(cclTemplate->codeValues, 5)-1, 0)
 
    for (nCVLoop = 1 to size(cclTemplate->codeValues, 5))
        ; Collect the code value
        set cclTemplate->codeValues[nCVLoop].codeValue = cvLookup(nCVLoop)
        if (cclTemplate->codeValues[nCVLoop].codeValue = -1)
            set nAudit = 1
        endif
 
        ; Assign named variables
        if (validate(cclTemplate->codeValues[nCVLoop].name,"") != "")
            set cParser = concat("declare ", cclTemplate->codeValues[nCVLoop].name, "=f8 with noconstant(",
                    trim(cnvtstring(cclTemplate->codeValues[nCVLoop].codeValue),3) ,"), persist go")
            call parser(cParser)
        endif
    endfor
endif
 
; If there is an error of any type including invalid code values, alert the developer team
if (nAudit = 1)
    call echorecord(cclTemplate)
    call templateError("Invalid Code Values")
endif
 
/*
 
    SUBROUTINES
 
*/
 
; Basic Error Message
subroutine templateError(cMessage)
 
    ; Here we need to run bc_all_ops_sftp_report to send an audit report to IT for now it is just an error message
 
    call echo(concat("Error: ", cMessage))
    go to end_program
end
 
; Code value lookup by reference value
subroutine cvLookup(iterator)
    set nCodeSet = cclTemplate->codevalues[iterator].codeSet
    if (validate(cclTemplate->codevalues[iterator].meaning,"") != "")
        return (uar_get_code_by("MEANING", nCodeSet, cclTemplate->codevalues[iterator].meaning))
    elseif (validate(cclTemplate->codevalues[iterator].display_key,"") != "")
        return (uar_get_code_by("DISPLAYKEY", nCodeSet, cclTemplate->codevalues[iterator].display_key))
    elseif (validate(cclTemplate->codevalues[iterator].display,"") != "")
        return (uar_get_code_by("DISPLAY", nCodeSet, cclTemplate->codevalues[iterator].display))
    else
        return (0.0)
    endif
end
 
#end_program
 
end go
