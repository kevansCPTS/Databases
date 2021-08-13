-- =============================================
-- Author:		Charles Krebs
-- Create date: 3/14/2013
-- Description:	Retrieves the details for BillableProtectionPlusReturn
-- records for the specified Account with the specified StatusID
-- Update 3/14/2013
--	Added optional UserID parameter
-- =============================================
CREATE PROCEDURE [dbo].[up_insertProtectionPlusPrepayment] 
	@OrderNumber int, 
	@PaymentAmount money,
	@UpdateBy varchar(11)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Account varchar(8)
	DECLARE @BalanceDue money
	DECLARE @PassthroughTotal money
	DECLARE @PassthroughAvailable money
	DECLARE @leadIndex int
	DECLARE @referenceID int
	DECLARE @Season int


	SELECT @Account = Account, 
	@BalanceDue = bal_due,
	@Season = Season
	FROM dbCrosslinkGlobal..orders 
	WHERE ord_num = @OrderNumber


	/* If we could not locate the Order, exit */
	IF (@Account is null OR @BalanceDue is null OR @Season is null)
	BEGIN
		SELECT 0 AS Success, 'Error retrieving invoice' Message	
		RETURN
	END
	/* If BalanceDue is not positive, exit */
	IF (@BalanceDue <= 0)
	BEGIN
		SELECT 0 AS Success, 'Invoice has no balance due' Message	
		RETURN
	END
	/* If PaymentAmount is invalid, exit */
	IF (@PaymentAmount <= 0)
	BEGIN
		SELECT 0 AS Success, 'Invalid payment amount' Message	
		RETURN
	END

	/* If BalanceDue is less than payment amount, exit */
	IF (@BalanceDue < @PaymentAmount)
	BEGIN
		SELECT 0 AS Success, 'Balance Due less than payment amount' Message	
		RETURN
	END


	

	/* Insert the payment */
	INSERT INTO dbCrosslinkGlobal..mo_payment 
	(ord_num, amount, mo_date, mo_number) 
	VALUES (@OrderNumber, @PaymentAmount, getDate(), 'Prot Plus Payment')
	 

	/* Log this as a payment to Protection Plus, to avoid overpaying them later */
	INSERT INTO ProtectionPlusPayment
	(PaymentAmount, PaymentDate, PaymentNote, PaymentBy)
	VALUES
	(@PaymentAmount, GETDATE(), 'Return payments for ' + @Account, @UpdateBy)
	 
	 /* Retrieve the lead index for the account */
	SELECT @leadIndex = idx
	FROM customer 
	WHERE account = @Account

	 /* Log the payment in the lead history */
	 INSERT INTO dbCrosslinkGlobal..history (idx, login, hist_dt, action_cd, result_cd, quantity)
	 VALUES
	 (@leadIndex, @updateBy, GETDATE(), 'Q', 'J', @OrderNumber)
	 

	 /* Recalculate the current balance due for this order */
	 exec dbCrosslinkGlobal..up_calculateOrderBalanceDue @OrderNumber

	 SELECT 1 AS Success, 'Payment Processed' Message
END



