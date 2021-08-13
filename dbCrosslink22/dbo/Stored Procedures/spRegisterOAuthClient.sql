-- =============================================
-- Author:		Michael Langston
-- Create date: 01/10/2017
-- Description:	Inserts new OAuth clients
-- =============================================
CREATE PROCEDURE dbo.spRegisterOAuthClient
	@redirect_uri varchar(max), 
	@allowed_scopes varchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if not exists(select 1 from tblOAuthClients where redirect_uri = @redirect_uri)
	begin
		INSERT INTO [dbo].[tblOAuthClients]
			   ([redirect_uri]
			   ,[grant_code]
			   ,[access_code]
			   ,[refresh_code]
			   ,[allowed_scopes]
			   ,[grant_expires_at]
			   ,[access_expires_at])
		 VALUES
			   (@redirect_uri
			   ,null
			   ,null
			   ,null
			   ,@allowed_scopes
			   ,null
			   ,null)
	end
END
