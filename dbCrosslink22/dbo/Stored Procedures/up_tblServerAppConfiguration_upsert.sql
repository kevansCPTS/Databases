
create procedure [dbo].[up_tblServerAppConfiguration_upsert]
	@pk_key varchar(250)
,	@value varchar(2500)
,	@description varchar(250)
as

	set nocount on

    update sac
    set sac.value = @value,
		sac.description = @description
    from
        dbo.tblServerAppConfiguration sac
    where
        sac.pk_key = @pk_key

    if @@rowcount = 0
        insert dbo.tblServerAppConfiguration 
			(pk_key, value, description)
            values(@pk_key, @value, @description) 

