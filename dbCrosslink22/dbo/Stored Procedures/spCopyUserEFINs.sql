-- =============================================
-- Author:		Jay Willis
-- Create date: 10/22/2010
-- Description:	Copy User Logins
--		09/21/2016		Updated by Jay Willis
--				Removed Special Bank
-- =============================================
CREATE PROCEDURE [dbo].[spCopyUserEFINs]
	-- Add the parameters for the stored procedure here
	@user_id varchar(8),
	@efin varchar(8),
	@efin_id int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		IF NOT EXISTS (SELECT * FROM tblxlinkEfinDatabase WHERE user_id = @user_id and efin = @efin)
			BEGIN
				INSERT INTO tblxlinkEfinDatabase SELECT getdate(), getdate(), NULL, account_id, @user_id, bank, efin, 
				company_name, self_employed, ssn, ein, address, city, state, zip, office_phone, first_dcn, state_code_1,
				state_id_1, state_code_2, state_id_2, sbin, special_bank_app_loc, default_pin, transmitter_fee, sb_fee, sb_name, sb_fee_all, 
				franchiseuser_id, cell_phone, cell_phone_carrier
				FROM tblxlinkEfinDatabase where efin_id = @efin_id
			END
END









