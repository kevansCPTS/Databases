
-- =============================================
-- Author:		Sundeep Brar
-- This stored procedure will grab the bank application information for the currnet year for the EROMarkupReport
-- =============================================
CREATE PROCEDURE [dbo].[up_rptEROMarkupReportCurrentVersion]

AS

DECLARE @Season SMALLINT

    set nocount on

    SET @Season = '20' + right(db_name(),2)

    SELECT
	    App.AccountID					accountID
    ,	App.UserID						userID
    ,	App.Efin						efin
    ,	ch.parentAccount				parentAccount
    ,	CONCAT(lg.fname, ' ', lg.lname)	accountRep
    ,	Customer.CustomerSize			customerSize
    ,	(CASE VIP.vip_stat 
		    WHEN 'Y' THEN 'VIP' 
		    WHEN 'P' THEN 'Platinum' 
		    ELSE '' END) 				vipSize
    ,	App.Bank						Bank
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
	    END)							AddonFee
    ,	ISNULL(App.CPTSAdminFee, 0)		CPTSAdminFee
	,	ISNULL(App.CPTSAdminEFFee, 0)	CPTSAdminEFFee
    ,	ISNULL(App.NetEFFee / 100, 0)	eFilesFee
    ,	App.SBPrepFee/100				SBPrepFee
    ,	ISNULL(TAAPCP.agreeToTerms,0)	checkPrintFee
    ,	ISNULL(TAAPRS.agreeToTerms, 0)	RemoteSig
    ,	ISNULL(XUP.eroAddonFee, 0)		currentRemoteSigFee
	,	App.UpdatedDate					UpdatedDate
	,	isnull(dfa.totAcks, 0)			totalAcks
	,	isnull(dfa.submittedBPs, 0)		submittedBPs
	,	isnull(dfa.fundedBPs, 0)		fundedBPs
	,	convert(money, App.CPTSAdminFee/100.0) * isnull(dfa.fundedBPs, 0) expectedAdminFee
	,	convert(money, App.CPTSAdminEFFee/100.0) * isnull(dfa.fundedBPs, 0) expectedAdminEFFee
    FROM
	    vwLatestSubmittedApplication App
	    LEFT JOIN dbCrosslinkGlobal.dbo.tblCustomerHierarchy CH on App.AccountID = CH.childAccount and CH.season = @Season
	    LEFT JOIN dbCrosslinkGlobal.dbo.SeasonalLeadExecutive SLE ON App.AccountID = SLE.AccountCode AND SLE.Season = @Season
	    LEFT JOIN dbCrosslinkGlobal.dbo.customer Customer ON Customer.account = App.AccountID
	    LEFT JOIN dbCrosslinkGlobal.dbo.vip VIP ON VIP.idx = Customer.idx
	    LEFT JOIN tblAccountAncillaryProduct TAAPCP ON TAAPCP.account = App.AccountID AND TAAPCP.tag = 'CAF' and TAAPCP.agreeToTerms = 1	 
	    LEFT JOIN tblAccountAncillaryProduct TAAPRS ON TAAPRS.account = App.AccountID AND TAAPRS.tag = 'RMS' and TAAPRS.agreeToTerms = 1	
	    LEFT JOIN tblXlinkUserProducts XUP on App.AccountID = XUP.account and App.UserID = XUP.userID and XUP.tag = 'RMS' 
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
		LEFT JOIN dbCrosslinkGlobal.dbo.logins lg on lg.initials = SLE.LeadExec
    ORDER BY
	    App.AccountID,
	    App.Efin,
	    App.Bank

