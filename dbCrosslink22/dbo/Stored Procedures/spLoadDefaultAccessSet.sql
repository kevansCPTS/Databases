-- =============================================
-- Author:		Jay Willis
-- Create date: 10/24/2009
-- Description:	Load Default Access Set
-- =============================================
CREATE PROCEDURE [dbo].[spLoadDefaultAccessSet] 
	-- Add the parameters for the stored procedure here
	@account varchar (8)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    Declare @Identity1 int
    Declare @Identity2 int

    -- Insert statements for procedure here
	INSERT INTO tblXlinkAccessSets (set_name, account_id) VALUES ('DEFAULT',@account)
	SET @Identity1 = SCOPE_IDENTITY() 
	INSERT INTO tblXlinkAccessLevels (level_name,account_id, set_id) VALUES ('ADMINISTRATOR', @account, @Identity1)
	SET @Identity2 = SCOPE_IDENTITY()
	INSERT INTO tblXlinkAccessDetail (account_id, detail, level_id) VALUES (@account, '01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,', @Identity2)
	INSERT INTO tblXlinkAccessLevels (level_name,account_id, set_id) VALUES ('DATA_ENTRY', @account, @Identity1)
	SET @Identity2 = SCOPE_IDENTITY()
	INSERT INTO tblXlinkAccessDetail (account_id, detail, level_id) VALUES (@account, '06,07,11,', @Identity2)
	INSERT INTO tblXlinkAccessLevels (level_name,account_id, set_id) VALUES ('OPERATOR', @account, @Identity1)
	SET @Identity2 = SCOPE_IDENTITY() 
	INSERT INTO tblXlinkAccessDetail (account_id, detail, level_id) Values (@account, '01,04,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,22,24,25,', @Identity2)
END


