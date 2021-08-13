-- =============================================
-- Author:		Charles Krebs
-- Create date: 2/23/2013
-- Description:	Creates an invoice for all currently billable records in 
--   BillableProtectionPlusReturn under UserIDs belonging to the specified 
--   Account Code.  The OrderNumber of the new invoice is returned if an 
--   invoice was created.  Null is returned if there were no billable records
--   found for the specified Account Code.
--
--   This procedure will fail if: 
--        There are no billable protection plus returns
--        The product code for 'XP' cannot be found
-- =============================================
CREATE PROCEDURE [dbo].[up_createProtectionPlusInvoice] 
	@Account varchar(8), 
	@ExpectedTotal money
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET FMTONLY OFF
	DECLARE	@SEInitials varchar(20), @SEEmail varchar(50), @OrdNum int, @Season int
	DECLARE @OwnerFirstName varchar(14), @OwnerLastName varchar(20), @OwnerCompany varchar(50)
	DECLARE @OwnerAddress varchar(34), @OwnerCity varchar(20), @OwnerState varchar(2), @OwnerZip varchar(10)
	DECLARE @ShipToFirstName varchar(14), @ShipToLastName varchar(20), @ShipToCompany varchar(50)
	DECLARE @ShipToAddress varchar(34), @ShipToCity varchar(20), @ShipToState varchar(2)
	DECLARE @ShipToZip varchar(10), @ShipToPhone varchar(10), @ShipToFax varchar(10)
	DECLARE @Qty int, @Price money
	DECLARE @RunningTotal decimal(10,7), @Message varchar(250), @UserID int, @ReturnCount int
	DECLARE @ProductCode varchar(5)

	SET @ProductCode = 'XP'
	SET @Season = dbo.getXlinkSeason()
			
	/* Determine that we have some returns to bill */
	SELECT PrimarySSN, FilingStatus, UserID
	INTO #BillableReturns
	FROM BillableProtectionPlusReturn PPR
		INNER JOIN dbCrosslinkGlobal..tblUser ON tblUser.user_id = PPR.UserID
	WHERE tblUser.account = @Account
	AND OrderNumber is null
	AND StatusID = 2

	SELECT @ReturnCount = COUNT(*)
	FROM #BillableReturns

	DECLARE @ErrorMessage varchar(100)

	/* If there were no returns to bill, then there's nothing to do here. */
	IF (@ReturnCount = 0)
	BEGIN
		SET @ErrorMessage = 'No billable returns retrieved'
	END
	ELSE
	BEGIN
		/* Look up the protection plus price for this season */
		SELECT @Price = uprice
		FROM dbCrosslinkGlobal..ord_stock
		WHERE prod_cd = @ProductCode AND Season = @season

		/* If the price couldn't be determined. */
		IF @Price is null
		BEGIN
			SET @ErrorMessage = 'Unable to locate protection plus return stock item'
		END
		ELSE
		BEGIN		
			/* Gather general order details */
			SELECT  @SEInitials = l.initials, @SEEmail = memberemail, 
						@OwnerFirstName = c.fname, @OwnerLastName = c.lname, @OwnerCompany = c.company,
						@OwnerAddress = c.addr1, @OwnerCity = c.city, @OwnerState = c.state, @OwnerZip = c.zip, 
				@ShipToPhone = c.phone, @ShipToFirstName = c.fname, @ShipToLastName = c.lname,
					@ShipToCompany = c.company, @ShipToAddress = c.addr1, @ShipToCity = c.city,
					@ShipToState = c.state, @ShipToZip = c.zip, @ShipToFax = c.fax
			FROM	dbCrosslinkGlobal..ltblSalesTeamMembers stm
			INNER JOIN dbCrosslinkGlobal..logins l on l.initials = stm.initials
			INNER JOIN dbCrosslinkGlobal..leads ls on ls.lead_exec = stm.initials
			INNER JOIN dbCrosslinkGlobal..customer c on c.idx = ls.idx
			WHERE	c.account = @Account

			SELECT @UserID = MIN(user_ID)
			FROM dbCrosslinkGlobal..tblUser 
			WHERE account = @Account

			DECLARE @OrderTotal money = @ReturnCount * @Price
			
			IF (@OrderTotal != @ExpectedTotal)
			BEGIN
				SET @ErrorMessage = 'Return Count has changed, please refresh'
			END
			ELSE
			BEGIN
			
				/* Generate Quote */
				INSERT INTO Orders (ord_stat, OrderType, account, user_id, season, sales_exec, orig_by, orig_dt, edit_by, edit_dt, 
					exec_email, do_not_ship, b_fname, b_lname, b_company, b_addr1, b_city, b_state, b_zip, 
					s_phone, s_fname, s_lname, s_company, s_addr1, s_city, s_state, s_zip, s_fax, county, tax_rate, tax_amt,
					disc_pct, disc_amt, freight, ord_tot, bal_due, pmt1_amt, pmt1_dt, pmt2_amt, note1)
				VALUES	('P', 'P', @Account, @UserId, @Season, @SEInitials, 'webportal', getdate(), 'webportal', getdate(),
						 @SEEmail, 'X', @OwnerFirstName, @OwnerLastName, @OwnerCompany, @OwnerAddress, @OwnerCity, 
						 @OwnerState, @OwnerZip, @ShipToPhone, @ShipToFirstName, @ShipToLastName, @ShipToCompany, @ShipToAddress, 
						 @ShipToCity, @ShipToState, @ShipToZip, @ShipToFax, '---', 0, 0, 0, 0, 0, @OrderTotal, @ReturnCount * @Price, 0, null, null,
						 'DO NOT SHIP - Protection Plus Invoice')
				
				SET @OrdNum = SCOPE_IDENTITY()
				
				/* Insert the protection plus item for the order */
				INSERT INTO ord_items 
				(ord_num, prod_cd, qty, uprice, bank_id, ship_via, bank_stat)
				VALUES (@OrdNum, @ProductCode, @ReturnCount, @Price, 'U', 'BLUE', '')

				/* Update returns with order number and generate Order Item for Return Count */
				UPDATE PPR 
				SET OrderNumber = @OrdNum
				FROM BillableProtectionPlusReturn PPR
					INNER JOIN #BillableReturns ON #BillableReturns.PrimarySSN = PPR.PrimarySSN 
							AND #BillableReturns.UserID = PPR.UserID
							AND #BillableReturns.FilingStatus = PPR.FilingStatus
			END
		END
	END
		
	DROP TABLE #BillableReturns
	SELECT (CASE WHEN @ErrorMessage is null THEN 1 ELSE 0 END) Success, @OrdNum OrderNumber, IsNull('', 0) Message

END


