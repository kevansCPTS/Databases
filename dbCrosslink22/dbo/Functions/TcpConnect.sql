-- =============================================
-- Author:		Josh Daniel
-- Create date: 8/20/2010
-- Description:	This function will be a wrapper for the 
--				TCPConnect com object
-- =============================================
CREATE FUNCTION [dbo].[TcpConnect] 
(
	-- Add the parameters for the function here
	@host varchar(25),
	@port varchar(20),
	@msg varchar(256)
	
)
RETURNS int
AS
BEGIN

	DECLARE @objJET AS INTEGER,
	@status AS INT,
	@Source AS VARCHAR(1000),
	@Description AS VARCHAR(1000),
	@retVal VARCHAR(8000)

	EXEC @status = sp_OACreate 'TcpConnect.ConnectionManager', @objJET OUT

	IF @status <> 0
    begin
	exec  sp_OAGetErrorInfo @objJET,@Source OUT,@Description OUT
	SELECT  @retVal = 'Instantiate Error: ' + @Source  + '  ' +  @description 
	EXEC sp_OADestroy @objJET
	return -1
    end
	
	DECLARE @retSql as VARCHAR(8000)
	EXEC @status = sp_OAMethod @objJET, 'connect', NULL,@host, @port
	

	
	IF @status <> 0
    begin
	exec  sp_OAGetErrorInfo @objJET,@Source OUT,@Description OUT
	SELECT @retVal = 'Method Call Error: ' +  @Source  + '  ' +  @description 
	EXEC sp_OADestroy @objJET
	return -2
    end
	
	set @msg = @msg + char(13) + char(10)
	
	EXEC @status = sp_OAMethod @objJET, 'send',NULL, @msg
	
	
	
	
	IF @status <> 0
    begin
	exec  sp_OAGetErrorInfo @objJET,@Source OUT,@Description OUT
	SELECT @retVal = 'Method Call Error: ' +  @Source  + '  ' +  @description 
	EXEC sp_OADestroy @objJET
	return -3
    end
    
    
    EXEC @status = sp_OAMethod @objJET, 'disconnect',NULL
	

	
	IF @status <> 0
    begin
	exec  sp_OAGetErrorInfo @objJET,@Source OUT,@Description OUT
	SELECT @retVal = 'Method Call Error: ' +  @Source  + '  ' +  @description 
	EXEC sp_OADestroy @objJET
	return -4
    end
	

	
	-- Return the result of the function
	RETURN 0

END


