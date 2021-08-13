
CREATE PROC [dbo].[spMobileReportSummaryByUserID]
	@AccountID int
AS
SELECT COUNT(TM.pssn) AS Total, 
	COUNT(CASE WHEN TM.irs_acc_cd = 'A' THEN TM.pssn END) AS Acks,
	COUNT(CASE WHEN TM.irs_acc_cd = 'R' THEN TM.pssn END) AS Rejects, 
	COUNT(CASE WHEN (TM.irs_acc_cd <> 'A' and TM.irs_acc_cd <> 'R') THEN TM.pssn END) AS Other,
	COUNT(CASE WHEN TM.ral_flag = 3 THEN TM.pssn END) AS Rals, 
	COUNT(CASE WHEN TM.ral_flag = 5 THEN TM.pssn END) AS Racs,
	COUNT(CASE WHEN TM.ral_flag = 1 THEN TM.pssn END) AS Paper, 
	COUNT(CASE WHEN TM.ral_flag = 4 THEN TM.pssn END) AS BDue, 
	COUNT(CASE WHEN TM.ral_flag = 2 THEN TM.pssn END) AS Direct, 
	US.Paid 
FROM tblTaxmast AS TM WITH (NOLOCK), 
(SELECT ISNULL(SUM(paid_amt),0) AS Paid FROM user_stats WHERE season = 2014 
	AND user_id IN (SELECT user_id FROM tbluser WHERE status = 'L' AND 
		(user_id IN (SELECT ChildUserID FROM FranchiseChild WHERE ParentUserID = @AccountID) OR 
		user_id IN (SELECT UserID FROM FranchiseOwner WHERE UserID = @AccountID)) 
	)) AS US 
WHERE (TM.user_id IN (SELECT user_id FROM tbluser WHERE status = 'L' 
AND (user_id IN (SELECT ChildUserID FROM FranchiseChild WHERE ParentUserID = @AccountID) 
OR user_id IN (SELECT UserID FROM FranchiseOwner WHERE UserID = @AccountID)) 
)) 
GROUP BY Us.Paid

