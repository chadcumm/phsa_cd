drop program bc_all_get_catalog_data:dba go
create program bc_all_get_catalog_data:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "CATALOG_CD" = 0
	, "SYNONYM_ID" = "" 

with OUTDEV, CATALOG_CD, SYNONYM_ID
 
 
 
FREE RECORD reply
RECORD reply
(
%i cclsource:status_block.inc
)
 
free record order_data
record order_data
(
	1 primary_synonym = vc
	1 ordered_synonym = vc
	1 order_id = f8
	1 catalog_cd = f8
	1 synonym_id = f8
	1 current_prsnl_id = f8
	1 current_user = vc
	1 qualified_ind = i4
	1 ref[*]
	 2 catalog_cd = f8
)
 

set order_data->catalog_cd = $CATALOG_CD
set order_data->synonym_id = $SYNONYM_ID

declare cStatus 			= c1 WITH protect, noconstant("Z")
 
declare i=i4 with protect, noconstant(0)

select into "nl:"
from
	order_catalog oc
plan oc
	where oc.primary_mnemonic in(
									 "Administer - Albumin Transfusion"
									,"Administer - Albumin 5% Transfusion PED/NEO"
									,"Administer - Albumin 25% Transfusion PED/NEO"
								)
	and oc.active_ind = 1
detail
	stat = alterlist(order_data->ref,(size(order_data->ref,5)+1))
	order_data->ref[size(order_data->ref,5)].catalog_cd = oc.catalog_cd
with nocounter

select into "nl:"
from
	order_catalog oc
	,order_catalog_synonym ocs
plan oc
	where oc.catalog_cd = order_data->catalog_cd
join ocs
	where ocs.catalog_cd = oc.catalog_cd
	and   ocs.synonym_id = order_data->synonym_id
detail
	order_data->ordered_synonym = ocs.mnemonic
	order_data->synonym_id = ocs.synonym_id
	order_data->primary_synonym = oc.primary_mnemonic
	if (locateval(i,1,size(order_data->ref,5),oc.catalog_cd,order_data->ref[i].catalog_cd) > 0.0)
		order_data->qualified_ind = 1
	endif
with nocounter
 
select into "nl:"
from
	prsnl p
plan p
	where p.person_id = reqinfo->updt_id
detail
	order_data->current_prsnl_id = p.person_id
	order_data->current_user = p.name_full_formatted
with nocounter
 

 
SET cStatus = "S"
 
#exit_script
SET reply->status_data->status = cStatus
 
set _memory_reply_string = cnvtrectojson(order_data)

call echo(_memory_reply_string) 
end
go
 
