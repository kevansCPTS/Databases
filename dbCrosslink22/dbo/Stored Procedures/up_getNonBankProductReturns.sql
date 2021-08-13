-- =============================================
-- Author:		Charles Krebs
-- Create date: 3/11/2013
-- Description:	Returns a table containing all Billable returns for non-bank products
--	Update Charles Krebs 5/1/2013 
--		Added logic to include non-bank product MSO returns that are acked
-- =============================================
CREATE PROCEDURE [dbo].[up_getNonBankProductReturns] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	

	CREATE TABLE #br1
	(PrimarySSN int, 
	 UserID int,
	 FilingStatus tinyint,
	 GUID varchar(255),
	 SBFee int,
	 PEIProtPlusFee int,
	 RowID int)

	INSERT #br1
	
	/* If one of the returns was e-filed and acked (taxmaster.irs_ack_cd = 'A'), we always want that one, otherwise we 
		want the record with the earliest timestamp. This is for crosslink only*/
	select	a.PrimarySSN, a.UserID, a.FilingStatus, a.GUID, a.SBFee,
		a.PEIProtPlusFee, 
		RANK() over (partition by a.GUID order by 
		(CASE WHEN c.irs_acc_cd = 'A' THEN 0 ELSE 1 END) asc, 
		A.recTS asc) RowID
	from tblReturnMaster a  (nolock)
		LEFT JOIN tblTaxmast c with (nolock) ON a.PrimarySSN=c.pssn AND
			a.userID = c.user_id AND a.FilingStatus = c.filing_stat
	where  
		(
			(ISNULL(c.ral_flag, 0) != 5 AND c.irs_acc_cd = 'A') OR
			(PrintFinal is not null AND IsNull(c.irs_acc_cd, ' ') != 'A')
		)
		AND a.BankProductAttached=0
		AND a.UserID < 995000
		

	INSERT #br1
	/* For MSO and Taxbrain, we want to include recrods with no bank product, 
		a PEI Prot Plus Fee and a Paper File transaction. */
	select	a.PrimarySSN, a.UserID, a.FilingStatus, a.GUID, A.SBFee, 
		A.PEIProtPlusFee,
		1 RowID
	from tblReturnMaster a  (nolock)
	INNER JOIN tblTaxmast c with (nolock) ON a.PrimarySSN=c.pssn AND
			a.userID = c.user_id AND a.FilingStatus = c.filing_stat
	INNER JOIN taxbrain14..vwTransactionSummary TS ON Ts.ReturnID = C.rtn_id
	where 
		-- Return is an MSO return
		c.user_id > 995000 
		-- ReturnMaster says there's no bank product
		AND a.BankProductAttached=0 
		-- Taxmaster says there's no bank product
		AND c.ral_flag != 5
		-- Return was Paper Filed or acknowledged
		AND (TS.PaperFileDate is not null OR c.irs_acc_cd = 'A')
		
		
	SELECT PrimarySSN, UserID, FilingStatus, GUID, 
		Cast(IsNull(SBFee, 0) as Money) / 100 SBFee, 
		CAST(IsNull(PEIProtPlusFee, 0) AS Money) / 100 PEIProtPlusFee
	FROM #br1
	WHERE RowID = 1
	
	DROP TABLE #br1
END
