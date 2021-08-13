
-- =============================================
-- Author:		Jay Willis
-- Create date: 10/4/2009
-- Description:	
-- Update: 11/22/2011 added franchise user code - Jay Willis
-- Update: 10/30/2017 removed office publish - use spPublishAll for replacement - Jay Willis
-- Update: 1/10/2020 don't publish user logins 
-- =============================================
CREATE PROCEDURE [dbo].[spPublishUser] 
	-- Add the parameters for the stored procedure here
	@usersettings_id int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @userlogin_id int,
			@user_id int,
	   		@Franchiseuserid int

	exec spLaunchSettings @usersettings_id;
	-- is this really needed anymore? 
	exec spAuthCodeMaintenance @usersettings_id;
	exec spAddAuthLevels @usersettings_id;
	exec spAddBilling @usersettings_id;
	exec spAddBilling @usersettings_id, 'C';
	--exec spOfficeSettings @usersettings_id;
	exec spGroupSettings @usersettings_id;

	select @user_id = user_id,
		   @Franchiseuserid = ISNULL(franchiseuser_id, 0)
	from   tblXlinkUserSettings 
	where  usersettings_id = @usersettings_id

	exec spPublishTags @user_id
	--exec spAddRestrictedForms @user_id; -- Added JW 10/23/2012
	--exec spAddRestrictedFields @user_id; -- Added JW 11/12/2012

	--DECLARE cur_rs CURSOR
	--FOR
	--select userlogin_id 
	--from   tblXlinkUserLogins 
	--where  user_id = @user_id
 --          and isnull(franchiseuser_id, 0) = @Franchiseuserid
		   
	--OPEN cur_rs;
	--FETCH NEXT FROM cur_rs INTO @userlogin_id;
	--WHILE (@@FETCH_STATUS <> -1)
	--BEGIN
	--	IF (@@FETCH_STATUS <> -2)
	--		BEGIN   
	--			exec spAddUserLogins @userlogin_id;
	--		END;
	--	FETCH NEXT FROM cur_rs INTO @userlogin_id;
	--END;
	--CLOSE cur_rs;
	--DEALLOCATE cur_rs;
END



