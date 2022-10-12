/*************************************************************************
 
        Script Name:    BC_ALL_CHT_RTF.INC
 
        Description:    Clinical Docs - Rich Text Support Routines
 
        Date Written:   March 8, 2010
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 None
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    02/24/10 J. Simpson     Initial Development
 *************************************************************************/
 
; Static Variables
; ----------------
SET cROWDEF = FILLSTRING(2000," ")
SET cROWDATA = FILLSTRING(32768," ")
SET cROWPREFIX = FILLSTRING(2000," ")
SET nCELLPOS = 0
SET cPROT_L = "{\*\txfieldstart\txfieldtype0\txfieldflags19}"
SET cPROT_R = "{\*\txfieldend}"
SET cSYSCOLOR = "\cf8 "		; Used to highlight system data
SET cSYSEDIT = "\cf9 "		; Used to highlight editable system data
 
; Function Definitions
; --------------------
 
; Generic function to add Rich Text to REPLY structure
SUBROUTINE ADD_RTF(cTEXT)
	SET REPLY->TEXT = CONCAT(TRIM(REPLY->TEXT), TRIM(cTEXT))
END
 
; Clear spreadsheet row
SUBROUTINE CLEAR_ROW(nFONT, nFONTSIZE)
	SET cROWDEF = " "
	SET cROWDATA = " "
	SET nCELLPOS = 0
 
;	SET cROWDEF = BUILD("{\pard\trowd\trgaph30\trleft30")
	SET cROWDEF = BUILD("{\pard\trowd")
	SET cROWPREFIX = BUILD("\pard\intbl\plain\f", nFONT, "\fs", nFONTSIZE)
END
 
; Add defintion and data for spreadsheet row
SUBROUTINE ADD_CELL(cTEXT, cSTYLE, nWIDTH, nATTRIBS, nLOCKED)
	SET nCELLPOS = nCELLPOS + nWIDTH		; Place the cursor position
 
	; Parse out the cell attributes
	; Four digit number. Positions indicate the following
	; 1 - Not Used
	; 2 - Not Used
	; 3 - Text Alignment (0-left, 1-Center)
	; 4 - Color (0 - 9, see color tables below)
	SET cATTRIBS = FORMAT(nATTRIBS,"####;P0")
	SET nBGCOLOR = SUBSTRING(4,1,cATTRIBS)
 
	IF (SUBSTRING(3,1,cATTRIBS) = "0")
		SET cALIGN = "\ql"
	ELSE
		SET cALIGN = "\qc"
	ENDIF
 
	CASE (cSTYLE)
		OF "NONE":		SET cROWDEF = BUILD(cROWDEF, "\clvertalt\clcbpat", nBGCOLOR, "\cellx", nCELLPOS)
		OF "UNDERLINE": SET cROWDEF = BUILD(cROWDEF, "\clvertalt\clbrdrb\brdrs\brdrw15\clcbpat", nBGCOLOR, "\cellx", nCELLPOS)
		OF "OVERLINE":  SET cROWDEF = BUILD(cROWDEF, "\clvertalt\clbrdrt\brdrs\brdrw15\clcbpat", nBGCOLOR, "\cellx", nCELLPOS)
		OF "BOX":		SET cROWDEF = BUILD(cROWDEF, "\clvertalt\clbrdrl\brdrs\brdrw15\clcbpat", nBGCOLOR, "\clbrdrt\brdrs\brdrw15",
													 "\clbrdrr\brdrs\brdrw15\clbrdrb\brdrs\brdrw15\cellx", nCELLPOS)
	ENDCASE
 
	IF (nLOCKED = 1)
		SET cROWDATA = CONCAT(TRIM(cROWDATA,3), cPROT_L)
		SET cROWDATA = CONCAT(TRIM(cROWDATA,3), TRIM(cROWPREFIX,3), cALIGN, " {", TRIM(cTEXT), "}")
		SET cROWDATA = CONCAT(TRIM(cROWDATA,3), cPROT_R)
		SET cROWDATA = CONCAT(TRIM(cROWDATA,3), "\cell")
	ELSE
		SET cROWDATA = CONCAT(TRIM(cROWDATA,3), TRIM(cROWPREFIX,3), cALIGN, " {", TRIM(cTEXT), "}\cell")
	ENDIF
END
 
; Write the table row to the RTF document
SUBROUTINE WRITE_ROW(X)
	CALL ADD_RTF(cROWDEF)
	CALL ADD_RTF(cROWDATA)
	CALL ADD_RTF("\row}")
END
 
; Create a line that goes the full page length
SUBROUTINE WRITE_LINE(X)
	CALL CLEAR_ROW(0,MAXVAL(X,8))
	CALL ADD_CELL(" ", "OVERRLINE", 12000, 0, 0)
	CALL WRITE_ROW(0)
END
 
; Document Header
SUBROUTINE RTF_HEADER(X)
	; Define beginning of document and Font
	CALL ADD_RTF("{\rtf1\ansi\deff0{\fonttbl{\f0\fswiss Arial;}{\f9\fmodern Courier New;}}")
 
	; Define the color table
	; ----------------------
	CALL ADD_RTF("{\colortbl;")											; Init color definition
	CALL ADD_RTF("\red0\green0\blue0;")									; Black
	CALL ADD_RTF("\red255\green255\blue255;")							; White
	CALL ADD_RTF("\red0\green255\blue0;")								; Green
	CALL ADD_RTF("\red255\green0\blue0;")								; Red
	CALL ADD_RTF("\red192\green192\blue192;")							; Grey
	CALL ADD_RTF("\red215\green215\blue236;")							; Pale Blue
	CALL ADD_RTF("\red0\green128\blue255;")								; Medium Blue
	CALL ADD_RTF("\red0\green0\blue200;")								; Dark Blue
	CALL ADD_RTF("\red0\green128\blue0;")								; Dark Green
	CALL ADD_RTF("}")													; End color definition
END
