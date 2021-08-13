

--CREATE
CREATE PROC [dbo].[spRptRejectedReturns]
	@LoginType varchar(20), --account or franchise
	@Userid int = null,
	@AccountId varchar(10) = null,
	@StartDate datetime,
	@EndDate datetime
AS

	declare @FILING_STATUS_LOOKUP_TYPE int = 15
	select 
		dbo.PadString(TM.efin,'0',6) AS EFIN
		, dbo.PadString(TM.pssn,'0',9) AS SSN
		, LU.LookupDescription AS 'FilingStatus'
		, LTRIM(RTRIM(TM.pri_lname)) AS pri_lname
		, LTRIM(RTRIM(TM.pri_fname)) AS pri_fname
		, TM.fdate
		, TM.irs_ack_dt
		, E.ErrorID
		, LTRIM(RTRIM(E.ErrorCategory)) AS ErrorCategory
		, LTRIM(RTRIM(E.ErrorMessage)) as ErrorMessage
	from tbltaxmast TM With (nolock)
	inner join vwUser US With (nolock) on TM.user_id = US.user_id
	inner join tblLookup LU on TM.filing_stat = LU.LookupID And LU.LookupTypeID = @FILING_STATUS_LOOKUP_TYPE
	left join MEFError E on TM.pssn = E.primid
	where ((@LoginType = 'account' AND US.account = @AccountId) OR
					(@LoginType = 'franchise' AND (US.ParentUserID = @Userid OR US.user_id = @Userid)))
	AND irs_acc_cd='R'
	AND
	(@StartDate is null OR @StartDate <= irs_ack_dt)
	AND
	(@EndDate is null OR @EndDate >= irs_ack_dt)
	ORDER BY TM.pssn	
