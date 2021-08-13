
CREATE PROC [dbo].[spMobileUserListByUserID]
	@AccountID int
AS
SELECT user_id, fname, lname, company, addr1, city, state, hold_flag 
--, (SELECT COUNT(*) FROM tblTaxmast (nolock) tm WHERE tm.user_id = u.user_id) as TOTAL
FROM tblUser u
WHERE status = 'L' AND user_id IS NOT NULL 
AND (user_id IN (SELECT ChildUserID FROM FranchiseChild WHERE ParentUserID = @AccountID) OR 
	user_id IN (SELECT UserID FROM FranchiseOwner WHERE UserID = @AccountID)) 

