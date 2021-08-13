create PROCEDURE [dbo].[spIphoneGetIrsIDs] 
	
AS

Declare @SQL varchar(max)
SELECT @SQL = 'SELECT update_id, issue FROM tblIrsUpdates WHERE getdate() > start_date AND active = 1 ORDER BY start_date DESC, create_date DESC'
exec (@SQL)


