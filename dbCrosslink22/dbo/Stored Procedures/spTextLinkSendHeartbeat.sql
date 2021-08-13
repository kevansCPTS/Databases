
-- =============================================
-- Author:		Steve Trautman
-- Create date: 07/25/2016
-- Description: Set a heartbeat timestamp from the textlink windows service so we know it's running
-- =============================================
CREATE PROCEDURE [dbo].[spTextLinkSendHeartbeat]
	@server_app_config_key varchar(250) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	UPDATE dbo.tblServerAppConfiguration
	SET value = SYSUTCDATETIME()
	WHERE pk_key = @server_app_config_key;

END

