

CREATE PROC [dbo].[up_rptRejectedReturns]
	@LoginID varchar(8), --can be for account, franchise, or user
	@StartDate datetime,
	@EndDate datetime
AS
	SET NOCOUNT ON

	declare @FILING_STATUS_LOOKUP_TYPE int = 15

	select 
		  dbo.PadString(TM.efin,'0',6) AS EFIN
		, dbo.udf_MaskSSN(TM.pssn) AS SSN
		, LU.LookupDescription AS 'FilingStatus'
		, LTRIM(RTRIM(TM.pri_lname)) AS pri_lname
		, LTRIM(RTRIM(TM.pri_fname)) AS pri_fname
		, TM.fdate
		, TM.irs_ack_dt
		, E.ErrorID
		, LTRIM(RTRIM(E.ErrorCategory)) AS ErrorCategory
		, LTRIM(RTRIM(E.ErrorMessage)) as ErrorMessage
	from dbo.tbltaxmast TM With (nolock)
	JOIN dbo.udf_GetUserIDs(@LoginID) uids on uids.user_id = TM.user_id
	inner join dbo.tblLookup LU on TM.filing_stat = LU.LookupID And LU.LookupTypeID = @FILING_STATUS_LOOKUP_TYPE
	left join dbo.MEFError E on TM.pssn = E.primid
	where irs_acc_cd='R'
	AND
	(@StartDate is null OR @StartDate <= irs_ack_dt)
	AND
	(@EndDate is null OR @EndDate >= irs_ack_dt)
	ORDER BY TM.pssn	

