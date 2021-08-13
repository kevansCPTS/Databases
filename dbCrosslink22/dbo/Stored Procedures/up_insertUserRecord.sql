-- ===============================================================
-- Author:		Chuck Robertson
-- Create date: 11/28/2018
-- Description:	This stored procedure is used to insert a record
--				into the table tblUser.
--  Update: Added optional parameters for company name and shipping address 8/7/2012 CK
-- ===============================================================
CREATE PROCEDURE [dbo].[up_insertUserRecord]
	@Account		 varchar(8),
	@OwnerPhone		 varchar(10),
	@OwnerFName		 varchar(14),
	@OwnerLName		 varchar(20),
	@Email			 varchar(50),
	@CompanyName	 varchar(50) = null, 
	@ShippingAddress varchar(34) = null,
	@ShippingCity	 varchar(20) = null,
	@ShippingState	 varchar(2)  = null,
	@ShippingZip	 varchar(10) = null,
	@ProdType		 int		 = null,
	@Source			 varchar(20) = null
AS
BEGIN
	DECLARE @userID int
	DECLARE @userType int

	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;

/*
	-- 1 = DESKTOP 
	IF (@ProdType = 1)
	BEGIN
		SELECT @UserID = max(user_id) + 1 from dbCrossLinkGlobal..tbluser where user_id < 500000
		SET @userType = 1
	END
	-- 2 = ONLINE
	ELSE
	BEGIN
		SET @userType = 4
		exec dbcrosslinkglobal.dbo.up_getNewUserId @uType = 2, @newId = @UserID output
	END
*/
    if isnull(@ProdType, 4) = 4
        set @ProdType = 2

    set @userType = case @ProdType
                        when 1 then 1
                        else 4
                    end

	exec dbcrosslinkglobal.dbo.up_getNewUserId @uType = @ProdType, @newId = @UserID output

	INSERT INTO dbCrossLinkGlobal..tblUser (user_id, account, hold_flag, status, phone, fname, lname, edit_by, edit_dt, email, company, addr1, city, state, zip, uType)
	VALUES (@UserID, @Account, 'N', '-', @OwnerPhone, @OwnerFName, @OwnerLName, @Source, getdate(), @Email, @CompanyName, @ShippingAddress, @ShippingCity, @ShippingState, @ShippingZip, @userType)

	SELECT @UserID as userid
END
