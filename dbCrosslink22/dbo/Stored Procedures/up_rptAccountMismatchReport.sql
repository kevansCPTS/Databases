
-- =============================================
-- Author:		Sundeep Brar
-- Create date: 06/04/2020
-- Description:	Stored procedure for inteneral report > customer support report > Account Mismatch Report
-- =============================================
CREATE PROCEDURE [dbo].[up_rptAccountMismatchReport]

AS

BEGIN

	select
		lsa.Efin Efin
	,	lsa.AccountID SubmittedAccount
	,	lsa.[Master] SubmittedMaster
	,	e.Account MasterAccount
	,	lsa.BankID BankID
	,	lsa.RegisteredDescription RegisteredDescription
	from
		dbo.vwLatestSubmittedApplication lsa join efin e on e.EFIN = lsa.[Master]
	where
		lsa.Efin != lsa.[Master] 
        and lsa.Master != 0 
        and lsa.AccountID != e.Account

END

