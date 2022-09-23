drop program lab_oef_orig_id_updt go
create program lab_oef_orig_id_updt

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Order Entry Format" = "" 

with OUTDEV, OE_FORMAT_NAME

declare i=i4 with noconstant(0), protect

record t_rec
(
	1 prompts 
	 2 outdev = vc
	 2 oe_format_name = vc
	1 values
	 2 oe_format_id = f8
	 2 oe_format_name = vc
	 2 action_type_cd = f8
	 2 orig_order_id
	  3 oe_field_id = f8
	  3 description = vc
	1 var
	 2 oe_field_present = i2
	 2 max_group_seq = i2
	 2 new_group_seq = i2
) with protect

set t_rec->prompts.outdev = $OUTDEV
set t_rec->prompts.oe_format_name = $OE_FORMAT_NAME

set t_rec->values.oe_format_name = t_rec->prompts.oe_format_name

set t_rec->values.action_type_cd = uar_get_code_by("MEANING",6003,"ORDER")
set t_rec->values.orig_order_id.description = "Original Order Id"

select into "nl:"
from
	order_entry_fields oef
plan oef
	where oef.description = t_rec->values.orig_order_id.description
detail
	t_rec->values.orig_order_id.oe_field_id = oef.oe_field_id
with nocounter

if (t_rec->values.orig_order_id.oe_field_id <=0.0)
	go to exit_script
endif

select into "nl:"
from
	order_entry_format oef
plan oef
	where oef.oe_format_name = t_rec->values.oe_format_name
	and   oef.action_type_cd = t_rec->values.action_type_cd
detail
	t_rec->values.oe_format_id = oef.oe_format_id
with nocounter 

free record 500026request
record 500026request (
  1 oe_format_id = f8   
  1 action_type_cd = f8   
) 

free record 500026reply

set 500026request->action_type_cd = t_rec->values.action_type_cd
set 500026request->oe_format_id = t_rec->values.oe_format_id

set stat = tdbexecute(500003,500022,500026,"REC",500026request,"REC",500026reply)

if (size(500026reply->data,5) < 0)
	go to exit_script
endif


for (i=1 to size(500026reply->data,5))
	if (500026reply->data[i].oe_field_id = t_rec->values.orig_order_id.oe_field_id)
		set t_rec->var.oe_field_present = 1
		set i = (size(500026reply->data,5) + 1)
	endif
endfor

if (t_rec->var.oe_field_present = 1)
	go to exit_script
endif

for (i=1 to size(500026reply->data,5))
	if (500026reply->data[i].group_seq > t_rec->var.max_group_seq)
		set t_rec->var.max_group_seq = 500026reply->data[i].group_seq
	endif
endfor

set t_rec->var.new_group_seq = (t_rec->var.max_group_seq + 1)


if ((t_rec->var.max_group_seq = t_rec->var.new_group_seq) or (t_rec->var.new_group_seq = 0))
	go to exit_script
endif

free record 500027request
record 500027request (
  1 oe_format_id = f8   
  1 oe_field_id = f8   
  1 action_type_cd = f8   
  1 accept_flag = i2   
  1 default_value = c100  
  1 input_mask = c50  
  1 prolog_method = f8   
  1 epilog_method = f8   
  1 status_line = c200  
  1 label_text = c200  
  1 group_seq = i4   
  1 field_seq = i4   
  1 max_nbr_occur = i4   
  1 value_required_ind = i2   
  1 core_ind = i2   
  1 clin_line_ind = i2   
  1 clin_line_label = c25  
  1 clin_suffix_ind = i2   
  1 disp_yes_no_flag = i2   
  1 dept_line_ind = i2   
  1 dept_line_label = c25  
  1 dept_suffix_ind = i2   
  1 disp_dept_yes_no_flag = i2   
  1 def_prev_order_ind = i2   
  1 filter_params = c255  
  1 require_cosign_ind = i2   
  1 require_verify_ind = i2   
  1 require_review_ind = i2   
  1 lock_on_modify_flag = i2   
  1 carry_fwd_plan_ind = i2   
) 

free record 500027reply

set 500027request->oe_format_id 		= t_rec->values.oe_format_id
set 500027request->oe_field_id 			= t_rec->values.orig_order_id.oe_field_id
set 500027request->action_type_cd 		= t_rec->values.action_type_cd
set 500027request->accept_flag 			= 2
set 500027request->label_text 			= t_rec->values.orig_order_id.description
set 500027request->group_seq 			= t_rec->var.new_group_seq
set 500027request->max_nbr_occur 		= 1
set 500027request->def_prev_order_ind	= 1

set stat = tdbexecute(500003,500023,500027,"REC",500027request,"REC",500027reply)

call echorecord(500027reply)

#exit_script
call echorecord(t_rec)

end 
go

