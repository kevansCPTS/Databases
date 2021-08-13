

-- ==========================================================================
-- Author:		Steve Trautman
-- Create date: 6/29/2017
-- 06/29/2017	Get the userids for a given login
--				LoginID can be for an account, franchise, or user
-- ==========================================================================
CREATE FUNCTION [dbo].[udf_GetUserIDs](@LoginID varchar(8))
RETURNS @retUserIDS TABLE (user_id int not null)
AS
BEGIN
	declare @AccountID varchar(8) = null
	declare @UserID int = null

	if @LoginID like '%[^0-9]%' -- matches anything not a digit
		set @AccountID = @LoginID
	else
		set @UserID = @LoginID

	INSERT INTO @retUserIDs
	SELECT DISTINCT user_id
	from dbCrosslinkGlobal.dbo.tblUser u 
	left join dbo.FranchiseOwner fo on fo.UserID = u.user_id
	left join dbo.FranchiseChild fc on fc.ChildUserID = u.user_id
	where (u.account = @AccountID) -- condition for an account
	or (fc.ChildUserID = u.user_id and fc.ParentUserID = @UserID) -- condition for a franchise child
	or (u.user_id = @UserID) -- condition for a user or franchise owner

	RETURN
END


