-- =============================================
-- Author:		Charles Krebs
-- Create date: 1/31/2012
-- Description:	Return the XML to send all Users to a Franchise Owner
-- =============================================
CREATE PROCEDURE [dbo].[spGroupGetFranchiseUsers]
@FranchiseID int,
@XMLString varchar(max) = null output
	
AS
BEGIN
	declare @user_id int,
			@site_id varchar(8),
			@group_name varchar(20)
	
	SELECT @XMLString = '<xmldata><cmnd>SBureauGroups</cmnd>'
	
	DECLARE cur_rs CURSOR FOR
	SELECT tblXlinkUserSettings.user_id, 
	       ISNULL(tblXlinkUserSettings.site_id,''), 
	       group_name 
	FROM   tblXlinkUserSettings join tblXlinkGroups 
	ON	   tblXlinkUserSettings.group_id = tblXlinkGroups.group_id
	WHERE  
		   tblXlinkUserSettings.user_id < 996000
		   and ISNULL(tblXlinkUserSettings.franchiseuser_id,0) = @franchiseID
		   --Jay, Feel Free to add an @account parameter if you think it's needed
		   --AND tblXlinkUserSettings.account_id = @account  
	
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

	SET @XMLString = @XMLString + '</xmldata>'
	
	SELECT @XMLString
	
END


