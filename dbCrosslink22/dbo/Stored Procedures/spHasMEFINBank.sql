-- =============================================
-- Author:		Josh
-- Create date: 9/8/2010
-- Updated by: Charles K.
-- Update date: 8/8/2011
-- Description:	sp to return true or false depending on if there
--				is exists an efin under the same account that is already registered
--				with the bank passed in
-- =============================================
CREATE PROCEDURE [dbo].[spHasMEFINBank] 
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

	/** Determine if there is another master efin under the same account for the indicated bank. */
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
