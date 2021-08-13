
CREATE PROC [dbo].[spMobileEFINListByUserID]
	@AccountID int
AS
SELECT DISTINCT u.user_id, e.efin, e.FirstName, e.LastName, e.company, e.Address, e.city, e.state 
--, (SELECT COUNT(*) FROM tblTaxmast (nolock) tm WHERE tm.efin = e.Efin) as TOTAL
FROM tbluser AS u 
JOIN efin AS e ON u.user_id = e.userid 
WHERE u.status = 'L' 
AND (u.user_id IN (SELECT ChildUserID FROM FranchiseChild WHERE ParentUserID = @AccountID) 
     OR u.user_id IN (SELECT UserID FROM FranchiseOwner WHERE UserID = @AccountID)) 

