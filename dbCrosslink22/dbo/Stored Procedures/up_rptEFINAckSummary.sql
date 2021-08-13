

CREATE PROC [dbo].[up_rptEFINAckSummary]
	@LoginID varchar(8), --can be for account, franchise, or user
	@DateType int = 1, --1 = File Date, 2 = IRS Ack Date
	@StartDate datetime,
	@EndDate datetime
AS
	SET NOCOUNT ON

	SELECT TM.user_id 'User ID', 
		dbo.PadString(TM.EFIN, '0', 6) EFIN, 
		Count(DISTINCT TM.PSSN) Total, 
		Count(Case when TM.irs_acc_cd = 'A' and ral_flag not in (3,5,6) then 1 end) 'Non Financial Acks',
		Count(Case when TM.irs_acc_cd = 'A' and ral_flag in (3,5,6) then 1 end) 'Financial Acks',
		Count(Case when TM.isFullyFunded = 1 then 1 end) 'Funded Financial Returns'
	FROM dbo.tblTaxmast TM 
	JOIN dbo.udf_GetUserIDs(@LoginID) uids ON uids.user_id = TM.user_id
	WHERE TM.submissionid != ''
		AND
		(@StartDate is null OR @StartDate <= (CASE @DateType WHEN 1 THEN fdate WHEN 2 THEN irs_ack_dt END))
		AND
		(@EndDate is null OR @EndDate >= (CASE @DateType WHEN 1 THEN fdate WHEN 2 THEN irs_ack_dt END))
	GROUP BY TM.efin, TM.user_id


