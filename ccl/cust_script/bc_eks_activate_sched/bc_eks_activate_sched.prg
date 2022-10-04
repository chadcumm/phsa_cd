/***********************************************************************************************************************
  Program Name:       	bc_eks_activate_sched
  Source File Name:   	bc_eks_activate_sched.prg
  Program Written By: 	Chad Cummings
  Date:  			  	Unhide Scheduling Event
 
************************************************************************************************************************
												*MODIFICATION HISTORY*
************************************************************************************************************************
 
Rev  Date         Jira       Programmer             Comment
---  -----------  ---------  ---------------------  --------------------------------------------------------------------
000  17-Aug-2022  CST-172234 Chad Cummings          Created
***********************************************************************************************************************/
 
drop program bc_eks_activate_sched go
create program bc_eks_activate_sched 


set retval = 0

if (link_orderid <= 0.0)
	go to exit_script
endif

declare link_sch_event_id = f8 with noconstant(0.0)

select into "nl:"
	se.*
from
	sch_event_attach sea
	,sch_event se
plan sea
	where sea.order_id = link_orderid
join se
	where se.sch_event_id = sea.sch_event_id
detail
	link_sch_event_id = se.sch_event_id
with nocounter

if (link_sch_event_id <= 0.0)
	go to exit_script
endif

update into sch_event set active_ind = 1 where sch_event_id = link_sch_event_id
commit

set retval = 100

#exit_script

end 
go
