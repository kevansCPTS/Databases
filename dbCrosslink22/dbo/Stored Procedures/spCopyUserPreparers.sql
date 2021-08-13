-- =============================================
-- Author:		Jay Willis
-- Create date: 10/22/2010
-- Description:	Copy User Logins
-- =============================================
CREATE PROCEDURE [dbo].[spCopyUserPreparers]
	-- Add the parameters for the stored procedure here
	@user_id varchar(8),
	@shortcut_id varchar(7),
	@preparer_id int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		IF NOT EXISTS (SELECT * FROM tblXlinkPreparerDatabase WHERE user_id = @user_id and shortcut_id = @shortcut_id)
			BEGIN
				INSERT INTO tblxlinkPreparerDatabase SELECT getdate(), getdate(), NULL, account_id, @user_id, shortcut_id, 
				preparer_name, self_employed, firm_name, ein, address, city, state, zip, office_phone, efin, 
				state_code_1, state_id_1, state_code_2, state_id_2, ptin, ssn, third_party_pin, email, 
				preparer_type, cell_phone, cell_phone_carrier, franchiseuser_id
				FROM tblxlinkPreparerDatabase where preparer_id = @preparer_id
			END
END


