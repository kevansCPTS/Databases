﻿

CREATE procedure up_tblXlinkUserLogins_upsert
	@create_date                                       datetime         = null                 

    set nocount on

    merge 
        [dbo].[tblXlinkUserLogins] xul
    using (
        select
    when matched then
        update
		 	set xul.create_date = a.create_date
    when not matched then
        insert (
			create_date
            values (
		 	    a.create_date
            );





