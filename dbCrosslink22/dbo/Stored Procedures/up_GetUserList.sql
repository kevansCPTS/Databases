

-- ==========================================================================
-- Author:		Steve Trautman
-- Create date: 6/29/2017
-- 06/29/2017	Get the list of userids for a given login
--				LoginID can be for an account, franchise, or user
-- ==========================================================================

CREATE PROC [dbo].[up_GetUserList]
	@LoginID varchar(8) --can be for account, franchise, or user.
AS
	SET NOCOUNT ON

	SELECT DISTINCT u.user_id, u.fname, u.lname, u.company, u.addr1, u.city, u.state, u.hold_flag
	from dbCrosslinkGlobal.dbo.tblUser u 
	JOIN dbo.udf_GetUserIDs(@LoginID) uids on uids.user_id = u.user_id