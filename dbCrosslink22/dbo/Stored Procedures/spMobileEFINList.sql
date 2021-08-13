
CREATE PROC [dbo].[spMobileEFINList]
	@AccountID varchar(8)
AS
SELECT DISTINCT u.user_id, e.efin, e.FirstName, e.LastName, e.company, e.Address, e.city, e.state
--, (SELECT COUNT(*) FROM tblTaxmast (nolock) tm WHERE tm.efin = e.Efin) as TOTAL
FROM tbluser AS u 
JOIN efin AS e ON u.user_id = e.userid
WHERE u.account = @AccountID 
AND u.status = 'L' 
AND (u.user_id NOT IN (SELECT childuserid FROM FranchiseChild) AND
     u.user_id NOT IN (SELECT userid FROM franchiseowner)) 

