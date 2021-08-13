
-- =============================================
-- Author:		Sundeep Brar
-- =============================================
CREATE PROCEDURE [dbo].[up_rptEROMarkupReportPriorVersion]

AS

DECLARE @Season SMALLINT

    set nocount on 

    SET @Season = '20' + right(db_name(),2)

    SELECT
	    efin.Efin						priorEfin			
    ,	(CASE
		    WHEN Cast(App.EROTranFee as float)/ Cast(100 as float) < Cast(2 as float) 
			    THEN Cast(App.EROTranFee as float)/ Cast(100 as float)
		    WHEN Cast(App.EROTranFee as float)/ Cast(100 as float) < Cast(11.01 as float) 
			    THEN (Cast(App.EROTranFee as float)/ Cast(100 as float)) - Cast(1 as float)
		    WHEN Cast(App.EROTranFee as float)/ Cast(100 as float) < Cast(22.01 as float) 
			    THEN (Cast(App.EROTranFee as float)/ Cast(100 as float)) - Cast(2 as float)
		    WHEN Cast(App.EROTranFee as float)/ Cast(100 as float) < Cast(33.01 as float) 
			    THEN (Cast(App.EROTranFee as float)/ Cast(100 as float)) - Cast(3 as float)
		    WHEN Cast(App.EROTranFee as float)/ Cast(100 as float) < Cast(44.01 as float) 
			    THEN (Cast(App.EROTranFee as float)/ Cast(100 as float)) - Cast(4 as float)
		    WHEN Cast(App.EROTranFee as float)/ Cast(100 as float) < Cast(55.01 as float) 
			    THEN (Cast(App.EROTranFee as float)/ Cast(100 as float)) - Cast(5 as float)
		    WHEN Cast(App.EROTranFee as float)/ Cast(100 as float) < Cast(66.01 as float) 
			    THEN (Cast(App.EROTranFee as float)/ Cast(100 as float)) - Cast(6 as float)
		    ELSE (Cast(App.EROTranFee as float)/ Cast(100 as float)) - Cast(7 as float)
	    END)							priorAddonFee
    ,	ISNULL(App.NetEFFee/100, 0)		priorEFilesFee
    ,	App.SBPrepFee/100				priorSBPrepFee
    ,	ISNULL(TAAPCP.agreeToTerms,0)	priorCheckPrintFee
    ,	App.Bank						priorYearBank
	,	isnull(dfa.totAcks, 0)			priorYearAcks
	,	isnull(dfa.submittedBPs, 0)		priorYearSubmittedBPs
	,	isnull(dfa.fundedBPs, 0)		priorYearFundedBPs
	,	convert(money, App.CPTSAdminFee/100.0) + isnull(dfa.fundedBPs, 0) priorYearExpectedAdminFee
	,	convert(money, App.CPTSAdminEFFee/100.0) + isnull(dfa.fundedBPs, 0) priorYearExpectedAdminEFFee
    FROM
	    efin efin
	    JOIN vwLatestSubmittedApplication App on efin.Efin = App.Efin AND efin.SelectedBank = App.BankID
	    LEFT JOIN tblAccountAncillaryProduct TAAPCP ON TAAPCP.account = App.AccountID AND TAAPCP.tag = 'CAF' and TAAPCP.agreeToTerms = 1	 
		LEFT JOIN (
			SELECT	UserID
			,		EFIN
			,		Sum(Acks)					totAcks
			,		Sum(SubmittedBankProducts)	submittedBPs
			,		Sum(FundedBankProducts)		fundedBPs
			FROM	dbCrosslinkGlobal..tblDailyFilingActivity
			WHERE	Season = @Season
			GROUP BY UserID, EFIN
		) dfa on dfa.UserID = App.UserID and dfa.EFIN = app.Efin