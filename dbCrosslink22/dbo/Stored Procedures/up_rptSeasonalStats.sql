CREATE procedure [dbo].[up_rptSeasonalStats]
	@LoginID     varchar(8) --can be for account, franchise, or user
AS
	SET NOCOUNT ON

	declare @season smallint = dbo.getXlinkSeason()

	SELECT  
		dbo.PadString(dfa.EFIN, '0', 6) 'EFIN'
	,   dfa.UserID 'User ID'
	,   SUM(efiles) 'Total E-Files'
	,   SUM(StateEfiles) 'Total State E-Files'
	,   SUM(acks) 'Total Federal Acknowledges'
	,   SUM(Rejects) 'Total Federal Rejects'
	,   SUM(stateAcks) 'Total State Acknowledges'
	,   SUM(stateRejects) 'Total State Rejects'
	,   SUM(SubmittedBankProducts) 'Submitted Bank Products'
	,   SUM(FundedBankProducts) 'Funded Bank Products'
	FROM dbCrosslinkGlobal.dbo.tblDailyFilingActivity dfa
	JOIN dbo.udf_GetUserIDs(@LoginID) uids ON uids.user_id = dfa.UserID
	WHERE Season = @season
	AND DATE >= CONVERT(DATE, '1/1/' + STR(@season, 4), 101)
	GROUP BY dfa.userid, dfa.EFIN
	ORDER BY dfa.userid, dfa.EFIN