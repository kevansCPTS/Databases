-- =============================================
-- Author:		Charles Krebs
-- Create date: 8/8/2011
-- Description:	Determine whether the parameter EFIN is an approved Master EFIN
--		at the parameter bank.
-- Modifed to work correctly. 6/29/2012 -Charles K.
-- Modified to allow submission of sub-EFINs when Master is pending 9/13/2012 -Charles K.
-- =============================================
CREATE PROCEDURE [dbo].[spVerifyMasterEFIN]
		 @efin int,
		 @ralBank char(1)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @masterEFIN int

		IF @ralbank = 'R' BEGIN		
			SELECT @masterEFIN = efin
			FROM vwLatestSubmittedApplication 
			WHERE Registered in ('A')
			AND Master = Efin
			AND Efin = @efin 
			AND BankID = @ralBank
		END ELSE BEGIN
			SELECT @masterEFIN = efin
			FROM vwLatestSubmittedApplication 
			WHERE Registered in ('A', 'C', 'P')
			AND Master = Efin
			AND Efin = @efin 
			AND BankID = @ralBank
		END

		
		SELECT (CASE WHEN @masterEFIN is null THEN 0 ELSE 1 END) returnValue
	
END

