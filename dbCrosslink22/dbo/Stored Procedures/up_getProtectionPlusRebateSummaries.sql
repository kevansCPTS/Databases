
-- =============================================
-- Author:		Charles Krebs
-- Create date: 4/2/2013
-- Description:	Retrieve the protection plus rebate report
-- =============================================
-- 4/9/2013 Tim Gong added left join to ProtPlusRebate
-- 5/13/2013 Charles Krebs Added Cut off date parameter and updated to use
--		tblProtectionPlusReturn
CREATE PROCEDURE [dbo].[up_getProtectionPlusRebateSummaries] 
@CutOff date = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/* Protection Plus Deposit Deficiencies */

SELECT Account, 
SUM(CASE WHEN RecordType = 2 THEN Amount ELSE 0 END) ProtectionPlusInvoiced,
SUM(CASE WHEN RecordType = 4 THEN Amount ELSE 0 END) - 
SUM(CASE WHEN RecordType = 5 THEN Amount ELSE 0 END) AS ProtectionPlusPaid, 
SUM(CASE WHEN RecordType = 4 THEN Amount ELSE 0 END) Payments,
SUM(CASE WHEN RecordType = 5 THEN Amount ELSE 0 END) SBLoanInvoices, 
SUM(CASE WHEN RecordType = 2 THEN Amount ELSE 0 END) - 
(SUM(CASE WHEN RecordType = 4 THEN Amount ELSE 0 END) - 
SUM(CASE WHEN RecordType = 5 THEN Amount ELSE 0 END)) ProtectionPlusOwed
INTO #FeeOptionPayments
FROM tblFeeOptionBalance
	INNER JOIN efin on efin.efin = tblFeeOptionBalance.EFIN
GROUP BY account


SELECT Account, COUNT(*) PolicyCount
INTO #PPReturns
FROM tblProtectionPlusReturns
WHERE DateDiff(dd, PaymentDate, ISNULL(@CutOff, PaymentDate)) >= 0
GROUP BY Account

SELECT account
,SUM(IsNull(ProtPlusRebate.RebateCount, 0)) PostedRebateCount
,SUM(IsNull(ProtPlusRebate.RebateAmount, 0)) PostedRebateAmount
INTO #ProtPlusRebate
FROM ProtPlusRebate
GROUP BY account



SELECT #PPReturns.Account, PolicyCount, 
(CASE WHEN ProtPlusCustomRebate.account IS null THEN ProtPlusTiers.RebateRate ELSE ProtPlusCustomRebate.RebateRate END) RebateRate,
(CASE WHEN ProtPlusCustomRebate.account IS null THEN 'Standard' ELSE 'Custom' END) RebateSchedule,
PolicyCount * 
(CASE WHEN ProtPlusCustomRebate.account IS null THEN ProtPlusTiers.RebateRate ELSE ProtPlusCustomRebate.RebateRate END) RebateAmount, 
IsNull(#FeeOptionPayments.ProtectionPlusOwed, 0) FeeOptionShortage
,IsNull(#ProtPlusRebate.PostedRebateCount, 0) PostedRebateCount
,IsNull(#ProtPlusRebate.PostedRebateAmount, 0) PostedRebateAmount

FROM #PPReturns
LEFT JOIN ProtPlusCustomRebate ON #PPReturns.account = ProtPlusCustomRebate.account
LEFT JOIN ProtPlusTiers ON IsNull(ProtPlusTiers.MinVolume, PolicyCount) <= PolicyCount
	AND IsNull(ProtPlusTiers.MaxVolume, PolicyCount) >= PolicyCount
LEFT JOIN #FeeOptionPayments ON #FeeOptionPayments.Account = #PPReturns.account
		AND ProtectionPlusOwed > 0 AND ProtectionPlusInvoiced > 0
left join #ProtPlusRebate ON #ProtPlusRebate.account = #PPReturns.account

ORDER BY PolicyCount

DROP TABLE #FeeOptionPayments
DROP TABLE #ProtPlusRebate
DROP TABLE #PPReturns
END


