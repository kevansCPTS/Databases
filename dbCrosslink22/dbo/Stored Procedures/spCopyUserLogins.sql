-- =============================================
-- Author:		Jay Willis
-- Create date: 9/28/2010
-- Description:	Copy User Logins
-- =============================================
CREATE PROCEDURE [dbo].[spCopyUserLogins]
	-- Add the parameters for the stored procedure here
	@user_id varchar(8),
	@login_id varchar(8),
	@userlogin_id int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		IF NOT EXISTS (SELECT * FROM tblxlinkuserlogins WHERE user_id = @user_id and login_id = @login_id)
			BEGIN
				INSERT INTO tblxlinkuserlogins SELECT getdate(), getdate(), NULL, account_id, @user_id, login_id, 
				login_name, login_password, change_password, hide_work_in_progress, access_level, shortcut_id, bank_id_code, RBIN, 
				franchiseuser_id, display_short_form, training_returns_only, show_fees_in_transmit, 0, email, cell_phone
				FROM tblxlinkuserlogins where userlogin_id = @userlogin_id
			END
END


