
/*
free record 4903request go
record 4903request (
  1 batch_selection = vc
  1 output_dist = vc
  1 ops_date = dq8
)  go
 
free record 4903reply go
record 4903reply
(
1 ops_event = vc
%i cclsource:status_block.inc
) go
 
set 4903request->batch_selection = concat(^bc_all_onc_dot_rpt_ops^) go
set stat = tdbexecute(4600,4801,4903,"REC",4903request,"REC",4903reply) go
call echorecord(4903reply) go
*/


;OPERATIONS -> sys_runccl (4903)
 
free record request go
record request (
	1 batch_selection = vc
	1 output_dist = vc
	1 ops_date = dq8
	) go
 
Free record reply go
record reply (
	1 ops_event = vc
%i cclsource:status_block.inc
	) go
 
set request->batch_selection = ^bc_all_onc_dot_rpt_ops^ go
set request->output_dist = "chad.cummings@phsa.ca" go
set request->ops_date = cnvtdatetime(curdate+0,curtime3) go
set reqinfo->updt_req = 4903 go
 
execute sys_runccl go
 
call echorecord(reply) go
 

 
;execute bc_all_onc_dot_rpt_ops go
 
