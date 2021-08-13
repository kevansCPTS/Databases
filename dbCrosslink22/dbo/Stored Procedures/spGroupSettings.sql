
-- =============================================
-- Author:		Jay Willis
-- Create date: 12/9/2009
-- Description:	Publish Groups
-- Update: 11/18/2011 added franchise user code - Jay Willis
-- Update: 1/31/2012 changed group publishing for franchises and SB - Jay Willis
-- Update: 8/23/2013 Modified showimg published groups.
-- =============================================
CREATE PROCEDURE [dbo].[spGroupSettings] 
	-- Add the parameters for the stored procedure here
	@usersettings_id int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @user_id int,
			@master_id int,
			@seqno int,
			@site_id varchar(8),
			@account_id varchar(8),
			@group_id int,
			@group_name varchar(20),
			@XMLStringLaunch xml = '<xmldata><cmnd>Launch</cmnd><NAME /><PHONE /><LOCATION /><FAX /><EMAIL /><SITE /><XMIT /><XFRSETUP /><XFRBILL /><XFRDB/><XFRLOGIN /><XFRAPPT /><ADMP /><AESK /></xmldata>',
			@XMLString varchar(max),
			@Franchiseuserid int,
			@PriorFranchiseuserid int

	SELECT @master_id = master_id, 
	       @user_id = user_id, 
		   @account_id = account_id, 
		   @group_id = group_id,
		   @Franchiseuserid = ISNULL(franchiseuser_id,0),
		   @PriorFranchiseuserid = ISNULL(prior_franchise_user_id, 0)
	FROM   tblXlinkUserSettings 
	WHERE  usersettings_id = @usersettings_id

	select 'accountid: ' + @account_id + ' franchise: ' + CONVERT(varchar(10), @Franchiseuserid) + ' priorfranchise: ' + CONVERT(varchar(10), @PriorFranchiseuserid)

	-- Always update Service Bureau Groups
	EXEC spGroupGetServiceBureauUsers @account_id, @XMLString out

	-- get last sequence number and increment by 1
	SELECT @seqno = 0
	SELECT TOP 1 @seqno = seqno FROM tblMgmt WHERE userid = @master_id ORDER BY seqno DESC
	SELECT @seqno = @seqno + 1

    IF @seqno = 1
	BEGIN
		INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@master_id,@seqno,@XMLStringLaunch)
		SELECT @seqno = 2
	END		

	INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@master_id,@seqno,@XMLString)

	UPDATE tblXlinkGroups SET publish_date = GETDATE() where group_id IN (
		SELECT DISTINCT tblXlinkGroups.group_id from tblXlinkGroups 
		join tblXlinkUserSettings on tblXlinkGroups.group_id = tblXlinkUserSettings.group_id
		WHERE tblXlinkUserSettings.account_id = @account_id AND ISNULL(tblXlinkUserSettings.franchiseuser_id,0) = 0)

	-- If FranchiseUserID changes then update old franchise groups
	IF @PriorFranchiseuserid <> 0 AND @PriorFranchiseuserid <> @Franchiseuserid
	BEGIN
		EXEC spGroupGetFranchiseUsers @PriorFranchiseuserid, @XMLString out

		-- get last sequence number and increment by 1
		SELECT @seqno = 0
		SELECT TOP 1 @seqno = seqno FROM tblMgmt WHERE userid = @PriorFranchiseuserid ORDER BY seqno DESC
		SELECT @seqno = @seqno + 1

		IF @seqno = 1
		BEGIN
			INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@PriorFranchiseuserid,@seqno,@XMLStringLaunch)
			SELECT @seqno = 2
		END		

		INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@PriorFranchiseuserid,@seqno,@XMLString)
	
		UPDATE tblXlinkGroups SET publish_date = GETDATE() where group_id IN (
			SELECT DISTINCT tblXlinkGroups.group_id from tblXlinkGroups 
			join tblXlinkUserSettings on tblXlinkGroups.group_id = tblXlinkUserSettings.group_id
			WHERE tblXlinkUserSettings.account_id = @account_id AND ISNULL(tblXlinkUserSettings.franchiseuser_id,0) = @PriorFranchiseuserid)
			UPDATE tblXlinkUserSettings SET prior_franchise_user_id = null WHERE prior_franchise_user_id = @PriorFranchiseuserid
	END
	
	
	-- If FranchiseUserID exists then update franchise groups
	IF @Franchiseuserid > 0
	BEGIN
		EXEC spGroupGetFranchiseUsers @Franchiseuserid , @XMLString out

		-- get last sequence number and increment by 1
		SELECT @seqno = 0
		SELECT TOP 1 @seqno = seqno FROM tblMgmt WHERE userid = @Franchiseuserid ORDER BY seqno DESC
		SELECT @seqno = @seqno + 1

		IF @seqno = 1
		BEGIN
			INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@Franchiseuserid,@seqno,@XMLStringLaunch)
			SELECT @seqno = 2
		END		

		INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@Franchiseuserid,@seqno,@XMLString)
		UPDATE tblXlinkUserSettings SET prior_franchise_user_id = @Franchiseuserid WHERE franchiseuser_id = @Franchiseuserid
		UPDATE tblXlinkGroups SET publish_date = GETDATE() where group_id IN (
			SELECT DISTINCT tblXlinkGroups.group_id from tblXlinkGroups 
			join tblXlinkUserSettings on tblXlinkGroups.group_id = tblXlinkUserSettings.group_id
			WHERE tblXlinkUserSettings.account_id = @account_id AND ISNULL(tblXlinkUserSettings.franchiseuser_id,0) = @Franchiseuserid)
	END
	ELSE
	BEGIN
		UPDATE tblXlinkUserSettings SET prior_franchise_user_id = null WHERE franchiseuser_id = 0
	END
END

--- use nothing below
/*
	-- get last sequence number and increment by 1
	SELECT @seqno = 0
	SELECT TOP 1 @seqno = seqno FROM tblMgmt WHERE userid = @master_id ORDER BY seqno DESC
	SELECT @seqno = @seqno + 1

	SELECT @XMLString = '<xmldata><cmnd>SBureauGroups</cmnd>'
	
	DECLARE cur_rs CURSOR FOR
	SELECT tblXlinkUserSettings.user_id, 
	       ISNULL(tblXlinkUserSettings.site_id,''), 
	       group_name 
	FROM   tblXlinkUserSettings join tblXlinkGroups 
	ON	   tblXlinkUserSettings.group_id = tblXlinkGroups.group_id
	WHERE  tblXlinkUserSettings.account_id = @account_id
		   and tblXlinkUserSettings.user_id < 996000
		   and ISNULL(tblXlinkUserSettings.franchiseuser_id,0) = @Franchiseuserid
		   -- and tblXlinkUserSettings.group_id = @group_id -- added 11/18/2011 to restrict to single group
	
	OPEN cur_rs
	FETCH NEXT FROM cur_rs INTO @user_id, @site_id, @group_name
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		SELECT @XMLString = @XMLString + 
		       '<u' + dbo.PadString(@user_id,'0',6) + '>'
		       + dbo.PadString(@site_id,'_',7) + @group_name
		       + '</' + 'u' + dbo.PadString(@user_id,'0',6) + '>'
		FETCH NEXT FROM cur_rs INTO @user_id, @site_id, @group_name
	END
	CLOSE cur_rs
	DEALLOCATE cur_rs

	select @XMLString = @XMLString + '</xmldata>'
	
    IF @seqno = 1
	BEGIN
		SELECT @XMLStringLaunch = '<xmldata><cmnd>Launch</cmnd><NAME /><PHONE /><LOCATION /><FAX /><EMAIL /><SITE /><XMIT /><XFRSETUP /><XFRBILL /><XFRDB/><XFRLOGIN /><XFRAPPT /><ADMP /><AESK /></xmldata>'
		INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@master_id,@seqno,@XMLStringLaunch)
		SELECT @seqno = 2
	END		

	INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@master_id,@seqno,@XMLString)

	UPDATE tblXlinkGroups SET publish_date = getdate() WHERE @group_id = group_id AND account_id = @account_id

*/



