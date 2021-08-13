

CREATE procedure up_tblXlinkUserLogins_upsert
	@create_date                                       datetime         = null                 ,	@edit_date                                         datetime         = null                     ,	@publish_date                                      datetime         = null                     ,	@account_id                                        varchar(8)                         ,	@user_id                                           int                             ,	@login_id                                          varchar(8)         ,	@login_name                                        varchar(35)              ,	@login_password                                    varchar(16)      = null        ,	@change_password                                   char(1)          = null        ,	@hide_work_in_progress                             char(1)          = null        ,	@access_level                                      int              = null        ,	@shortcut_id                                       varchar(7)       = null        ,	@bank_id_code                                      varchar(5)       = null        ,	@RBIN                                              varchar(8)       = null        ,	@franchiseuser_id                                  int              = null        ,	@display_short_form                                char(1)          = null        ,	@training_returns_only                             char(1)          = null        ,	@show_fees_in_transmit                             char(1)          = null         as

    set nocount on

    merge 
        [dbo].[tblXlinkUserLogins] xul
    using (
        select			@create_date		,	@edit_date		,	@publish_date		,	@account_id		,	@user_id		,	@login_id		,	@login_name		,	@login_password		,	@change_password		,	@hide_work_in_progress		,	@access_level		,	@shortcut_id		,	@bank_id_code		,	@RBIN		,	@franchiseuser_id		,	@display_short_form		,	@training_returns_only		,	@show_fees_in_transmit        )            as a (            	create_date			,	edit_date			,	publish_date			,	account_id			,	user_id			,	login_id			,	login_name			,	login_password			,	change_password			,	hide_work_in_progress			,	access_level			,	shortcut_id			,	bank_id_code			,	RBIN			,	franchiseuser_id			,	display_short_form			,	training_returns_only			,	show_fees_in_transmit            )    on        xul.[account_id] = a.[account_id]        and xul.[user_id] = a.[user_id]        and xul.[login_id] = a.[login_id]        and xul.[login_name] = a.[login_name]    
    when matched then
        update
		 	set xul.create_date = a.create_date		,	xul.edit_date = a.edit_date		,	xul.publish_date = a.publish_date		,	xul.login_password = a.login_password		,	xul.change_password = a.change_password		,	xul.hide_work_in_progress = a.hide_work_in_progress		,	xul.access_level = a.access_level		,	xul.shortcut_id = a.shortcut_id		,	xul.bank_id_code = a.bank_id_code		,	xul.RBIN = a.RBIN		,	xul.franchiseuser_id = a.franchiseuser_id		,	xul.display_short_form = a.display_short_form		,	xul.training_returns_only = a.training_returns_only		,	xul.show_fees_in_transmit = a.show_fees_in_transmit            
    when not matched then
        insert (
			create_date		,	edit_date		,	publish_date		,	account_id		,	user_id		,	login_id		,	login_name		,	login_password		,	change_password		,	hide_work_in_progress		,	access_level		,	shortcut_id		,	bank_id_code		,	RBIN		,	franchiseuser_id		,	display_short_form		,	training_returns_only		,	show_fees_in_transmit        )
            values (
		 	    a.create_date		    ,	a.edit_date		    ,	a.publish_date		    ,	a.account_id		    ,	a.user_id		    ,	a.login_id		    ,	a.login_name		    ,	a.login_password		    ,	a.change_password		    ,	a.hide_work_in_progress		    ,	a.access_level		    ,	a.shortcut_id		    ,	a.bank_id_code		    ,	a.RBIN		    ,	a.franchiseuser_id		    ,	a.display_short_form		    ,	a.training_returns_only		    ,	a.show_fees_in_transmit    
            );






