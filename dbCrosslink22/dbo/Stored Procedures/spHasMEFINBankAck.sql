
-- =============================================
-- Author:		Josh
-- Create date: 9/8/2010
-- Description:	sp to return true or false depending on whether or not
--				efin has a master efin that has an acked bank for that bank
--				If there is a master efin under the same account as this subefin
--				with an accept from the bank then return true else return false
--				11/1/2010
--				This has been modified to return true as long as we have a pending response
--				back. This applies to all banks
--				11/5/2010
--				This has been modified to return true in the case of Refund Advantage as the bank
--				efin if we don't have a response back from them
--				11/16/2010 
--				Also included Advent in the banks in which efins don't need a pending response back from the bank
--				12/27/2010 
--				Fixed bug with not segragating MSO user_ids
--				8/8/2011
--				Re-written to use the new bank application views.
--	Updated to allow the submission of sub-EFINs when the master is pending 9/17/2012 CK
-- Updated by: Charles K.
-- Update date: 8/8/2011
-- =============================================
CREATE PROCEDURE [dbo].[spHasMEFINBankAck] 
		 @efin int,
		 @ralBank char(1)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @toReturn int
	Declare @accountid varchar(8)
	Declare @isCLOMasterEFIN bit

		/*  The goal is to determine whether there is another EFIN under the same 
			account as the parameter EFIN that has been approved by the bank given 
			as a parameter.  The UserID clause is meant to verify that the master 
			and sub are either both under MSO UserIDs or both under Crosslink UserIDs.
		*/

	select @accountid = Account from efin where efin = @efin;
	select @accountid = Account from efin where efin = @efin;
	select @isCLOMasterEFIN = CLOMasterEFIN from dbCrosslinkGlobal..customer where account = @accountid
	IF @isCLOMasterEFIN = 1 BEGIN
		IF @ralbank = 'R' BEGIN		
			SELECT @toReturn = sibling_efin.Efin
			FROM efin 
			INNER JOIN vwLatestSubmittedApplication sibling_efin ON sibling_efin.AccountID = efin.Account
					AND sibling_efin.Efin != efin.Efin AND sibling_efin.BankID = @ralBank
			WHERE efin.Efin = @efin 
			AND (sibling_efin.Registered in ('A'))
		
			AND sibling_efin.Master = sibling_efin.Efin
			AND ((efin.userid >= 996000 AND sibling_efin.userid >= 996000) 
					OR (efin.userid < 500000 AND sibling_efin.userid < 500000)
					OR (efin.userid >= 500000 AND efin.userid < 996000 
						AND sibling_efin.userid >= 500000 AND sibling_efin.userid < 996000))
		
			SELECT (CASE WHEN @toReturn is null THEN 0 ELSE 1 END) returnValue, 
				(CASE WHEN @toReturn is null THEN 0 ELSE @toReturn END) master
		END ELSE BEGIN
			SELECT @toReturn = sibling_efin.Efin
			FROM efin 
			INNER JOIN vwLatestSubmittedApplication sibling_efin ON sibling_efin.AccountID = efin.Account
					AND sibling_efin.Efin != efin.Efin AND sibling_efin.BankID = @ralBank
			WHERE efin.Efin = @efin 
			AND (sibling_efin.Registered in ('A', 'C', 'P'))
		
			AND sibling_efin.Master = sibling_efin.Efin
			AND ((efin.userid >= 996000 AND sibling_efin.userid >= 996000) 
					OR (efin.userid < 500000 AND sibling_efin.userid < 500000)
					OR (efin.userid >= 500000 AND efin.userid < 996000 
						AND sibling_efin.userid >= 500000 AND sibling_efin.userid < 996000))
		
			SELECT (CASE WHEN @toReturn is null THEN 0 ELSE 1 END) returnValue, 
				(CASE WHEN @toReturn is null THEN 0 ELSE @toReturn END) master
		END
	END ELSE BEGIN
		IF @ralbank = 'R' BEGIN		
			SELECT @toReturn = sibling_efin.Efin
			FROM efin 
			INNER JOIN vwLatestSubmittedApplication sibling_efin ON sibling_efin.AccountID = efin.Account
					AND sibling_efin.Efin != efin.Efin AND sibling_efin.BankID = @ralBank
			WHERE efin.Efin = @efin 
			AND (sibling_efin.Registered in ('A'))
		
			AND sibling_efin.Master = sibling_efin.Efin
			AND ( (efin.userid >= 996000 AND sibling_efin.userid >= 996000) 
					OR (efin.userid < 996000 AND sibling_efin.userid < 996000) )		
			
			SELECT (CASE WHEN @toReturn is null THEN 0 ELSE 1 END) returnValue, 
				(CASE WHEN @toReturn is null THEN 0 ELSE @toReturn END) master
		END ELSE BEGIN
			SELECT @toReturn = sibling_efin.Efin
			FROM efin 
			INNER JOIN vwLatestSubmittedApplication sibling_efin ON sibling_efin.AccountID = efin.Account
					AND sibling_efin.Efin != efin.Efin AND sibling_efin.BankID = @ralBank
			WHERE efin.Efin = @efin 
			AND (sibling_efin.Registered in ('A', 'C', 'P'))
		
			AND sibling_efin.Master = sibling_efin.Efin
			AND ( (efin.userid >= 996000 AND sibling_efin.userid >= 996000) 
					OR (efin.userid < 996000 AND sibling_efin.userid < 996000) )

			SELECT (CASE WHEN @toReturn is null THEN 0 ELSE 1 END) returnValue, 
				(CASE WHEN @toReturn is null THEN 0 ELSE @toReturn END) master
		END
	END	
END
