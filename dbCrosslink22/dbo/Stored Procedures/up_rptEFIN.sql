

CREATE PROC [dbo].[up_rptEFIN]
	@EFIN int
AS
	SET NOCOUNT ON

	SELECT COUNT(TM.pssn) AS Total, 
		COUNT(CASE WHEN TM.irs_acc_cd = 'A' THEN TM.pssn END) AS Acks, 
		COUNT(CASE WHEN TM.irs_acc_cd = 'R' THEN TM.pssn END) AS Rejects, 
		COUNT(CASE WHEN (TM.irs_acc_cd <> 'A' AND TM.irs_acc_cd <> 'R') THEN TM.pssn END) AS Other, 
		COUNT(CASE WHEN TM.ral_flag = 3 THEN TM.pssn END) AS Rals, 
		COUNT(CASE WHEN TM.ral_flag = 5 THEN TM.pssn END) AS Racs, 
		COUNT(CASE WHEN TM.ral_flag = 1 THEN TM.pssn END) AS Paper, 
		COUNT(CASE WHEN TM.ral_flag = 4 THEN TM.pssn END) AS BDue, 
		COUNT(CASE WHEN TM.ral_flag = 2 THEN TM.pssn END) AS Direct, 
		ISNULL(SUM(CAST (ISNULL(TM.tax_prep_fee, 0) AS MONEY)) / 100, 0) AS Booked,
		ISNULL(SUM(CAST (ISNULL(TM.fee_pay_amt, 0) AS MONEY)) / 100, 0) AS Paid,
		TM.user_id
	FROM dbo.tblTaxmast AS TM
	WHERE TM.efin = @EFIN 
	GROUP BY TM.user_id


