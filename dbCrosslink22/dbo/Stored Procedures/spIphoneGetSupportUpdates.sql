create PROCEDURE [dbo].[spIphoneGetSupportUpdates] 
	@UpdateID varchar(10)
AS

Declare @SQL varchar(max)
SELECT @SQL = 'SELECT type, issue, date, iphone FROM tblSupportUpdates WHERE update_id = ' + @UpdateID
exec (@sql)


