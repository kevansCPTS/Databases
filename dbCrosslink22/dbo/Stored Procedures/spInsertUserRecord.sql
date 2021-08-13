
-- ===============================================================
-- Author:		Chuck Robertson
-- Create date: 091/17/2010
-- Description:	This stored procedure is used to insert a record
--				into the table tblUser.
--  Update: Added optional parameters for company name and shipping address 8/7/2012 CK
-- ===============================================================
CREATE PROCEDURE [dbo].[spInsertUserRecord]
	@Account		varchar(8),
	@OwnerPhone		varchar(10),
	@OwnerFName		varchar(14),
	@OwnerLName		varchar(20),
	@Email			varchar(50),
	@CompanyName		varchar(50) = null, 
	@ShippingAddress varchar(34) = null,
	@ShippingCity	varchar(20) = null,
	@ShippingState varchar(2) = null,
	@ShippingZip varchar(10) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @UserID int

	--SELECT @UserID = max(user_id) + 1 from dbCrossLinkGlobal..tbluser where user_id < 500000

    -- @uType: 1 = Standard User, 2 = Cloud User, 3 = MSO User
    exec dbCrosslinkGlobal.dbo.up_getNewUserId @uType = 1, @newId = @UserID output

	INSERT INTO dbCrossLinkGlobal..tblUser 
		(user_id, account, hold_flag, status, phone, fname, lname, edit_by, edit_dt, email, 
		company, addr1, city, state, zip)
	VALUES (@UserID, @Account, 'N', '-', @OwnerPhone, @OwnerFName, @OwnerLName, 'portal', getdate(), @Email, 
	@CompanyName, @ShippingAddress, @ShippingCity, @ShippingState, @ShippingZip)

	SELECT @UserID as userid
END



