
CREATE PROC [dbo].[spMobileReportEFIN]
	@EFIN int
AS
SELECT COUNT(TM.pssn) AS Total, 
	COUNT(CASE WHEN TM.irs_acc_cd = 'A' THEN TM.pssn END) AS Acks, 
	COUNT(CASE WHEN TM.irs_acc_cd = 'R' THEN TM.pssn END) AS Rejects, 
	COUNT(CASE WHEN (TM.irs_acc_cd <> 'A' AND TM.irs_acc_cd <> 'R') THEN TM.pssn END) AS Other, 
	COUNT(CASE WHEN TM.ral_flag = 3 THEN TM.pssn END) AS Rals, 
	COUNT(CASE WHEN TM.ral_flag = 5 THEN TM.pssn END) AS Racs, 
	TM.user_id, US.Booked, US.Paid 
FROM tblTaxmast AS TM WITH (NOLOCK), 
(SELECT ISNULL(SUM(paid_amt),0) AS Paid, ISNULL(SUM(booked_amt), 0) AS Booked 
	FROM efin_stats WHERE efin = @EFIN AND season = 2014) AS US 
WHERE TM.efin = @EFIN 
GROUP BY Us.Paid, US.Booked, TM.user_id

