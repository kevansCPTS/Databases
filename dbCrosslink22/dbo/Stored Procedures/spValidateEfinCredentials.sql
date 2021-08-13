-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spValidateEfinCredentials]
	-- Add the parameters for the stored procedure here
	@efin int,
	@password varchar(max),
	@value bit = 0 OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    IF Exists(SELECT e.efin, u.passwd FROM efin e LEFT JOIN dbcrosslinkglobal.dbo.tblUser u ON e.userid = u.user_id
    WHERE e.efin = @efin AND u.passwd = @password)
	BEGIN
		SET @value = 1
	END
END


