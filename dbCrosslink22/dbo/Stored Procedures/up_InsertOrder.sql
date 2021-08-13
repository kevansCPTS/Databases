-- ==========================================================
-- Author:		Chuck Robertson
-- Create date: 11/29/2018
-- Description:	Generate Online Order records.
-- @userLevelOrder
--		0 - only need an Office license (XLCA)
--		1 - need to add User level license (XLCO)
-- ==========================================================
CREATE PROCEDURE [dbo].[up_InsertOrder]
	@Account	varchar(8),
	@UserId		int,
	@overrideMailSuppress	bit = 0,
	@includeBusinessPackage bit = 0,
	@userLevelOrder bit = 0,
	@source varchar(15)
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE	@SEInitials varchar(20), @SEEmail varchar(50), @OrdNum int, @Season int
	DECLARE @OwnerFirstName varchar(14), @OwnerLastName varchar(20), @OwnerCompany varchar(50)
	DECLARE @OwnerAddress varchar(34), @OwnerCity varchar(20), @OwnerState varchar(2), @OwnerZip varchar(10)
	DECLARE @ShipToFirstName varchar(14), @ShipToLastName varchar(20), @ShipToCompany varchar(50)
	DECLARE @ShipToAddress varchar(34), @ShipToCity varchar(20), @ShipToState varchar(2)
	DECLARE @ShipToZip varchar(10), @ShipToPhone varchar(10), @ShipToFax varchar(10)
	DECLARE @Message varchar(250)

	SET @Message = ''
	
	-- If this isn't an Online user, then get out.
	IF @UserId < 500000 OR @UserID > 900000
		RETURN

	SET @Season = dbo.getXlinkSeason()
	
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

	-- Insert the Order
	INSERT INTO dbCrosslinkGlobal.dbo.Orders (ord_stat, account, user_id, season, sales_exec, orig_by, orig_dt, edit_by, edit_dt, 
		exec_email, do_not_ship, b_fname, b_lname, b_company, b_addr1, b_city, b_state, b_zip, 
		s_phone, s_fname, s_lname, s_company, s_addr1, s_city, s_state, s_zip, s_fax, note1, note2, ord_tot, bal_due)
	VALUES	('A', @Account, @UserId, @Season, @SEInitials, @source, getdate(), @source, getdate(),
			 @SEEmail, 'X', @OwnerFirstName, @OwnerLastName, @OwnerCompany, @OwnerAddress, @OwnerCity, 
			 @OwnerState, @OwnerZip, @ShipToPhone, @ShipToFirstName, @ShipToLastName, @ShipToCompany, @ShipToAddress, 
			 @ShipToCity, @ShipToState, @ShipToZip, @ShipToFax, 'DO NOT SHIP - SB CLIENT', 'Order created with UserId ' + convert(char(8), @UserId), 0, 0)

	-- Need to get the Order Number.
	SELECT @OrdNum = SCOPE_IDENTITY()

	-- Insert the office level order (XLCA)
	INSERT INTO dbCrosslinkGlobal.dbo.ord_items (ord_num, prod_cd, qty, uprice, bank_id, ship_via, bank_stat)
	VALUES (@OrdNum , 'XLCA', 1, 0, 'U', 'BLUE', '')

	-- Do we need the User Level added (XLCO)
	IF (@userLevelOrder = 1)
	BEGIN
		INSERT INTO dbCrosslinkGlobal.dbo.ord_items (ord_num, prod_cd, qty, uprice, bank_id, ship_via, bank_stat)
		VALUES (@OrdNum , 'XLCO', 1, 0, 'U', 'BLUE', '')
	END

	/*
	-- THIS IS BEING LEFT IN HERE FOR EXPANSION NEXT YEAR. NOT SURE WHAT IT MEANS YET.
	IF (@includeBusinessPackage = 1)
	BEGIN
		INSERT INTO dbCrosslinkGlobal.dbo.ord_items (ord_num, prod_cd, qty, uprice, bank_id, ship_via, bank_stat)
		VALUES (@OrdNum , 'BUS', 1, 0, 'U', 'BLUE', '')
	END
	*/
	
	-- Commenting this out for right now, until Ken can fix it.
	exec dbCrosslinkGlobal..up_processOrder @OrdNum, @Season, 1, @Account, 'XLCO', null

	/*
	-- Need to send out the Order Email - if not on excluded servers or overridden.
	-- LEAVING THIS IN HERE FOR NOW, BUT MAY NEED TO SEND OUT EMAILS LATER.
	if ((@@SERVERNAME not like 'DEVDB%' and @@SERVERNAME not like 'QADB%') or @overrideMailSuppress = 1)
		begin
			SELECT @Message = @Message +
				 '<li>CrossLink Software Order (Order Number: ' + convert(varchar(15), @OrdNum) + ') has been created.</li>'

			EXEC spSendMessage 'O', @Account, @UserId, @Message
	end
	*/
END
