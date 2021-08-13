-- ===============================================================================
-- Author:		Jay Willis
-- Create date: 1/16/2011
-- ===============================================================================
create PROCEDURE [dbo].[spAddBankInfo] 
	-- Add the parameters for the stored procedure here
	@efin_id int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE 
		@user_id int,
		@padded_user_id varchar(6),
		@efin char(6)

	-- get user_id
	SELECT @user_id = user_id, @efin = efin FROM tblXlinkEfinDatabase WHERE efin_id = @efin_id

	SELECT @padded_user_id = dbo.PadString(@user_id,'0',6)

    EXEC spInsertAdminMessage2 @efin , 'E', @padded_user_id, 'web-portal'

END


