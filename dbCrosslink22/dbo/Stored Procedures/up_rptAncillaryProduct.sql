
CREATE procedure [dbo].[up_rptAncillaryProduct] --'AMOAND', 'Ancillary Product Detail'
	@account		varchar(8)
,	@reportName		varchar(150)
as

	set nocount on
	DECLARE @FILING_STATUS_LOOKUP_TYPE INT = 15

	select 
		dbo.PadString(tm.pssn,'0',9) AS PrimarySSN
	,	ap.[name] Product
	,	tm.[user_id] UserID
	,	dbo.PadString(tm.efin,'0',6) AS EFIN
	,	lu.LookupDescription AS 'FilingStatus'
	,	u.account Account
	,	e.Company
	,	LTRIM(RTRIM(tm.pri_fname)) PrimaryFirstName
	,	LTRIM(RTRIM(tm.pri_lname)) PrimaryLastName
	,	tm.submissionid
	,	tm.irs_ack_dt AckDate
	,	'Bank Product' BillingType 
	,	ap.ancillaryFeeRequested FeesRequested 
	,	ap.ancillaryFeePaid FeesPaid
	,	case
			when ap.ancillaryFeePaid >= ap.ancillaryFeeRequested then 'Fully Funded'
			else 'Unfunded'
		end PaymentStatus
	,	case
			when ap.ancillaryFeePaid >= ap.ancillaryFeeRequested then convert(char(10), ap.ancillaryFeePaidDate, 110)
			else ''
		end PaymentDate 
	,	LTRIM(RTRIM(tm.[address])) AS address
	,	LTRIM(RTRIM(tm.city)) AS city
	,	tm.[state] 
	,	substring(tm.zip, 1, 9) Zip 
	,	case
			when tm.irs_acc_cd = 'A' then 'Approved'
			else 'Requested'
		end ancillaryStatus
	from
		dbo.tblTaxmast tm join (
									select
										tf1.pssn
									,	sum(tf1.reqAmount) ancillaryFeeRequested
									,	sum(tf1.payAmount) ancillaryFeePaid
									,	max(tf1.payDate) ancillaryFeePaidDate
									,	ap1.company
									,	ap1.[name]
									from
										dbo.tblAncillaryProductReports apr1 join dbo.tblAncillaryProduct ap1 on apr1.aprodId = ap1.aprodId
											and apr1.account = @account
											and apr1.reportName = @reportName
										join dbo.tblTaxmastFee tf1 on ap1.aprodId = tf1.aprodId
									group by
										tf1.pssn
									,	ap1.company
									,	ap1.[name]
							   ) ap on tm.pssn = ap.pssn
			and tm.ral_flag = 5
		join dbCrosslinkGlobal.dbo.tblUser u on tm.[user_id] = u.[user_id]
		left join dbo.efin e on tm.EFIN = e.Efin
		INNER JOIN tblLookup lu WITH (NOLOCK) ON tm.filing_stat = lu.LookupID And lu.LookupTypeID = @FILING_STATUS_LOOKUP_TYPE

