-- =============================================
-- Author:		Michael Langston
-- Create date: 01/10/2017
-- Description:	Inserts new OAuth scope and optional parent mapping
-- =============================================
CREATE PROCEDURE dbo.spRegisterOAuthScope
	@scope_name varchar(50), 
	@scope_parent varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if not exists(select 1 from tblOAuthScope where scope_name = @scope_name)
	begin
		INSERT INTO [dbo].[tblOAuthScope]
				   ([scope_name]
				   ,[scope_parent]
				   ,[created_dttm]
				   ,[updated_dttm])
			 VALUES
				   (@scope_name
				   ,@scope_parent
				   ,GETDATE()
				   ,GETDATE())
	end
END
