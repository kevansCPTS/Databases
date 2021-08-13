CREATE PROCEDURE [dbo].[up_processProtectionPlusReturns] 

AS


	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	CREATE TABLE #BillableReturns
	(PrimarySSN int, 
	 UserID int, 
	 FilingStatus tinyint, 
	 GUID varchar(255),
	 SBFee money, 
	 PEIProtPlusFee money)

	INSERT #BillableReturns
		exec up_getNonBankProductReturns
	
	
	INSERT BillableProtectionPlusReturn 
		(PrimarySSN, UserID, FilingStatus, UpdatedBy)



	/* This collects the returns to be placed in BillableProtectionPlusReturn */
	SELECT #BillableReturns.PrimarySSN, #BillableReturns.UserID, #BillableReturns.FilingStatus, 
		'System' UpdatedBy
	FROM #BillableReturns
		INNER JOIN dbCrosslinkGlobal..tblUser ON tblUser.user_id = #BillableReturns.UserID
		LEFT JOIN BillableProtectionPlusReturn PPR ON PPR.userID = #BillableReturns.UserID 
			AND PPR.FilingStatus = #BillableReturns.FilingStatus
			AND PPR.PrimarySSN = #BillableReturns.PrimarySSN
	WHERE PPR.PrimarySSN is null -- Don't Bill for already billed returns
		AND (#BillableReturns.PEIProtPlusFee > 0)
	ORDER BY #BillableReturns.PrimarySSN
		
	
	DROP TABLE #BillableReturns
