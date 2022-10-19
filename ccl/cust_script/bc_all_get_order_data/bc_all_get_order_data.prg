drop program bc_all_get_order_data:dba go
create program bc_all_get_order_data:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "ORDER_ID" = 0
 
with OUTDEV, ORDER_ID
 
 
 
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
	1 synonym_id = f8
	1 plan_group_nbr = f8
	1 current_prsnl_id = f8
	1 current_user = vc
	1 ordering_prsnl_id = f8
	1 ordering_provider = vc
	1 template_order_flag = i4
	1 template_order_id = f8
	1 protocol_order_id = f8
)
 

set order_data->order_id = $ORDER_ID

declare cStatus 			= c1 WITH protect, noconstant("Z")
 
declare i=i4 with protect, noconstant(0)

select into "nl:"
from
	orders o
	,order_catalog oc
	,order_catalog_synonym ocs
plan o
	where o.order_id =  order_data->order_id
join oc
	where oc.catalog_cd = o.catalog_cd
join ocs
	where ocs.catalog_cd = o.catalog_cd
	and   ocs.synonym_id = o.synonym_id
detail
	order_data->ordered_synonym = ocs.mnemonic
	order_data->synonym_id = ocs.synonym_id
	order_data->primary_synonym = oc.primary_mnemonic
	order_data->template_order_flag = o.template_order_flag
	order_data->template_order_id = o.template_order_id
	order_data->protocol_order_id = o.protocol_order_id
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
 
 
select into "nl:"
from
	order_action oa
	,prsnl p
plan oa
	where oa.order_id = order_data->order_id
	and oa.action_type_cd = value(uar_get_code_by("MEANING",6003,"ORDER"))
join p
	where p.person_id = oa.order_provider_id
order by
	oa.order_id
head oa.order_id
	order_data->ordering_prsnl_id = oa.order_provider_id
	order_data->ordering_provider = p.name_full_formatted
with nocounter
 
SET cStatus = "S"
 
#exit_script
SET reply->status_data->status = cStatus
 
set _memory_reply_string = cnvtrectojson(order_data)
 
end
go
 
