
CREATE PROC [dbo].[up_GetEFINList]
	@LoginID varchar(8) --can be for account, franchise, or user
AS
	SET NOCOUNT ON

	SELECT DISTINCT u.user_id, dbo.PadString(e.efin,'0',6) as efin, e.FirstName, e.LastName, e.company, e.Address, e.city, e.state
	from dbCrosslinkGlobal.dbo.tblUser u
	JOIN dbo.udf_GetUserIDs(@LoginID) uids on uids.user_id = u.user_id
	JOIN efin AS e ON u.user_id = e.userid
	AND e.Deleted <> 1

