-- =============================================
-- Author:		Charles Krebs
-- Create date: 1/31/2012
-- Description:	Return the XML to send all Users to a Service Bureau
-- =============================================
CREATE PROCEDURE [dbo].[spGroupGetServiceBureauUsers]
@Account varchar(10),
@XMLString varchar(max) = null output
	
AS
BEGIN

	declare @user_id int,
			@site_id varchar(8),
			@group_name varchar(20)
	
	SELECT @XMLString = '<xmldata><cmnd>SBureauGroups</cmnd>'
	
	DECLARE cur_rs CURSOR FOR
	/* This segment is for standard users who are not franchise parents or children and 
		assign them to groups based on their designated group name */
	SELECT tblXlinkUserSettings.user_id, 
	       ISNULL(tblXlinkUserSettings.site_id,''), 
	       group_name 
	FROM   tblXlinkUserSettings 
		LEFT JOIN FranchiseOwner ON FranchiseOwner.UserID = tblXlinkUserSettings.user_ID	
	join tblXlinkGroups 
	ON	   tblXlinkUserSettings.group_id = tblXlinkGroups.group_id
	WHERE  
		   tblXlinkUserSettings.user_id < 996000
		   AND tblXlinkUserSettings.Account_ID = @Account
		   AND ISNULL(tblXlinkUserSettings.franchiseuser_id,0) = 0
		   AND FranchiseOwner.UserID is null

	UNION
	
	/* This segment will get all users who are franchise parents or children and assign them 
		to a group based on the Franchise Name */
	SELECT tblXlinkUserSettings.user_id, 
	       ISNULL(tblXlinkUserSettings.site_id,''), 
	       FranchiseName 
	FROM   tblXlinkUserSettings 
		INNER JOIN FranchiseOwner ON FranchiseOwner.UserID = tblXlinkUserSettings.user_ID
				OR FranchiseOwner.UserID = tblXlinkUserSettings.franchiseuser_id
	WHERE  
		   tblXlinkUserSettings.user_id < 996000
		   AND Account_ID = @Account
		   
	
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


