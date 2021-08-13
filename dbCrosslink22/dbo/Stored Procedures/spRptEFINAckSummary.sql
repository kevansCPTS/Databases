

CREATE PROC [dbo].[spRptEFINAckSummary]
	@LoginType varchar(20), --account or franchise
	@Userid int = null,
	@AccountId varchar(10) = null,
	@DateType int = 1, --1 = File Date, 2 = IRS Ack Date
	@StartDate datetime,
	@EndDate datetime
AS

	Select TM.user_id 'User ID', 
		dbo.PadString(TM.EFIN, '0', 6) EFIN, 
		Count(Distinct TM.PSSN) Total, 
		Count(Case when TM.irs_acc_cd = 'A' and ral_flag not in (3,5,6) then 1 end) 'Non Financial Acks',
		Count(Case when TM.irs_acc_cd = 'A' and ral_flag in (3,5,6) then 1 end) 'Financial Acks',
		Count(Case when TM.isFullyFunded = 1 then 1 end) 'Funded Financial Returns'
	from tblTaxmast TM with (nolock)
	inner join vwUser US with (nolock) on TM.user_id = US.user_id 
	where ((@LoginType = 'account' AND US.account = @AccountId) OR
			(@LoginType = 'franchise' AND (US.ParentUserID = @Userid OR US.user_id = @Userid)))
		AND TM.submissionid != ''
		AND
		(@StartDate is null OR @StartDate <= (CASE @DateType WHEN 1 THEN fdate WHEN 2 THEN irs_ack_dt END))
		AND
		(@EndDate is null OR @EndDate >= (CASE @DateType WHEN 1 THEN fdate WHEN 2 THEN irs_ack_dt END))
	Group by TM.efin, TM.user_id
	
