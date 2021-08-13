CREATE TABLE [dbo].[tblXlinkAccounts] (
    [accounts_id]    INT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [master_user_id] INT         NULL,
    [account_id]     VARCHAR (8) NULL,
    [processed]      BIT         CONSTRAINT [DF_tblXlinkAccounts_processed] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblXlinkAccounts] PRIMARY KEY CLUSTERED ([accounts_id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ID1_tblXlinkAccounts]
    ON [dbo].[tblXlinkAccounts]([account_id] ASC);


GO
-- =============================================
-- Author:		Charles Krebs & Tim Gong
-- Create date: 12/29/2010
-- Description:	Keep the Customer up to date on the Master User ID field
-- =============================================
CREATE TRIGGER [dbo].[tgrXLinkAccountMasterUserID] 
   ON  [dbo].[tblXlinkAccounts] 
   AFTER INSERT,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF Update(master_user_id) 
	BEGIN
		DECLARE @master_user_ID varchar(8)
		DECLARE @account_ID varchar (8)
		
		SELECT @master_user_ID = master_user_ID, 
			@account_ID = account_ID
		FROM inserted

		IF (IsNumeric(@master_user_ID) = 1) 
		BEGIN
			UPDATE customer 
			SET Master_User_ID = @master_user_ID 
			WHERE Account = @account_ID
				AND IsNull(Master_USER_ID, -1) != IsNull(@master_user_ID, -1)
		END
	END
    -- Insert statements for trigger here

END



