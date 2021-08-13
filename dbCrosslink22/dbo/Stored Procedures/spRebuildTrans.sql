-- =============================================
-- Author:		Tim Gong
-- Create date: 2/9/2011
-- Description:	Rebuild the Trans table entries for 2011
--		Update: Added logic to include non-bank product protection 
--			plus returns in the calculation Charles Krebs 2/13/2013
-- =============================================
CREATE PROCEDURE [dbo].[spRebuildTrans] 
	-- Add the parameters for the stored procedure here
	@p1 int = 0, 
	@p2 int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @yr Smallint
	Set @yr = dbo.getXlinkSeason()

	DELETE FROM dbCrosslinkGlobal..trans WHERE prod_cd = 'ACKF' AND season = @yr
	DELETE FROM dbCrosslinkGlobal..trans WHERE prod_cd = 'ACKS' AND season = @yr
	/*
	DELETE FROM dbCrosslinkGlobal..trans WHERE prod_cd = 'ACKP' AND season = @yr
*/
	INSERT INTO dbCrosslinkGlobal..trans
	Select tm.user_id, account, @yr, 'ACKF', Count(*)
		  FROM tblTaxmast tm with (nolock)
		  INNER JOIN dbCrosslinkGlobal..tblUser ON tm.user_id = tblUser.user_id
		  Where irs_acc_cd = 'A'
		  AND tm.user_id < 997000
		  GROUP By tm.user_id, account

	INSERT INTO dbCrosslinkGlobal..trans
	Select sm.user_id, account, @yr, 'ACKS', Count(*)
		  From tblStamast sm With (nolock)
		  Left JOIN dbCrosslinkGlobal..tblUser ON tblUser.user_id = sm.user_id
		  WHERE (state_ack = 'A'
		  OR (state_id = 'PA' AND state_ack IN ('C','N')))
		  AND sm.user_id < 997000
		  GROUP By sm.user_id, tblUser.account

/*
	INSERT INTO dbCrosslinkGlobal..trans		  
	select	a.UserID user_id, tblUser.account, @yr, 'ACKP', count(*) 
		from tblReturnMaster a  (nolock)
		INNER JOIN dbCrosslinkGlobal..tblUser (nolock) ON a.userid = tblUser.user_id
		LEFT JOIN tblTaxmast c with (nolock) ON a.PrimarySSN=c.pssn AND
				a.userID = c.user_id AND a.FilingStatus = c.filing_stat
	where tblUser.account not in (SELECT AccountCode FROM tblPPFeeOptionAccounts) 
			AND 
			a.BankProductAttached=0 
			AND A.PEIProtPlusFee > 0
			and (c.irs_acc_cd='A' or a.PrintFinal is not null)
			AND a.UserID < 997000
	group by a.UserID, tblUser.account		  
*/
END



