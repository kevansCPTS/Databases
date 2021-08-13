
CREATE PROC [dbo].[spMobileUserList]
	@AccountID varchar(8)
AS

SELECT user_id, fname, lname, company, addr1, city, state, hold_flag
--, (SELECT COUNT(*) FROM tblTaxmast (nolock) tm WHERE tm.user_id = u.user_id) as TOTAL
FROM tblUser u
WHERE account = @AccountID AND status = 'L' AND user_id IS NOT NULL 
AND (user_id NOT IN (SELECT childuserid FROM FranchiseChild) 
	AND user_id NOT IN (SELECT userid FROM franchiseowner))

