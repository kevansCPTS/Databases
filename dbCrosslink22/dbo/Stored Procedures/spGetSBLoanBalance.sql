-- =============================================
-- Author:		Charles Krebs
-- Create date: 12/28/2012
-- Description:	Returns the amount currently owed by the parameter Account.  
-- =============================================
CREATE PROCEDURE [dbo].[spGetSBLoanBalance] 
	@account varchar(8),
	@LoanBalance money output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @LoanAmount money
	DECLARE @PriorPayments money
	
	SELECT @LoanAmount = LoanAmount
	FROM tblSBLoans 
	WHERE Account = @account
	
	SELECT @PriorPayments = SUM(Amount)
	FROM tblFeeOptionBalance
	INNER JOIN efin ON efin.EFIN = tblFeeOptionBalance.EFIN
	WHERE efin.Account = @account
	AND RecordType = 5
	
	SET @LoanBalance = ISNULL(@LoanAmount, 0) - ISNULL(@PriorPayments, 0)
    

END


