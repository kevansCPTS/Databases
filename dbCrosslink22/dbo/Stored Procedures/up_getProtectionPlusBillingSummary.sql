-- =============================================
-- Author:		Charles Krebs
-- Create date: 2/22/2013
-- Description:	Retrieves Protection Plus Billing summary information for an account
-- =============================================
CREATE PROCEDURE [dbo].[up_getProtectionPlusBillingSummary] 
	@account varchar(8)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @PendingReturns int
	DECLARE @ApprovedUnpaidReturns int
	DECLARE @DeclinedReturns int	
	DECLARE @OpenInvoices int
	DECLARE @PriorInvoices int

	SELECT @PEndingReturns = COUNT(CASE WHEN PPR.StatusID = 1 THEN 1 END),
		@ApprovedUnpaidReturns = COUNT(CASE WHEN PPR.StatusID = 2 AND PPR.OrderNumber is null THEN 1 END),
		@DeclinedReturns = COUNT(CASE WHEN PPR.StatusID = 3 THEN 1 END)
	FROM BillableProtectionPlusReturn PPR
	INNER JOIN dbCrosslinkGlobal..tblUser ON tblUser.user_id = PPR.UserID
	WHERE account = @Account

	SELECT @OpenInvoices = Count(CASE WHEN bal_due > 0 THEN 1 END),
	@PriorInvoices = Count(CASE WHEN bal_due = 0 THEN 1 END)
	FROM dbCrosslinkGlobal..orders
	WHERE account = @Account
	AND OrderType = 'P'
	AND ord_stat in ('N', 'A', 'P', 'C')

	SELECT IsNull(@PendingReturns, 0) PendingReturns,
		IsNull(@ApprovedUnpaidReturns, 0) ApprovedUnpaidReturns,
		IsNull(@DeclinedReturns, 0) DeclinedReturns,
		IsNull(@OpenInvoices, 0) OpenInvoices,
		IsNull(@PriorInvoices, 0) PriorInvoices
END

