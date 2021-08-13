-- =============================================
-- Author:		Michael Langston
-- Create date: 2017-03-01
-- Description:	Alert via SMS if a signature service error is detected
-- =============================================
CREATE PROCEDURE [dbo].[spSigServiceMonitor]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @system_errors int = 0

	select @system_errors = count(*) from dbcrosslink17.dbo.tblSignatureAuditLog
	where created_dttm > DATEADD(HOUR,-1,GETDATE()) 
		and remotesig_error_code = 4

	if @system_errors > 0
	begin
		declare @errMsg varchar(50) = cast(@system_errors as varchar(10)) + ' system errors in prod over the last hour'
		exec msdb.dbo.sp_send_dbmail
			@recipients = '9515323791@vtext.com', 
			@subject = 'Error',
			@body = @errMsg
	end	
END
