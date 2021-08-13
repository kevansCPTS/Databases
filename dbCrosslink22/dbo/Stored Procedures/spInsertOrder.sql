-- ==========================================================
-- Author:		Chuck Robertson
-- Create date: 9/20/2010
-- Description:	Generate Order records:  FFF and 2011 XLS
-- Update: Prevented the date field from being populated in the ord_items table 
--			** 12/10/2010 - Charles Krebs & Tim Gong
-- Update: Set package pricing to $0.  12/15/2010 - Charles Krebs
-- Update: Initialize spProcessOrder for each order. 12/16/2010 - Charles Krebs & Tim Gong
-- Update: Updated for tax year 2011 - Jay Willis
-- Update: Removed Crosslink order and change FFF for current season  4/2/2012
-- Update: Increased size of owner address and ship to address from 34 characters to 50 4/25/2012 - Charles Krebs
-- Update: Replaced portions to create both a FFF for the prior season and a
--		   standard order for the current season - 8/6/2012 Charles Krebs
-- Update: Updated process to add sub-items of fly for free product for prior season 11/9/2012 - Charles Krebs
-- Update: Added logic to ignore prior orders that were Cancelled, Refunded, or Refunds 1/4/2013 - Charles Krebs
-- Update: Changed Lead Executive lookup process to look at vwLeadExecutive
--		Changed from active sales season (XLS Current Year and FFF Prior) to FFF Current year only - 3/25/2013 Charles Krebs
-- Update: Excluded email notification from DEV and QA. Added a third parameter to override that suppression.
--		10/24/2013 KJE 
-- Update: Migrated all the view updates to point to the actual tables in dbCrosslinkGlobal
--		11/12/2013 KJE 
-- Update: Added parameters and logic to support business product activation 1/2/2014 Charles Krebs
-- Update: Added parameter for Prior Year FFF 4/9/2014 Jay Willis
-- Update: will send prior year FFF for all years back to 2012 4/15/2014 Jay Willis
-- Update: Deleted most of the work in here and simplified the procedure 7/2/2014 Charles Krebs
-- ==========================================================
CREATE PROCEDURE [dbo].[spInsertOrder]
	@Account	varchar(8),
	@UserId		int,
	@overrideMailSuppress	bit = 0,
	@includeFederalPackage bit = 1,
	@includeBusinessPackage bit = 0,
	@includePriorYearFFF bit = 1

AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE	@SEInitials varchar(20), @SEEmail varchar(50), @OrdNum int, @Season int
	DECLARE @OwnerFirstName varchar(14), @OwnerLastName varchar(20), @OwnerCompany varchar(50)
	DECLARE @OwnerAddress varchar(34), @OwnerCity varchar(20), @OwnerState varchar(2), @OwnerZip varchar(10)
	DECLARE @ShipToFirstName varchar(14), @ShipToLastName varchar(20), @ShipToCompany varchar(50)
	DECLARE @ShipToAddress varchar(34), @ShipToCity varchar(20), @ShipToState varchar(2)
	DECLARE @ShipToZip varchar(10), @ShipToPhone varchar(10), @ShipToFax varchar(10)
	DECLARE @Message varchar(250)

	SET @Message = ''
	
	-- Is this a VTax User, if so then get out.
	If @UserID > 990000
		RETURN

	SET @Season = dbo.getXlinkSeason()
	
	IF @includeFederalPackage = 1 AND Exists(SELECT * FROM dbCrosslinkGlobal..orders o
			INNER JOIN dbCrosslinkGlobal..ord_items i ON o.ord_num = i.ord_num
			WHERE o.user_id = @UserId 
			and o.season = @Season
			AND i.prod_cd = 'USTP'
			AND i.qty > 0
			AND o.ord_stat not in ('W', 'X', 'R'))
	BEGIN
		-- Federal should already be active
		SET @includeFederalPackage = 0
	END
	
	IF @includeBusinessPackage = 1 AND Exists(SELECT * FROM dbCrosslinkGlobal..orders o
			INNER JOIN dbCrosslinkGlobal..ord_items i ON o.ord_num = i.ord_num
			WHERE o.user_id = @UserId 
			and o.season = @Season
			AND i.prod_cd = 'BUS'
			AND i.qty > 0
			AND o.ord_stat not in ('W', 'X', 'R'))
	BEGIN
		-- Business should already be active
		SET @includeBusinessPackage = 0
	END
	
	IF @includeBusinessPackage = 0 AND @includeFederalPackage = 0
		RETURN
		

	
	-- Retrieve the Sales Executive and Billing Address from the Customer Record.
	SELECT  @SEInitials = l.initials, @SEEmail = memberemail, 
			@OwnerFirstName = c.fname, @OwnerLastName = c.lname, @OwnerCompany = c.company,
			@OwnerAddress = c.addr1, @OwnerCity = c.city, @OwnerState = c.state, @OwnerZip = c.zip
	FROM	dbCrosslinkGlobal..ltblSalesTeamMembers stm
	INNER JOIN dbCrosslinkGlobal..logins l on l.initials = stm.initials
	INNER JOIN dbCrosslinkGlobal..vwLeadExecutive ls on ls.LeadExec = stm.initials
	INNER JOIN dbCrosslinkGlobal..customer c on c.idx = ls.LeadIndex
	WHERE	c.account = @Account

	-- Retrieve the Ship To Address from the User record.
	SELECT	@ShipToPhone = phone, @ShipToFirstName = fname, @ShipToLastName = lname,
			@ShipToCompany = company, @ShipToAddress = addr1, @ShipToCity = city,
			@ShipToState = state, @ShipToZip = zip, @ShipToFax = fax
	FROM	dbCrosslinkGlobal..tblUser
	WHERE	user_id = @UserID


	-- Insert the XLS Order
	INSERT INTO dbCrosslinkGlobal.dbo.Orders (ord_stat, account, user_id, season, sales_exec, orig_by, orig_dt, edit_by, edit_dt, 
		exec_email, do_not_ship, b_fname, b_lname, b_company, b_addr1, b_city, b_state, b_zip, 
		s_phone, s_fname, s_lname, s_company, s_addr1, s_city, s_state, s_zip, s_fax, note1, ord_tot, bal_due)
	VALUES	('A', @Account, @UserId, @Season, @SEInitials, 'webportal', getdate(), 'webportal', getdate(),
			 @SEEmail, 'X', @OwnerFirstName, @OwnerLastName, @OwnerCompany, @OwnerAddress, @OwnerCity, 
			 @OwnerState, @OwnerZip, @ShipToPhone, @ShipToFirstName, @ShipToLastName, @ShipToCompany, @ShipToAddress, 
			 @ShipToCity, @ShipToState, @ShipToZip, @ShipToFax, 'DO NOT SHIP - SB CLIENT', 0, 0)

	-- Need to get the Order Number.
	SELECT @OrdNum = SCOPE_IDENTITY()

	IF (@includeFederalPackage = 1)
	BEGIN
		INSERT INTO dbCrosslinkGlobal.dbo.ord_items (ord_num, prod_cd, qty, uprice, bank_id, ship_via, bank_stat)
		VALUES (@OrdNum , 'USTP', 1, 0, 'U', 'BLUE', '')
	END

	IF (@includeBusinessPackage = 1)
	BEGIN
		INSERT INTO dbCrosslinkGlobal.dbo.ord_items (ord_num, prod_cd, qty, uprice, bank_id, ship_via, bank_stat)
		VALUES (@OrdNum , 'BUS', 1, 0, 'U', 'BLUE', '')
	END

	exec dbCrosslinkGlobal..up_processOrder @OrdNum, @Season, 1, @Account, null
	
	-- Need to send out the Order Email - if not on excluded servers or overridden.
	if ((@@SERVERNAME not like 'DEVDB%' and @@SERVERNAME not like 'QADB%') or @overrideMailSuppress = 1)
		begin
			SELECT @Message = @Message +
				 '<li>CrossLink Software Order (Order Number: ' + convert(varchar(15), @OrdNum) + ') has been created.</li>'

			EXEC spSendMessage 'O', @Account, @UserId, @Message
		end

END
